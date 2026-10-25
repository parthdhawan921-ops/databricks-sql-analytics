-- Course version: chapter 2 exercise, product performance.
-- Issues, fixed in ../corrected/03_product_performance.sql:
--   * COUNT(o.order_id) counts order lines, not orders.
--   * total_amount includes tax and shipping.
--   * A flat EUR 1,000 cut labels 94% of products "High Performance".

SELECT
    p.product_id,
    p.product_name,
    p.category,
    COUNT(o.order_id) AS total_orders,
    ROUND(COALESCE(SUM(o.total_amount), 0), 2) AS total_sales,
    CASE
        WHEN COALESCE(SUM(o.total_amount), 0) >= 1000
            THEN 'High Performance'
        ELSE 'Low Performance'
    END AS product_segment
FROM workspace.default.products AS p
LEFT JOIN workspace.default.orders AS o
    ON p.product_id = o.product_id
GROUP BY
    p.product_id,
    p.product_name,
    p.category
ORDER BY total_sales DESC;
