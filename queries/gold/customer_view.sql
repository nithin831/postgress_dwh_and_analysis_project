-- **************************************************************************************************************************
-- We see that customer specific infomation in silver.crm_cust_info, silver.erp_loc_a101 and silver.erp_cust_az12.
-- Join all customer specifc info in a single view using foreign keys and name the view as dim_customers.
-- Rename the column user friendly.
-- create Surrogate Key: A surrogate key is a system-generated, unique identifier for a row in a table. It has no business meaning.
-- **************************************************************************************************************************
create or replace view gold.dim_customers as
Select 
	row_number() over(order by ci.cst_id) as customer_key, -- Surrogate Key is created using cst_id because it has relation with sales
	ci.cst_id as customer_id,
	ci.cst_key as customer_number,
	ci.cst_firstname as first_name,
	ci.cst_lastname as last_name,
	cb.bdate as birthdate,
	cl.cntry as country, -- from erp_loc_a101
	ci.cst_marital_status as marital_status,
	case 
		when ci.cst_gndr = 'n/a' and cb.gen = 'n/a' then 'Unknown'
		when ci.cst_gndr = 'n/a' then cb.gen
		else ci.cst_gndr
	end Gender,
	ci.cst_create_date as create_date
from 
silver.crm_cust_info as ci 
left join
silver.erp_loc_a101 as cl on ci.cst_key = cl.cid
left join 
silver.erp_cust_az12 as cb on ci.cst_key = cb.cid;

-- Select * from silver.crm_cust_info;

-- select * from silver.erp_loc_a101;

-- select * from silver.erp_cust_az12;

-- select *  from gold.dim_customers; -- customer view