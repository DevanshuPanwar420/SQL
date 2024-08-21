create database if not exists WalmartSales;

CREATE TABLE IF NOT EXISTS sales(
	invoice_id VARCHAR(30) NOT NULL PRIMARY KEY,
    branch VARCHAR(5) NOT NULL,
    city VARCHAR(30) NOT NULL,
    customer_type VARCHAR(30) NOT NULL,
    gender VARCHAR(10) NOT NULL,
    product_line VARCHAR(100) NOT NULL,
    unit_price DECIMAL(10) NOT NULL,
    quantity INT NOT NULL,
    VAT FLOAT(6,4) NOT NULL,
    total DECIMAL(12,4) NOT NULL,
    date DATETIME NOT NULL,
    time TIME NOT NULL,
    payment_method VARCHAR(15) NOT NULL,
    cogs DECIMAL(10,2) NOT NULL,
    gross_margin_percentage FLOAT(11,9),
    gross_income DECIMAL(12,4) NOT NULL,
    rating FLOAT(2,1)
);  
-- Data cleaning
SELECT
	*
FROM sales;
-------------- FEATURE ENGINEERING -----------------  

-- Add the time_of_day column
SELECT
	time,
	(CASE
		WHEN `time` BETWEEN "00:00:00" AND "12:00:00" THEN "Morning"
        WHEN `time` BETWEEN "12:01:00" AND "16:00:00" THEN "Afternoon"
        ELSE "Evening"
    END) AS time_of_day
FROM sales;

ALTER TABLE sales ADD COLUMN time_of_day VARCHAR(20);

-- For this to work turn off safe mode for update
-- Edit > Preferences > SQL Edito > scroll down and toggle safe mode
-- Reconnect to MySQL: Query > Reconnect to server
UPDATE sales
SET time_of_day = (
	CASE
		WHEN `time` BETWEEN "00:00:00" AND "12:00:00" THEN "Morning"
        WHEN `time` BETWEEN "12:01:00" AND "16:00:00" THEN "Afternoon"
        ELSE "Evening"
    END
);

-- day_name
SELECT 
	date,
    DAYNAME(date)
FROM sales;  

ALTER TABLE sales ADD COLUMN day_name VARCHAR(10);  

SELECT 
	date,
    DAYNAME(date) AS day_name
FROM sales;  

UPDATE sales
SET day_name = DAYNAME(date);

--- Month_name

SELECT
	date,
    MONTHNAME(date)
FROM sales; 

ALTER TABLE sales ADD COLUMN month_name VARCHAR(10);

UPDATE sales
SET month_name = MONTHNAME(date);

--------- ----------------------------------------------------------------------------------------------------------------------
--- How many unique cities does the data have?

SELECT 
	DISTINCT city
FROM sales;

-- -- In which city is each branch?

SELECT 
	DISTINCT branch
FROM sales;

SELECT 
	DISTINCT city,
    branch
FROM sales;

-- -- --------------------------------------------------------------------
-- ---------------------------- Product -------------------------------
-- --------------------------------------------------------------------

-- 1. How many unique product lines does the data have?

SELECT
	DISTINCT product_line
FROM sales;

SELECT
	COUNT(DISTINCT product_line)
FROM sales;   

-- -- 2.What is the most common payment method?

SELECT
	COUNT(payment_method)
FROM sales;

SELECT
	payment_method,
    COUNT(payment_method) AS cnt
FROM sales
GROUP BY payment_method;    

SELECT
	payment_method,
    COUNT(payment_method) AS cnt
FROM sales
GROUP BY payment_method   
ORDER BY cnt DESC;

-- -- 3.What is the most selling product line?

SELECT
	product_line,
    COUNT(product_line) AS cnt
FROM sales
GROUP BY product_line   
ORDER BY cnt DESC;

-- -- What is the total revenue by month?
SELECT
	month_name AS month
FROM sales;

SELECT
	month_name AS month,
    SUM(total) AS total_revenue
FROM sales
GROUP BY month_name
ORDER BY total_revenue DESC;

-- -- What month had the largest cogs?
SELECT
	month_name AS month,
    SUM(cogs) AS cogs
FROM sales
GROUP BY month_name
ORDER BY cogs DESC;   

-- -- what product line had the largest revenue

SELECT 
	product_line,
    SUM(total) AS total_revenue
FROM sales
GROUP BY product_line
ORDER BY total_revenue DESC;    

-- -- what is the city with the largest revenue

SELECT
	branch,
    city,
    SUM(total) AS total_revenue
FROM sales
GROUP BY city,branch
ORDER BY total_revenue DESC;

-- -- What product line had the largest VAT?

SELECT
	product_line,
    AVG(VAT) AS avg_tax
FROM sales    
group by product_line
order by avg_tax desc;

-- -- Fetch each product line and add a column to those product line showing "Good", "Bad". Good if its greater than average sales
SELECT 
	AVG(quantity) AS avg_qnty
FROM sales;

SELECT
	product_line,
	CASE
		WHEN AVG(quantity) > 6 THEN "Good"
        ELSE "Bad"
    END AS remark
FROM sales
GROUP BY product_line;

-- -- Which branch sold more products than average product sold
select
	branch,
    SUM(quantity) as qty
from sales
group by branch
having SUM(quantity) > (select AVG(quantity) from sales);    

-- -- What is the most common product line by gender?

select
	gender,
    product_line,
    count(gender) as total_cnt
from sales
group by gender,product_line
order by total_cnt desc;    

-- --  What is the average rating of each product line?
select
	round(avg(rating),2) as avg_rating,
    product_line
from sales
group by product_line
order by avg_rating desc; 

-- --------------------------------------------------------------------
-- --------------------------------------------------------------------

-- --------------------------------------------------------------------
-- -------------------------- Sales -------------------------------
-- --------------------------------------------------------------------

-- Number of sales made in each time of the day per weekday
select
	time_of_day,
    COUNT(*) AS total_sales
from sales
group by time_of_day;    

select
	time_of_day,
    COUNT(*) AS total_sales
from sales
WHERE day_name = "Sunday"
group by time_of_day
order by total_sales DESC; 

-- -- Which of the customer types brings the most revenue?

select
	customer_type,
    sum(total) as total_rev
from sales
group by customer_type
order by total_rev desc;  

-- -- Which city has the largest tax percent/ VAT (Value Added Tax)?

select
	city,
    sum(VAT) as largest_vat
from sales
group by city
order by largest_vat DESC;  

select
	city,
    avg(VAT) as avg_vat
from sales
group by city
order by avg_vat DESC;   

-- --  Which customer type pays the most in VAT?
select
	customer_type,
    sum(VAT) as largest_vat
from sales
group by customer_type
order by largest_vat DESC;   

select
	customer_type,
    avg(VAT) as avg_vat
from sales
group by customer_type
order by avg_vat DESC;   

-- --------------------------------------------------------------------
-- --------------------------------------------------------------------

-- --------------------------------------------------------------------
-- -------------------------- Customers -------------------------------
-- --------------------------------------------------------------------

-- --  How many unique customer types does the data have?
select
	distinct customer_type
from sales; 

-- ---  How many unique payment methods does the data have?
select
	distinct payment_method
from sales;    

-- ---  What is the most common customer type?
select
	customer_type,
    count(*) as cnt
from sales
group by customer_type
order by cnt desc;  

-- --  Which customer type buys the most?
select
	customer_type,
    count(*) as cstm_cnt
from sales
group by customer_type;    

-- --  What is the gender of most of the customers?
select
	gender,
    count(*) as cnt
from sales
group by gender
order by cnt;

-- --  What is the gender distribution per branch?

select
	branch,
	gender,
    count(*) as cnt
from sales
group by gender,branch
order by cnt;  
    
select
	gender,
    count(*) as cnt
from sales
where branch = 'A'
group by gender
order by cnt;

-- --  Which time of the day do customers give most ratings?
select
	time_of_day,
    avg(rating) as avg_rating
from sales
group by time_of_day
order by avg_rating;  

-- --  Which time of the day do customers give most ratings per branch?
select
	branch,
	time_of_day,
    avg(rating) as avg_rating
from sales
group by time_of_day,branch
order by avg_rating DESC; 

-- --  Which day of the week has the best avg ratings?

select
	day_name,
    avg(rating) as avg_rating
from sales
group by day_name
order by avg_rating DESC;

-- --   Which day of the week has the best average ratings per branch?

select
	branch,
	day_name,
    avg(rating) as avg_rating
from sales
group by day_name,branch
order by avg_rating DESC;
  
