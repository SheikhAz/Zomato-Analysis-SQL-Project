SELECT * FROM customers;
SELECT * FROM restaurants;
SELECT * FROM riders;
SELECT * FROM orders;
SELECT * FROM deliveries;


--! CHECKING FOR NULL VALUES

SELECT COUNT(*) FROM customers
WHERE customer_id IS NULL OR
customer_name IS NULL OR reg_date IS NULL;


SELECT COUNT(*) FROM restaurants
WHERE restaurant_id IS NULL OR
restaurant_name IS NULL OR city IS NULL
OR opening_hours IS NULL OR closing_hours IS NUll;

SELECT COUNT(*) FROM orders
WHERE order_id IS NULL OR
order_item IS NULL OR customer_id IS NULL
OR restaurant_id IS NULL OR order_time IS NUll
OR order_status IS NULL OR total_amount IS NULL;


SELECT COUNT(*) FROM riders
WHERE rider_id IS NULL OR
rider_name IS NULL;


SELECT COUNT(*) FROM deliveries
WHERE delivery_id IS NULL OR
delivery_status IS NULL OR delivery_time IS NULL
OR order_id IS NULL OR rider_id IS NULL;

