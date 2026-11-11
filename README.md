# EDA Project: Sales Data Exploration (MySQL)

Exploratory data analysis of a sales dataset using SQL (MySQL 8).

## Dataset

Three tables in a star schema:

- `fact_sales`: one row per order line (order, product, customer, dates, amount, quantity, price)
- `dim_customers`: customer details (country, gender, marital status, birthdate)
- `dim_products`: product details (category, subcategory, cost, product line)

## What's covered

- **Database exploration:** tables and columns
- **Dimensions exploration:** countries, categories, subcategories
- **Date exploration:** date range of the sales, oldest and youngest customers
- **Measures exploration:** total sales, quantity sold, average price, number of orders, products and customers
- **Magnitude analysis:** customers, products and revenue by country, gender and category
- **Ranking analysis:** top and bottom products and customers

## Files

- `eda_project.sql`: database and table creation, data import, then the analysis queries

## How to run

1. Use MySQL 8 or later.
2. Change the file paths in the `LOAD DATA` commands to where your CSV files are saved.
3. Run the creation and import block once, then the queries one by one.

Note: the script starts with `DROP DATABASE IF EXISTS`, so running the whole file again resets the database.
