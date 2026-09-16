-- How do customers pay, and how common are instalments?
SELECT p.payment_type,
       COUNT(DISTINCT p.order_id)                        AS orders,
       ROUND(100.0 * COUNT(DISTINCT p.order_id) / (SELECT COUNT(*) FROM base_orders), 1) AS pct_orders,
       ROUND(AVG(p.payment_value), 2)                    AS avg_payment,
       ROUND(AVG(p.payment_installments), 1)             AS avg_instalments
FROM order_payments p
JOIN base_orders b USING (order_id)
GROUP BY 1
ORDER BY orders DESC;
