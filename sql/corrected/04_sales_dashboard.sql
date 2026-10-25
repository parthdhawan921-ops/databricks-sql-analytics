-- Fixes ../course/04_dashboard_dataset.sql: adds order_number, net sales, cost and the
-- customer segment, so dashboard counters can count real orders and sum real sales.

CREATE OR REPLACE VIEW workspace.default.sales_dashboard AS
SELECT o.order_id,
       o.order_number,
       o.order_at,
       DATE_TRUNC('MONTH', o.order_at)            AS order_month,
       o.quantity,
       o.line_subtotal_amount - o.discount_amount AS net_sales,
       o.total_amount                             AS paid_incl_tax_shipping,
       o.quantity * p.unit_cost                   AS cost,
       p.product_name,
       p.category,
       p.brand,
       s.store_name,
       s.store_type,
       s.country_code                             AS store_country,
       c.country_code                             AS customer_country,
       cs.customer_segment
FROM workspace.default.orders AS o
LEFT JOIN workspace.default.products          AS p  ON o.product_id  = p.product_id
LEFT JOIN workspace.default.stores            AS s  ON o.store_id    = s.store_id
LEFT JOIN workspace.default.customers         AS c  ON o.customer_id = c.customer_id
LEFT JOIN workspace.default.customer_segments AS cs ON o.customer_id = cs.customer_id;

-- Headline KPIs, as the dashboard counters should show them.
SELECT COUNT(DISTINCT order_number)                                   AS orders,
       ROUND(SUM(net_sales), 2)                                       AS net_sales,
       ROUND(SUM(net_sales) / COUNT(DISTINCT order_number), 2)        AS avg_order_value,
       ROUND((SUM(net_sales) - SUM(cost)) / SUM(net_sales) * 100, 1)  AS gross_margin_pct
FROM workspace.default.sales_dashboard;
-- Expected: 2,453 orders, 1,503,452.30 net sales, 612.90 average order value, 25.8% margin.
-- The course dataset would show 4,494 "orders" and 1,829,662.23 in "sales".

-- Breakdowns used on the dashboard.
SELECT category, ROUND(SUM(net_sales), 0) AS net_sales,
       ROUND(SUM(net_sales) / SUM(SUM(net_sales)) OVER () * 100, 1) AS share_pct
FROM workspace.default.sales_dashboard
GROUP BY category ORDER BY net_sales DESC;

SELECT store_type, ROUND(SUM(net_sales) / SUM(SUM(net_sales)) OVER () * 100, 1) AS share_pct
FROM workspace.default.sales_dashboard
GROUP BY store_type;

SELECT YEAR(order_at) AS order_year, COUNT(DISTINCT order_number) AS orders,
       ROUND(SUM(net_sales), 0) AS net_sales
FROM workspace.default.sales_dashboard
GROUP BY YEAR(order_at) ORDER BY order_year;
