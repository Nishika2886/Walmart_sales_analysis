-- Create database
CREATE DATABASE IF NOT EXISTS walmartsalesdata;

-- Use the database (optional depending on environment)
USE walmartsalesdata ;

-- Create table
CREATE TABLE IF NOT EXISTS sales (
    invoice_id VARCHAR(30) NOT NULL PRIMARY KEY,
    branch VARCHAR(5) NOT NULL,
    city VARCHAR(30) NOT NULL,
    customer_type VARCHAR(30) NOT NULL,
    gender VARCHAR(30) NOT NULL,
    product_line VARCHAR(100) NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    quantity INT NOT NULL,
    tax_pct FLOAT(6,4) NOT NULL,
    total DECIMAL(12, 4) NOT NULL,
    date DATETIME NOT NULL,
    time TIME NOT NULL,
    payment VARCHAR(15) NOT NULL,
    cogs DECIMAL(10,2) NOT NULL,
    gross_margin_pct FLOAT(11,9),
    gross_income DECIMAL(12, 4),
    rating FLOAT(2, 1)
);

-- Data inspection
SELECT * FROM sales;

-- Add and populate time_of_day column

ALTER TABLE sales ADD COLUMN time_of_day VARCHAR(20);

SET SQL_SAFE_UPDATES = 0 ;
SHOW COLUMNS FROM SALES ;
UPDATE sales
SET time_of_day = (
    CASE
        WHEN `time` >= '00:00:00' AND `time` < '12:00:00' THEN 'Morning'
        WHEN `time` >= '12:00:00' AND `time` < '16:00:00' THEN 'Afternoon'
        ELSE 'Evening'
    END
);

-- Add and populate day_name column
ALTER TABLE sales ADD COLUMN day_name VARCHAR(10);
UPDATE sales SET day_name = DAYNAME(date);

-- Add and populate month_name column
ALTER TABLE sales ADD COLUMN month_name VARCHAR(10);
UPDATE sales SET month_name = MONTHNAME(date);

-- Unique cities
SELECT DISTINCT city FROM sales;

-- Branches in each city
SELECT DISTINCT city, branch FROM sales;

-- Unique product lines
SELECT DISTINCT product_line FROM sales;

-- Most selling product line
SELECT SUM(quantity) AS qty, product_line
FROM sales
GROUP BY product_line
ORDER BY qty DESC;

-- Total revenue by month
SELECT month_name AS month, SUM(total) AS total_revenue
FROM sales
GROUP BY month_name
ORDER BY total_revenue DESC;

-- Month with largest COGS
SELECT month_name AS month, SUM(cogs) AS cogs
FROM sales
GROUP BY month_name
ORDER BY cogs DESC;

-- Product line with largest revenue
SELECT product_line, SUM(total) AS total_revenue
FROM sales
GROUP BY product_line
ORDER BY total_revenue DESC;

-- City with largest revenue
SELECT branch, city, SUM(total) AS total_revenue
FROM sales
GROUP BY city, branch
ORDER BY total_revenue DESC;

-- Product line with highest average VAT
SELECT product_line, AVG(tax_pct) AS avg_tax
FROM sales
GROUP BY product_line
ORDER BY avg_tax DESC;

-- Good/Bad product lines based on quantity
SELECT AVG(quantity) AS avg_qnty FROM sales;

SELECT product_line,
    CASE
        WHEN AVG(quantity) > (SELECT AVG(quantity) FROM sales) THEN 'Good'
        ELSE 'Bad'
    END AS remark
FROM sales
GROUP BY product_line;

-- Branches selling more than average quantity
SELECT branch, SUM(quantity) AS qnty
FROM sales
GROUP BY branch
HAVING SUM(quantity) > (SELECT AVG(quantity) FROM sales);

-- Most common product line by gender
SELECT gender, product_line, COUNT(*) AS total_cnt
FROM sales
GROUP BY gender, product_line
ORDER BY total_cnt DESC;

-- Average rating per product line
SELECT ROUND(AVG(rating), 2) AS avg_rating, product_line
FROM sales
GROUP BY product_line
ORDER BY avg_rating DESC;

-- Unique customer types
SELECT DISTINCT customer_type FROM sales;

-- Unique payment methods
SELECT DISTINCT payment FROM sales;

-- Most common customer type
SELECT customer_type, COUNT(*) AS count
FROM sales
GROUP BY customer_type
ORDER BY count DESC;

-- Customer type that buys the most
SELECT customer_type, COUNT(*)
FROM sales
GROUP BY customer_type;

-- Gender distribution overall
SELECT gender, COUNT(*) AS gender_cnt
FROM sales
GROUP BY gender
ORDER BY gender_cnt DESC;

-- Gender distribution in Branch C
SELECT gender, COUNT(*) AS gender_cnt
FROM sales
WHERE branch = 'C'
GROUP BY gender
ORDER BY gender_cnt DESC;

-- Time of day with most average ratings
SELECT time_of_day, AVG(rating) AS avg_rating
FROM sales
GROUP BY time_of_day
ORDER BY avg_rating DESC;

-- Time of day average ratings in Branch A
SELECT time_of_day, AVG(rating) AS avg_rating
FROM sales
WHERE branch = 'A'
GROUP BY time_of_day
ORDER BY avg_rating DESC;

-- Day of the week with best average ratings
SELECT day_name, AVG(rating) AS avg_rating
FROM sales
GROUP BY day_name
ORDER BY avg_rating DESC;

-- Sales per weekday for Branch C
SELECT day_name, COUNT(*) AS total_sales
FROM sales
WHERE branch = 'C'
GROUP BY day_name
ORDER BY total_sales DESC;

-- Sales by time of day on Sunday
SELECT time_of_day, COUNT(*) AS total_sales
FROM sales
WHERE day_name = 'Sunday'
GROUP BY time_of_day
ORDER BY total_sales DESC;

-- Customer type contributing most revenue
SELECT customer_type, SUM(total) AS total_revenue
FROM sales
GROUP BY customer_type
ORDER BY total_revenue DESC;

-- City with highest average tax percentage
SELECT city, ROUND(AVG(tax_pct), 2) AS avg_tax_pct
FROM sales
GROUP BY city
ORDER BY avg_tax_pct DESC;

-- Customer type paying most VAT
SELECT customer_type, AVG(tax_pct) AS total_tax
FROM sales
GROUP BY customer_type
ORDER BY total_tax DESC;


