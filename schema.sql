-- CJ Toner Express — sample PostgreSQL schema
-- Small toner & ink cartridge retail shop in San Juan, PR.
-- Tracks products (cartridges), printer compatibility, clients, orders,
-- and a full inventory movement audit trail.
--
-- All names and data are fictional. This is a portfolio sample, not a
-- copy of any real production system.

-- ============================================================
-- Enumerated types
-- ============================================================

CREATE TYPE client_type     AS ENUM ('individual', 'business');
CREATE TYPE cartridge_type  AS ENUM ('toner', 'ink');
CREATE TYPE cartridge_color AS ENUM ('black', 'cyan', 'magenta', 'yellow', 'tricolor');
CREATE TYPE order_status    AS ENUM ('quote', 'paid', 'delivered', 'cancelled');
CREATE TYPE payment_method  AS ENUM ('cash', 'card', 'transfer', 'account');

-- received:   stock arrived from a supplier
-- sold:       stock left as part of a customer order
-- return:     customer returned product; stock came back in
-- adjustment: manual correction (recount discrepancy, damaged stock, etc.)
CREATE TYPE movement_type   AS ENUM ('received', 'sold', 'return', 'adjustment');


-- ============================================================
-- Reference tables
-- ============================================================

CREATE TABLE brands (
    brand_id  SERIAL PRIMARY KEY,
    name      TEXT NOT NULL UNIQUE
);

CREATE TABLE printer_models (
    printer_model_id  SERIAL PRIMARY KEY,
    brand_id          INTEGER NOT NULL REFERENCES brands(brand_id) ON DELETE RESTRICT,
    model_name        TEXT NOT NULL,
    UNIQUE (brand_id, model_name)
);

CREATE TABLE suppliers (
    supplier_id   SERIAL PRIMARY KEY,
    name          TEXT NOT NULL UNIQUE,
    contact_name  TEXT,
    phone         TEXT,
    email         TEXT,
    notes         TEXT
);


-- ============================================================
-- Catalog
-- ============================================================

CREATE TABLE cartridges (
    cartridge_id           SERIAL PRIMARY KEY,
    sku                    TEXT NOT NULL UNIQUE,
    brand_id               INTEGER NOT NULL REFERENCES brands(brand_id) ON DELETE RESTRICT,
    name                   TEXT NOT NULL,
    type                   cartridge_type NOT NULL,
    color                  cartridge_color NOT NULL,
    page_yield             INTEGER CHECK (page_yield IS NULL OR page_yield > 0),
    unit_cost              NUMERIC(10, 2) NOT NULL CHECK (unit_cost >= 0),
    unit_price             NUMERIC(10, 2) NOT NULL CHECK (unit_price >= 0),
    reorder_threshold      INTEGER NOT NULL DEFAULT 5 CHECK (reorder_threshold >= 0),
    preferred_supplier_id  INTEGER REFERENCES suppliers(supplier_id) ON DELETE SET NULL,
    active                 BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE INDEX idx_cartridges_brand ON cartridges(brand_id);

-- Many-to-many: each cartridge fits several printer models, and a printer
-- model can usually take several cartridges (e.g. a high-yield variant).
CREATE TABLE cartridge_compatibility (
    cartridge_id      INTEGER NOT NULL REFERENCES cartridges(cartridge_id) ON DELETE CASCADE,
    printer_model_id  INTEGER NOT NULL REFERENCES printer_models(printer_model_id) ON DELETE CASCADE,
    PRIMARY KEY (cartridge_id, printer_model_id)
);


-- ============================================================
-- Clients
-- ============================================================

CREATE TABLE clients (
    client_id     SERIAL PRIMARY KEY,
    type          client_type NOT NULL,
    -- Individual: person's name. Business: legal/DBA name.
    name          TEXT NOT NULL,
    -- For business accounts: the person we usually talk to.
    contact_name  TEXT,
    email         TEXT,
    phone         TEXT,
    address       TEXT,
    notes         TEXT,
    created_at    TIMESTAMPS NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_clients_name ON clients(name);


-- ============================================================
-- Orders
-- ============================================================

CREATE TABLE orders (
    order_id        SERIAL PRIMARY KEY,
    client_id       INTEGER NOT NULL REFERENCES clients(client_id) ON DELETE RESTRICT,
    order_date      DATE NOT NULL DEFAULT CURRENT_DATE,
    status          order_status NOT NULL DEFAULT 'quote',
    payment_method  payment_method,
    notes           TEXT,
    created_at      TIMESTAMPS NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_orders_client ON orders(client_id);
CREATE INDEX idx_orders_date   ON orders(order_date);

CREATE TABLE order_items (
    order_item_id  SERIAL PRIMARY KEY,
    order_id       INTEGER NOT NULL REFERENCES orders(order_id) ON DELETE CASCADE,
    cartridge_id   INTEGER NOT NULL REFERENCES cartridges(cartridge_id) ON DELETE RESTRICT,
    quantity       INTEGER NOT NULL CHECK (quantity > 0),
    -- Captured at sale time so historical totals don't change if the
    -- catalog price is updated later.
    unit_price     NUMERIC(10, 2) NOT NULL CHECK (unit_price >= 0)
);

CREATE INDEX idx_order_items_order     ON order_items(order_id);
CREATE INDEX idx_order_items_cartridge ON order_items(cartridge_id);


-- ============================================================
-- Inventory
-- ============================================================

-- Every stock change lands here. Current on-hand = SUM(quantity_change)
-- per cartridge. Keeping a full audit trail (instead of a single
-- "current_stock" column) makes month-end recounts, discrepancy
-- investigations, and returns easy to reason about.
CREATE TABLE inventory_movements (
    movement_id          SERIAL PRIMARY KEY,
    cartridge_id         INTEGER NOT NULL REFERENCES cartridges(cartridge_id) ON DELETE RESTRICT,
    movement_type        movement_type NOT NULL,
    -- Positive for received / return / positive adjustment,
    -- negative for sold / negative adjustment.
    quantity_change      INTEGER NOT NULL CHECK (quantity_change <> 0),
    occurred_at          TIMESTAMPS NOT NULL DEFAULT NOW(),
    related_order_id     INTEGER REFERENCES orders(order_id)       ON DELETE SET NULL,
    related_supplier_id  INTEGER REFERENCES suppliers(supplier_id) ON DELETE SET NULL,
    notes                TEXT
);

CREATE INDEX idx_movements_cartridge ON inventory_movements(cartridge_id);


-- ============================================================
-- Views — convenience for the daily-admin queries
-- ============================================================

-- Current stock on hand per cartridge.
CREATE VIEW v_stock_on_hand AS
SELECT
    c.cartridge_id,
    c.sku,
    c.name,
    c.reorder_threshold,
    COALESCE(SUM(m.quantity_change), 0)::INTEGER AS on_hand
FROM cartridges c
LEFT JOIN inventory_movements m USING (cartridge_id)
GROUP BY c.cartridge_id, c.sku, c.name, c.reorder_threshold;

-- Per-order total (sum of line items).
CREATE VIEW v_order_totals AS
SELECT
    o.order_id,
    o.client_id,
    o.order_date,
    o.status,
    COALESCE(SUM(oi.quantity * oi.unit_price), 0)::NUMERIC(12, 2) AS total
FROM orders o
LEFT JOIN order_items oi USING (order_id)
GROUP BY o.order_id, o.client_id, o.order_date, o.status;
