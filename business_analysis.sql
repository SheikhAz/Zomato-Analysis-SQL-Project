SELECT * FROM customers;
SELECT * FROM restaurants;
SELECT * FROM riders;
SELECT * FROM orders;
SELECT * FROM deliveries;


--! Q1  Write the Query to Find the top 5 most frequently ordered dishes by customer called 'Arjun Mehta' in last 1 Years ?

SELECT
    o.order_item AS dish_name,
    COUNT(*) AS total_orders
FROM orders AS o
INNER JOIN customers AS c
    ON o.customer_id = c.customer_id
WHERE c.customer_name = 'Arjun Mehta'
  AND o.order_date >= CURRENT_DATE - INTERVAL '1 year'
  AND o.order_date <= CURRENT_DATE
GROUP BY o.order_item
ORDER BY total_orders DESC
LIMIT 5;


-- ! Q2 Popular Time Slot
-- Identity the time slots during the most ordered are placed based on 2 hour intervals ?

SELECT
FLOOR(EXTRACT(HOUR FROM order_time)/2) * 2 AS start_time,
COUNT(*) AS total_order
FROM orders
GROUP BY start_time
ORDER BY total_order DESC;


-- ! Q3 Order Value Analysis
-- find the average order value per customers who has placed more than 15 orders and return customer_name , aov( average order value)

SELECT
c.customer_name ,ROUND(SUM(o.total_amount),2) AS total_value,ROUND(AVG(o.total_amount),2) AS average_order_value
FROM orders AS o
INNER JOIN customers AS c
    ON o.customer_id = c.customer_id
GROUP BY c.customer_name,c.customer_id
HAVING COUNT(o.order_id) > 7
ORDER BY average_order_value DESC;


-- ! Q4 High-Value Customers
-- List the customers who have spent more than 1k in total on food orders.
-- return customer_name and customer_id

SELECT
c.customer_id,c.customer_name
FROM orders AS o
INNER JOIN customers AS c
 ON o.customer_id = c.customer_id
GROUP BY c.customer_id , c.customer_name
HAVING SUM(o.total_amount) > 15000;


-- ! Q5 Orders Without Delivery
-- write a query that are placed but not deleivered and return each restaurants name , city and number of not delivered orders.


SELECT
r.restaurant_name , r.city , COUNT(o.order_id) AS number_of_orders
FROM orders AS o
INNER JOIN restaurants AS r
    ON o.restaurant_id = r.restaurant_id
INNER JOIN deliveries AS d
    ON o.order_id = d.order_id
WHERE d.delivery_status = 'Not Delivered'
GROUP BY r.restaurant_name,r.city;


-- ! Q6 Restaurants Revenues Ranking
-- Rank restaurants by thier total revenues from last year , including their name , total revenues and rank within their city.

WITH ranked_table AS(
    SELECT
    r.restaurant_name , r.city ,
    ROUND(SUM(o.total_amount),2) AS total_revenues,
    RANK() OVER(PARTITION BY  r.city ORDER BY SUM(o.total_amount)) AS city_rank
    FROM orders AS o
    INNER JOIN restaurants AS r
        ON o.restaurant_id = r.restaurant_id
    WHERE o.order_date >= CURRENT_DATE - INTERVAL '1 year'
    AND o.order_date <= CURRENT_DATE
    GROUP BY r.restaurant_name ,r.city
    ORDER BY  city_rank , total_revenues DESC
)
SELECT * FROM ranked_table WHERE city_rank = '1'
ORDER BY city;



-- ! Q7 Most Popular Dish by City 
-- Identity the most popular dish in each city based on the number of order.

WITH ranked_dishes AS (
    SELECT
        r.city,
        o.order_item AS dish_name,
        COUNT(o.order_id) AS total_orders,
        ROW_NUMBER() OVER (
            PARTITION BY r.city
            ORDER BY COUNT(o.order_id) DESC ,o.order_item ASC
        ) AS ranked_dish
    FROM orders AS o
    INNER JOIN restaurants AS r
        ON o.restaurant_id = r.restaurant_id
    GROUP BY
        r.city,
        o.order_item
)
SELECT *
FROM ranked_dishes
WHERE ranked_dish = 1
ORDER BY city;

-- ! Q8 Customer Churn
-- find the customer who havn't placed an order in 2026 but did in 2025

SELECT
    c.customer_id,
    c.customer_name
FROM customers AS c
WHERE EXISTS (
    SELECT 1
    FROM orders o
    WHERE o.customer_id = c.customer_id
    AND o.order_date >= DATE '2025-01-01'
    AND o.order_date < DATE '2026-01-01'
)
AND NOT EXISTS(
    SELECT 1
    FROM orders o
    WHERE o.customer_id = c.customer_id
    AND o.order_date >= DATE '2026-01-01'
    AND o.order_date < DATE '2027-01-01'
);

-- ! Q9 Cancellation Rate Comparison
-- calculate and compare the order cancellation rate for each restaurants between the current year and the previous year

WITH cancellation_rate AS (
    SELECT
        r.restaurant_id,
        r.restaurant_name,

        COUNT(*) FILTER (
            WHERE o.order_date >= DATE '2025-01-01'
              AND o.order_date < DATE '2026-01-01'
              AND o.order_status = 'Cancelled'
        ) AS cancelled_orders_2025,

        COUNT(*) FILTER (
            WHERE o.order_date >= DATE '2025-01-01'
              AND o.order_date < DATE '2026-01-01'
        ) AS total_orders_2025,

        COUNT(*) FILTER (
            WHERE o.order_date >= DATE '2026-01-01'
              AND o.order_date < DATE '2027-01-01'
              AND o.order_status = 'Cancelled'
        ) AS cancelled_orders_2026,

        COUNT(*) FILTER (
            WHERE o.order_date >= DATE '2026-01-01'
              AND o.order_date < DATE '2027-01-01'
        ) AS total_orders_2026

    FROM orders AS o
    INNER JOIN restaurants AS r
        ON o.restaurant_id = r.restaurant_id
    WHERE o.order_date >= DATE '2025-01-01'
      AND o.order_date < DATE '2027-01-01'
    GROUP BY r.restaurant_id, r.restaurant_name
)
SELECT
    restaurant_name,
    cancelled_orders_2025,
    total_orders_2025,
    cancelled_orders_2026,
    total_orders_2026,
    ROUND(
        100.0 * cancelled_orders_2025
        / NULLIF(total_orders_2025, 0), 2
    ) AS cancellation_rate_2025,
    ROUND(
        100.0 * cancelled_orders_2026
        / NULLIF(total_orders_2026, 0), 2
    ) AS cancellation_rate_2026

FROM cancellation_rate
ORDER BY restaurant_name;


-- ! Q10 Rider Average Delivery Time:
-- Determine each riders average delivery time

SELECT
    r.rider_id,
    r.rider_name,
    ROUND(
        AVG(EXTRACT(EPOCH FROM (d.delivery_time - o.order_time + 
        CASE WHEN d.delivery_time < o.order_time THEN INTERVAL '1 day'
        ELSE INTERVAL '0 day' 
        END))/60) 
    ,2) AS average_delivery_time
FROM deliveries AS d
INNER JOIN riders AS r
    ON d.rider_id = r.rider_id
INNER JOIN orders AS o
    ON d.order_id = o.order_id
WHERE
    d.delivery_status = 'Delivered'
GROUP BY 
    r.rider_name,
    r.rider_id
ORDER BY
    r.rider_name;

-- ! Q11 Monthly reaturants Growth Ratio:
-- calculate each restaurants growth ratio based on the total numbers of delivered orders since it joining.


WITH monthly_growth AS (
    SELECT
        o.restaurant_id,
        DATE_TRUNC('month',o.order_date)::date AS month,
        COUNT(DISTINCT o.order_id) AS curr_month_orders
    FROM orders AS o
    INNER JOIN deliveries AS d
        ON o.order_id = d.order_id
    WHERE
        d.delivery_status = 'Delivered'
    GROUP BY
        o.restaurant_id,
        DATE_TRUNC('month',o.order_date)::date
),
restaurants_growth AS (
    SELECT
        restaurant_id,
        month,
        curr_month_orders,
        LAG(curr_month_orders) OVER(
            PARTITION BY restaurant_id
            ORDER BY month
        ) AS prev_month_orders
    FROM monthly_growth
)
SELECT
    restaurant_id,
    TO_CHAR(month,'YYYY-MM') AS months,
    curr_month_orders,
    prev_month_orders,
    ROUND(
        100*((curr_month_orders::numeric - prev_month_orders::numeric ) /
        NULLIF(prev_month_orders::numeric , 0))    
    ,2) AS growth
FROM restaurants_growth
ORDER BY
restaurant_id,months;


-- ! Q12 Customer Segmentation:
-- segment customer into 'Gold' and 'Silver' groups based on the total spending compared to average order values. if customer total spending exceeds the aov
-- labels them AS 'Gold' otherwise label them 'Silver'.
-- Write the SQL query to Determine each segment total number of orders and total revenues ?


SELECT
    c.customer_id,
    c.customer_name,
    COUNT(o.order_id) AS total_orders,
    ROUND(
        SUM(o.total_amount)
    ,2) AS total_spend,
    CASE WHEN
        SUM(o.total_amount) > (SELECT AVG(total_amount) FROM orders)
        THEN 'Gold'
        ELSE 'Silver'
    END as category
FROM orders AS o
INNER JOIN customers AS c
    ON o.customer_id = c.customer_id
GROUP BY
    c.customer_id,
    c.customer_name

WITH customer_category AS(
    SELECT
        c.customer_id,
        c.customer_name,
        COUNT(o.order_id) AS total_orders,
        ROUND(
            SUM(o.total_amount)
        ,2) AS total_spend,
        CASE WHEN
            SUM(o.total_amount) > (SELECT AVG(total_amount) FROM orders)
            THEN 'Gold'
            ELSE 'Silver'
        END as category
    FROM orders AS o
    INNER JOIN customers AS c
        ON o.customer_id = c.customer_id
    GROUP BY
        c.customer_id,
        c.customer_name
)
SELECT
    category,
    COUNT(category) AS category_count,
    SUM(total_spend) AS total_spend_by_cu
FROM customer_category
GROUP BY
    category;



-- ! Q13 Rider Monthly Earning
-- calculate each riders total monthly earning assuming they earns 8% of the order amount.


SELECT
    r.rider_id,
    r.rider_name,
    TO_CHAR(o.order_date , 'YYYY-MM') as months,
    SUM(total_amount)*0.08 AS monthly_revenues

FROM riders AS r
INNER JOIN deliveries AS d 
    ON r.rider_id = d.rider_id
INNER JOIN orders AS o 
    ON d.order_id = o.order_id
GROUP BY
    r.rider_id,
    r.rider_name,
    o.order_date
ORDER BY 
    r.rider_id

-- ! Q14 Order Frequency by Day:
-- Analyze order frequency per day of the week and identify the peak day for each restaurants.


WITH order_frequency AS(
    SELECT
        r.restaurant_name,
        TO_CHAR(o.order_date,'Day') as day,
        COUNT(o.order_id) AS total_orders,
        RANK() OVER(PARTITION BY r.restaurant_name ORDER BY COUNT(o.order_id) DESC) as rank
    FROM orders AS o 
    INNER JOIN restaurants AS r
        ON o.restaurant_id = r.restaurant_id
    GROUP BY
        r.restaurant_name,
        day
    ORDER BY
        total_orders DESC
)
SELECT *
FROM order_frequency
WHERE rank = '1';


-- ! Q15 Customer Lifetime Values(CLV)
-- calculate the total revenues generated vy each customer over all their order.

SELECT
    o.customer_id,
    SUM(o.total_amount) AS total_revenue
FROM orders AS o
INNER JOIN customers AS c
    ON o.customer_id = c.customer_id
GROUP BY
    o.customer_id
ORDER BY
    o.customer_id