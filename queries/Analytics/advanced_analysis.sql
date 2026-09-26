-- note: if same queries are used as subqueries, then make it as cte

-- **********************************************************************************************************
-- Change over time analysis : compare measure values by time periods
-- Generate a report that shows sales performance over time.
-- **********************************************************************************************************

select 
    extract(year from order_date) as year,
    sum(sales_amount) as sales_amount,
    count(distinct customer_key) as total_customers,
    count(distinct product_key) as total_products,
    sum(quantity) as total_quantity
from gold.fact_sales
where order_date is not null 
group by extract(year from order_date)
order by extract(year from order_date); -- Analyze sales performance over time by year, to observe which year had the highest sales.


select 
    to_char(order_date, 'fmmonth') as month,
    sum(sales_amount) as sales_amount,
    count(distinct customer_key) as total_customers,
    count(distinct product_key) as total_products,
    sum(quantity) as total_quantity
from gold.fact_sales
where order_date is not null 
group by to_char(order_date, 'fmmonth'), extract(month from order_date)
order by extract(month from order_date); -- Analyze sales performance over time by month, to observe which month is best for sales.


select 
    extract(year from order_date) as year,
    to_char(order_date, 'fmmonth') as month,
    sum(sales_amount) as sales_amount,
    count(distinct customer_key) as total_customers,
    count(distinct product_key) as total_products,
    sum(quantity) as total_quantity
from gold.fact_sales
where order_date is not null 
group by extract(year from order_date), to_char(order_date, 'fmmonth'), extract(month from order_date)
order by extract(year from order_date), extract(month from order_date); -- Analyze sales performance over time by year and month, to observe which periods had the highest sales.
-- or
select 
    date_trunc('month', order_date) as order_date, -- o/p is 2010-12-01 00:00:00+05:30(beginning of the month in that year) -> which is datetime datatype
    sum(sales_amount) as sales_amount,
    count(distinct customer_key) as total_customers,
    count(distinct product_key) as total_products,
    sum(quantity) as total_quantity
from gold.fact_sales
where order_date is not null 
group by date_trunc('month', order_date)
order by date_trunc('month', order_date); -- Analyze sales performance over time by year and month, to observe which periods had the highest sales. using date_trunc function to group by month and year together.

-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- **********************************************************************************************************
-- Cumulative analysis : aggregate data progressively over time.
-- Generate a report that shows moving average of total price over time and running total of sales over time for total price and total sales per month and year.
-- **********************************************************************************************************

select 
    extract(year from order_date) as year,
    to_char(order_date, 'fmmonth') as month,
    sum(sales_amount) as sales_amount,
    sum(sum(sales_amount)) over (order by extract(year from order_date), extract(month from order_date)) as running_total_sales, -- sales_amount + next month sales_amount + next month sales_amount + so on for all data
    avg(price) :: int as average_price,
    avg(avg(price) :: int) over (order by extract(year from order_date), extract(month from order_date)) :: int as moving_average_price -- moving average of total price over time, calculated using window function
from gold.fact_sales
where order_date is not null 
group by extract(year from order_date), to_char(order_date, 'fmmonth'), extract(month from order_date)
order by extract(year from order_date), extract(month from order_date); -- analyze sales performance over time by year and month and using window function to calculate running total of sales over time and moving average of price.
-- or
select 
    year, 
    month,
    sales_amount, 
    sum(sales_amount) over (order by year, month_num) as running_total_sales, -- sales_amount + next month sales_amount + next month sales_amount + so on for all data,
    average_price,
    avg(average_price) over (order by year, month_num)  :: int as moving_average_price -- moving average of total price over time, calculated using window function
from
(
    select 
        extract(year from order_date) as year,
        to_char(order_date, 'fmmonth') as month,
        extract(month from order_date) as month_num,
        sum(sales_amount) as sales_amount,
        avg(price) :: int as average_price
    from gold.fact_sales
    where order_date is not null 
    group by extract(year from order_date), to_char(order_date, 'fmmonth'), extract(month from order_date)
)order by year, month_num; -- analyze sales performance over time by year and month and using window function to calculate running total of sales over time and moving average of price.


select 
    year, 
    month,
    sales_amount, 
    sum(sales_amount) over (partition by year order by year, month_num) as running_total_sales, -- sales_amount + next month sales_amount + next month sales_amount + so on for all data, but partitioned by year, so that the running total resets for each year
    average_price,
    avg(average_price) over (partition by year order by year, month_num)  :: int as moving_average_price -- moving average of total price over time, calculated using window function
from
(
    select 
        extract(year from order_date) as year,
        to_char(order_date, 'fmmonth') as month,
        extract(month from order_date) as month_num,
        sum(sales_amount) as sales_amount,
        avg(price) :: int as average_price
    from gold.fact_sales
    where order_date is not null 
    group by extract(year from order_date), to_char(order_date, 'fmmonth'), extract(month from order_date)
)order by year, month_num; -- analyze sales performance over time by year and month and using window function to calculate running total of sales over time and moving average of price, but partitioned by year, so that the running total and moving average reset for each year.



-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- **********************************************************************************************************
-- performance analysis : comparing current value to target value.
-- Generate a report that shows the yearly perfomance of products by comparing each product's sale to both its average sales performance and previous years sales.
-- **********************************************************************************************************

select 
    *,
    avg(sales_amount) over (partition by product_name) :: int as average_sales_amount,
    lag(sales_amount) over (partition by product_name order by year) as previous_year_sales_amount,
    case 
        when sales_amount > avg(sales_amount) over (partition by product_name) :: int  then 'Above Average'
        when sales_amount < avg(sales_amount) over (partition by product_name) :: int  then 'Below Average'
        else 'Average'
    end as average_sales_performance, -- average sales performance of each product by comparing each product's sale to its average sales performance
    case 
        when sales_amount > lag(sales_amount) over (partition by product_name order by year) then 'Increased'
        when sales_amount < lag(sales_amount) over (partition by product_name order by year) then 'Decreased'
        else 'No Change'
    end as yearly_sales_performance -- yearly sales performance of each product by comparing each product's sale to its previous year's sales
from(
    select 
        extract(year from order_date) as year,
        p.product_name,
        sum(s.sales_amount) as sales_amount
    from 
    gold.fact_sales s 
    left join 
    gold.dim_products p on s.product_key = p.product_key
    where order_date is not null
    group by p.product_name, extract(year from order_date)
)
order by  product_name, year; 


-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- **********************************************************************************************************
-- part to whole analysis : analyze how an individual part is performing compared to the overall.
-- Generate a report that shows which categories contribute the most to overall sales.
-- **********************************************************************************************************

SELECT
*,
sum(total_sales) over () as overall_sales,
concat(round((total_sales/sum(total_sales) over ())*100, 2), ' %') as contribution
FROM
(
    select 
        p.category,
        sum(sales_amount) as total_sales
    from gold.fact_sales s
    left join gold.dim_products p on s.product_key = p.product_key
    group by p.category
)
order by contribution desc; -- analyze which categories contribute the most to overall sales by calculating the contribution of each category to the overall sales.



-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- **********************************************************************************************************
-- Data segmentation : Group the data based on specific range.
-- Generate a report in which segment the products into cost ranges and count how many products fall into each segment.
-- **********************************************************************************************************

with cost_range AS  -- cte to segment the products into cost ranges
(
select 
    product_key,
    product_name,
    category,
    subcategory,
    product_line,
    cost,
    case 
        when cost < 100 then 'below 100'
        when cost between 100 and 1000 then '100 to 1000'  -- 100 and 1000 are included
        when cost between 1001 and 2000 then '1001 to 2000' 
        else 'above 2000'
    end as cost_range
from gold.dim_products
order by cost
)
select 
    cost_range,
    count(product_key) 
from cost_range
group by cost_range; -- analyze how many products fall into each cost range by segmenting the products into cost ranges and counting the number of products in each range.


