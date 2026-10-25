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