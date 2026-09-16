-- RFM segmentation: group customers by Recency, Frequency and Monetary value.
-- Because almost everyone buys only once, frequency is split into 1 vs 2+ orders
-- and recency and monetary are scored into quartiles.
CREATE OR REPLACE TABLE rfm AS
WITH snapshot AS (SELECT MAX(purchased_at) + INTERVAL 1 DAY AS ref FROM base_orders),
per_customer AS (
    SELECT customer_unique_id,
           DATE_DIFF('day', MAX(purchased_at), (SELECT ref FROM snapshot)) AS recency_days,
           COUNT(*)          AS frequency,
           SUM(order_value)  AS monetary
    FROM base_orders
    GROUP BY 1
),
scored AS (
    SELECT *,
           5 - NTILE(4) OVER (ORDER BY recency_days) AS r_score,  -- 4 = most recent
           NTILE(4) OVER (ORDER BY monetary)         AS m_score   -- 4 = highest spend
    FROM per_customer
)
SELECT *,
       CASE
           WHEN frequency >= 2 AND m_score >= 3               THEN 'Loyal high spenders'
           WHEN frequency >= 2                                 THEN 'Repeat buyers'
           WHEN r_score >= 3 AND m_score >= 3                  THEN 'Recent big spenders'
           WHEN r_score >= 3                                   THEN 'Recent low spenders'
           WHEN m_score >= 3                                   THEN 'Lapsed big spenders'
           ELSE 'Lapsed low spenders'
       END AS segment
FROM scored;

SELECT segment,
       COUNT(*)                                             AS customers,
       ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 1)   AS pct_customers,
       ROUND(AVG(recency_days), 0)                          AS avg_recency_days,
       ROUND(AVG(monetary), 2)                              AS avg_spend,
       ROUND(100.0 * SUM(monetary) / SUM(SUM(monetary)) OVER (), 1) AS pct_revenue
FROM rfm
GROUP BY 1
ORDER BY pct_revenue DESC;
