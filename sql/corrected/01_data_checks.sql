-- Data checks: what one row of orders means and what total_amount contains.
-- Run in Databricks SQL Editor after ../course/01_create_tables.sql.

-- 1. Grain: one row per order LINE. An order is a distinct order_number.
SELECT COUNT(*)                     AS order_lines,
       COUNT(DISTINCT order_number) AS orders,
       ROUND(COUNT(*) / COUNT(DISTINCT order_number), 2) AS lines_per_order
FROM workspace.default.orders;
-- Expected: 4,494 lines, 2,453 orders, 1.83 lines per order.

-- 2. Money: total_amount = net sales + tax + shipping, on every row.
SELECT ROUND(SUM(line_subtotal_amount - discount_amount), 2) AS net_sales,
       ROUND(SUM(tax_amount), 2)                             AS tax,
       ROUND(SUM(shipping_amount), 2)                        AS shipping,
       ROUND(SUM(total_amount), 2)                           AS total_paid,
       SUM(CASE WHEN ABS(total_amount - (line_subtotal_amount - discount_amount
                                         + tax_amount + shipping_amount)) > 0.01
                THEN 1 ELSE 0 END)                           AS rows_not_reconciling
FROM workspace.default.orders;
-- Expected: net 1,503,452.30 + tax 303,042.47 + shipping 23,167.46 = paid 1,829,662.23; 0 rows off.

-- 3. Status and currency: nothing to filter out.
SELECT order_status, currency_code, COUNT(*) AS order_lines
FROM workspace.default.orders
GROUP BY order_status, currency_code;
-- Expected: one row, delivered / EUR / 4,494.

-- 4. How many customers and products a flat EUR 1,000 cut labels "top".
SELECT 'customers over 1,000' AS check_name,
       ROUND(AVG(CASE WHEN spent > 1000 THEN 1.0 ELSE 0 END) * 100, 1) AS pct_labelled_top
FROM (SELECT customer_id, SUM(total_amount) AS spent
      FROM workspace.default.orders GROUP BY customer_id) AS by_customer
UNION ALL
SELECT 'products 1,000 or more',
       ROUND(AVG(CASE WHEN COALESCE(sales, 0) >= 1000 THEN 1.0 ELSE 0 END) * 100, 1)
FROM (SELECT p.product_id, SUM(o.total_amount) AS sales
      FROM workspace.default.products AS p
      LEFT JOIN workspace.default.orders AS o ON p.product_id = o.product_id
      GROUP BY p.product_id) AS by_product;
-- Expected: customers 59.1%, products 94.4%. A segment that holds most rows is not a segment.

-- 5. Dates: the month inside order_number and orders before a product launched.
SELECT SUM(CASE WHEN SPLIT(o.order_number, '-')[1] <> DATE_FORMAT(o.order_at, 'yyyyMM')
                THEN 1 ELSE 0 END)                            AS order_number_month_differs,
       SUM(CASE WHEN o.order_at < p.launch_date THEN 1 ELSE 0 END) AS sold_before_launch
FROM workspace.default.orders AS o
JOIN workspace.default.products AS p ON o.product_id = p.product_id;
-- Expected: 4,416 lines where the month differs (use order_at, not order_number, for dates)
--           and 377 lines dated before the product's launch_date (flagged, kept).
