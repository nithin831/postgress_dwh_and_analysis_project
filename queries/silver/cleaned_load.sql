create or replace procedure silver.silver_clean_load()
LANGUAGE plpgsql
AS $$
DECLARE
	v_detail    text;
	v_hint      text;
	v_context   text;
	v_count INTEGER;
begin
	-- =========================================================================================================================================================================================================================================================================================
	-- CRM
	-- =========================================================================================================================================================================================================================================================================================
	
	-- ************************************************************************************************************************
	-- cleaning involved in crm_cust_info 
	-- 1. Remove unwanted space
	-- 2. Data Normalization and Standardization - abbrevating short forms
	-- 3. Handeling missing values - null to n/a
	-- 4. removing duplicates 
	-- ************************************************************************************************************************
	
	-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	-- Inserting the cleaned data after performing quality check from bronze.crm_cust_info and loading to silver.crm_cust_info
	-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

	RAISE NOTICE 'Truncate table silver.crm_cust_info';
	Truncate table silver.crm_cust_info;
	
	RAISE NOTICE 'Inserting the cleaned data after performing quality check from bronze.crm_cust_info and loading to silver.crm_cust_info';
	Insert into silver.crm_cust_info
	(cst_id, cst_key, cst_firstname, cst_lastname, cst_marital_status, cst_gndr, cst_create_date)
	select 
		cst_id,
		cst_key,
		trim(cst_firstname),
		trim(cst_lastname),
		case upper(trim(cst_marital_status))
			when 'M' then 'Married'
			when 'S' then 'Single'
			else 'n/a'
		end cst_marital_status,
		case 
			when upper(trim(cst_gndr)) = 'M' then 'Male'
			when upper(trim(cst_gndr)) = 'F' then 'Female'
			else 'n/a'
		end cst_gndr,
		cst_create_date
	from (
			select *, row_number() over (partition by cst_id order by cst_create_date desc) flag 
			from bronze.crm_cust_info
		) where flag=1 and cst_id is not null; 

	GET DIAGNOSTICS v_count = ROW_COUNT;
	RAISE NOTICE 'Rows inserted in silver.crm_cust_info: %', v_count;
	RAISE NOTICE ' ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ ';
	
	-- Select * from silver.crm_cust_info;
	
	
	
	
	-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	
	
	
	-- ************************************************************************************************************************
	-- cleaning involved in crm_prd_info 
	-- 1. Remove unwanted space
	-- 2. Data Normalization and Standardization - abbrevating short forms
	-- 3. Handeling missing values - null to n/a or 0
	-- 4. removing duplicates 
	-- 5. derived new columns from existing column(prd_key to prd_key and cat_id, to maintain relationships))
	-- ************************************************************************************************************************
	
	-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	-- Inserting the cleaned data after performing quality check from bronze.crm_prd_info and loading to silver.crm_prd_info
	-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

	RAISE NOTICE 'Truncate table silver.crm_prd_info';
	Truncate table silver.crm_prd_info;

	RAISE NOTICE 'Inserting the cleaned data after performing quality check from bronze.crm_prd_info and loading to silver.crm_prd_info';
	insert into silver.crm_prd_info(
		prd_id ,
		cat_id ,
		prd_key ,
		prd_nm ,
		prd_cost ,
		prd_line ,
		prd_start_dt ,
		prd_end_dt 
	)select 
		prd_id ,
		-- prd_key , -- this column contain 2 info(frist five character is catagoery id and next character is prd_key - refer data_model.drawio) 
		replace(substring(prd_key, 1, 5), '-', '_') cat_id, -- add this column in table
		substring(prd_key, 7, length(prd_key)) prd_key, -- add this column in table
		prd_nm ,
		coalesce (prd_cost,0),
		case upper(trim(prd_line)) 
			when 'M' then 'Mountains'
			when 'S' then 'Sports'
			when 'T' then 'Touring'
			when 'R' then 'Roads'
			else 'n/a'
		end prd_line,
		prd_start_dt ,
		lead(prd_start_dt)over(partition by prd_nm order by prd_start_dt) -1 as prd_end_dt-- ignore end date value and for end date, consider 1 day behind of start date of the next same product
	from bronze.crm_prd_info;

	GET DIAGNOSTICS v_count = ROW_COUNT;
	RAISE NOTICE 'Rows inserted in silver.crm_prd_info: %', v_count;
	RAISE NOTICE ' ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ ';

	
	-- Select * from silver.crm_prd_info;
	
	
	
	-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	
	
	
	-- ************************************************************************************************************************
	-- cleaning involved in crm_sales_details 
	-- 1. Remove unwanted space
	-- 2. Handeling invalid data(dates, sales, price)
	-- 3. Type casting varchar to date
	-- 3. Handeling missing values - null to n/a or 0
	-- 4. removing duplicates 
	-- 5. derived columns from existing column for invalid data(sales = quantity * price or price = sales/quantity)
	-- ************************************************************************************************************************
	
	-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	-- Inserting the cleaned data after performing quality check from bronze.crm_sales_details and loading to silver.crm_sales_details
	-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	
	RAISE NOTICE 'Truncate table silver.crm_sales_details';
	Truncate table silver.crm_sales_details;
	
	RAISE NOTICE 'Inserting the cleaned data after performing quality check from bronze.crm_sales_details and loading to silver.crm_sales_details';
	Insert into silver.crm_sales_details(
		sls_ord_num ,
		sls_prd_key ,
		sls_cust_id ,
		sls_order_dt,
		sls_ship_dt,
		sls_due_dt,
		sls_sales,
		sls_quantity,
		sls_price
	)select 
		sls_ord_num ,
		sls_prd_key ,
		sls_cust_id ,
		case 
			when length(sls_order_dt) != 8 or sls_order_dt::int = 0 then null
			else to_date(sls_order_dt, 'YYYYMMDD') 
		end as sls_order_dt, -- cast varchar to date, invalid date to null
		case 
			when length(sls_ship_dt) != 8 or sls_ship_dt::int = 0 then null
			else to_date(sls_ship_dt, 'YYYYMMDD') 
		end as sls_ship_dt, -- cast varchar to date, invalid date to null
		case 
			when length(sls_due_dt) != 8 or sls_due_dt::int = 0 then null
			else to_date(sls_due_dt, 'YYYYMMDD') 
		end as sls_due_dt, -- cast varchar to date, invalid date to null
		case
			when sls_sales <= 0 or sls_sales is null or sls_sales != sls_quantity*sls_price then abs(sls_quantity*sls_price)
			else abs(sls_sales)
		end sls_sales, -- if sales is null, zeros or -ve no's or not equal to quantity * price, then solve it using quantity * price.
		abs(sls_quantity), 
		case 
			when sls_price <= 0 or sls_price is null  then abs(sls_sales/nullif(sls_quantity, 0))
			else abs(sls_price)
		end sls_price -- if price is null or zeros, then solve it using sales/quantity and if price is -ve, then convert it to positive.
	from bronze.crm_sales_details;

	GET DIAGNOSTICS v_count = ROW_COUNT;
	RAISE NOTICE 'Rows inserted in silver.crm_sales_details: %', v_count;
	RAISE NOTICE ' ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ ';

	-- select * from silver.crm_sales_details;
	
	
	
	-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	
	
	-- =========================================================================================================================================================================================================================================================================================
	-- ERP
	-- =========================================================================================================================================================================================================================================================================================
	
	-- ************************************************************************************************************************
	-- cleaning involved in erp_cust_az12 
	-- 1. Remove unwanted space
	-- 2. Data Normalization and Standardization - abbrevating short forms
	-- 3. Handeling missing values - null to n/a
	-- 4. Handeling invalid data(bdate)
	-- 5. Handel cid(remove NAS, to maintain relationships))
	-- ************************************************************************************************************************
	
	-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	-- Inserting the cleaned data after performing quality check from bronze.erp_cust_az12 and loading to silver.erp_cust_az12
	-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

	RAISE NOTICE 'Truncate table silver.erp_cust_az12';
	Truncate table silver.erp_cust_az12;

	RAISE NOTICE 'Inserting the cleaned data after performing quality check from bronze.erp_cust_az12 and loading to silver.erp_cust_az12';
	Insert into silver.erp_cust_az12 (
	cid, 
	bdate,
	gen
	)select 
		Case 
			when cid like 'NAS%' then substring(cid, 4, length(cid))
			else cid
		end cid ,
		Case 
			when bdate > now() then null
			else bdate
		end bdate ,
		case 
			when upper(trim(gen)) in ('M', 'MALE') then 'Male'
			when upper(trim(gen)) in ('F', 'FEMALE') then 'Female'
			else 'n/a'
		end gen
	from bronze.erp_cust_az12;

	GET DIAGNOSTICS v_count = ROW_COUNT;
	RAISE NOTICE 'Rows inserted in silver.erp_cust_az12: %', v_count;
	RAISE NOTICE ' ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ ';

	-- select * from silver.erp_cust_az12;
	
	
	
	-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	
	
	
	-- ************************************************************************************************************************
	-- cleaning involved in erp_loc_a101 
	-- 1. Remove unwanted space
	-- 2. Data Normalization and Standardization - abbrevating short forms
	-- 3. Handeling missing values - null to n/a
	-- 4. Handel cntry(remove -, to maintain relationships)
	-- ************************************************************************************************************************
	
	-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	-- Inserting the cleaned data after performing quality check from bronze.erp_loc_a101 and loading to silver.erp_loc_a101
	-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

	RAISE NOTICE 'Truncate table silver.erp_loc_a101';
	Truncate table silver.erp_loc_a101;

	RAISE NOTICE 'Inserting the cleaned data after performing quality check from bronze.erp_loc_a101 and loading to silver.erp_loc_a101';
	insert into silver.erp_loc_a101(
		cid,
		cntry
	)select 
		replace(cid, '-', '') as cid, --converted like this because, needs to be same every where for relationship
		case
			when upper(trim(cntry)) in ('GERMANY', 'DE') then 'Germany'
			when upper(trim(cntry)) in ('UNITED STATES', 'US', 'USA') then 'United States'
			when upper(trim(cntry)) = '' or upper(trim(cntry)) is null then 'n/a'
			else trim(cntry)
		end cntry
	from bronze.erp_loc_a101;

	GET DIAGNOSTICS v_count = ROW_COUNT;
	RAISE NOTICE 'Rows inserted in silver.erp_loc_a101: %', v_count;
	RAISE NOTICE ' ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ ';

	-- select * from silver.erp_loc_a101;
	
	
	
	-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	
	
	
	-- ************************************************************************************************************************
	-- cleaning involved in erp_px_cat_g1v2 
	-- no need to clean, data is good after quality check
	-- ************************************************************************************************************************
	
	-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	-- Inserting the cleaned data after performing quality check from bronze.erp_px_cat_g1v2 and loading to silver.erp_px_cat_g1v2
	-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

	RAISE NOTICE 'Truncate table silver.erp_px_cat_g1v2';
	Truncate table silver.erp_px_cat_g1v2;

	RAISE NOTICE 'Inserting the cleaned data after performing quality check from bronze.erp_px_cat_g1v2 and loading to silver.erp_px_cat_g1v2';
	insert into silver.erp_px_cat_g1v2(
		id ,
		cat ,
		subcat ,
		maintenance
	)select 
		id ,
		cat ,
		subcat ,
		maintenance 
	from bronze.erp_px_cat_g1v2; -- no need to clean, data is good

	GET DIAGNOSTICS v_count = ROW_COUNT;
	RAISE NOTICE 'Rows inserted in silver.erp_px_cat_g1v2: %', v_count;
	RAISE NOTICE ' ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ ';

	-- select * from silver.erp_px_cat_g1v2;

	-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	

EXCEPTION
	WHEN OTHERS THEN
		RAISE NOTICE 'Error: %', SQLERRM;
		RAISE NOTICE 'Error code: %', SQLSTATE;

		GET STACKED DIAGNOSTICS
			v_detail  = PG_EXCEPTION_DETAIL,
			v_hint    = PG_EXCEPTION_HINT,
			v_context = PG_EXCEPTION_CONTEXT;

		RAISE NOTICE 'Detail: %', v_detail;
		RAISE NOTICE 'Hint: %', v_hint;
		RAISE NOTICE 'Context: %', v_context;

end;
$$;


-- to call stored procedure for silver load: call silver.silver_clean_load();




