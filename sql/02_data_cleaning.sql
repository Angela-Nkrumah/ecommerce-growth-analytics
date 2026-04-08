-- ================================================
-- E-Commerce Growth Analytics
-- File: 02_data_cleaning.sql
-- Purpose: Data cleaning
-- Author: Angela Nkrumah
-- Date: 2025
-- ================================================
-- Cleaning of data
-- Checking for nulls
Select * from events
 where event_id is null
   OR user_id IS NULL 
   OR product_id IS NULL 
   OR event_timestamp IS NULL;
-- No null recorded

-- Checking for duplicates
SELECT event_id, COUNT(*)
FROM events
GROUP BY event_id
HAVING COUNT(*) > 1; 
-- No duplicates found

-- Checking for invalid data ranges
Select*
from events
where event_timestamp> now() 
or event_timestamp < '2015-01-01';
-- No invalid data range

-- checking for trails from product_id
select* 
from events
where product_id != trim(product_id);
-- no trails

-- Set primary key
Alter table events
add  primary key (event_id);

Select * from order_items
where order_id is null 
or user_id is null 
or quantity is null
or order_item_id;
-- no null recorded

-- checking for duplicates
select order_id, product_id, quantity, count(*)
from order_items
group by order_id, product_id, quantity
having count(*)> 1;
-- Check for true duplicates in order_items by combining order_id, product_id, and quantity.
-- This helps distinguish repeated entries from normal multiple orders of the same product.

SELECT order_id, product_id, SUM(quantity) AS total_quantity
FROM order_items
GROUP BY order_id, product_id;
-- Aggregate duplicate order-item rows to get actual total quantity sold per product per order.
-- Original 'quantity' column could have duplicates due to multiple entries for the same order_id and product_id. The sum is stored as 'total_quantity'

-- check for invalid values and range
select *
from order_items
where quantity< 0 or item_price < 0;
-- No invalid values


SELECT order_item_id, COUNT(*) AS cnt
FROM order_items
GROUP BY order_item_id
HAVING COUNT(*) > 1;

-- Set order_item_id as primary key 
ALter table order_items
add constraint PK_order_item_id primary key(order_item_id);

-- Checking for nulls in the orders table
select*
from orders
where order_id is null
or user_id is null
or total_amount is null;
-- no null values

-- checking for invalid values and range
SELECT * 
FROM orders
WHERE total_amount < 0;
-- No invalid range

-- checking for duplicates
select user_id, user_id, order_date, count(*)
from orders
group by user_id, user_id, order_date
having count(*) > 1;
-- no duplicates found

select order_id, count(*)
from orders
group by order_id
having count(*) > 1;
-- no duplicates found

-- Check for future dates in orders
SELECT * FROM orders
WHERE order_date > NOW();

-- set primary key
alter table orders
add constraint PK_order_id primary key(order_id);

SELECT * 
FROM products
WHERE product_id IS NULL
or product_name is null
or brand is null
or category is null;
-- no null values

-- checking for duplicates
SELECT product_id, COUNT(*)
FROM products
GROUP BY product_id
HAVING COUNT(*) > 1;
-- no duplicates found

-- checking for invalid values and ranges
-- Negative quantities or prices
SELECT * 
FROM products
WHERE price < 0 OR rating < 0;
-- no invalid values and range

-- checking for typos and trails
SELECT DISTINCT category FROM products;
SELECT DISTINCT brand FROM products;
-- no typos in category and brand colum

SELECT category, LENGTH(product_name), LENGTH(TRIM(product_name))
FROM products
WHERE LENGTH(product_name) != LENGTH(TRIM(product_name));
-- no trim needed

-- set primary key
alter table products
add constraint PK_product_id primary key(product_id);


-- check for nulls in the reviews table
SELECT * 
FROM reviews
WHERE review_id IS NULL
or order_id is null
or user_id is null
or rating is null;
-- no null values

-- checking for duplicates
SELECT review_id, COUNT(*)
FROM reviews
GROUP BY review_id
HAVING COUNT(*) > 1;
-- no duplicates found

-- checking for rating range in reviews
SELECT * FROM reviews
WHERE rating < 1 OR rating > 5;

SELECT review_text, LENGTH(review_text), LENGTH(TRIM(review_text))
FROM reviews
WHERE LENGTH(review_text) != LENGTH(TRIM(review_text));
-- no trim needed

-- set primary key
alter table reviews
add constraint PK_review_id primary key(review_id);

-- checking for nulls in the users table
select *
from users
 where user_id is null
 or gender is null
 or city is null
 or signup_date is null
 or name is null;
 -- no null values
 
 -- check for duplicates in the user_id column
 SELECT user_id, COUNT(*) AS cnt
FROM users
GROUP BY user_id
HAVING COUNT(*) > 1;
-- no duplicates

-- remove extra spaces and trim
SET SQL_SAFE_UPDATES = 0;

-- Trim spaces
UPDATE users
SET name = TRIM(name)
WHERE name IS NOT NULL;
-- trims did not affect any row

-- Optional: Proper case (first letter capitalized)
UPDATE users
SET name = CONCAT(UPPER(SUBSTRING(name,1,1)), LOWER(SUBSTRING(name,2)))
WHERE name IS NOT NULL;
-- proper case names was applied
