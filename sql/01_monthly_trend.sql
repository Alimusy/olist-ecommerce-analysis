-- How fast is the business growing? Orders, revenue and average order value per month.
SELECT order_month,
       COUNT(*)                     AS orders,
       ROUND(SUM(order_value), 0)   AS revenue,
       ROUND(AVG(order_value), 2)   AS avg_order_value
FROM base_orders
GROUP BY order_month
ORDER BY order_month;
