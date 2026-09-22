-- ********************************************************************************************************************
-- This script is used to create the silver layer tables in the data warehouse,
-- where the data from the bronze layer will be loaded after performing necessary cleaning of each column in each table.
-- ********************************************************************************************************************

-- ==============================================
-- Source: CMR(cust_info.csv file)
-- ==============================================

DROP TABLE IF EXISTS silver.crm_cust_info;

-- creating the table for customer info
CREATE TABLE IF NOT EXISTS silver.crm_cust_info(
	cst_id int,
	cst_key varchar(50),
	cst_firstname varchar(50),
	cst_lastname varchar(50),
	cst_marital_status varchar(50),
	cst_gndr varchar(50),
	cst_create_date date, 
	dwh_create_date TIMESTAMPTZ default NOW() -- metadata column to track the datetime when the record was created in the data warehouse
);

select * from silver.crm_cust_info;


-- ==============================================
-- Source: CMR(prd_info.csv file)
-- ==============================================

DROP TABLE IF EXISTS silver.crm_prd_info;

-- creating the table for product info
CREATE TABLE IF NOT EXISTS silver.crm_prd_info(
	prd_id int,
	cat_id varchar(50),
	prd_key varchar(50),
	prd_nm varchar(50),
	prd_cost int,
	prd_line varchar(50),
	prd_start_dt date,
	prd_end_dt date,
	dwh_create_date TIMESTAMPTZ default NOW() -- metadata column to track the datetime when the record was created in the data warehouse
);

select * from silver.crm_prd_info;


-- ==============================================
-- Source: CMR(sales_details.csv file)
-- ==============================================

DROP TABLE IF EXISTS silver.crm_sales_details;

-- creating the table for Sales info
CREATE TABLE IF NOT EXISTS silver.crm_sales_details(
	sls_ord_num varchar(50),
	sls_prd_key varchar(50),
	sls_cust_id int,
	sls_order_dt Date, -- changed form varchar to date
	sls_ship_dt Date, -- changed form varchar to date
	sls_due_dt Date, -- changed form varchar to date
	sls_sales int,
	sls_quantity int,
	sls_price int,
	dwh_create_date TIMESTAMPTZ default NOW() -- metadata column to track the datetime when the record was created in the data warehouse
);

select * from silver.crm_sales_details;


-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


-- ==============================================
-- Source: ERP(CUST_AZ12.csv file)
-- ==============================================

DROP TABLE IF EXISTS silver.erp_cust_az12;

-- creating the table for Customer info
CREATE TABLE IF NOT EXISTS silver.erp_cust_az12(
	cid varchar(50),
    bdate date,
    gen varchar(50),
	dwh_create_date TIMESTAMPTZ default NOW() -- metadata column to track the datetime when the record was created in the data warehouse
);

select * from silver.erp_cust_az12;


-- ==============================================
-- Source: ERP(LOC_A101.csv file)
-- ==============================================

DROP TABLE IF EXISTS silver.erp_loc_a101;

-- creating the table for Customer location info
CREATE TABLE IF NOT EXISTS silver.erp_loc_a101
(
    cid varchar(50),
    cntry varchar(50),
	dwh_create_date TIMESTAMPTZ default NOW() -- metadata column to track the datetime when the record was created in the data warehouse
);

select * from silver.erp_loc_a101;


-- ==============================================
-- Source: ERP(PX_CAT_G1V2.csv file)
-- ==============================================

DROP TABLE IF EXISTS silver.erp_px_cat_g1v2;

-- creating the table for Product info
CREATE TABLE IF NOT EXISTS silver.erp_px_cat_g1v2
(
    id varchar(50),
    cat varchar(50),
    subcat varchar(50),
    maintenance varchar(50),
	dwh_create_date TIMESTAMPTZ default NOW() -- metadata column to track the datetime when the record was created in the data warehouse
);

select * from silver.erp_px_cat_g1v2;
