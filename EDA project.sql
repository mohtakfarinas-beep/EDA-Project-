
/*
=============================================================
Create Database and Tables
=============================================================
Script Purpose:
    Creates a database named 'eda_project'.
=============================================================
*/
/*
CREATE DATABASE eda_project;

USE eda_project;

-- Create customers dimension
CREATE TABLE dim_customers (
    customer_key INT,
    customer_id INT,
    customer_number VARCHAR(50),
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    country VARCHAR(50),
    marital_status VARCHAR(50),
    gender VARCHAR(50),
    birthdate DATE,
    create_date DATE
);


-- Create products dimension
CREATE TABLE dim_products (
    product_key INT,
    product_id INT,
    product_number VARCHAR(50),
    product_name VARCHAR(50),
    category_id VARCHAR(50),
    category VARCHAR(50),
    subcategory VARCHAR(50),
    maintenance VARCHAR(50),
    cost INT,
    product_line VARCHAR(50),
    start_date DATE
);


-- Create sales fact table
CREATE TABLE fact_sales (
    order_number VARCHAR(50),
    product_key INT,
    customer_key INT,
    order_date DATE,
    shipping_date DATE,
    due_date DATE,
    sales_amount INT,
    quantity TINYINT,
    price INT
);


-- Import customers CSV
LOAD DATA LOCAL INFILE
'C:/Users/gold.dim_customers.csv'
INTO TABLE dim_customers
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE
'C:/Users/gold.dim_products.csv'
INTO TABLE dim_products
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE
'C:/Users/gold.fact_sales.csv'
INTO TABLE fact_sales
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;
-- Database oxploration
Select * from information_schema.tables;
Select * from information_schema.columns
where table_name = 'dim_customers';
*/


                                                -- Dimensions exploration
-- THE COUNTRIES 
Select Distinct country from dim_customers;
-- The categories 
Select distinct category from dim_products;
-- The sub-categories 
Select distinct subcategory from dim_products;

                                                   -- Date exploration
Select order_date from fact_sales;
Select Min(order_date), max(order_date) ,
timestampdiff(Year,min(order_date) ,Max(order_date)) years_between
from fact_sales;

-- Oldest customer
Select customer_key, first_name,last_name,Min(birthdate) from dim_customers
group by customer_key, first_name,last_name
order by min(birthdate) 
limit 1 ;

-- Youngest
Select customer_key, first_name,last_name,max(birthdate) from dim_customers
group by customer_key, first_name,last_name
order by max(birthdate) desc
limit 1 ;

                                                      -- Measures exploration
-- Total sales 
Select Sum(sales_amount) total_sales from fact_sales;
-- How many items are sold
Select Sum(quantity) quantity_sold from fact_sales;
-- The average selling price 
Select Round(avg(price),0) average_price from fact_sales;
-- Total number of orders
Select count(distinct order_number) as Orders from fact_sales;


-- Total number of products
Select count(*) as total_prodacts from dim_products;

-- Total number of customers
Select count(customer_key) as total_customers from dim_customers;

-- Customers that had placed an order 
Select count(distinct customer_key) as total_customers from fact_sales;


                                         -- A report Showing key metrics of the business

Select 'Total sales' as measure_name,Sum(sales_amount) measure_value from fact_sales
Union
Select 'Quantity_sold' as measure_name, Sum(quantity) measure_value from fact_sales 
union
Select 'Average_price' measure_name, Round(avg(price),0) measure_value from fact_sales
union
Select 'Orders' measure_name ,count(distinct order_number) as measure_value from fact_sales
union
Select  'Total_prodacts' measure_name, count(distinct product_key) as measure_value from fact_sales
union
Select  'Total_customers' measure_name, count(customer_key) as measure_value from dim_customers;

                                               -- Magnitude Analysis

-- Total customers by country
Select country,count(distinct customer_key) as Total_customers
fROM dim_customers
group by country
order by Total_customers DESC ;

-- Total customers by gender
Select gender ,count(customer_key) 
From dim_customers
group by gender;

-- Total products by category 
Select category , count(product_key)
From dim_products
group by category;

-- Average cost in every category 
Select category , round(avg(cost),2) average
from fact_sales join dim_products on fact_sales.product_key = dim_products.product_key
group by category
order by average DESC ;

-- Total revenue for each category 

Select category , Sum(fact_sales.sales_amount) as revenue
from fact_sales join dim_products on fact_sales.product_key = dim_products.product_key
group by category
order by revenue DESC ;


-- Total revenue by each customer
Select customer_key , sum(sales_amount)
From fact_sales
group by customer_key;


-- Total quantity by country

SELECT 
    country, SUM(quantity)
FROM
    fact_sales
        JOIN
    dim_customers ON fact_sales.customer_key = dim_customers.customer_key
GROUP BY country;


                                                        -- Ranking analysis

-- Which five products generate the highest revenue
Select *  from (
Select fact_sales.product_key,product_name ,Sum(sales_amount) as sales ,row_number() over( order by Sum(sales_amount) desc) rank_products
From fact_sales join dim_products on fact_sales.product_key = dim_products.product_key
group by product_key,product_name )t 
Where rank_products <= 5;

-- 5 Worst performing products in term of sales
select * from (
Select product_name , Sum(sales_amount), row_number() over (order by Sum(sales_amount)) rank2
From fact_sales join dim_products on fact_sales.product_key = dim_products.product_key
group by product_name)t
Where rank2 <= 5 ; 

-- Top 10 customers in term of sales
Select * from (
Select dim_customers.customer_key,first_name ,last_name, sum(sales_amount), row_number() over(order by sum(sales_amount) DESC ) customers_rank
from fact_sales join dim_customers on fact_sales.customer_key = dim_customers.customer_key
group by customer_key,first_name ,last_name)t
Where customers_rank <= 10;

-- 5 CUSTOMERS WITH THE FEWEST ORDER  PLACED
Select dim_customers.customer_key, first_name ,last_name, count(distinct order_number) orders, row_number() over(order by count(distinct order_number) ) customers_rank2
from fact_sales join dim_customers on fact_sales.customer_key = dim_customers.customer_key
group by dim_customers.customer_key, first_name ,last_name
Limit 5
;