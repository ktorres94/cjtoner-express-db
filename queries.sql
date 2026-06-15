-- CJ Toner Express — sample operational queries
--
-- These are the lookups that replace pen-and-paper admin: stock to reorder,
-- which cartridge fits a customer's printer, who the top clients are,
-- this month's sales, recent orders for a recurring client, etc.
-- Each query is wrapped in a header so you can copy/paste one at a time.


-- ============================================================
-- 1. Low-stock report
--    Replaces: walking to the back room and counting boxes.
--    Returns every cartridge whose on-hand stock has dropped to or below
--    its reorder threshold, with the supplier to call.
-- ============================================================

SELECT
    s.on_hand,
    s.reorder_threshold,
    s.sku,
    s.name              AS cartridge,
    sup.name            AS preferred_supplier,
    sup.phone           AS supplier_phone
FROM v_stock_on_hand s
JOIN cartridges  c   ON c.cartridge_id = s.cartridge_id
LEFT JOIN suppliers sup ON sup.supplier_id = c.preferred_supplier_id
WHERE c.active
  AND s.on_hand <= s.reorder_threshold
ORDER BY s.on_hand ASC, s.name;


-- ============================================================
-- 2. "What cartridge fits this printer?"
--    Replaces: thumbing through a compatibility binder at the counter.
--    Replace the model name with whatever the customer brought in.
-- ============================================================

SELECT
    c.sku,
    c.name        AS cartridge,
    c.color,
    c.unit_price,
    soh.on_hand
FROM printer_models pm
JOIN cartridge_compatibility cc ON cc.printer_model_id = pm.printer_model_id
JOIN cartridges c               ON c.cartridge_id      = cc.cartridge_id
JOIN v_stock_on_hand soh        ON soh.cartridge_id    = c.cartridge_id
WHERE pm.model_name = 'OfficeJet Pro 9015e'
  AND c.active
ORDER BY c.color, c.name;


-- ============================================================
-- 3. Top clients by revenue, year-to-date
--    Replaces: flipping through a paper ledger at month end.
--    Excludes quotes and cancelled orders so the totals reflect real money.
-- ============================================================

SELECT
    cl.name                                 AS client,
    cl.type                                 AS client_type,
    COUNT(DISTINCT o.order_id)              AS orders,
    SUM(oi.quantity * oi.unit_price)::NUMERIC(12,2) AS revenue_ytd
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
JOIN clients cl     ON cl.client_id = o.client_id
WHERE o.status IN ('paid', 'delivered')
  AND o.order_date >= DATE_TRUNC('year', CURRENT_DATE)
GROUP BY cl.client_id, cl.name, cl.type
ORDER BY revenue_ytd DESC
LIMIT 10;


-- ============================================================
-- 4. Monthly sales summary
--    Replaces: tallying receipts at the end of each month.
-- ============================================================

SELECT
    DATE_TRUNC('month', o.order_date)::DATE  AS month,
    COUNT(DISTINCT o.order_id)               AS orders,
    SUM(oi.quantity)                         AS units_sold,
    SUM(oi.quantity * oi.unit_price)::NUMERIC(12,2) AS revenue
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
WHERE o.status IN ('paid', 'delivered')
GROUP BY DATE_TRUNC('month', o.order_date)
ORDER BY month;


-- ============================================================
-- 5. Recent orders for a recurring client
--    Replaces: digging through a binder when a regular calls.
-- ============================================================

SELECT
    o.order_id,
    o.order_date,
    o.status,
    ot.total
FROM orders o
JOIN clients cl       ON cl.client_id = o.client_id
JOIN v_order_totals ot ON ot.order_id = o.order_id
WHERE cl.name = 'Bufete García & Asociados'
ORDER BY o.order_date DESC
LIMIT 5;


-- ============================================================
-- 6. Reorder list grouped by supplier
--    Replaces: manually figuring out who to call for what.
--    For each supplier, lists the cartridges below threshold and the
--    suggested order quantity (enough to bring stock up to 2× threshold).
-- ============================================================

SELECT
    sup.name                                AS supplier,
    c.sku,
    c.name                                  AS cartridge,
    s.on_hand,
    c.reorder_threshold,
    (c.reorder_threshold * 2 - s.on_hand)   AS suggested_order_qty
FROM v_stock_on_hand s
JOIN cartridges c   ON c.cartridge_id = s.cartridge_id
JOIN suppliers sup  ON sup.supplier_id = c.preferred_supplier_id
WHERE c.active
  AND s.on_hand <= c.reorder_threshold
ORDER BY sup.name, c.name;


-- ============================================================
-- 7. Outstanding quotes
--    Replaces: a sticky note on the monitor.
-- ============================================================

SELECT
    o.order_id,
    o.order_date,
    cl.name        AS client,
    ot.total       AS quoted_total,
    o.notes
FROM orders o
JOIN clients cl        ON cl.client_id = o.client_id
JOIN v_order_totals ot ON ot.order_id  = o.order_id
WHERE o.status = 'quote'
ORDER BY o.order_date;


-- ============================================================
-- 8. Inventory audit trail for one cartridge
--    Replaces: explaining a stock discrepancy after the fact.
-- ============================================================

SELECT
    m.occurred_at,
    m.movement_type,
    m.quantity_change,
    SUM(m.quantity_change) OVER (
        PARTITION BY m.cartridge_id
        ORDER BY m.occurred_at, m.movement_id
    )                          AS running_balance,
    o.order_id                 AS order_ref,
    sup.name                   AS supplier_ref,
    m.notes
FROM inventory_movements m
JOIN cartridges c       ON c.cartridge_id = m.cartridge_id
LEFT JOIN orders   o   ON o.order_id      = m.related_order_id
LEFT JOIN suppliers sup ON sup.supplier_id = m.related_supplier_id
WHERE c.sku = 'HP-962-C'
ORDER BY m.occurred_at, m.movement_id;
