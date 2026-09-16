-- How many customers ever come back for a second order?
WITH per_customer AS (
    SELECT customer_unique_id, COUNT(*) AS n_orders, SUM(order_value) AS spend
    FROM base_orders
    GROUP BY 1
)
SELECT CASE WHEN n_orders = 1 THEN '1 order' WHEN n_orders = 2 THEN '2 orders' ELSE '3+ orders' END AS bucket,
       COUNT(*)                                        AS customers,
       ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS pct_customers,
       ROUND(100.0 * SUM(spend) / SUM(SUM(spend)) OVER (), 2) AS pct_revenue
FROM per_customer
GROUP BY 1
ORDER BY 1;
