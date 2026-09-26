-- **********************************************************************************************************
-- Database Exploration
-- **********************************************************************************************************
select * from information_schema.tables; -- Analyze table information in database

select * from information_schema.columns where table_name = 'dim_customers'; -- Analyze column information in database


-- **********************************************************************************************************
-- Views Exploration
-- **********************************************************************************************************
select * from gold.dim_customers; -- Analyze data in dim_customers view

select * from gold.dim_products; -- Analyze data in dim_products view

select * from gold.fact_sales; -- Analyze data in fact_sales view


-- **********************************************************************************************************
-- Dimension Exploration - dimensions include vaues other than integers and even few integers that have no mening after aggregation
-- **********************************************************************************************************
select distinct country from gold.dim_customers; -- Analyze distinct countries in dim_customers table

select distinct category, subcategory, product_name from gold.dim_products order by category, subcategory; -- Analyze distinct categories, subcategories and product names in dim_products table


-- **********************************************************************************************************
-- Date Exploration
-- **********************************************************************************************************
select min(order_date) as first_order, max(order_date) as last_order, age(max(order_date), min(order_date)) as date_range from gold.fact_sales; -- Analyze the date range of orders in fact_sales table

select min(birthdate) as oldest_customer, age(min(birthdate)) as oldest_age, max(birthdate) as youngest_customer, age(max(birthdate)) as youngest_age from gold.dim_customers ; -- Analyze the age range of customers in dim_customers table


-- **********************************************************************************************************
-- Measure Exploration - measures include only integers and are used for aggregation
-- **********************************************************************************************************
select sum(sales_amount) as total_sales from gold.fact_sales; -- Analyze total sales amount in fact_sales table

select sum(quantity) as total_quantity from gold.fact_sales; -- analyze how many products were sold 

select avg(price) as average_price from gold.fact_sales; -- Analyze average selling price in fact_sales table

select count(distinct order_number) as total_orders from gold.fact_sales; -- Analyze distinct number of orders in fact_sales table 

select count(distinct product_key) as total_products from gold.fact_sales; -- Analyze distinct number of products that were sold in fact_sales table 

select count(distinct product_key) as total_products from gold.dim_products; -- Analyze distinct number of products in dim_products table

select count(distinct customer_key) as total_customers from gold.fact_sales; -- Analyze distinct number of customers who have placed an order in fact_sales table

select count(distinct customer_key) as total_customers from gold.dim_customers; -- Analyze distinct number of customers in dim_customers table


-- **********************************************************************************************************
-- Magnitude Analysis : compare measure values by categories
-- **********************************************************************************************************
select country, count(customer_key) as total_customers from gold.dim_customers group by country order by total_customers desc; -- Analyze total customers by country in dim_customers table

select gender, count(customer_key) as total_customers from gold.dim_customers group by gender order by total_customers desc; -- Analyze total customers by gender in dim_customers table

select category, count(product_key) as total_products from gold.dim_products group by category order by total_products desc; -- Analyze total products by category in dim_products table

select category, avg(cost) as average_cost from gold.dim_products group by category order by average_cost desc; -- Analyze average cost of products by category in dim_products table

select p.category, sum(s.sales_amount) as total_revenue from gold.fact_sales s
left join gold.dim_products p on s.product_key = p.product_key
group by p.category order by total_revenue desc; -- Analyze total revenue by each category 

select c.customer_key, c.first_name, sum(s.sales_amount) as total_revenue from gold.fact_sales s
left join gold.dim_customers c on s.customer_key = c.customer_key
group by c.customer_key, c.first_name order by total_revenue desc; -- Analyze total revenue by each customer

select c.country, sum(s.quantity) as total_sold_items from gold.fact_sales s
left join gold.dim_customers c on s.customer_key = c.customer_key
group by c.country order by total_sold_items desc; -- Analyze total sold items by country

select c.country, sum(s.sales_amount) as total_revenue from gold.fact_sales s
left join gold.dim_customers c on s.customer_key = c.customer_key
group by c.country order by total_revenue desc; -- Analyze total revenue by country


-- **********************************************************************************************************
-- Ranking Analysis : order the dimension by measure values
-- **********************************************************************************************************
select p.product_name, sum(s.sales_amount) as total_revenue from gold.fact_sales s
left join gold.dim_products p on s.product_key = p.product_key
group by p.product_name order by total_revenue desc limit 5; -- Analyze top 5 products that generate highest revenue
-- or
select * from (
    select p.product_name, sum(s.sales_amount) as total_revenue, row_number() over (order by sum(s.sales_amount) desc) as revenue_rank from gold.fact_sales s
    left join gold.dim_products p on s.product_key = p.product_key
    group by p.product_name
) ranked_products where revenue_rank <= 5; -- Analyze top 5 products that generate highest revenue -- using row_number window function


select p.product_name, sum(s.sales_amount) as total_revenue from gold.fact_sales s
left join gold.dim_products p on s.product_key = p.product_key
group by p.product_name order by total_revenue asc limit 5; -- Analyze worst 5 products that generate highest revenue


select c.customer_key, c.first_name, count(distinct s.order_number) as total_order from gold.fact_sales s
left join gold.dim_customers c on s.customer_key = c.customer_key
group by c.customer_key, c.first_name order by total_order desc limit 10;  -- Analyze top 10 customers who placed highest number of distinct orders


select c.customer_key, c.first_name, count(distinct s.order_number) as total_order from gold.fact_sales s
left join gold.dim_customers c on s.customer_key = c.customer_key
group by c.customer_key, c.first_name order by total_order asc limit 3;  -- Analyze 3 customers who placed lowest number of distinct orders