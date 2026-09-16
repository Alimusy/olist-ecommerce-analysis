-- Where are deliveries slowest? States with at least 500 orders.
SELECT customer_state,
       COUNT(*)                                   AS orders,
       ROUND(AVG(delivery_days), 1)               AS avg_delivery_days,
       ROUND(100.0 * AVG(is_late::INT), 1)        AS pct_late,
       ROUND(AVG(freight_value / NULLIF(order_value,0)) * 100, 1) AS freight_pct_of_order
FROM base_orders
GROUP BY 1
HAVING COUNT(*) >= 500
ORDER BY avg_delivery_days DESC;
