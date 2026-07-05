-- ============================================================
-- FurniFlow Demo Data Seed - Sales Orders & Quotations
-- Spreads realistic data across 12 months for dashboard testing
-- ============================================================

-- Use the first 6 customers and first 6 products from existing data
DO $$
DECLARE
  c1 UUID := '0c56601e-f6c8-4d97-8c4e-198d14f71890';
  c2 UUID := 'f02a95ab-2246-4d53-9b68-7d5fce9c5f30';
  c3 UUID := '79a9ddfe-c94e-4bd3-81f6-8f8a66283177';
  c4 UUID := '8509b93e-4358-48e3-bafe-e8feff13e134';
  c5 UUID := 'a59c60a2-991b-45a7-9461-09e9d73ea240';
  c6 UUID := '2997f6eb-091e-45e1-bb77-73bf6e86664b';
  tid VARCHAR := 'SYSTEM_TENANT';
BEGIN

-- ============================================================
-- SALES ORDERS - spread across last 12 months
-- Statuses: Confirmed, Ready for Delivery, Delivered, In Production
-- ============================================================

-- July 2025
INSERT INTO sales_orders (id, tenant_id, customer_id, status, order_date, total_amount, subtotal, discount, tax, created_on, updated_on, is_active)
VALUES
  (gen_random_uuid()::text, tid, c1, 'Confirmed',          '2025-07-03 10:00:00+05:30', 85000.00,  80000, 2000, 7000,  '2025-07-03 10:00:00+05:30', NOW(), true),
  (gen_random_uuid()::text, tid, c2, 'Delivered',          '2025-07-15 11:30:00+05:30', 42000.00,  40000, 1000, 3000,  '2025-07-15 11:30:00+05:30', NOW(), true),
  (gen_random_uuid()::text, tid, c3, 'In Production',      '2025-07-22 14:00:00+05:30', 120000.00, 115000, 3000, 8000, '2025-07-22 14:00:00+05:30', NOW(), true);

-- August 2025
INSERT INTO sales_orders (id, tenant_id, customer_id, status, order_date, total_amount, subtotal, discount, tax, created_on, updated_on, is_active)
VALUES
  (gen_random_uuid()::text, tid, c4, 'Confirmed',          '2025-08-05 09:00:00+05:30', 67000.00,  63000, 1500, 5500,  '2025-08-05 09:00:00+05:30', NOW(), true),
  (gen_random_uuid()::text, tid, c5, 'Delivered',          '2025-08-12 10:30:00+05:30', 98000.00,  92000, 2500, 8500,  '2025-08-12 10:30:00+05:30', NOW(), true),
  (gen_random_uuid()::text, tid, c1, 'Ready for Delivery', '2025-08-20 13:00:00+05:30', 55000.00,  52000, 1200, 4200,  '2025-08-20 13:00:00+05:30', NOW(), true),
  (gen_random_uuid()::text, tid, c6, 'Delivered',          '2025-08-28 15:00:00+05:30', 31000.00,  29000, 800,  2800,  '2025-08-28 15:00:00+05:30', NOW(), true);

-- September 2025
INSERT INTO sales_orders (id, tenant_id, customer_id, status, order_date, total_amount, subtotal, discount, tax, created_on, updated_on, is_active)
VALUES
  (gen_random_uuid()::text, tid, c2, 'Confirmed',          '2025-09-04 09:00:00+05:30', 145000.00, 138000, 4000, 11000, '2025-09-04 09:00:00+05:30', NOW(), true),
  (gen_random_uuid()::text, tid, c3, 'Delivered',          '2025-09-11 11:00:00+05:30', 78000.00,  74000, 2000, 6000,  '2025-09-11 11:00:00+05:30', NOW(), true),
  (gen_random_uuid()::text, tid, c4, 'In Production',      '2025-09-19 14:30:00+05:30', 89000.00,  84000, 2500, 7500,  '2025-09-19 14:30:00+05:30', NOW(), true),
  (gen_random_uuid()::text, tid, c5, 'Confirmed',          '2025-09-25 10:00:00+05:30', 62000.00,  58000, 1500, 5500,  '2025-09-25 10:00:00+05:30', NOW(), true);

-- October 2025
INSERT INTO sales_orders (id, tenant_id, customer_id, status, order_date, total_amount, subtotal, discount, tax, created_on, updated_on, is_active)
VALUES
  (gen_random_uuid()::text, tid, c6, 'Delivered',          '2025-10-02 09:00:00+05:30', 110000.00, 104000, 3000, 9000,  '2025-10-02 09:00:00+05:30', NOW(), true),
  (gen_random_uuid()::text, tid, c1, 'Ready for Delivery', '2025-10-09 10:30:00+05:30', 73000.00,  69000, 2000, 6000,  '2025-10-09 10:30:00+05:30', NOW(), true),
  (gen_random_uuid()::text, tid, c2, 'Confirmed',          '2025-10-17 13:00:00+05:30', 95000.00,  90000, 2500, 7500,  '2025-10-17 13:00:00+05:30', NOW(), true),
  (gen_random_uuid()::text, tid, c3, 'Delivered',          '2025-10-24 09:30:00+05:30', 48000.00,  45000, 1200, 4200,  '2025-10-24 09:30:00+05:30', NOW(), true);

-- November 2025
INSERT INTO sales_orders (id, tenant_id, customer_id, status, order_date, total_amount, subtotal, discount, tax, created_on, updated_on, is_active)
VALUES
  (gen_random_uuid()::text, tid, c4, 'Confirmed',          '2025-11-03 09:00:00+05:30', 135000.00, 128000, 3500, 10500, '2025-11-03 09:00:00+05:30', NOW(), true),
  (gen_random_uuid()::text, tid, c5, 'In Production',      '2025-11-10 11:00:00+05:30', 82000.00,  77000, 2200, 7200,  '2025-11-10 11:00:00+05:30', NOW(), true),
  (gen_random_uuid()::text, tid, c6, 'Delivered',          '2025-11-18 14:00:00+05:30', 57000.00,  54000, 1400, 4400,  '2025-11-18 14:00:00+05:30', NOW(), true),
  (gen_random_uuid()::text, tid, c1, 'Confirmed',          '2025-11-25 10:00:00+05:30', 91000.00,  86000, 2300, 7300,  '2025-11-25 10:00:00+05:30', NOW(), true),
  (gen_random_uuid()::text, tid, c2, 'Ready for Delivery', '2025-11-29 15:00:00+05:30', 44000.00,  41000, 1100, 4100,  '2025-11-29 15:00:00+05:30', NOW(), true);

-- December 2025
INSERT INTO sales_orders (id, tenant_id, customer_id, status, order_date, total_amount, subtotal, discount, tax, created_on, updated_on, is_active)
VALUES
  (gen_random_uuid()::text, tid, c3, 'Delivered',          '2025-12-02 09:00:00+05:30', 160000.00, 152000, 4500, 12500, '2025-12-02 09:00:00+05:30', NOW(), true),
  (gen_random_uuid()::text, tid, c4, 'Confirmed',          '2025-12-08 10:00:00+05:30', 74000.00,  70000, 2000, 6000,  '2025-12-08 10:00:00+05:30', NOW(), true),
  (gen_random_uuid()::text, tid, c5, 'Delivered',          '2025-12-15 13:30:00+05:30', 103000.00, 97000, 2700, 8700,  '2025-12-15 13:30:00+05:30', NOW(), true),
  (gen_random_uuid()::text, tid, c6, 'In Production',      '2025-12-20 09:00:00+05:30', 66000.00,  62000, 1700, 5700,  '2025-12-20 09:00:00+05:30', NOW(), true),
  (gen_random_uuid()::text, tid, c1, 'Confirmed',          '2025-12-27 11:00:00+05:30', 88000.00,  83000, 2300, 7300,  '2025-12-27 11:00:00+05:30', NOW(), true);

-- January 2026
INSERT INTO sales_orders (id, tenant_id, customer_id, status, order_date, total_amount, subtotal, discount, tax, created_on, updated_on, is_active)
VALUES
  (gen_random_uuid()::text, tid, c2, 'Confirmed',          '2026-01-05 09:00:00+05:30', 115000.00, 109000, 3000, 9000,  '2026-01-05 09:00:00+05:30', NOW(), true),
  (gen_random_uuid()::text, tid, c3, 'Delivered',          '2026-01-12 10:30:00+05:30', 79000.00,  75000, 2000, 6000,  '2026-01-12 10:30:00+05:30', NOW(), true),
  (gen_random_uuid()::text, tid, c4, 'Ready for Delivery', '2026-01-19 13:00:00+05:30', 52000.00,  49000, 1300, 4300,  '2026-01-19 13:00:00+05:30', NOW(), true),
  (gen_random_uuid()::text, tid, c5, 'In Production',      '2026-01-26 09:30:00+05:30', 134000.00, 127000, 3700, 10700, '2026-01-26 09:30:00+05:30', NOW(), true);

-- February 2026
INSERT INTO sales_orders (id, tenant_id, customer_id, status, order_date, total_amount, subtotal, discount, tax, created_on, updated_on, is_active)
VALUES
  (gen_random_uuid()::text, tid, c6, 'Confirmed',          '2026-02-03 09:00:00+05:30', 96000.00,  91000, 2500, 7500,  '2026-02-03 09:00:00+05:30', NOW(), true),
  (gen_random_uuid()::text, tid, c1, 'Delivered',          '2026-02-10 11:00:00+05:30', 68000.00,  64000, 1800, 5800,  '2026-02-10 11:00:00+05:30', NOW(), true),
  (gen_random_uuid()::text, tid, c2, 'Confirmed',          '2026-02-17 14:00:00+05:30', 142000.00, 135000, 4000, 11000, '2026-02-17 14:00:00+05:30', NOW(), true),
  (gen_random_uuid()::text, tid, c3, 'Ready for Delivery', '2026-02-22 09:00:00+05:30', 59000.00,  56000, 1500, 4500,  '2026-02-22 09:00:00+05:30', NOW(), true);

-- March 2026
INSERT INTO sales_orders (id, tenant_id, customer_id, status, order_date, total_amount, subtotal, discount, tax, created_on, updated_on, is_active)
VALUES
  (gen_random_uuid()::text, tid, c4, 'Delivered',          '2026-03-04 09:00:00+05:30', 175000.00, 166000, 5000, 14000, '2026-03-04 09:00:00+05:30', NOW(), true),
  (gen_random_uuid()::text, tid, c5, 'Confirmed',          '2026-03-11 11:30:00+05:30', 83000.00,  78000, 2200, 7200,  '2026-03-11 11:30:00+05:30', NOW(), true),
  (gen_random_uuid()::text, tid, c6, 'In Production',      '2026-03-18 14:00:00+05:30', 107000.00, 101000, 2800, 8800, '2026-03-18 14:00:00+05:30', NOW(), true),
  (gen_random_uuid()::text, tid, c1, 'Confirmed',          '2026-03-25 09:30:00+05:30', 71000.00,  67000, 1900, 5900,  '2026-03-25 09:30:00+05:30', NOW(), true),
  (gen_random_uuid()::text, tid, c2, 'Delivered',          '2026-03-29 11:00:00+05:30', 49000.00,  46000, 1300, 4300,  '2026-03-29 11:00:00+05:30', NOW(), true);

-- April 2026
INSERT INTO sales_orders (id, tenant_id, customer_id, status, order_date, total_amount, subtotal, discount, tax, created_on, updated_on, is_active)
VALUES
  (gen_random_uuid()::text, tid, c3, 'Confirmed',          '2026-04-03 09:00:00+05:30', 128000.00, 122000, 3500, 9500,  '2026-04-03 09:00:00+05:30', NOW(), true),
  (gen_random_uuid()::text, tid, c4, 'Delivered',          '2026-04-09 10:30:00+05:30', 87000.00,  82000, 2300, 7300,  '2026-04-09 10:30:00+05:30', NOW(), true),
  (gen_random_uuid()::text, tid, c5, 'Ready for Delivery', '2026-04-15 13:30:00+05:30', 63000.00,  59000, 1700, 5700,  '2026-04-15 13:30:00+05:30', NOW(), true),
  (gen_random_uuid()::text, tid, c6, 'Confirmed',          '2026-04-22 09:00:00+05:30', 94000.00,  89000, 2500, 7500,  '2026-04-22 09:00:00+05:30', NOW(), true),
  (gen_random_uuid()::text, tid, c1, 'In Production',      '2026-04-28 11:00:00+05:30', 151000.00, 143000, 4200, 12200, '2026-04-28 11:00:00+05:30', NOW(), true);

-- May 2026
INSERT INTO sales_orders (id, tenant_id, customer_id, status, order_date, total_amount, subtotal, discount, tax, created_on, updated_on, is_active)
VALUES
  (gen_random_uuid()::text, tid, c2, 'Confirmed',          '2026-05-02 09:00:00+05:30', 118000.00, 112000, 3200, 9200,  '2026-05-02 09:00:00+05:30', NOW(), true),
  (gen_random_uuid()::text, tid, c3, 'Delivered',          '2026-05-08 11:00:00+05:30', 76000.00,  72000, 2000, 6000,  '2026-05-08 11:00:00+05:30', NOW(), true),
  (gen_random_uuid()::text, tid, c4, 'Confirmed',          '2026-05-14 14:00:00+05:30', 165000.00, 157000, 4700, 12700, '2026-05-14 14:00:00+05:30', NOW(), true),
  (gen_random_uuid()::text, tid, c5, 'Delivered',          '2026-05-20 09:30:00+05:30', 91000.00,  86000, 2400, 7400,  '2026-05-20 09:30:00+05:30', NOW(), true),
  (gen_random_uuid()::text, tid, c6, 'Ready for Delivery', '2026-05-26 11:30:00+05:30', 58000.00,  55000, 1500, 4500,  '2026-05-26 11:30:00+05:30', NOW(), true);

-- June 2026
INSERT INTO sales_orders (id, tenant_id, customer_id, status, order_date, total_amount, subtotal, discount, tax, created_on, updated_on, is_active)
VALUES
  (gen_random_uuid()::text, tid, c1, 'Confirmed',          '2026-06-03 09:00:00+05:30', 137000.00, 130000, 3800, 10800, '2026-06-03 09:00:00+05:30', NOW(), true),
  (gen_random_uuid()::text, tid, c2, 'In Production',      '2026-06-09 11:00:00+05:30', 104000.00, 98000, 2800, 8800,  '2026-06-09 11:00:00+05:30', NOW(), true),
  (gen_random_uuid()::text, tid, c3, 'Delivered',          '2026-06-15 13:00:00+05:30', 82000.00,  77000, 2200, 7200,  '2026-06-15 13:00:00+05:30', NOW(), true),
  (gen_random_uuid()::text, tid, c4, 'Confirmed',          '2026-06-21 09:30:00+05:30', 197000.00, 187000, 5500, 15500, '2026-06-21 09:30:00+05:30', NOW(), true),
  (gen_random_uuid()::text, tid, c5, 'Ready for Delivery', '2026-06-27 11:00:00+05:30', 73000.00,  69000, 1900, 5900,  '2026-06-27 11:00:00+05:30', NOW(), true);

-- July 2026 (current month)
INSERT INTO sales_orders (id, tenant_id, customer_id, status, order_date, total_amount, subtotal, discount, tax, created_on, updated_on, is_active)
VALUES
  (gen_random_uuid()::text, tid, c6, 'Confirmed',          '2026-07-01 09:00:00+05:30', 156000.00, 148000, 4300, 12300, '2026-07-01 09:00:00+05:30', NOW(), true),
  (gen_random_uuid()::text, tid, c1, 'In Production',      '2026-07-03 11:00:00+05:30', 88000.00,  83000, 2300, 7300,  '2026-07-03 11:00:00+05:30', NOW(), true);

-- ============================================================
-- QUOTATIONS - spread across last 12 months
-- Statuses: Draft, Sent, Approved, Rejected, Converted
-- ============================================================

-- July 2025
INSERT INTO quotations (id, tenant_id, customer_id, status, date_created, valid_until, total, subtotal, discount, tax, created_on, updated_on, is_active)
VALUES
  (gen_random_uuid()::text, tid, c1, 'Converted', '2025-07-05 09:00:00+05:30', '2025-08-05 09:00:00+05:30', 85000, 80000, 2000, 7000, '2025-07-05 09:00:00+05:30', NOW(), true),
  (gen_random_uuid()::text, tid, c2, 'Approved',  '2025-07-12 10:00:00+05:30', '2025-08-12 10:00:00+05:30', 42000, 40000, 1000, 3000, '2025-07-12 10:00:00+05:30', NOW(), true),
  (gen_random_uuid()::text, tid, c3, 'Rejected',  '2025-07-20 11:00:00+05:30', '2025-08-20 11:00:00+05:30', 32000, 30000, 800,  2800, '2025-07-20 11:00:00+05:30', NOW(), true),
  (gen_random_uuid()::text, tid, c4, 'Sent',      '2025-07-28 14:00:00+05:30', '2025-08-28 14:00:00+05:30', 71000, 67000, 1900, 5900, '2025-07-28 14:00:00+05:30', NOW(), true);

-- August 2025
INSERT INTO quotations (id, tenant_id, customer_id, status, date_created, valid_until, total, subtotal, discount, tax, created_on, updated_on, is_active)
VALUES
  (gen_random_uuid()::text, tid, c5, 'Converted', '2025-08-04 09:00:00+05:30', '2025-09-04 09:00:00+05:30', 98000, 93000, 2500, 7500, '2025-08-04 09:00:00+05:30', NOW(), true),
  (gen_random_uuid()::text, tid, c6, 'Approved',  '2025-08-11 10:30:00+05:30', '2025-09-11 10:30:00+05:30', 55000, 52000, 1400, 4400, '2025-08-11 10:30:00+05:30', NOW(), true),
  (gen_random_uuid()::text, tid, c1, 'Rejected',  '2025-08-19 13:00:00+05:30', '2025-09-19 13:00:00+05:30', 28000, 26000, 700,  2700, '2025-08-19 13:00:00+05:30', NOW(), true),
  (gen_random_uuid()::text, tid, c2, 'Sent',      '2025-08-26 09:30:00+05:30', '2025-09-26 09:30:00+05:30', 67000, 63000, 1700, 5700, '2025-08-26 09:30:00+05:30', NOW(), true);

-- September 2025
INSERT INTO quotations (id, tenant_id, customer_id, status, date_created, valid_until, total, subtotal, discount, tax, created_on, updated_on, is_active)
VALUES
  (gen_random_uuid()::text, tid, c3, 'Converted', '2025-09-03 09:00:00+05:30', '2025-10-03 09:00:00+05:30', 145000, 138000, 4000, 11000, '2025-09-03 09:00:00+05:30', NOW(), true),
  (gen_random_uuid()::text, tid, c4, 'Draft',     '2025-09-10 10:00:00+05:30', '2025-10-10 10:00:00+05:30', 78000,  74000,  2000, 6000,  '2025-09-10 10:00:00+05:30', NOW(), true),
  (gen_random_uuid()::text, tid, c5, 'Approved',  '2025-09-18 13:30:00+05:30', '2025-10-18 13:30:00+05:30', 89000,  84000,  2500, 7500,  '2025-09-18 13:30:00+05:30', NOW(), true),
  (gen_random_uuid()::text, tid, c6, 'Rejected',  '2025-09-25 09:00:00+05:30', '2025-10-25 09:00:00+05:30', 41000,  38000,  1100, 4100,  '2025-09-25 09:00:00+05:30', NOW(), true);

-- October 2025
INSERT INTO quotations (id, tenant_id, customer_id, status, date_created, valid_until, total, subtotal, discount, tax, created_on, updated_on, is_active)
VALUES
  (gen_random_uuid()::text, tid, c1, 'Converted', '2025-10-02 09:00:00+05:30', '2025-11-02 09:00:00+05:30', 110000, 104000, 3000, 9000, '2025-10-02 09:00:00+05:30', NOW(), true),
  (gen_random_uuid()::text, tid, c2, 'Sent',      '2025-10-09 10:00:00+05:30', '2025-11-09 10:00:00+05:30', 73000,  69000,  2000, 6000, '2025-10-09 10:00:00+05:30', NOW(), true),
  (gen_random_uuid()::text, tid, c3, 'Approved',  '2025-10-16 13:00:00+05:30', '2025-11-16 13:00:00+05:30', 95000,  90000,  2500, 7500, '2025-10-16 13:00:00+05:30', NOW(), true),
  (gen_random_uuid()::text, tid, c4, 'Rejected',  '2025-10-24 09:00:00+05:30', '2025-11-24 09:00:00+05:30', 37000,  35000,  900,  2900, '2025-10-24 09:00:00+05:30', NOW(), true);

-- November 2025
INSERT INTO quotations (id, tenant_id, customer_id, status, date_created, valid_until, total, subtotal, discount, tax, created_on, updated_on, is_active)
VALUES
  (gen_random_uuid()::text, tid, c5, 'Converted', '2025-11-03 09:00:00+05:30', '2025-12-03 09:00:00+05:30', 135000, 128000, 3500, 10500, '2025-11-03 09:00:00+05:30', NOW(), true),
  (gen_random_uuid()::text, tid, c6, 'Approved',  '2025-11-10 10:30:00+05:30', '2025-12-10 10:30:00+05:30', 82000,  77000,  2200, 7200,  '2025-11-10 10:30:00+05:30', NOW(), true),
  (gen_random_uuid()::text, tid, c1, 'Draft',     '2025-11-18 13:00:00+05:30', '2025-12-18 13:00:00+05:30', 57000,  54000,  1400, 4400,  '2025-11-18 13:00:00+05:30', NOW(), true),
  (gen_random_uuid()::text, tid, c2, 'Rejected',  '2025-11-25 09:00:00+05:30', '2025-12-25 09:00:00+05:30', 34000,  32000,  900,  2900,  '2025-11-25 09:00:00+05:30', NOW(), true);

-- December 2025
INSERT INTO quotations (id, tenant_id, customer_id, status, date_created, valid_until, total, subtotal, discount, tax, created_on, updated_on, is_active)
VALUES
  (gen_random_uuid()::text, tid, c3, 'Converted', '2025-12-02 09:00:00+05:30', '2026-01-02 09:00:00+05:30', 160000, 152000, 4500, 12500, '2025-12-02 09:00:00+05:30', NOW(), true),
  (gen_random_uuid()::text, tid, c4, 'Approved',  '2025-12-09 10:00:00+05:30', '2026-01-09 10:00:00+05:30', 74000,  70000,  2000, 6000,  '2025-12-09 10:00:00+05:30', NOW(), true),
  (gen_random_uuid()::text, tid, c5, 'Sent',      '2025-12-16 13:00:00+05:30', '2026-01-16 13:00:00+05:30', 103000, 97000,  2700, 8700,  '2025-12-16 13:00:00+05:30', NOW(), true),
  (gen_random_uuid()::text, tid, c6, 'Rejected',  '2025-12-23 09:00:00+05:30', '2026-01-23 09:00:00+05:30', 43000,  40000,  1100, 4100,  '2025-12-23 09:00:00+05:30', NOW(), true);

-- January 2026
INSERT INTO quotations (id, tenant_id, customer_id, status, date_created, valid_until, total, subtotal, discount, tax, created_on, updated_on, is_active)
VALUES
  (gen_random_uuid()::text, tid, c1, 'Converted', '2026-01-05 09:00:00+05:30', '2026-02-05 09:00:00+05:30', 115000, 109000, 3000, 9000,  '2026-01-05 09:00:00+05:30', NOW(), true),
  (gen_random_uuid()::text, tid, c2, 'Approved',  '2026-01-12 10:00:00+05:30', '2026-02-12 10:00:00+05:30', 79000,  75000,  2000, 6000,  '2026-01-12 10:00:00+05:30', NOW(), true),
  (gen_random_uuid()::text, tid, c3, 'Sent',      '2026-01-19 13:00:00+05:30', '2026-02-19 13:00:00+05:30', 52000,  49000,  1300, 4300,  '2026-01-19 13:00:00+05:30', NOW(), true),
  (gen_random_uuid()::text, tid, c4, 'Draft',     '2026-01-26 09:00:00+05:30', '2026-02-26 09:00:00+05:30', 134000, 127000, 3700, 10700, '2026-01-26 09:00:00+05:30', NOW(), true);

-- February 2026
INSERT INTO quotations (id, tenant_id, customer_id, status, date_created, valid_until, total, subtotal, discount, tax, created_on, updated_on, is_active)
VALUES
  (gen_random_uuid()::text, tid, c5, 'Converted', '2026-02-03 09:00:00+05:30', '2026-03-03 09:00:00+05:30', 96000,  91000,  2500, 7500,  '2026-02-03 09:00:00+05:30', NOW(), true),
  (gen_random_uuid()::text, tid, c6, 'Approved',  '2026-02-10 10:30:00+05:30', '2026-03-10 10:30:00+05:30', 68000,  64000,  1800, 5800,  '2026-02-10 10:30:00+05:30', NOW(), true),
  (gen_random_uuid()::text, tid, c1, 'Sent',      '2026-02-17 13:00:00+05:30', '2026-03-17 13:00:00+05:30', 142000, 135000, 4000, 11000, '2026-02-17 13:00:00+05:30', NOW(), true),
  (gen_random_uuid()::text, tid, c2, 'Rejected',  '2026-02-24 09:00:00+05:30', '2026-03-24 09:00:00+05:30', 38000,  36000,  1000, 3000,  '2026-02-24 09:00:00+05:30', NOW(), true);

-- March 2026
INSERT INTO quotations (id, tenant_id, customer_id, status, date_created, valid_until, total, subtotal, discount, tax, created_on, updated_on, is_active)
VALUES
  (gen_random_uuid()::text, tid, c3, 'Converted', '2026-03-04 09:00:00+05:30', '2026-04-04 09:00:00+05:30', 175000, 166000, 5000, 14000, '2026-03-04 09:00:00+05:30', NOW(), true),
  (gen_random_uuid()::text, tid, c4, 'Approved',  '2026-03-11 10:00:00+05:30', '2026-04-11 10:00:00+05:30', 83000,  78000,  2200, 7200,  '2026-03-11 10:00:00+05:30', NOW(), true),
  (gen_random_uuid()::text, tid, c5, 'Sent',      '2026-03-18 13:00:00+05:30', '2026-04-18 13:00:00+05:30', 107000, 101000, 2800, 8800,  '2026-03-18 13:00:00+05:30', NOW(), true),
  (gen_random_uuid()::text, tid, c6, 'Draft',     '2026-03-25 09:00:00+05:30', '2026-04-25 09:00:00+05:30', 61000,  58000,  1600, 4600,  '2026-03-25 09:00:00+05:30', NOW(), true);

-- April 2026
INSERT INTO quotations (id, tenant_id, customer_id, status, date_created, valid_until, total, subtotal, discount, tax, created_on, updated_on, is_active)
VALUES
  (gen_random_uuid()::text, tid, c1, 'Converted', '2026-04-02 09:00:00+05:30', '2026-05-02 09:00:00+05:30', 128000, 122000, 3500, 9500,  '2026-04-02 09:00:00+05:30', NOW(), true),
  (gen_random_uuid()::text, tid, c2, 'Approved',  '2026-04-09 10:30:00+05:30', '2026-05-09 10:30:00+05:30', 87000,  82000,  2300, 7300,  '2026-04-09 10:30:00+05:30', NOW(), true),
  (gen_random_uuid()::text, tid, c3, 'Sent',      '2026-04-16 13:30:00+05:30', '2026-05-16 13:30:00+05:30', 63000,  59000,  1700, 5700,  '2026-04-16 13:30:00+05:30', NOW(), true),
  (gen_random_uuid()::text, tid, c4, 'Rejected',  '2026-04-23 09:00:00+05:30', '2026-05-23 09:00:00+05:30', 44000,  41000,  1200, 4200,  '2026-04-23 09:00:00+05:30', NOW(), true),
  (gen_random_uuid()::text, tid, c5, 'Draft',     '2026-04-29 11:00:00+05:30', '2026-05-29 11:00:00+05:30', 151000, 143000, 4200, 12200, '2026-04-29 11:00:00+05:30', NOW(), true);

-- May 2026
INSERT INTO quotations (id, tenant_id, customer_id, status, date_created, valid_until, total, subtotal, discount, tax, created_on, updated_on, is_active)
VALUES
  (gen_random_uuid()::text, tid, c6, 'Converted', '2026-05-03 09:00:00+05:30', '2026-06-03 09:00:00+05:30', 118000, 112000, 3200, 9200,  '2026-05-03 09:00:00+05:30', NOW(), true),
  (gen_random_uuid()::text, tid, c1, 'Approved',  '2026-05-09 10:00:00+05:30', '2026-06-09 10:00:00+05:30', 76000,  72000,  2000, 6000,  '2026-05-09 10:00:00+05:30', NOW(), true),
  (gen_random_uuid()::text, tid, c2, 'Sent',      '2026-05-15 13:00:00+05:30', '2026-06-15 13:00:00+05:30', 165000, 157000, 4700, 12700, '2026-05-15 13:00:00+05:30', NOW(), true),
  (gen_random_uuid()::text, tid, c3, 'Rejected',  '2026-05-21 09:30:00+05:30', '2026-06-21 09:30:00+05:30', 47000,  44000,  1300, 4300,  '2026-05-21 09:30:00+05:30', NOW(), true),
  (gen_random_uuid()::text, tid, c4, 'Draft',     '2026-05-28 11:00:00+05:30', '2026-06-28 11:00:00+05:30', 91000,  86000,  2400, 7400,  '2026-05-28 11:00:00+05:30', NOW(), true);

-- June 2026
INSERT INTO quotations (id, tenant_id, customer_id, status, date_created, valid_until, total, subtotal, discount, tax, created_on, updated_on, is_active)
VALUES
  (gen_random_uuid()::text, tid, c5, 'Converted', '2026-06-04 09:00:00+05:30', '2026-07-04 09:00:00+05:30', 137000, 130000, 3800, 10800, '2026-06-04 09:00:00+05:30', NOW(), true),
  (gen_random_uuid()::text, tid, c6, 'Approved',  '2026-06-10 10:30:00+05:30', '2026-07-10 10:30:00+05:30', 104000, 98000,  2800, 8800,  '2026-06-10 10:30:00+05:30', NOW(), true),
  (gen_random_uuid()::text, tid, c1, 'Sent',      '2026-06-16 13:00:00+05:30', '2026-07-16 13:00:00+05:30', 82000,  77000,  2200, 7200,  '2026-06-16 13:00:00+05:30', NOW(), true),
  (gen_random_uuid()::text, tid, c2, 'Draft',     '2026-06-22 09:30:00+05:30', '2026-07-22 09:30:00+05:30', 197000, 187000, 5500, 15500, '2026-06-22 09:30:00+05:30', NOW(), true),
  (gen_random_uuid()::text, tid, c3, 'Rejected',  '2026-06-28 11:00:00+05:30', '2026-07-28 11:00:00+05:30', 53000,  50000,  1400, 4400,  '2026-06-28 11:00:00+05:30', NOW(), true);

-- July 2026 (current month)
INSERT INTO quotations (id, tenant_id, customer_id, status, date_created, valid_until, total, subtotal, discount, tax, created_on, updated_on, is_active)
VALUES
  (gen_random_uuid()::text, tid, c4, 'Sent',  '2026-07-01 09:00:00+05:30', '2026-08-01 09:00:00+05:30', 156000, 148000, 4300, 12300, '2026-07-01 09:00:00+05:30', NOW(), true),
  (gen_random_uuid()::text, tid, c5, 'Draft', '2026-07-03 11:00:00+05:30', '2026-08-03 11:00:00+05:30', 88000,  83000,  2300, 7300,  '2026-07-03 11:00:00+05:30', NOW(), true);

END $$;
