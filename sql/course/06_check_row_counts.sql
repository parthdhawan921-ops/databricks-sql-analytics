-- Course version: confirm every table loaded.
-- Expected: customers 800, orders 4,494, products 250, stores 20.

SELECT 'customers' AS table_name, COUNT(*) AS row_count
FROM workspace.default.customers

UNION ALL

SELECT 'orders', COUNT(*)
FROM workspace.default.orders

UNION ALL

SELECT 'products', COUNT(*)
FROM workspace.default.products

UNION ALL

SELECT 'stores', COUNT(*)
FROM workspace.default.stores;
