-- How does the review score change as delivery takes longer?
SELECT CASE WHEN delivery_days <= 7  THEN '1. Within a week'
            WHEN delivery_days <= 14 THEN '2. 8 to 14 days'
            WHEN delivery_days <= 21 THEN '3. 15 to 21 days'
            WHEN delivery_days <= 30 THEN '4. 22 to 30 days'
            ELSE '5. Over 30 days' END AS delivery_time,
       COUNT(*)                     AS orders,
       ROUND(AVG(review_score), 2)  AS avg_review
FROM base_orders
WHERE review_score IS NOT NULL
GROUP BY 1
ORDER BY 1;
