-- =========================================================================================================================================================================================================================================================================================
-- Customer(dim_customers)
-- =========================================================================================================================================================================================================================================================================================
	
-- ____________________________________________________________________________
-- Column: cst_id
-- Quality check: Check for nulls or duplicates in primary Key after joining
-- Expected O/P: No result(if there is O/P, then gives the data that has null and duplicates)
-- ____________________________________________________________________________
Select 
	cst_id,
	count(*) cnt
from (
select 
	ci.cst_id,
	ci.cst_key,
	ci.cst_firstname,
	ci.cst_lastname,
	cb.bdate,
	cl.cntry, -- from erp_loc_a101
	ci.cst_marital_status,
	ci.cst_gndr,
	cb.gen, -- from erp_cust_az12
	ci.cst_create_date
	from
	silver.crm_cust_info as ci 
	left join
	silver.erp_loc_a101 as cl on ci.cst_key = cl.cid
	left join 
	silver.erp_cust_az12 as cb on ci.cst_key = cb.cid
)
group by cst_id having count(*)>1 or cst_id is null; -- no result


-- ____________________________________________________________________________
-- Column: ci.cst_gndr, cb.gen
-- cb.gen, -- from erp_cust_az12
-- Quality check: Handle gender(Check weather both are having same value, else handel)
-- Expected O/P: No result(if there is O/P, then there are 2 gender for a person)
-- Solution: business rule(consider CRM(crm_cust_info) as master) and if there are n/a in CRM, then take from ERP, if both n/a then unknown
-- ____________________________________________________________________________
Select 
	distinct ci.cst_gndr,
	case 
		when ci.cst_gndr = 'n/a' and cb.gen = 'n/a' then 'Unknown'
		when ci.cst_gndr = 'n/a' then cb.gen
		else ci.cst_gndr
	end Gender,
	cb.gen -- from erp_cust_az12
from 
silver.crm_cust_info as ci 
left join 
silver.erp_cust_az12 as cb on ci.cst_key = cb.cid
order by 1, 2; -- observed 2 values for gender


-- ____________________________________________________________________________________________________

select distinct gender  from gold.dim_customers; -- quality check after creating dim_customers view




-- =========================================================================================================================================================================================================================================================================================
-- Product(dim_products)
-- =========================================================================================================================================================================================================================================================================================

-- ____________________________________________________________________________
-- Column: prd_id
-- Quality check: Check for nulls or duplicates in primary Key after joining
-- Expected O/P: No result(if there is O/P, then gives the data that has null and duplicates)
-- ____________________________________________________________________________
Select 
	prd_id,
	count(*) cnt
from (
Select 
	pi.prd_id ,
	pi.cat_id ,
	pi.prd_key ,
	pi.prd_nm ,
	pc.cat ,
	pc.subcat ,
	pi.prd_cost ,
	pi.prd_line ,
	pi.prd_start_dt ,
	pi.prd_end_dt,
	pc.maintenance
from silver.crm_prd_info as pi
left join
silver.erp_px_cat_g1v2 as pc on pi.cat_id = pc.id
where pi.prd_end_dt is null
)
group by prd_id having count(*)>1 or prd_id is null; -- no result


-- ____________________________________________________________________________________________________

select *  from gold.dim_products; -- quality check after creating dim_products view




-- =========================================================================================================================================================================================================================================================================================
-- Sales(fact_sales)
-- =========================================================================================================================================================================================================================================================================================

select *  from gold.fact_sales as s
left join gold.dim_products p
on s.product_key = p.product_key
left join gold.dim_customers c
on s.customer_key = c.customer_key
-- where p.product_key is null -- quality check after creating fact_sales view for foreign key integrity(o/p should be no result]) -- noresult 
where c.customer_key is null; -- quality check after creating fact_sales view for foreign key integrity(o/p should be no result]) -- noresult
