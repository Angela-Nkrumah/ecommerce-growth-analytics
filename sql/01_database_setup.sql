-- ================================================
-- E-Commerce Growth Analytics
-- File: 01_database_setup.sql
-- Purpose: Database and table creation
-- Author: Angela Nkrumah
-- Date: 2025
-- ================================================
Create Database ecommerce_growth;
Use ecommerce_growth;
Create Table users(
     user_id varchar(50),
     `name` varchar(100),
     email varchar(100),
     gender varchar(20),
     city varchar(100),
     signup_date date
);
Create table products(
	product_id varchar(50),
	product_name VARCHAR(200),
    category VARCHAR(100),
    price DECIMAL(10,2),
    rating DECIMAL(3,2)
);
ALTER TABLE products
ADD COLUMN brand VARCHAR(100) AFTER category;
Create table orders(
    order_id varchar(50),
    user_id VARCHAR(50),
    order_date DATETIME,
    order_status VARCHAR(50),
    total_amount DECIMAL(10,2)
);
Create table order_items(
    order_item_id VARCHAR(50),
    order_id VARCHAR(50),
    product_id VARCHAR(50),
    quantity INT,
    item_price DECIMAL(10,2)
);
Alter table order_items
ADD column user_id varchar(50) After product_id,
Add column item_total decimal(10,2) After item_price;

     DROP TABLE reviews;
     
     Create Table reviews(
        review_id varchar(50),
        order_id varchar(50),
        product_id varchar(50),
        user_id varchar(50),
        rating decimal(3,2),
        review_text text,
        review_date date
   );     
    
    CREATE TABLE events (
    event_id VARCHAR(50),
    user_id VARCHAR(50),
    product_id VARCHAR(50),
    event_type VARCHAR(50),
    event_timestamp DATETIME
);
