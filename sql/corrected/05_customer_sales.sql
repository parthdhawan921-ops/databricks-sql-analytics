-- Fixes ../course/05_customer_sales_analysis.sql: one row per customer, not per order time,
-- and average sales per customer measured where it means something: by country.

-- 5a. One row per customer.
SELECT c.customer_id,
       c.country_code,
       COUNT(DISTINCT o.order_number)                                       AS total_orders,
       ROUND(SUM(o.line_subtotal_amount - o.discount_amount), 2)            AS net_sales,
       ROUND(SUM(o.line_subtotal_amount - o.discount_amount)
             / NULLIF(COUNT(DISTINCT o.order_number), 0), 2)                AS avg_order_value,
       MIN(o.order_at)                                                      AS first_order_at,
       MAX(o.order_at)                                                      AS last_order_at
FROM workspace.default.customers AS c
LEFT JOIN workspace.default.orders AS o
    ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.country_code
ORDER BY net_sales DESC;

-- 5b. Average net sales per customer, by customer country.
SELECT c.country_code,
       COUNT(DISTINCT c.customer_id)                                        AS customers,
       COUNT(DISTINCT o.order_number)                                       AS orders,
       ROUND(SUM(o.line_subtotal_amount - o.discount_amount), 2)            AS net_sales,
       ROUND(SUM(o.line_subtotal_amount - o.discount_amount)
             / COUNT(DISTINCT c.customer_id), 2)                            AS net_sales_per_customer
FROM workspace.default.customers AS c
LEFT JOIN workspace.default.orders AS o
    ON c.customer_id = o.customer_id
GROUP BY c.country_code
ORDER BY net_sales DESC;
-- Expected: Italy first (103 customers, 326 orders, 193,464.81);
--           Switzerland has the highest net sales per customer (2,110.20).
