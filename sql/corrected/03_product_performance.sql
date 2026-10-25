-- Fixes ../course/03_product_performance.sql:
-- real orders, units, net sales, gross margin, and a top-20% segment by rank.

CREATE OR REPLACE VIEW workspace.default.product_performance AS
WITH perf AS (
    SELECT p.product_id,
           p.product_name,
           p.category,
           p.brand,
           COUNT(DISTINCT o.order_number)                            AS total_orders,
           COALESCE(SUM(o.quantity), 0)                              AS units,
           ROUND(COALESCE(SUM(o.line_subtotal_amount - o.discount_amount), 0), 2) AS net_sales,
           ROUND(COALESCE(SUM(o.line_subtotal_amount - o.discount_amount
                              - p.unit_cost * o.quantity), 0), 2)    AS gross_margin
    FROM workspace.default.products AS p
    LEFT JOIN workspace.default.orders AS o
        ON p.product_id = o.product_id
    GROUP BY p.product_id, p.product_name, p.category, p.brand
)
SELECT *,
       CASE WHEN NTILE(5) OVER (ORDER BY net_sales) = 5 THEN 'Top 20%' ELSE 'Other 80%' END
           AS product_segment
FROM perf;

SELECT product_segment,
       COUNT(*) AS products,
       ROUND(SUM(net_sales) / SUM(SUM(net_sales)) OVER () * 100, 1) AS share_of_net_sales_pct
FROM workspace.default.product_performance
GROUP BY product_segment;
-- Expected: Top 20% = 50 products and 53.4% of net sales.
