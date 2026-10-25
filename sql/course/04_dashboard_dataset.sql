-- Course version: chapter 3, dataset behind the AI/BI dashboard.
-- Issue, fixed in ../corrected/04_sales_dashboard.sql: there is no order_number or net sales
-- column, so a dashboard counting order_id or summing total_amount overstates orders and sales.

SELECT
    o.order_id,
    o.total_amount,
    o.customer_id,
    o.product_id,
    o.store_id,
    o.order_at,
    o.order_status,
    p.product_name,
    p.category,
    c.country_code AS customer_country,
    s.store_name,
    s.store_type,
    s.country_code AS store_country
FROM workspace.default.orders AS o
LEFT JOIN workspace.default.products AS p
    ON o.product_id = p.product_id
LEFT JOIN workspace.default.customers AS c
    ON o.customer_id = c.customer_id
LEFT JOIN workspace.default.stores AS s
    ON o.store_id = s.store_id;
