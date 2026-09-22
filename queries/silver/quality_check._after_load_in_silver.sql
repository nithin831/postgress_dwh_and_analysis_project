-- =========================================================================================================================================================================================================================================================================================
-- CRM
-- =========================================================================================================================================================================================================================================================================================

-- *******************************************************************************
-- Source Table: silver.crm_cust_info
-- *******************************************************************************
select * from silver.crm_cust_info;

-- ____________________________________________________________________________
-- Column: cst_id
-- Quality check: Check for nulls or duplicates in primary Key
-- Expected O/P: No result(if there is O/P, then gives the data that has null and duplicates)
-- ____________________________________________________________________________
select cst_id, count(*) cnt from silver.crm_cust_info group by cst_id having count(*)>1 or cst_id is null; -- no result

-- ____________________________________________________________________________
-- Column: cst_id
-- Quality check: select the latest primary key that has duplicate based on create date(solution for dupilicates)
-- Expected O/P: result with no duplicate
-- ____________________________________________________________________________
select * from (select *, row_number() over (partition by cst_id order by cst_create_date desc) flag from silver.crm_cust_info) where flag=1 and cst_id is not null;

-- ____________________________________________________________________________
-- Column: cst_key, cst_firstname, cst_lastname, cst_marital_status, cst_gndr
-- Quality check: check for unwanted space
-- Expected O/P: no result(if there is O/P, then gives the data is with unwanted space)
-- solution to clean is use trim()(refer cleaned_load.sql)
-- ____________________________________________________________________________
select cst_firstname from silver.crm_cust_info where cst_firstname != trim(cst_firstname); -- no result
select cst_key from silver.crm_cust_info where cst_key != trim(cst_key); -- no result
select cst_lastname from silver.crm_cust_info where cst_lastname != trim(cst_lastname); -- no result
select cst_marital_status from silver.crm_cust_info where cst_marital_status != trim(cst_marital_status); -- no result
select cst_gndr from silver.crm_cust_info where cst_gndr != trim(cst_gndr); -- no result


-- ____________________________________________________________________________
-- Column: cst_marital_status, cst_gndr
-- Quality check: check the consistency of values(check for differnt values) in low cardinality columns(less no of different values) 
-- Expected O/P: distinct values, but w/o abbrevation
-- solution : give the full abbrevation of the data(refer cleaned_load.sql)
-- ____________________________________________________________________________
select distinct cst_marital_status from silver.crm_cust_info;
select distinct cst_gndr from silver.crm_cust_info; 




-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++



-- *******************************************************************************
-- Source Table: silver.crm_prd_info
-- *******************************************************************************
select * from silver.crm_prd_info;

-- ____________________________________________________________________________
-- Column: prd_id
-- Quality check: Check for nulls or duplicates in primary Key
-- Expected O/P: No result(if there is O/P, then gives the data that has null and duplicates)
-- ____________________________________________________________________________
select prd_id, count(*) cnt from silver.crm_prd_info group by prd_id having count(*)>1 or prd_id is null; -- no result

-- ____________________________________________________________________________
-- Column: prd_nm
-- Quality check: check for unwanted space
-- Expected O/P: no result(if there is O/P, then gives the data is with unwanted space)
-- solution to clean is use trim()(refer cleaned_load.sql)
-- ____________________________________________________________________________
select prd_nm from silver.crm_prd_info where prd_nm != trim(prd_nm); -- no result


-- ____________________________________________________________________________
-- Column: prd_cost
-- Quality check: Check for nulls or negative no 
-- Expected O/P: No result(if there is O/P, then there are null or negative no)
-- solution: replace null or -ve no to 0
-- ____________________________________________________________________________
select prd_nm, prd_cost from silver.crm_prd_info where prd_cost < 0 or prd_cost is null; -- no result

-- ____________________________________________________________________________
-- Column: prd_line
-- Quality check: check the consistency of values(check for differnt values) in low cardinality columns(less no of different values) 
-- Expected O/P: distinct values, but w/o abbrevation
-- solution : give the full abbrevation of the data(refer cleaned_load.sql)
-- ____________________________________________________________________________
select distinct prd_line from silver.crm_prd_info;

-- ____________________________________________________________________________
-- Column: prd_start_dt, prd_end_dt
-- Quality check: Check for invalid date(end date must not be earlier than start date)
-- Expected O/P: No result(if there is O/P, then there are invalid date)
-- solution: ignore end date value and for end date, consider 1 day behind of start date of the next same product  
-- ____________________________________________________________________________
select prd_start_dt, prd_end_dt from silver.crm_prd_info where prd_end_dt < prd_start_dt; -- no result



-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++



-- *******************************************************************************
-- Source Table: silver.crm_sales_details
-- *******************************************************************************
select * from silver.crm_sales_details;

-- ____________________________________________________________________________
-- Column: sls_ord_num, sls_prd_key, sls_cust_id 
-- Quality check: Check for nulls
-- Expected O/P: No result(if there is O/P, then gives the data that has null)
-- ____________________________________________________________________________
select sls_ord_num from silver.crm_sales_details where sls_ord_num is null; -- no result
select sls_prd_key from silver.crm_sales_details where sls_prd_key is null; -- no result
select sls_cust_id from silver.crm_sales_details where sls_cust_id is null; -- no result

-- ____________________________________________________________________________
-- Quality check: Check for relationships b/w other table
-- Expected O/P: No result(if there is O/P, then ther are few unmacthed keys)
-- ____________________________________________________________________________
select * from silver.crm_sales_details where sls_prd_key not in (select prd_key from silver.crm_prd_info); -- no result
select * from silver.crm_sales_details where sls_cust_id not in (select cst_id from silver.crm_cust_info); -- no result

-- ____________________________________________________________________________
-- Column: sls_order_dt, sls_ship_dt, sls_due_dt 
-- Quality check: Check for datatype
-- Expected O/P: Date datatype
-- soultion: if it is not date type cast it to date 
-- ____________________________________________________________________________
select pg_typeof(sls_order_dt), pg_typeof(sls_ship_dt), pg_typeof(sls_due_dt) from silver.crm_sales_details; -- date

-- ____________________________________________________________________________
-- Column: sls_order_dt(business rule: 19000101 < sls_order_dt < 20500101), sls_ship_dt, sls_due_dt 
-- Quality check: Check for invalid date(sls_order_dt< sls_ship_dt and sls_due_dt, and should not be negative value, lenghtof character should be 8)
-- Expected O/P: No result(if there is O/P, then there are invalid date)
-- solution: cast varchar to date, invalid date to null
-- ____________________________________________________________________________
select sls_order_dt from silver.crm_sales_details where sls_order_dt < '1900-01-01' or sls_order_dt > '2050-01-01'; -- no result
select sls_ship_dt from silver.crm_sales_details where sls_ship_dt < '1900-01-01' or sls_ship_dt > '2050-01-01'; -- no result  
select sls_due_dt from silver.crm_sales_details where  sls_due_dt < '1900-01-01' or sls_due_dt > '2050-01-01'; -- no result  

select * from silver.crm_sales_details where sls_order_dt > sls_ship_dt or sls_order_dt > sls_due_dt; -- no result

-- ____________________________________________________________________________
-- Column: sls_sales, sls_quantity, sls_price (business rule: sales = quantity * price)
-- Quality check: Check for nulls, negative values, business rule(business rule: sales = quantity * price)
-- Expected O/P: No result(if there is O/P, then there are null, zeros and -ve no's and few calucations are wrong)
-- solution: >> if sales is null, zeros or -ve no's or not equal to quantity * price, then solve it using quantity * price.
-- 			 >> if price is null or zeros, then solve it using sales/quantity.
-- 			 >> if price is -ve, then convert it to positive
-- ____________________________________________________________________________
select sls_sales, sls_quantity, sls_price from silver.crm_sales_details where sls_sales != sls_quantity*sls_price or 
sls_sales is null or sls_quantity is null or sls_price is null or
sls_sales <= 0 or sls_quantity <= 0 or sls_price <= 0 order by sls_sales, sls_quantity, sls_price; -- observed quantity is good, but sales and price, there are null, zeros and -ve no's and few calucations are wrong


-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


-- =========================================================================================================================================================================================================================================================================================
-- ERP
-- =========================================================================================================================================================================================================================================================================================

-- *******************************************************************************
-- Source Table: silver.erp_cust_az12
-- *******************************************************************************
select * from silver.erp_cust_az12;

-- ____________________________________________________________________________
-- Column: cid
-- Quality check: Check for nulls
-- Expected O/P: No result(if there is O/P, then gives the data that has null)
-- ____________________________________________________________________________
select cid from silver.erp_cust_az12 where cid is null; -- no result

-- ____________________________________________________________________________
-- Column: cid
-- Quality check: check for unwanted space
-- Expected O/P: no result(if there is O/P, then gives the data is with unwanted space)
-- solution to clean is use trim()(refer cleaned_load.sql)
-- ____________________________________________________________________________
select cid from silver.erp_cust_az12 where cid != trim(cid); -- no result

-- ____________________________________________________________________________
-- Column: cid
-- Quality check: Handle cid(check for different pattern in cid)
-- Expected O/P: different pattern in cid
-- ____________________________________________________________________________
select cid from silver.erp_cust_az12 where cid like '%AW000%'; -- Only begins with AW000
select cid from silver.erp_cust_az12 where cid like 'NAS%'; -- count - 0
select cid from silver.erp_cust_az12 where cid like 'AW000%'; -- count - 18484
select * from silver.erp_cust_az12; -- count - 18484 

-- ____________________________________________________________________________
-- Column: bdate
-- Quality check: Check for invalid date(bdate cannot be more than current date)
-- Expected O/P: No result(if there is O/P, then there are invalid date)
-- solution: invalid date to null
-- ____________________________________________________________________________
select bdate from silver.erp_cust_az12 where bdate > now(); --  No result 

-- ____________________________________________________________________________
-- Column: gen
-- Quality check: check the consistency of values(check for differnt values and handle it) in low cardinality columns(less no of different values) 
-- Expected O/P: distinct values, but w/o abbrevation
-- solution : give the full abbrevation of the data and empty string as n/a(refer cleaned_load.sql)
-- ____________________________________________________________________________
select distinct gen from silver.erp_cust_az12;



-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


-- *******************************************************************************
-- Source Table: silver.erp_loc_a101
-- *******************************************************************************
select * from silver.erp_loc_a101;

-- ____________________________________________________________________________
-- Column: cid
-- Quality check: Check for nulls
-- Expected O/P: No result(if there is O/P, then gives the data that has null)
-- ____________________________________________________________________________
select cid from silver.erp_loc_a101 where cid is null; -- no result

-- ____________________________________________________________________________
-- Column: cntry
-- Quality check: check the consistency of values(check for differnt values) in low cardinality columns(less no of different values) 
-- Expected O/P: distinct values, but w/o abbrevation
-- solution : give the full abbrevation of the data and convert null or empty string as n/a(refer cleaned_load.sql)
-- ____________________________________________________________________________
select distinct cntry from silver.erp_loc_a101;


-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


-- *******************************************************************************
-- Source Table: silver.erp_px_cat_g1v2
-- *******************************************************************************
select * from silver.erp_px_cat_g1v2;

-- ____________________________________________________________________________
-- Column: id, cat, subcat, maintenance 
-- Quality check: Check for nulls
-- Expected O/P: No result(if there is O/P, then gives the data that has null)
-- ____________________________________________________________________________
select id from silver.erp_px_cat_g1v2 where id is null; -- no result
select cat from silver.erp_px_cat_g1v2 where cat is null; -- no result
select subcat from silver.erp_px_cat_g1v2 where subcat is null; -- no result
select maintenance from silver.erp_px_cat_g1v2 where maintenance is null; -- no result

-- ____________________________________________________________________________
-- Column: id, cat, subcat, maintenance 
-- Quality check: check for unwanted space
-- Expected O/P: no result(if there is O/P, then gives the data is with unwanted space)
-- solution to clean is use trim()(refer cleaned_load.sql)
-- ____________________________________________________________________________
select id from silver.erp_px_cat_g1v2 where id != trim(id); -- no result
select cat from silver.erp_px_cat_g1v2 where cat != trim(cat); -- no result
select subcat from silver.erp_px_cat_g1v2 where subcat != trim(subcat); -- no result
select maintenance from silver.erp_px_cat_g1v2 where maintenance != trim(maintenance); -- no result

-- ____________________________________________________________________________
-- Column: cat, subcat, maintenance 
-- Quality check: check the consistency of values(check for differnt values) in low cardinality columns(less no of different values) 
-- Expected O/P: distinct values
-- solution : give the full abbrevation of the data and empty string as n/a(refer cleaned_load.sql)
-- ____________________________________________________________________________
select distinct cat from silver.erp_px_cat_g1v2;
select distinct maintenance from silver.erp_px_cat_g1v2;
select distinct subcat from silver.erp_px_cat_g1v2;



-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++



-- to call stored procedure for silver load: call silver.silver_clean_load();





