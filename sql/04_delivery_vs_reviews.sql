-- Do late deliveries hurt customer satisfaction?
SELECT CASE WHEN is_late THEN 'Late' ELSE 'On time' END AS delivery,
       COUNT(*)                                          AS orders,
       ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 1) AS pct_orders,
       ROUND(AVG(review_score), 2)                       AS avg_review,
       ROUND(100.0 * AVG(CASE WHEN review_score <= 2 THEN 1 ELSE 0 END), 1) AS pct_bad_reviews
FROM base_orders
WHERE review_score IS NOT NULL
GROUP BY 1;
