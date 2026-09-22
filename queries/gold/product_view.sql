-- **************************************************************************************************************************
-- We see that product specific infomation in silver.crm_prd_info and silver.erp_px_cat_g1v2.
-- Businesss rule: consider only the latest product(in silver.crm_prd_info, we have history of product, to have only the latest product, consider the product having enddate as null )
-- Join all product specifc info in a single view using foreign keys and name the view as dim_products.
-- Rename the column user friendly.
-- create Surrogate Key: A surrogate key is a system-generated, unique identifier for a row in a table. It has no business meaning.
-- **************************************************************************************************************************
create or replace view gold.dim_products as
Select 
	row_number() over(order by prd_start_dt, pi.prd_key) as product_key, -- Surrogate Key is created using prd_key because it has relation with sales, and for safety included start_date
	pi.prd_id as product_id,
	pi.prd_key as product_number,
	pi.prd_nm as product_name,
	pi.cat_id as category_id,
	pc.cat as category,
	pc.subcat subcategory,
	pi.prd_cost as cost,
	pi.prd_line as product_line,
	pi.prd_start_dt as start_date,
	-- pi.prd_end_dt, -- no need to this info because we are considering only the latest product
	pc.maintenance
from silver.crm_prd_info as pi
left join
silver.erp_px_cat_g1v2 as pc on pi.cat_id = pc.id
where pi.prd_end_dt is null; -- consider only the latest product

-- Select * from silver.crm_prd_info;

-- select * from silver.erp_px_cat_g1v2;

-- select * from gold.dim_products; -- Product view