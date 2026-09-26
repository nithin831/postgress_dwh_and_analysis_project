-- note: if same queries are used as subqueries, then make it as cte

-- **********************************************************************************************************
-- Generate a report that shows all the key metrics for the business, including total sales, total customers, 
-- total products, and any other relevant metrics that can help the business make informed decisions.
-- **********************************************************************************************************

select 'Total Sum' as measure_name, sum(sales_amount) as measure_value from gold.fact_sales -- Analyze total sales amount in fact_sales table
union all
select 'Total Quantity' as measure_name, sum(quantity) as measure_value from gold.fact_sales -- analyze how many products were sold 
union all
select 'Average Price' as measure_name, avg(price) as measure_value from gold.fact_sales -- Analyze average selling price in fact_sales table
union all
select 'Total Orders' as measure_name, count(distinct order_number) as measure_value from gold.fact_sales -- Analyze distinct number of orders in fact_sales table 
union all
select 'Total Product Sold' as measure_name, count(distinct product_key) as measure_value from gold.fact_sales -- Analyze distinct number of products that were sold in fact_sales table 
union all
select 'Total Products' as measure_name, count(distinct product_key) as measure_value from gold.dim_products -- Analyze distinct number of products in dim_products table
union all
select 'Total Customers Placed Orders' as measure_name, count(distinct customer_key) as measure_value from gold.fact_sales -- Analyze distinct number of customers who have placed an order in fact_sales table
union all
select 'Total Customers' as measure_name, count(distinct customer_key) as measure_value from gold.dim_customers; -- Analyze distinct number of customers in dim_customers table

-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


-- **********************************************************************************************************
-- group the customers into 3 segments based on their spending behaviour:
--  - vip: customers with atleast 12 months of history and spending more than 5000
--  - regular: customers with atleast 12 months of history but spending 5000 or less
--  - new: customer with lifespan less than 12 months
-- and find the total no of customers by each group
-- **********************************************************************************************************

with customer_history AS -- cte to group the customers into 3 segments based on their spending behaviour
(
    select 
        s.customer_key,
        concat(c.first_name, ' ', c.last_name) as name,
        min(s.order_date) as min_order_date,
        max(s.order_date) as max_order_date,
        age(max(s.order_date), min(s.order_date)) as history,
        COALESCE(EXTRACT(YEAR from age(max(s.order_date), min(s.order_date))), 0) as year,
        sum(s.sales_amount) as total_sales,
        CASE
            when COALESCE(EXTRACT(YEAR from age(max(s.order_date), min(s.order_date))), 0)  < 1 then 'NEW'
            when COALESCE(EXTRACT(YEAR from age(max(s.order_date), min(s.order_date))), 0)  >= 1 and sum(s.sales_amount) > 5000 then 'VIP'
            else 'REGULAR'
        end customer_category
    from gold.fact_sales s 
    left JOIN
    gold.dim_customers c on s.customer_key = c.customer_key
    group by s.customer_key, concat(c.first_name, ' ', c.last_name)
    order by history desc
)
select 
    customer_category,
    count(customer_key) as total_customers
from customer_history
group by customer_category
order by total_customers desc; -- analyze the total no of customers by each group based on their spending behaviour

