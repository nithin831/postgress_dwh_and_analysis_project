/*
===================================================================
Product Report
===================================================================

Purpose:
  - This report consolidates key product metrics and behaviors.

Highlights:
  1. Gathers essential fields such as product name, category, subcategory, and cost.
  2. Aggregates product-level metrics:
     - total orders
     - total sales
     - total quantity sold
     - total customers (unique)
     - lifespan (in months)
  3. Segments products by revenue to identify High-Performers, Mid-Range, or Low-Performers.
  4. Calculates valuable KPIs:
     - recency (months since last sale)(months since last order till now)
     - average order revenue (AOR)(total_sales/total_order)
     - average monthly revenue(total_sales/order_lifespan_in months)
===================================================================
*/

-- view to consolidate key product metrics and behaviors

create or replace view gold.product_analysis_report as 
(
    with 
    --   1. Gathers essential fields such as product name, category, subcategory, and cost.
    product_info as
    (
        select 
            s.order_number,
            p.product_id,
            p.product_number,
            p.product_name,
            s.customer_key,
            p.category_id,
            p.category,
            p.subcategory,
            p.product_line,
            p.start_date,
            p.cost, -- Cost = what you pay
            s.order_date,
            s.sales_amount,
            s.quantity,
            s.price, -- Price = what you charge or sell
            p.maintenance
        from gold.fact_sales as s
        left JOIN
        gold.dim_products p on s.product_key = p.product_key
        where s.order_date is not null
    ),
    --   2. Aggregates product-level metrics: total orders, total sales, total quantity sold, total customers (unique), lifespan (in months)
    product_metrics AS
    (
        select 
            product_id,
            product_number,
            product_name,
            category,
            subcategory,
            product_line,
            cost,
            avg(price) :: int as selling_price,
            count(distinct order_number) as total_order,
            count(distinct customer_key) as total_customers,
            min(order_date) as first_order_date,
            max(order_date) as last_order_date,
            extract(year from age(max(order_date), min(order_date)))*12 + extract(month from age(max(order_date), min(order_date))) as order_lifespan_in_months, -- first order to last order
            sum(quantity) as total_quantity,
            sum(sales_amount) as total_sales
        from product_info
        group by product_id, product_number, product_name, category, subcategory, product_line, cost
    )
    -- 3. Segments products by revenue to identify High-Performers, Mid-Range, or Low-Performers.
    -- 4. Calculates valuable KPIs: recency (months since last sale)(months since last order till now), average order revenue (AOR)(total_sales/total_order), average monthly revenue(total_sales/order_lifespan_in_months)
    select 
        product_id,
        product_number,
        product_name,
        category,
        subcategory,
        product_line,
        total_order,
        total_customers,
        first_order_date,
        last_order_date,
        order_lifespan_in_months, -- first order to last order
        EXTRACT(year from age(last_order_date))*12 + EXTRACT(year from age(last_order_date)) as recency_in_months, -- months since last order till now
        cost as cost_price,
        selling_price,
        total_quantity,
        total_sales,
        case 
            when total_sales < 50000 then 'Low-Performers' 
            when total_sales BETWEEN 50000 and 500000 then 'Mid-Range'
            else 'High-Performers'
        end as performance,
        case 
            when total_order is null or total_order = 0 then 0
            else total_sales/total_order::int
        end as average_order_revenue, -- total_sales/total_order
        case 
            when order_lifespan_in_months = 0 then total_sales
            else total_sales/order_lifespan_in_months :: int
        end as average_monthly_revenue -- total_sales/order_lifespan_in_months
    from product_metrics
);

-- select * from gold.product_analysis_report; -- view to consolidate key product metrics and behaviors