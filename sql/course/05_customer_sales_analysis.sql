-- Course version: chapter 3 exercise, customer sales analysis.
-- Issue, fixed in ../corrected/05_customer_sales.sql: grouping by order_at gives one row per
-- customer per order time, so COUNT(DISTINCT customer_id) is always 1 and
-- "avg_sales_per_customer" just repeats each row's total.

SELECT
    c.customer_id,
    c.country_code,
    o.order_at,
    COUNT(o.order_id) AS total_orders,
    ROUND(COALESCE(SUM(o.total_amount), 0), 2) AS total_sales,
    ROUND(
        COALESCE(SUM(o.total_amount), 0)
        / NULLIF(COUNT(DISTINCT c.customer_id), 0),
        2
    ) AS avg_sales_per_customer
FROM workspace.default.customers AS c
LEFT JOIN workspace.default.orders AS o
    ON c.customer_id = o.customer_id
GROUP BY
    c.customer_id,
    c.country_code,
    o.order_at
ORDER BY o.order_at;
