-- When do people shop? Orders by day of week and hour.
SELECT DAYNAME(purchased_at) AS weekday,
       ISODOW(purchased_at)  AS dow,
       HOUR(purchased_at)    AS hour,
       COUNT(*)              AS orders
FROM base_orders
GROUP BY 1, 2, 3
ORDER BY dow, hour;
