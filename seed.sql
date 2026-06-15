-- CJ Toner Express — sample seed data
-- All clients, suppliers, prices, and order numbers are fictional.
-- Dates are set around mid-2026 so "recent activity" queries return something.

BEGIN;

-- ============================================================
-- Brands and printer models
-- ============================================================

INSERT INTO brands (name) VALUES
    ('HP'),
    ('Canon'),
    ('Brother'),
    ('Epson'),
    ('Xerox');

INSERT INTO printer_models (brand_id, model_name) VALUES
    ((SELECT brand_id FROM brands WHERE name = 'HP'),      'LaserJet Pro M404dn'),
    ((SELECT brand_id FROM brands WHERE name = 'HP'),      'LaserJet Pro MFP M428fdw'),
    ((SELECT brand_id FROM brands WHERE name = 'HP'),      'OfficeJet Pro 9015e'),
    ((SELECT brand_id FROM brands WHERE name = 'HP'),      'DeskJet 2755e'),
    ((SELECT brand_id FROM brands WHERE name = 'Canon'),   'imageCLASS MF445dw'),
    ((SELECT brand_id FROM brands WHERE name = 'Canon'),   'PIXMA TR4720'),
    ((SELECT brand_id FROM brands WHERE name = 'Brother'), 'HL-L2350DW'),
    ((SELECT brand_id FROM brands WHERE name = 'Brother'), 'MFC-J895DW'),
    ((SELECT brand_id FROM brands WHERE name = 'Epson'),   'EcoTank ET-2800'),
    ((SELECT brand_id FROM brands WHERE name = 'Xerox'),   'Phaser 6510'),
    ((SELECT brand_id FROM brands WHERE name = 'Xerox'),   'WorkCentre 6515');


-- ============================================================
-- Suppliers
-- ============================================================

INSERT INTO suppliers (name, contact_name, phone, email, notes) VALUES
    ('Caribe Tech Distributors',  'Luis Negrón',    '(787) 555-0142', 'ventas@caribetech.example',     'Main HP / Canon distributor; net-30.'),
    ('Antillas Office Supply',    'Sofía Ortiz',    '(787) 555-0188', 'pedidos@antillas.example',      'Good Brother stock, slower shipping.'),
    ('Boriken Imaging Imports',   'Rafael Colón',   '(787) 555-0211', 'rafael@boriken.example',        'Xerox specialist; minimum order applies.'),
    ('Plaza Mayor Wholesale',     'Diana Pérez',    '(787) 555-0263', 'diana@plazamayor.example',      'Epson bottles, walk-in pickup available.'),
    ('Isla Verde Trading Co.',    'Héctor Vázquez', '(787) 555-0307', 'hector@islaverde.example',      'Backup supplier; higher prices, fast.');


-- ============================================================
-- Cartridges (catalog)
-- ============================================================

INSERT INTO cartridges (sku, brand_id, name, type, color, page_yield, unit_cost, unit_price, reorder_threshold, preferred_supplier_id) VALUES
    ('HP-58A-BK',     (SELECT brand_id FROM brands WHERE name='HP'),      'HP 58A Black Toner',                'toner', 'black',    3000,  62.00,  89.99, 4, (SELECT supplier_id FROM suppliers WHERE name='Caribe Tech Distributors')),
    ('HP-58X-BK',     (SELECT brand_id FROM brands WHERE name='HP'),      'HP 58X High-Yield Black Toner',     'toner', 'black',   10000, 115.00, 169.99, 3, (SELECT supplier_id FROM suppliers WHERE name='Caribe Tech Distributors')),
    ('HP-962-BK',     (SELECT brand_id FROM brands WHERE name='HP'),      'HP 962 Black Ink',                  'ink',   'black',   1000,  28.00,  44.99, 6, (SELECT supplier_id FROM suppliers WHERE name='Caribe Tech Distributors')),
    ('HP-962-C',      (SELECT brand_id FROM brands WHERE name='HP'),      'HP 962 Cyan Ink',                   'ink',   'cyan',     700,  22.00,  36.99, 5, (SELECT supplier_id FROM suppliers WHERE name='Caribe Tech Distributors')),
    ('HP-962-M',      (SELECT brand_id FROM brands WHERE name='HP'),      'HP 962 Magenta Ink',                'ink',   'magenta',  700,  22.00,  36.99, 5, (SELECT supplier_id FROM suppliers WHERE name='Caribe Tech Distributors')),
    ('HP-962-Y',      (SELECT brand_id FROM brands WHERE name='HP'),      'HP 962 Yellow Ink',                 'ink',   'yellow',   700,  22.00,  36.99, 5, (SELECT supplier_id FROM suppliers WHERE name='Caribe Tech Distributors')),
    ('HP-67-TRI',     (SELECT brand_id FROM brands WHERE name='HP'),      'HP 67 Tricolor Ink',                'ink',   'tricolor', 100,  18.00,  29.99, 8, (SELECT supplier_id FROM suppliers WHERE name='Caribe Tech Distributors')),
    ('HP-67-BK',      (SELECT brand_id FROM brands WHERE name='HP'),      'HP 67 Black Ink',                   'ink',   'black',    120,  16.00,  26.99, 8, (SELECT supplier_id FROM suppliers WHERE name='Caribe Tech Distributors')),
    ('CAN-057-BK',    (SELECT brand_id FROM brands WHERE name='Canon'),   'Canon 057 Black Toner',             'toner', 'black',   3100,  68.00,  98.99, 4, (SELECT supplier_id FROM suppliers WHERE name='Caribe Tech Distributors')),
    ('CAN-PG275-BK',  (SELECT brand_id FROM brands WHERE name='Canon'),   'Canon PG-275 Black Pigment Ink',    'ink',   'black',    400,  19.00,  31.99, 6, (SELECT supplier_id FROM suppliers WHERE name='Caribe Tech Distributors')),
    ('CAN-CL276-TRI', (SELECT brand_id FROM brands WHERE name='Canon'),   'Canon CL-276 Tricolor Ink',         'ink',   'tricolor', 200,  21.00,  34.99, 6, (SELECT supplier_id FROM suppliers WHERE name='Caribe Tech Distributors')),
    ('BRO-TN760-BK',  (SELECT brand_id FROM brands WHERE name='Brother'), 'Brother TN-760 High-Yield Toner',   'toner', 'black',   3000,  55.00,  84.99, 4, (SELECT supplier_id FROM suppliers WHERE name='Antillas Office Supply')),
    ('BRO-LC3035-BK', (SELECT brand_id FROM brands WHERE name='Brother'), 'Brother LC3035BK Black Ink',        'ink',   'black',   6000,  42.00,  64.99, 4, (SELECT supplier_id FROM suppliers WHERE name='Antillas Office Supply')),
    ('EPS-502-BK',    (SELECT brand_id FROM brands WHERE name='Epson'),   'Epson 502 Black Ink Bottle',        'ink',   'black',   7500,  15.00,  24.99, 6, (SELECT supplier_id FROM suppliers WHERE name='Plaza Mayor Wholesale')),
    ('XRX-6510-BK',   (SELECT brand_id FROM brands WHERE name='Xerox'),   'Xerox 106R03480 Black Toner',       'toner', 'black',   2500,  74.00, 109.99, 3, (SELECT supplier_id FROM suppliers WHERE name='Boriken Imaging Imports'));


-- ============================================================
-- Compatibility (cartridge ↔ printer model)
-- ============================================================

INSERT INTO cartridge_compatibility (cartridge_id, printer_model_id) VALUES
    -- HP 58A and 58X fit both M404dn and M428fdw
    ((SELECT cartridge_id FROM cartridges WHERE sku='HP-58A-BK'), (SELECT printer_model_id FROM printer_models WHERE model_name='LaserJet Pro M404dn')),
    ((SELECT cartridge_id FROM cartridges WHERE sku='HP-58A-BK'), (SELECT printer_model_id FROM printer_models WHERE model_name='LaserJet Pro MFP M428fdw')),
    ((SELECT cartridge_id FROM cartridges WHERE sku='HP-58X-BK'), (SELECT printer_model_id FROM printer_models WHERE model_name='LaserJet Pro M404dn')),
    ((SELECT cartridge_id FROM cartridges WHERE sku='HP-58X-BK'), (SELECT printer_model_id FROM printer_models WHERE model_name='LaserJet Pro MFP M428fdw')),
    -- HP 962 set fits OfficeJet Pro 9015e
    ((SELECT cartridge_id FROM cartridges WHERE sku='HP-962-BK'), (SELECT printer_model_id FROM printer_models WHERE model_name='OfficeJet Pro 9015e')),
    ((SELECT cartridge_id FROM cartridges WHERE sku='HP-962-C'),  (SELECT printer_model_id FROM printer_models WHERE model_name='OfficeJet Pro 9015e')),
    ((SELECT cartridge_id FROM cartridges WHERE sku='HP-962-M'),  (SELECT printer_model_id FROM printer_models WHERE model_name='OfficeJet Pro 9015e')),
    ((SELECT cartridge_id FROM cartridges WHERE sku='HP-962-Y'),  (SELECT printer_model_id FROM printer_models WHERE model_name='OfficeJet Pro 9015e')),
    -- HP 67 set fits DeskJet 2755e
    ((SELECT cartridge_id FROM cartridges WHERE sku='HP-67-TRI'), (SELECT printer_model_id FROM printer_models WHERE model_name='DeskJet 2755e')),
    ((SELECT cartridge_id FROM cartridges WHERE sku='HP-67-BK'),  (SELECT printer_model_id FROM printer_models WHERE model_name='DeskJet 2755e')),
    -- Canon
    ((SELECT cartridge_id FROM cartridges WHERE sku='CAN-057-BK'),    (SELECT printer_model_id FROM printer_models WHERE model_name='imageCLASS MF445dw')),
    ((SELECT cartridge_id FROM cartridges WHERE sku='CAN-PG275-BK'),  (SELECT printer_model_id FROM printer_models WHERE model_name='PIXMA TR4720')),
    ((SELECT cartridge_id FROM cartridges WHERE sku='CAN-CL276-TRI'), (SELECT printer_model_id FROM printer_models WHERE model_name='PIXMA TR4720')),
    -- Brother
    ((SELECT cartridge_id FROM cartridges WHERE sku='BRO-TN760-BK'),  (SELECT printer_model_id FROM printer_models WHERE model_name='HL-L2350DW')),
    ((SELECT cartridge_id FROM cartridges WHERE sku='BRO-LC3035-BK'), (SELECT printer_model_id FROM printer_models WHERE model_name='MFC-J895DW')),
    -- Epson
    ((SELECT cartridge_id FROM cartridges WHERE sku='EPS-502-BK'), (SELECT printer_model_id FROM printer_models WHERE model_name='EcoTank ET-2800')),
    -- Xerox toner fits both Phaser 6510 and WorkCentre 6515
    ((SELECT cartridge_id FROM cartridges WHERE sku='XRX-6510-BK'), (SELECT printer_model_id FROM printer_models WHERE model_name='Phaser 6510')),
    ((SELECT cartridge_id FROM cartridges WHERE sku='XRX-6510-BK'), (SELECT printer_model_id FROM printer_models WHERE model_name='WorkCentre 6515'));


-- ============================================================
-- Clients
-- ============================================================

INSERT INTO clients (type, name, contact_name, email, phone, address, notes) VALUES
    ('business',   'Bufete García & Asociados',         'Lcda. Marisol García', 'oficina@bufetegarcia.example',   '(787) 555-0411', 'Ave. Ponce de León 1234, San Juan',  'Monthly recurring HP toner order.'),
    ('business',   'Consultorio Médico Dr. Ramírez',    'Dra. Elena Ramírez',   'recepcion@drramirez.example',    '(787) 555-0529', 'Calle Loíza 88, San Juan',           'Net-15 account.'),
    ('business',   'Escuela Elemental Santa Teresita',  'Sr. Roberto Sánchez',  'compras@stateresita.example',    '(787) 555-0617', 'Carr. 845 Km 3.2, Trujillo Alto',    'Buys in volume before school year starts.'),
    ('business',   'Imprenta del Caribe',               'Sr. Javier Morales',   'javier@imprentadelcaribe.example','(787) 555-0734','Carr. 2 Km 14.8, Bayamón',           'High Epson ink-bottle volume.'),
    ('business',   'Farmacia Vega',                     'Sra. Carmen Vega',     'farmacia.vega@example.com',      '(787) 555-0808', 'Calle Comercio 45, Río Piedras',     'Single PIXMA printer, low volume.'),
    ('individual', 'María Rodríguez',                    NULL,                   'mrodriguez@example.com',         '(787) 555-0922', 'Condado, San Juan',                  NULL),
    ('individual', 'Carlos Méndez',                      NULL,                   'cmendez@example.com',            '(787) 555-1015', 'Caparra, Guaynabo',                  NULL),
    ('business',   'Taller Mecánico Rivera',            'Sr. Ángel Rivera',     'taller.rivera@example.com',      '(787) 555-1144', 'Carr. 1 Km 8, Caguas',               'Walk-in. Cash preferred.'),
    ('individual', 'Ana Quiñones',                       NULL,                   'aquinones@example.com',          '(787) 555-1231', 'Levittown, Toa Baja',                NULL),
    ('business',   'Estudio Contable Pérez & Co.',      'CPA José Pérez',       'jose@perezcpa.example',          '(787) 555-1320', 'Plaza Las Américas Tower, San Juan', 'Heavy print season Feb–Apr.');


-- ============================================================
-- Inventory: opening stock received from suppliers in early April 2026
-- ============================================================

INSERT INTO inventory_movements (cartridge_id, movement_type, quantity_change, occurred_at, related_supplier_id, notes) VALUES
    ((SELECT cartridge_id FROM cartridges WHERE sku='HP-58A-BK'),     'received', 12, '2026-04-03 09:00-04', (SELECT supplier_id FROM suppliers WHERE name='Caribe Tech Distributors'), 'Q2 opening stock'),
    ((SELECT cartridge_id FROM cartridges WHERE sku='HP-58X-BK'),     'received',  8, '2026-04-03 09:00-04', (SELECT supplier_id FROM suppliers WHERE name='Caribe Tech Distributors'), 'Q2 opening stock'),
    ((SELECT cartridge_id FROM cartridges WHERE sku='HP-962-BK'),     'received', 20, '2026-04-03 09:00-04', (SELECT supplier_id FROM suppliers WHERE name='Caribe Tech Distributors'), 'Q2 opening stock'),
    ((SELECT cartridge_id FROM cartridges WHERE sku='HP-962-C'),      'received', 15, '2026-04-03 09:00-04', (SELECT supplier_id FROM suppliers WHERE name='Caribe Tech Distributors'), 'Q2 opening stock'),
    ((SELECT cartridge_id FROM cartridges WHERE sku='HP-962-M'),      'received', 15, '2026-04-03 09:00-04', (SELECT supplier_id FROM suppliers WHERE name='Caribe Tech Distributors'), 'Q2 opening stock'),
    ((SELECT cartridge_id FROM cartridges WHERE sku='HP-962-Y'),      'received', 15, '2026-04-03 09:00-04', (SELECT supplier_id FROM suppliers WHERE name='Caribe Tech Distributors'), 'Q2 opening stock'),
    ((SELECT cartridge_id FROM cartridges WHERE sku='HP-67-TRI'),     'received', 25, '2026-04-03 09:00-04', (SELECT supplier_id FROM suppliers WHERE name='Caribe Tech Distributors'), 'Q2 opening stock'),
    ((SELECT cartridge_id FROM cartridges WHERE sku='HP-67-BK'),      'received', 25, '2026-04-03 09:00-04', (SELECT supplier_id FROM suppliers WHERE name='Caribe Tech Distributors'), 'Q2 opening stock'),
    ((SELECT cartridge_id FROM cartridges WHERE sku='CAN-057-BK'),    'received', 10, '2026-04-03 09:00-04', (SELECT supplier_id FROM suppliers WHERE name='Caribe Tech Distributors'), 'Q2 opening stock'),
    ((SELECT cartridge_id FROM cartridges WHERE sku='CAN-PG275-BK'),  'received', 18, '2026-04-03 09:00-04', (SELECT supplier_id FROM suppliers WHERE name='Caribe Tech Distributors'), 'Q2 opening stock'),
    ((SELECT cartridge_id FROM cartridges WHERE sku='CAN-CL276-TRI'), 'received', 18, '2026-04-03 09:00-04', (SELECT supplier_id FROM suppliers WHERE name='Caribe Tech Distributors'), 'Q2 opening stock'),
    ((SELECT cartridge_id FROM cartridges WHERE sku='BRO-TN760-BK'),  'received', 14, '2026-04-04 10:00-04', (SELECT supplier_id FROM suppliers WHERE name='Antillas Office Supply'),   'Q2 opening stock'),
    ((SELECT cartridge_id FROM cartridges WHERE sku='BRO-LC3035-BK'), 'received', 12, '2026-04-04 10:00-04', (SELECT supplier_id FROM suppliers WHERE name='Antillas Office Supply'),   'Q2 opening stock'),
    ((SELECT cartridge_id FROM cartridges WHERE sku='EPS-502-BK'),    'received', 30, '2026-04-05 11:00-04', (SELECT supplier_id FROM suppliers WHERE name='Plaza Mayor Wholesale'),    'Q2 opening stock'),
    ((SELECT cartridge_id FROM cartridges WHERE sku='XRX-6510-BK'),   'received',  6, '2026-04-05 11:00-04', (SELECT supplier_id FROM suppliers WHERE name='Boriken Imaging Imports'),  'Q2 opening stock');


-- ============================================================
-- Orders and their line items (April–June 2026)
-- ============================================================
-- For readability we identify each order by its inserted row's id via currval();
-- one INSERT … RETURNING into a CTE would also work, but plain SQL keeps the
-- file portable for psql, DBeaver, etc.

-- Order 1: Bufete García — monthly HP toner refill
INSERT INTO orders (client_id, order_date, status, payment_method, notes)
VALUES ((SELECT client_id FROM clients WHERE name='Bufete García & Asociados'), '2026-04-10', 'delivered', 'account', 'Monthly standing order');
INSERT INTO order_items (order_id, cartridge_id, quantity, unit_price) VALUES
    (currval('orders_order_id_seq'), (SELECT cartridge_id FROM cartridges WHERE sku='HP-58A-BK'), 2,  89.99),
    (currval('orders_order_id_seq'), (SELECT cartridge_id FROM cartridges WHERE sku='HP-58X-BK'), 1, 169.99);
INSERT INTO inventory_movements (cartridge_id, movement_type, quantity_change, occurred_at, related_order_id, notes) VALUES
    ((SELECT cartridge_id FROM cartridges WHERE sku='HP-58A-BK'), 'sold', -2, '2026-04-10 14:00-04', currval('orders_order_id_seq'), NULL),
    ((SELECT cartridge_id FROM cartridges WHERE sku='HP-58X-BK'), 'sold', -1, '2026-04-10 14:00-04', currval('orders_order_id_seq'), NULL);

-- Order 2: Consultorio Médico Dr. Ramírez — color set for OfficeJet
INSERT INTO orders (client_id, order_date, status, payment_method)
VALUES ((SELECT client_id FROM clients WHERE name='Consultorio Médico Dr. Ramírez'), '2026-04-14', 'delivered', 'account');
INSERT INTO order_items (order_id, cartridge_id, quantity, unit_price) VALUES
    (currval('orders_order_id_seq'), (SELECT cartridge_id FROM cartridges WHERE sku='HP-962-BK'), 2, 44.99),
    (currval('orders_order_id_seq'), (SELECT cartridge_id FROM cartridges WHERE sku='HP-962-C'),  1, 36.99),
    (currval('orders_order_id_seq'), (SELECT cartridge_id FROM cartridges WHERE sku='HP-962-M'),  1, 36.99),
    (currval('orders_order_id_seq'), (SELECT cartridge_id FROM cartridges WHERE sku='HP-962-Y'),  1, 36.99);
INSERT INTO inventory_movements (cartridge_id, movement_type, quantity_change, occurred_at, related_order_id) VALUES
    ((SELECT cartridge_id FROM cartridges WHERE sku='HP-962-BK'), 'sold', -2, '2026-04-14 11:30-04', currval('orders_order_id_seq')),
    ((SELECT cartridge_id FROM cartridges WHERE sku='HP-962-C'),  'sold', -1, '2026-04-14 11:30-04', currval('orders_order_id_seq')),
    ((SELECT cartridge_id FROM cartridges WHERE sku='HP-962-M'),  'sold', -1, '2026-04-14 11:30-04', currval('orders_order_id_seq')),
    ((SELECT cartridge_id FROM cartridges WHERE sku='HP-962-Y'),  'sold', -1, '2026-04-14 11:30-04', currval('orders_order_id_seq'));

-- Order 3: Imprenta del Caribe — Epson ink bottles, big volume
INSERT INTO orders (client_id, order_date, status, payment_method)
VALUES ((SELECT client_id FROM clients WHERE name='Imprenta del Caribe'), '2026-04-18', 'paid', 'transfer');
INSERT INTO order_items (order_id, cartridge_id, quantity, unit_price) VALUES
    (currval('orders_order_id_seq'), (SELECT cartridge_id FROM cartridges WHERE sku='EPS-502-BK'), 8, 24.99);
INSERT INTO inventory_movements (cartridge_id, movement_type, quantity_change, occurred_at, related_order_id) VALUES
    ((SELECT cartridge_id FROM cartridges WHERE sku='EPS-502-BK'), 'sold', -8, '2026-04-18 09:45-04', currval('orders_order_id_seq'));

-- Order 4: María Rodríguez — walk-in, single tricolor
INSERT INTO orders (client_id, order_date, status, payment_method)
VALUES ((SELECT client_id FROM clients WHERE name='María Rodríguez'), '2026-04-20', 'paid', 'cash');
INSERT INTO order_items (order_id, cartridge_id, quantity, unit_price) VALUES
    (currval('orders_order_id_seq'), (SELECT cartridge_id FROM cartridges WHERE sku='HP-67-TRI'), 1, 29.99),
    (currval('orders_order_id_seq'), (SELECT cartridge_id FROM cartridges WHERE sku='HP-67-BK'),  1, 26.99);
INSERT INTO inventory_movements (cartridge_id, movement_type, quantity_change, occurred_at, related_order_id) VALUES
    ((SELECT cartridge_id FROM cartridges WHERE sku='HP-67-TRI'), 'sold', -1, '2026-04-20 13:10-04', currval('orders_order_id_seq')),
    ((SELECT cartridge_id FROM cartridges WHERE sku='HP-67-BK'),  'sold', -1, '2026-04-20 13:10-04', currval('orders_order_id_seq'));

-- Order 5: Estudio Contable Pérez & Co. — HP color set
INSERT INTO orders (client_id, order_date, status, payment_method)
VALUES ((SELECT client_id FROM clients WHERE name='Estudio Contable Pérez & Co.'), '2026-04-22', 'delivered', 'account');
INSERT INTO order_items (order_id, cartridge_id, quantity, unit_price) VALUES
    (currval('orders_order_id_seq'), (SELECT cartridge_id FROM cartridges WHERE sku='HP-962-BK'), 1, 44.99),
    (currval('orders_order_id_seq'), (SELECT cartridge_id FROM cartridges WHERE sku='HP-962-C'),  1, 36.99),
    (currval('orders_order_id_seq'), (SELECT cartridge_id FROM cartridges WHERE sku='HP-962-M'),  1, 36.99),
    (currval('orders_order_id_seq'), (SELECT cartridge_id FROM cartridges WHERE sku='HP-962-Y'),  1, 36.99);
INSERT INTO inventory_movements (cartridge_id, movement_type, quantity_change, occurred_at, related_order_id) VALUES
    ((SELECT cartridge_id FROM cartridges WHERE sku='HP-962-BK'), 'sold', -1, '2026-04-22 10:00-04', currval('orders_order_id_seq')),
    ((SELECT cartridge_id FROM cartridges WHERE sku='HP-962-C'),  'sold', -1, '2026-04-22 10:00-04', currval('orders_order_id_seq')),
    ((SELECT cartridge_id FROM cartridges WHERE sku='HP-962-M'),  'sold', -1, '2026-04-22 10:00-04', currval('orders_order_id_seq')),
    ((SELECT cartridge_id FROM cartridges WHERE sku='HP-962-Y'),  'sold', -1, '2026-04-22 10:00-04', currval('orders_order_id_seq'));

-- Order 6: Carlos Méndez — Brother toner, walk-in
INSERT INTO orders (client_id, order_date, status, payment_method)
VALUES ((SELECT client_id FROM clients WHERE name='Carlos Méndez'), '2026-04-28', 'paid', 'card');
INSERT INTO order_items (order_id, cartridge_id, quantity, unit_price) VALUES
    (currval('orders_order_id_seq'), (SELECT cartridge_id FROM cartridges WHERE sku='BRO-TN760-BK'), 1, 84.99);
INSERT INTO inventory_movements (cartridge_id, movement_type, quantity_change, occurred_at, related_order_id) VALUES
    ((SELECT cartridge_id FROM cartridges WHERE sku='BRO-TN760-BK'), 'sold', -1, '2026-04-28 15:20-04', currval('orders_order_id_seq'));

-- Order 7: Bufete García — May refill
INSERT INTO orders (client_id, order_date, status, payment_method, notes)
VALUES ((SELECT client_id FROM clients WHERE name='Bufete García & Asociados'), '2026-05-08', 'delivered', 'account', 'Monthly standing order');
INSERT INTO order_items (order_id, cartridge_id, quantity, unit_price) VALUES
    (currval('orders_order_id_seq'), (SELECT cartridge_id FROM cartridges WHERE sku='HP-58A-BK'), 3, 89.99);
INSERT INTO inventory_movements (cartridge_id, movement_type, quantity_change, occurred_at, related_order_id) VALUES
    ((SELECT cartridge_id FROM cartridges WHERE sku='HP-58A-BK'), 'sold', -3, '2026-05-08 14:00-04', currval('orders_order_id_seq'));

-- Order 8: Escuela Elemental Santa Teresita — pre-summer bulk Canon order
INSERT INTO orders (client_id, order_date, status, payment_method)
VALUES ((SELECT client_id FROM clients WHERE name='Escuela Elemental Santa Teresita'), '2026-05-11', 'delivered', 'transfer');
INSERT INTO order_items (order_id, cartridge_id, quantity, unit_price) VALUES
    (currval('orders_order_id_seq'), (SELECT cartridge_id FROM cartridges WHERE sku='CAN-057-BK'),    4, 98.99),
    (currval('orders_order_id_seq'), (SELECT cartridge_id FROM cartridges WHERE sku='CAN-PG275-BK'),  3, 31.99),
    (currval('orders_order_id_seq'), (SELECT cartridge_id FROM cartridges WHERE sku='CAN-CL276-TRI'), 3, 34.99);
INSERT INTO inventory_movements (cartridge_id, movement_type, quantity_change, occurred_at, related_order_id) VALUES
    ((SELECT cartridge_id FROM cartridges WHERE sku='CAN-057-BK'),    'sold', -4, '2026-05-11 09:30-04', currval('orders_order_id_seq')),
    ((SELECT cartridge_id FROM cartridges WHERE sku='CAN-PG275-BK'),  'sold', -3, '2026-05-11 09:30-04', currval('orders_order_id_seq')),
    ((SELECT cartridge_id FROM cartridges WHERE sku='CAN-CL276-TRI'), 'sold', -3, '2026-05-11 09:30-04', currval('orders_order_id_seq'));

-- Order 9: Farmacia Vega — small PIXMA refill
INSERT INTO orders (client_id, order_date, status, payment_method)
VALUES ((SELECT client_id FROM clients WHERE name='Farmacia Vega'), '2026-05-14', 'paid', 'card');
INSERT INTO order_items (order_id, cartridge_id, quantity, unit_price) VALUES
    (currval('orders_order_id_seq'), (SELECT cartridge_id FROM cartridges WHERE sku='CAN-PG275-BK'),  1, 31.99),
    (currval('orders_order_id_seq'), (SELECT cartridge_id FROM cartridges WHERE sku='CAN-CL276-TRI'), 1, 34.99);
INSERT INTO inventory_movements (cartridge_id, movement_type, quantity_change, occurred_at, related_order_id) VALUES
    ((SELECT cartridge_id FROM cartridges WHERE sku='CAN-PG275-BK'),  'sold', -1, '2026-05-14 12:00-04', currval('orders_order_id_seq')),
    ((SELECT cartridge_id FROM cartridges WHERE sku='CAN-CL276-TRI'), 'sold', -1, '2026-05-14 12:00-04', currval('orders_order_id_seq'));

-- Order 10: Taller Mecánico Rivera — Xerox toner
INSERT INTO orders (client_id, order_date, status, payment_method)
VALUES ((SELECT client_id FROM clients WHERE name='Taller Mecánico Rivera'), '2026-05-19', 'paid', 'cash');
INSERT INTO order_items (order_id, cartridge_id, quantity, unit_price) VALUES
    (currval('orders_order_id_seq'), (SELECT cartridge_id FROM cartridges WHERE sku='XRX-6510-BK'), 1, 109.99);
INSERT INTO inventory_movements (cartridge_id, movement_type, quantity_change, occurred_at, related_order_id) VALUES
    ((SELECT cartridge_id FROM cartridges WHERE sku='XRX-6510-BK'), 'sold', -1, '2026-05-19 16:00-04', currval('orders_order_id_seq'));

-- Order 11: Imprenta del Caribe — second Epson refill
INSERT INTO orders (client_id, order_date, status, payment_method)
VALUES ((SELECT client_id FROM clients WHERE name='Imprenta del Caribe'), '2026-05-22', 'delivered', 'transfer');
INSERT INTO order_items (order_id, cartridge_id, quantity, unit_price) VALUES
    (currval('orders_order_id_seq'), (SELECT cartridge_id FROM cartridges WHERE sku='EPS-502-BK'), 10, 24.99);
INSERT INTO inventory_movements (cartridge_id, movement_type, quantity_change, occurred_at, related_order_id) VALUES
    ((SELECT cartridge_id FROM cartridges WHERE sku='EPS-502-BK'), 'sold', -10, '2026-05-22 10:00-04', currval('orders_order_id_seq'));

-- Order 12: Ana Quiñones — DeskJet tricolor (returned later)
INSERT INTO orders (client_id, order_date, status, payment_method, notes)
VALUES ((SELECT client_id FROM clients WHERE name='Ana Quiñones'), '2026-05-25', 'paid', 'cash', 'Customer later returned tricolor — wrong printer.');
INSERT INTO order_items (order_id, cartridge_id, quantity, unit_price) VALUES
    (currval('orders_order_id_seq'), (SELECT cartridge_id FROM cartridges WHERE sku='HP-67-TRI'), 1, 29.99);
INSERT INTO inventory_movements (cartridge_id, movement_type, quantity_change, occurred_at, related_order_id) VALUES
    ((SELECT cartridge_id FROM cartridges WHERE sku='HP-67-TRI'), 'sold',   -1, '2026-05-25 11:00-04', currval('orders_order_id_seq')),
    ((SELECT cartridge_id FROM cartridges WHERE sku='HP-67-TRI'), 'return', +1, '2026-05-27 15:00-04', currval('orders_order_id_seq'));

-- Order 13: Consultorio Médico Dr. Ramírez — June black-only refill
INSERT INTO orders (client_id, order_date, status, payment_method)
VALUES ((SELECT client_id FROM clients WHERE name='Consultorio Médico Dr. Ramírez'), '2026-06-02', 'delivered', 'account');
INSERT INTO order_items (order_id, cartridge_id, quantity, unit_price) VALUES
    (currval('orders_order_id_seq'), (SELECT cartridge_id FROM cartridges WHERE sku='HP-962-BK'), 3, 44.99);
INSERT INTO inventory_movements (cartridge_id, movement_type, quantity_change, occurred_at, related_order_id) VALUES
    ((SELECT cartridge_id FROM cartridges WHERE sku='HP-962-BK'), 'sold', -3, '2026-06-02 11:30-04', currval('orders_order_id_seq'));

-- Order 14: Bufete García — June refill
INSERT INTO orders (client_id, order_date, status, payment_method, notes)
VALUES ((SELECT client_id FROM clients WHERE name='Bufete García & Asociados'), '2026-06-05', 'delivered', 'account', 'Monthly standing order');
INSERT INTO order_items (order_id, cartridge_id, quantity, unit_price) VALUES
    (currval('orders_order_id_seq'), (SELECT cartridge_id FROM cartridges WHERE sku='HP-58A-BK'), 2,  89.99),
    (currval('orders_order_id_seq'), (SELECT cartridge_id FROM cartridges WHERE sku='HP-58X-BK'), 2, 169.99);
INSERT INTO inventory_movements (cartridge_id, movement_type, quantity_change, occurred_at, related_order_id) VALUES
    ((SELECT cartridge_id FROM cartridges WHERE sku='HP-58A-BK'), 'sold', -2, '2026-06-05 14:00-04', currval('orders_order_id_seq')),
    ((SELECT cartridge_id FROM cartridges WHERE sku='HP-58X-BK'), 'sold', -2, '2026-06-05 14:00-04', currval('orders_order_id_seq'));

-- Order 15: Estudio Contable Pérez & Co. — June color refill
INSERT INTO orders (client_id, order_date, status, payment_method)
VALUES ((SELECT client_id FROM clients WHERE name='Estudio Contable Pérez & Co.'), '2026-06-08', 'paid', 'account');
INSERT INTO order_items (order_id, cartridge_id, quantity, unit_price) VALUES
    (currval('orders_order_id_seq'), (SELECT cartridge_id FROM cartridges WHERE sku='HP-962-BK'), 2, 44.99),
    (currval('orders_order_id_seq'), (SELECT cartridge_id FROM cartridges WHERE sku='HP-962-C'),  1, 36.99),
    (currval('orders_order_id_seq'), (SELECT cartridge_id FROM cartridges WHERE sku='HP-962-M'),  1, 36.99),
    (currval('orders_order_id_seq'), (SELECT cartridge_id FROM cartridges WHERE sku='HP-962-Y'),  1, 36.99);
INSERT INTO inventory_movements (cartridge_id, movement_type, quantity_change, occurred_at, related_order_id) VALUES
    ((SELECT cartridge_id FROM cartridges WHERE sku='HP-962-BK'), 'sold', -2, '2026-06-08 10:00-04', currval('orders_order_id_seq')),
    ((SELECT cartridge_id FROM cartridges WHERE sku='HP-962-C'),  'sold', -1, '2026-06-08 10:00-04', currval('orders_order_id_seq')),
    ((SELECT cartridge_id FROM cartridges WHERE sku='HP-962-M'),  'sold', -1, '2026-06-08 10:00-04', currval('orders_order_id_seq')),
    ((SELECT cartridge_id FROM cartridges WHERE sku='HP-962-Y'),  'sold', -1, '2026-06-08 10:00-04', currval('orders_order_id_seq'));

-- Order 16: Open quote for Imprenta del Caribe (not yet delivered)
INSERT INTO orders (client_id, order_date, status, notes)
VALUES ((SELECT client_id FROM clients WHERE name='Imprenta del Caribe'), '2026-06-11', 'quote', 'Waiting on customer confirmation.');
INSERT INTO order_items (order_id, cartridge_id, quantity, unit_price) VALUES
    (currval('orders_order_id_seq'), (SELECT cartridge_id FROM cartridges WHERE sku='EPS-502-BK'), 12, 24.99);

-- Order 17: Cancelled order — Carlos Méndez changed his mind
INSERT INTO orders (client_id, order_date, status, notes)
VALUES ((SELECT client_id FROM clients WHERE name='Carlos Méndez'), '2026-06-12', 'cancelled', 'Customer cancelled before pickup.');
INSERT INTO order_items (order_id, cartridge_id, quantity, unit_price) VALUES
    (currval('orders_order_id_seq'), (SELECT cartridge_id FROM cartridges WHERE sku='BRO-LC3035-BK'), 1, 64.99);

-- Stock-take adjustment on 2026-06-13: HP-962-C found to be one short
INSERT INTO inventory_movements (cartridge_id, movement_type, quantity_change, occurred_at, notes) VALUES
    ((SELECT cartridge_id FROM cartridges WHERE sku='HP-962-C'), 'adjustment', -1, '2026-06-13 17:30-04', 'Stock-take: one unit damaged in storage.');

COMMIT;
