# CJ Toner Express — Sample Database

A small PostgreSQL schema that models the day-to-day operations of a
toner & ink cartridge retail shop: products, printer-compatibility,
clients, orders, and a full inventory audit trail. Built as a
portfolio sample to illustrate the resume project below.

> **About this sample.** All clients, suppliers, prices, and order numbers
> here are **fictional**. The schema is a **fresh design**, not the actual
> production schema used at CJ Toner Express. It's meant to show how a
> database like this is structured, not to leak anything real.

## The resume bullet this sample illustrates

> **CJ Toner — Web Developer & Database Engineer** (San Juan, PR, Summers 2021–2024)
>
> Replaced a manual pen-and-paper workflow with a PostgreSQL inventory,
> product, and client-management system, cutting daily admin time from
> 5–6 hours to 1–2 and still in production use 2+ years later.

The shop sells toner and ink cartridges to individual walk-in customers
and to small-business accounts (law firms, doctors' offices, schools,
print shops). Before the database, daily admin meant counting boxes in
the back, hand-writing receipts, and flipping through a compatibility
binder when a customer brought in a printer. This sample models the
same workflow with a small relational schema and a handful of queries
that replace each of those tasks.

## Schema at a glance

```mermaid
erDiagram
    BRANDS ||--o{ PRINTER_MODELS : "makes"
    BRANDS ||--o{ CARTRIDGES : "makes"
    CARTRIDGES ||--o{ CARTRIDGE_COMPATIBILITY : ""
    PRINTER_MODELS ||--o{ CARTRIDGE_COMPATIBILITY : ""
    SUPPLIERS ||--o{ CARTRIDGES : "preferred for"
    CLIENTS ||--o{ ORDERS : "places"
    ORDERS ||--o{ ORDER_ITEMS : "contains"
    CARTRIDGES ||--o{ ORDER_ITEMS : "sold as"
    CARTRIDGES ||--o{ INVENTORY_MOVEMENTS : "stock for"
    ORDERS ||--o{ INVENTORY_MOVEMENTS : "ships from"
    SUPPLIERS ||--o{ INVENTORY_MOVEMENTS : "supplies"

    BRANDS {
        int brand_id PK
        text name
    }
    PRINTER_MODELS {
        int printer_model_id PK
        int brand_id FK
        text model_name
    }
    CARTRIDGES {
        int cartridge_id PK
        text sku
        int brand_id FK
        text name
        enum type
        enum color
        int page_yield
        numeric unit_cost
        numeric unit_price
        int reorder_threshold
        int preferred_supplier_id FK
        bool active
    }
    CARTRIDGE_COMPATIBILITY {
        int cartridge_id PK_FK
        int printer_model_id PK_FK
    }
    SUPPLIERS {
        int supplier_id PK
        text name
        text contact_name
        text phone
        text email
    }
    CLIENTS {
        int client_id PK
        enum type
        text name
        text contact_name
        text email
        text phone
        text address
    }
    ORDERS {
        int order_id PK
        int client_id FK
        date order_date
        enum status
        enum payment_method
    }
    ORDER_ITEMS {
        int order_item_id PK
        int order_id FK
        int cartridge_id FK
        int quantity
        numeric unit_price
    }
    INVENTORY_MOVEMENTS {
        int movement_id PK
        int cartridge_id FK
        enum movement_type
        int quantity_change
        timestamptz occurred_at
        int related_order_id FK
        int related_supplier_id FK
    }
```

### Design notes

- **Inventory is an append-only audit trail, not a single `current_stock`
  column.** Every receipt, sale, return, and adjustment is its own row in
  `inventory_movements`. Current stock is `SUM(quantity_change)` per
  cartridge, exposed through the `v_stock_on_hand` view. This makes
  month-end recounts and discrepancy investigations straightforward —
  you can always see *why* the number is what it is.
- **Order-line prices are captured at sale time** (`order_items.unit_price`)
  so historical totals don't shift if the catalog price changes later.
- **Many-to-many compatibility** between cartridges and printer models —
  a cartridge usually fits several printers, and a printer usually takes
  several cartridges (standard- and high-yield, color set, etc.).
- **`client_type`, `cartridge_type`, `cartridge_color`, `order_status`,
  `payment_method`, `movement_type`** are PostgreSQL `ENUM`s so bad
  values are rejected at the database layer.
- **Two convenience views** (`v_stock_on_hand`, `v_order_totals`) keep
  the day-to-day queries short and readable.

## Getting it running

You need PostgreSQL 12 or newer locally. On macOS:

```bash
brew install postgresql@16
brew services start postgresql@16
```

Then create the database and load the schema and seed data:

```bash
createdb cj_toner_express
psql -d cj_toner_express -f schema.sql
psql -d cj_toner_express -f seed.sql
```

Run the example queries:

```bash
psql -d cj_toner_express -f queries.sql
```

To start from a clean slate later:

```bash
dropdb cj_toner_express
```

## The queries that replaced pen-and-paper admin

Each query in [`queries.sql`](queries.sql) maps to a daily task that used
to take real time:

| #  | Query                                | Replaces                                          |
|----|--------------------------------------|---------------------------------------------------|
| 1  | Low-stock report                     | Walking to the back room and counting boxes       |
| 2  | "What cartridge fits this printer?"  | Thumbing through a compatibility binder           |
| 3  | Top clients by revenue (YTD)         | Flipping through a paper ledger at month end      |
| 4  | Monthly sales summary                | Tallying receipts at month end                    |
| 5  | Recent orders for a recurring client | Digging through a binder when a regular calls     |
| 6  | Reorder list grouped by supplier     | Manually figuring out who to call for what        |
| 7  | Outstanding quotes                   | A sticky note on the monitor                      |
| 8  | Inventory audit trail per cartridge  | Explaining a stock discrepancy after the fact     |

The compounding effect of these is the "5–6 hours to 1–2 hours" on the
resume: a clerk can answer a customer at the counter in seconds instead
of minutes, and end-of-day reconciliation drops from an hour of paper
sorting to a single query.

## Repo layout

```
cj-toner-express-db/
├── README.md      this file
├── schema.sql     table definitions, enums, indexes, views
├── seed.sql       fictional sample data to make the queries return something
└── queries.sql    the daily-admin queries above
```

## Honest framing

- The schema is a **fresh design** for this kind of business, not a copy of
  the real production schema. The real one belongs to the shop.
- All client names, supplier names, contact info, prices, and SKUs are
  **fictional**. The PR-flavored names are for realism only.
- This is a portfolio sample — it intentionally leaves out things a real
  production system would need (auth, soft deletes, multi-currency,
  taxes, a UI). The point is to show how the *core* data model fits the
  business.
