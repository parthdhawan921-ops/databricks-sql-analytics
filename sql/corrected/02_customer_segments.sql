-- Fixes ../course/02_customer_analysis_view.sql:
-- real orders, net sales (no tax or shipping) and segments by rank instead of a flat EUR 1,000.

CREATE OR REPLACE VIEW workspace.default.customer_segments AS
WITH spend AS (
    SELECT c.customer_id,
           c.country_code,
           COUNT(DISTINCT o.order_number)                            AS total_orders,
           COUNT(o.order_id)                                         AS order_lines,
           ROUND(SUM(o.line_subtotal_amount - o.discount_amount), 2) AS net_sales,
           ROUND(SUM(o.total_amount), 2)                             AS paid_incl_tax_shipping
    FROM workspace.default.customers AS c
    LEFT JOIN workspace.default.orders AS o
        ON c.customer_id = o.customer_id
    GROUP BY c.customer_id, c.country_code
)
SELECT *,
       CASE WHEN NTILE(10) OVER (ORDER BY net_sales) >= 9 THEN 'Top 20%'
            WHEN NTILE(10) OVER (ORDER BY net_sales) >= 6 THEN 'Middle 30%'
            ELSE 'Bottom 50%'
       END AS customer_segment
FROM spend;

SELECT customer_segment,
       COUNT(*)                 AS customers,
       ROUND(SUM(net_sales), 0) AS net_sales,
       ROUND(SUM(net_sales) / SUM(SUM(net_sales)) OVER () * 100, 1) AS share_pct
FROM workspace.default.customer_segments
GROUP BY customer_segment
ORDER BY net_sales DESC;
-- Expected: Top 20% = 160 customers, 900,673 (59.9%); Middle 30% = 240, 409,455 (27.2%);
--           Bottom 50% = 400, 193,324 (12.9%).
