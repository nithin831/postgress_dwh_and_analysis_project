-- ==============================================
-- Source: CMR(cust_info.csv file)
-- ==============================================

DROP TABLE IF EXISTS bronze.crm_cust_info;

-- creating the table for customer info
CREATE TABLE IF NOT EXISTS bronze.crm_cust_info(
	cst_id int,
	cst_key varchar(50),
	cst_firstname varchar(50),
	cst_lastname varchar(50),
	cst_marital_status varchar(50),
	cst_gndr varchar(50),
	cst_create_date date
);

-- use the below cmd in psql tool to import the csv file to table or use ui to directly import csv file to table(right click on table name) 
\copy bronze.crm_cust_info(cst_id, cst_key, cst_firstname, cst_lastname, cst_marital_status, cst_gndr, cst_create_date) FROM 'C:\Users\Nithin Kumar U\OneDrive\Documents\DWH_ProjectPostgress\datasets\source_crm\cust_info.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',');

select * from bronze.crm_cust_info;


-- ==============================================
-- Source: CMR(prd_info.csv file)
-- ==============================================

DROP TABLE IF EXISTS bronze.crm_prd_info;

-- creating the table for product info
CREATE TABLE IF NOT EXISTS bronze.crm_prd_info(
	prd_id int,
	prd_key varchar(50),
	prd_nm varchar(50),
	prd_cost int,
	prd_line varchar(50),
	prd_start_dt date,
	prd_end_dt date
);

select * from bronze.crm_prd_info;


-- ==============================================
-- Source: CMR(sales_details.csv file)
-- ==============================================

DROP TABLE IF EXISTS bronze.crm_sales_details;

-- creating the table for Sales info
CREATE TABLE IF NOT EXISTS bronze.crm_sales_details(
	sls_ord_num varchar(50),
	sls_prd_key varchar(50),
	sls_cust_id int,
	sls_order_dt varchar(50),
	sls_ship_dt varchar(50),
	sls_due_dt varchar(50),
	sls_sales int,
	sls_quantity int,
	sls_price int
);

select * from bronze.crm_sales_details;


-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


-- ==============================================
-- Source: ERP(CUST_AZ12.csv file)
-- ==============================================

DROP TABLE IF EXISTS bronze.erp_cust_az12;

-- creating the table for Customer info
CREATE TABLE IF NOT EXISTS bronze.erp_cust_az12(
	cid varchar(50),
    bdate date,
    gen varchar(50)
);

select * from bronze.erp_cust_az12;


-- ==============================================
-- Source: ERP(LOC_A101.csv file)
-- ==============================================

DROP TABLE IF EXISTS bronze.erp_loc_a101;

-- creating the table for Customer location info
CREATE TABLE IF NOT EXISTS bronze.erp_loc_a101
(
    cid varchar(50),
    cntry varchar(50)
);

select * from bronze.erp_loc_a101;


-- ==============================================
-- Source: ERP(PX_CAT_G1V2.csv file)
-- ==============================================

DROP TABLE IF EXISTS bronze.erp_px_cat_g1v2;

-- creating the table for Product info
CREATE TABLE IF NOT EXISTS bronze.erp_px_cat_g1v2
(
    id varchar(50),
    cat varchar(50),
    subcat varchar(50),
    maintenance varchar(50)
)

select * from bronze.erp_px_cat_g1v2;
