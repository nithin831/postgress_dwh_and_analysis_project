-- **************************************************************************************************************************
-- Here we see the transaction of sales by different customer and products, so this is considerd as Fact.
-- We created dimension view for customer specific infomation in gold.dim_customers
-- We created dimension view for products specific infomation in gold.dim_products
-- now use the surrogate keys of dimension views in place of actual ids in sales to easily connect dimension and facts and name the view as fact_sales.
-- Rename the column user friendly.
-- **************************************************************************************************************************
create  or replace view gold.fact_sales as
select 
	sd.sls_ord_num as order_number,
	p.product_key , -- using surrogate key(product_key) inplace of product_number(sls_prd_key)
	c.customer_key , -- using surrogate key(customer_key) inplace of customer_id(sls_cust_id)
	sls_order_dt as order_date,
	sd.sls_ship_dt as shipping_date,
	sd.sls_due_dt as due_date,
	sd.sls_sales as sales_amount,
	sd.sls_quantity as quantity,
	sd.sls_price as price
from 
silver.crm_sales_details as sd
left join
gold.dim_customers as c on sd.sls_cust_id = c.customer_id
left join
gold.dim_products as p on sd.sls_prd_key = p.product_number;


-- select * from gold.fact_sales; -- Sales view
	