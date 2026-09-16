-- Which product categories bring in the most revenue, and how well are they reviewed?
SELECT COALESCE(t.product_category_name_english, p.product_category_name, 'unknown') AS category,
       COUNT(DISTINCT oi.order_id)       AS orders,
       ROUND(SUM(oi.price), 0)           AS revenue,
       ROUND(AVG(oi.price), 2)           AS avg_item_price,
       ROUND(AVG(b.review_score), 2)     AS avg_review
FROM order_items oi
JOIN base_orders b USING (order_id)
LEFT JOIN products p USING (product_id)
LEFT JOIN category_translation t ON p.product_category_name = t.product_category_name
GROUP BY 1
ORDER BY revenue DESC
LIMIT 15;
