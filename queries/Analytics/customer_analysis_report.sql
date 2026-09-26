/*
========================================================================
Customer Report
========================================================================

Purpose:
  - This report consolidates key customer metrics and behaviors

Highlights:
  1. Gathers essential fields such as names, ages, and transaction details.
  2. Aggregates customer-level metrics:
     - total orders
     - total sales
     - total quantity purchased
     - total products
     - lifespan ->diff of max and min of orderdate(first order to last order) - order_lifespan
  3. Segments customers into categories (VIP, Regular, New) and age groups.
    - vip: customers with atleast 12 months of history and spending more than 5000
    - regular: customers with atleast 12 months of history but spending 5000 or less
    - new: customer with lifespan less than 12 months
  4. Calculates valuable KPIs:
     - recency (since last order till now)
     - average order value(total_sales/total_orders)
     - average yearly spend(total_sales/order_life_span)
========================================================================
*/

-- view to consolidate key customer metrics and behaviors

create OR REPLACE view gold.customer_analysis_report AS
(
    with
    -- 1. Gathers essential fields such as names, ages, and transaction details.
    basic_customer_detail AS(
        select 
            s.order_number,
            s.product_key,
            c.customer_id,
            c.customer_number,
            concat(c.first_name, ' ', c.last_name) as name,
            c.birthdate,
            EXTRACT(year from age(c.birthdate)) as age,
            c.country,
            c.marital_status,
            c.gender,
            s.order_date,
            s.sales_amount,
            s.quantity,
            s.Price
        from gold.fact_sales as s
        left JOIN
        gold.dim_customers c on s.customer_key = c.customer_key
        where s.order_date is not null
    ),
    -- 2. Aggregates customer-level metrics: total orders, total sales, total quantity purchased, total products, lifespan 
    customer_metrics AS(
        SELECT 
            customer_id,
            customer_number,
            name,
            birthdate,
            age,
            country,
            marital_status,
            gender,
            max(order_date) as last_order_date,
            age(max(order_date), min(order_date)) as order_lifespan, -- first order to last order
            count(distinct order_number) as total_orders,
            count(distinct product_key) as total_products,
            sum(quantity) as total_quantity,
            sum(sales_amount) as total_sales        
        from basic_customer_detail
        group by customer_id, customer_number, name, birthdate, age, country, marital_status, gender
    )
    -- 3. Segments customers into categories (VIP, Regular, New) and age groups.
    -- 4. Calculates valuable KPIs: recency (since last order till now), average order value(total_sales/total_orders), average yearly spend(total_sales/order_life_span)
    select 
        customer_id,
        customer_number,
        name,
        birthdate,
        age,
        case 
            when age is null then 'Unknown'
            when age <= 18 then 'Young'
            when age between 19 and 50 then 'Adults'
            else 'Senior'
        end as age_group,
        country,
        marital_status,
        gender,
        last_order_date,
        age(last_order_date) as recency, -- since last order till now
        order_lifespan, -- first order to last order
        case 
            when COALESCE(EXTRACT(year from order_lifespan), 0) < 1 then 'New'
            when COALESCE(EXTRACT(year from order_lifespan), 0) >= 1 and total_sales > 5000 then 'VIP'
            else 'Regular'
        end as customer_category, 
        total_orders,
        total_products,
        total_quantity,
        total_sales,
        case 
            when total_orders is null or total_orders = 0 then 0
            else total_sales/total_orders::int
        end as average_order_value, -- total_sales/total_orders
        case 
            when EXTRACT(year from order_lifespan) = 0 then total_sales
            else total_sales/EXTRACT(year from order_lifespan) :: int
        end as average_yearly_spend -- total_sales/order_life_span
    from customer_metrics
);

-- SELECT * from gold.customer_analysis_report; -- view to consolidate key customer metrics and behaviors