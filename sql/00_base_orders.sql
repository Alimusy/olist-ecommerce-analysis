-- Clean base table: delivered orders only, Jan 2017 to Aug 2018 (the months with complete data).
-- One row per order, with order value, delivery timing and review score attached.
CREATE OR REPLACE TABLE base_orders AS
WITH items AS (
    SELECT order_id,
           SUM(price)         AS product_value,
           SUM(freight_value) AS freight_value,
           COUNT(*)           AS n_items
    FROM order_items
    GROUP BY order_id
),
reviews AS (
    -- a few orders have more than one review, so keep the latest
    SELECT order_id, review_score
    FROM order_reviews
    QUALIFY ROW_NUMBER() OVER (PARTITION BY order_id ORDER BY review_answer_timestamp DESC) = 1
)
SELECT o.order_id,
       c.customer_unique_id,
       c.customer_state,
       o.order_purchase_timestamp                         AS purchased_at,
       DATE_TRUNC('month', o.order_purchase_timestamp)    AS order_month,
       i.product_value,
       i.freight_value,
       i.product_value + i.freight_value                  AS order_value,
       i.n_items,
       DATE_DIFF('day', o.order_purchase_timestamp, o.order_delivered_customer_date) AS delivery_days,
       o.order_delivered_customer_date > o.order_estimated_delivery_date + INTERVAL 1 DAY AS is_late,
       r.review_score
FROM orders o
JOIN customers c USING (customer_id)
JOIN items i     USING (order_id)
LEFT JOIN reviews r USING (order_id)
WHERE o.order_status = 'delivered'
  AND o.order_delivered_customer_date IS NOT NULL
  AND o.order_purchase_timestamp >= '2017-01-01'
  AND o.order_purchase_timestamp <  '2018-09-01';
