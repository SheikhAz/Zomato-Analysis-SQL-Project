CREATE TABLE customers(
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(50),
    reg_date DATE
);

CREATE TABLE restaurants(
    restaurant_id INT PRIMARY KEY,
    restaurant_name VARCHAR(50),
    city VARCHAR(30),
    opening_hours TIME,
    closing_hours TIME
);

CREATE TABLE orders(
    order_id INT PRIMARY KEY,
    customer_id INT REFERENCES customers(customer_id),
    restaurant_id INT REFERENCES restaurants(restaurant_id),
    order_item VARCHAR(100),
    order_date DATE,
    order_time TIME,
    order_status VARCHAR CHECK (order_status in ('Completed','Pending','Cancelled','Refunded')),
    total_amount NUMERIC(10,2)
)

CREATE TABLE deliveries(
    delivery_id INT PRIMARY KEY,
    order_id INT REFERENCES orders(order_id),
    delivery_status VARCHAR(30) CHECK (delivery_status in ('Delivered','Not Delivered','Order')),
    delivery_time TIME,
    rider_id INT
);


CREATE TABLE riders(
    rider_id INT PRIMARY KEY,
    rider_name VARCHAR(50),
    sign_up DATE
);

ALTER TABLE deliveries
ADD CONSTRAINT delivery_rider_fk
FOREIGN KEY (rider_id)
REFERENCES riders(rider_id);