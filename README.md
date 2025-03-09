# Danny's Diner - SQL Case Study 🍽️  

## Overview  
This project is a **SQL-based case study** analyzing customer purchase behavior at *Danny's Diner*, a fictional restaurant. The dataset includes customer sales transactions, menu items, and membership details. The analysis uncovers **purchase trends, duplicate orders, and membership impact on spending** using SQL queries.  

## Schema & Data  
The project consists of three tables:  

- **`sales`**: Records customer orders with:  
  - `customer_id` (unique ID for customers)  
  - `order_date` (date of purchase)  
  - `product_id` (ID of purchased product)  

- **`menu`**: Contains product details such as:  
  - `product_id` (unique product ID)  
  - `product_name` (name of the dish)  
  - `price` (cost of the product)  

- **`members`**: Tracks customer memberships:  
  - `customer_id` (ID of the customer)  
  - `join_date` (date when they became a member)  

## Key Insights from SQL Queries  
- Identifying **duplicate orders** (same day vs different days)  
- Analyzing **customer spending habits** based on membership status  
- Calculating **revenue contribution per product and customer**  
- Tracking **customer visit frequency**  

## How to Use  
1. Run `schema.sql` to set up the database and insert sample data.
2.  Execute `queries.sql` to generate insights.  

## Author  
Supreet Dodani
https://www.linkedin.com/in/supreet-dodani-3a3371246/

