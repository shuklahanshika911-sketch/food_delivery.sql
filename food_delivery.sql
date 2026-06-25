-- ================================================
-- FOOD DELIVERY ANALYTICS PROJECT
-- Tools: SQL (MySQL/PostgreSQL)
-- By: Hanshika Shukla
-- ================================================

-- TABLE 1: CUSTOMERS
CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100),
    city VARCHAR(50),
    signup_date DATE
);

-- TABLE 2: RESTAURANTS
CREATE TABLE restaurants (
    restaurant_id INT PRIMARY KEY,
    restaurant_name VARCHAR(100),
    cuisine_type VARCHAR(50),
    city VARCHAR(50),
    avg_rating DECIMAL(3,1)
);

-- TABLE 3: ORDERS
CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    restaurant_id INT,
    order_date DATE,
    order_amount DECIMAL(10,2),
    delivery_time_mins INT,
    status VARCHAR(20) -- delivered, cancelled, pending
);

-- ================================================
-- ANALYSIS QUERIES
-- ================================================

-- Q1: Top 5 restaurants by total revenue
SELECT r.restaurant_name, 
       SUM(o.order_amount) AS total_revenue
FROM orders o
JOIN restaurants r ON o.restaurant_id = r.restaurant_id
WHERE o.status = 'delivered'
GROUP BY r.restaurant_name
ORDER BY total_revenue DESC
LIMIT 5;

-- Q2: Monthly order trend
SELECT DATE_FORMAT(order_date, '%Y-%m') AS month,
       COUNT(order_id) AS total_orders,
       SUM(order_amount) AS total_revenue
FROM orders
GROUP BY month
ORDER BY month;

-- Q3: Average delivery time by city
SELECT r.city,
       ROUND(AVG(o.delivery_time_mins), 1) AS avg_delivery_time
FROM orders o
JOIN restaurants r ON o.restaurant_id = r.restaurant_id
WHERE o.status = 'delivered'
GROUP BY r.city
ORDER BY avg_delivery_time;

-- Q4: Cancellation rate by restaurant
SELECT r.restaurant_name,
       COUNT(*) AS total_orders,
       SUM(CASE WHEN o.status = 'cancelled' THEN 1 ELSE 0 END) AS cancelled,
       ROUND(SUM(CASE WHEN o.status = 'cancelled' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS cancellation_rate
FROM orders o
JOIN restaurants r ON o.restaurant_id = r.restaurant_id
GROUP BY r.restaurant_name
ORDER BY cancellation_rate DESC;

-- Q5: Customer segmentation using CASE
SELECT customer_id,
       COUNT(order_id) AS total_orders,
       CASE 
           WHEN COUNT(order_id) >= 10 THEN 'Loyal'
           WHEN COUNT(order_id) BETWEEN 5 AND 9 THEN 'Regular'
           ELSE 'New'
       END AS customer_segment
FROM orders
WHERE status = 'delivered'
GROUP BY customer_id;

-- Q6: Most popular cuisine type
SELECT r.cuisine_type,
       COUNT(o.order_id) AS total_orders
FROM orders o
JOIN restaurants r ON o.restaurant_id = r.restaurant_id
GROUP BY r.cuisine_type
ORDER BY total_orders DESC;

-- Q7: Rank restaurants by revenue using WINDOW FUNCTION
SELECT r.restaurant_name,
       SUM(o.order_amount) AS total_revenue,
       RANK() OVER (ORDER BY SUM(o.order_amount) DESC) AS revenue_rank
FROM orders o
JOIN restaurants r ON o.restaurant_id = r.restaurant_id
WHERE o.status = 'delivered'
GROUP BY r.restaurant_name;
