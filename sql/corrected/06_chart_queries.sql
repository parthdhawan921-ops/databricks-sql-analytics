-- Six chart-ready queries for the Databricks SQL Editor (Results -> + -> Visualization).
-- Each runs on the base tables, so no views are needed. Chart settings are in the comment above each.

-- Chart 1. "Order lines are not orders"
-- Bar: X = method, Y = orders (Sum). Data labels on.
SELECT 'Course: COUNT(order_id)' AS method, COUNT(*) AS orders
FROM workspace.default.orders
UNION ALL
SELECT 'Corrected: COUNT(DISTINCT order_number)', COUNT(DISTINCT order_number)
FROM workspace.default.orders;
-- Expected: 4,494 and 2,453.

-- Chart 2. "What total_amount contains"
-- Bar, horizontal: X = label, Y = net_sales, tax, shipping (Sum). Stacking = Stack. Data labels on.
SELECT 'total_amount' AS label,
       ROUND(SUM(line_subtotal_amount - discount_amount), 0) AS net_sales,
       ROUND(SUM(tax_amount), 0)                             AS tax,
       ROUND(SUM(shipping_amount), 0)                        AS shipping
FROM workspace.default.orders;
-- Expected: 1,503,452 + 303,042 + 23,167 = 1,829,662.

-- Chart 3. "Top 20% of customers bring 60% of sales"
-- Bar: X = customer_segment, Y = net_sales (Sum). Data labels on.
WITH spend AS (
    SELECT customer_id, SUM(line_subtotal_amount - discount_amount) AS net_sales
    FROM workspace.default.orders
    GROUP BY customer_id
),
ranked AS (
    SELECT *, NTILE(10) OVER (ORDER BY net_sales) AS decile FROM spend
)
SELECT CASE WHEN decile >= 9 THEN '1. Top 20%'
            WHEN decile >= 6 THEN '2. Middle 30%'
            ELSE '3. Bottom 50%' END AS customer_segment,
       COUNT(*)                 AS customers,
       ROUND(SUM(net_sales), 0) AS net_sales
FROM ranked
GROUP BY 1
ORDER BY 1;
-- Expected: Top 20% 160 customers 900,673; Middle 30% 240 409,455; Bottom 50% 400 193,324.

-- Chart 4. "Top 10 products by net sales"
-- Bar, horizontal: X = product, Y = net_sales (Sum). Data labels on.
SELECT CONCAT(p.product_name, ' (', p.product_id, ')')          AS product,
       ROUND(SUM(o.line_subtotal_amount - o.discount_amount), 0) AS net_sales
FROM workspace.default.orders AS o
JOIN workspace.default.products AS p ON o.product_id = p.product_id
GROUP BY p.product_name, p.product_id
ORDER BY net_sales DESC
LIMIT 10;
-- Expected: NovaTech Smartwatch (P000026) first.

-- Chart 5. "Sales grew every year"
-- Bar: X = order_year, Y = net_sales (Sum). Data labels on. (2022 starts in February.)
SELECT CAST(YEAR(order_at) AS STRING)                         AS order_year,
       COUNT(DISTINCT order_number)                          AS orders,
       ROUND(SUM(line_subtotal_amount - discount_amount), 0) AS net_sales
FROM workspace.default.orders
GROUP BY 1
ORDER BY 1;
-- Expected: 2022 34,828; 2023 161,892; 2024 361,505; 2025 945,228.

-- Chart 6. "Net sales by category"
-- Pie: X = category, Y = net_sales (Sum). Data labels: show percent.
SELECT p.category,
       ROUND(SUM(o.line_subtotal_amount - o.discount_amount), 0) AS net_sales
FROM workspace.default.orders AS o
JOIN workspace.default.products AS p ON o.product_id = p.product_id
GROUP BY p.category
ORDER BY net_sales DESC;
-- Expected: Electronics 39%, Home 24%, Sports 18%, Apparel 12%, Accessories 7%.
