-- Course version: chapter 2, customer analysis view.
-- Issues, fixed in ../corrected/02_customer_segments.sql:
--   * COUNT(o.order_id) counts order lines, not orders (4,494 lines vs 2,453 orders).
--   * total_amount includes tax and shipping, so "spent" is not sales.
--   * A flat EUR 1,000 cut labels 59% of customers as VIP.
--   * Named "mview", but it is a plain view, not a materialized view.

CREATE OR REPLACE VIEW workspace.default.customers_analysis_mview AS
SELECT
    c.customer_id,
    c.country_code,
    COUNT(o.order_id) AS total_orders,
    ROUND(COALESCE(SUM(o.total_amount), 0), 2) AS total_spent,
    CASE
        WHEN COALESCE(SUM(o.total_amount), 0) > 1000
            THEN 'VIP'
        ELSE 'Regular'
    END AS customer_segment
FROM workspace.default.customers AS c
LEFT JOIN workspace.default.orders AS o
    ON c.customer_id = o.customer_id
GROUP BY
    c.customer_id,
    c.country_code;
