# Data Warehouse and Analytics Project

## 📌 Project Overview

This project demonstrates the development of a **Data Warehouse (DWH)** using a layered data architecture consisting of:

- **Bronze Layer** – Raw data - Table
- **Silver Layer** – Cleaned and transformed data - Table
- **Gold Layer** – Business-ready dimensional model - Views
- **Data Analysis** – Postgres-based analysis to derive business insights and creating views inside **gold layer** for Customer and Product level analysis report 

The project integrates data from **CRM** and **ERP** source systems and organizes it into a **Star Schema** consisting of fact and dimension tables.

The Gold Layer is used to perform **data analysis using Postgres**, including sales, customer, product, and time-based analysis. Reusable **SQL views** are also created to simplify data access and support analytical reporting.

---

## 🏗️ Architecture

The project follows a **Medallion Architecture**

The overall data flow is:

**Source Systems → Bronze → Silver → Gold → Analytics / Reporting**

![Architecture](https://github.com/nithin831/postgress_dwh_and_analysis_project/blob/master/Document/architecture.png)

---

## 🥉 Bronze Layer

The Bronze layer stores the raw data ingested from the source systems with out any changes.

### Purpose

- Store raw source data
- Preserve the original data
- Maintain historical data
- Provide traceability for downstream transformations

### Bronze Data Model

![Bronze Data Model](https://github.com/nithin831/postgress_dwh_and_analysis_project/blob/master/Document/bronze_model.png)

### Bronze Layer – Table Queries
The Bronze Layer stores the raw data loaded from the CRM and ERP source systems.

```sql
SELECT * FROM bronze.crm_cust_info; -- Source: CRM, Schema: bronze, Table: crm_cust_info

SELECT * FROM bronze.crm_prd_info; -- Source: CRM, Schema: bronze, Table: crm_prd_info

SELECT * FROM bronze.crm_sales_details; -- Source: CRM, Schema: bronze, Table: crm_sales_details

SELECT * FROM bronze.erp_cust_az12; -- Source: ERP, Schema: bronze, Table: erp_cust_az12

SELECT * FROM bronze.erp_loc_a101; -- Source: ERP, Schema: bronze, Table: erp_loc_a101

SELECT * FROM bronze.erp_px_cat_g1v2; -- Source: ERP, Schema: bronze, Table: erp_px_cat_g1v2
```

---

## Silver Layer

The Silver layer contains cleaned, standardized, and transformed data from the Bronze layer.

### Purpose

- Clean and standardize data
- Handle NULL and invalid values
- Remove duplicates
- Standardize data types and formats
- Apply data quality rules

### Silver Data Model

![Silver Data Model](https://github.com/nithin831/postgress_dwh_and_analysis_project/blob/master/Document/silver_model.png)

### Clean Data load

Once data from the Bronze layer is cleaned and transformed, the quality check is performed to ensure that the data is accurate, complete, and consistent, then Stored procedure is created to load the cleaned data into the Silver layer.

```sql
call silver.silver_clean_load();-- Stored procedure to load cleaned data into Silver layer
```

### Silver Layer – Table Queries

The Silver Layer contains the cleaned and transformed data after performing quality checks considering source as bronze layer tables.

```sql
SELECT * FROM silver.crm_cust_info; -- Source: Bronze, Schema: silver, Table: crm_cust_info

SELECT * FROM silver.crm_prd_info; -- Source: Bronze, Schema: silver, Table: crm_prd_info

SELECT * FROM silver.crm_sales_details; -- Source: Bronze, Schema: silver, Table: crm_sales_details

SELECT * FROM silver.erp_cust_az12; -- Source: Bronze, Schema: silver, Table: erp_cust_az12

SELECT * FROM silver.erp_loc_a101; -- Source: Bronze, Schema: silver, Table: erp_loc_a101

SELECT * FROM silver.erp_px_cat_g1v2; -- Source: Bronze, Schema: silver, Table: erp_px_cat_g1v2
```

---

## Gold Layer

The Gold layer contains business-ready data designed for analytics, reporting, and dashboards.

### Purpose

- Provide business-friendly datasets
- Apply business rules and transformations
- Support reporting and analytics
- Simplify analytical queries
- Implement dimensional modeling

The Gold layer typically consists of:

- Fact tables
- Dimension tables
- Surrogate keys
- Measures
- Business attributes

### Gold Data Model

![Gold Data Model](https://github.com/nithin831/postgress_dwh_and_analysis_project/blob/master/Document/gold_model.png)

### Gold Layer – Views Queries

The Gold Layer contains the business-ready data after performing quality checks and transformations for analytical purposes.

```sql
select * from gold.dim_customers; -- customer view
 -- Source: Silver, Schema: gold, View: dim_customers

SELECT * FROM gold.dim_products; -- product view
 -- Source: Silver, Schema: gold, View: dim_products

SELECT * FROM gold.fact_sales; -- sales fact view
 -- Source: Silver, Schema: gold, View: fact_sales

SELECT * FROM gold.customer_analysis_report; -- customer report view
 -- Source: gold, Schema: gold, View: customer_analysis_report

SELECT * FROM gold.product_analysis_report; -- product report view
 -- Source: gold, Schema: gold, View: product_analysis_report
```

---

## 📊 Data Analysis

After building the Gold Layer, PostgreSQL-based analysis was performed to extract meaningful business insights from the data warehouse.

The analysis focuses on areas such as:

- Customer analysis
- Product analysis
- Sales analysis
- Revenue and sales performance
- Customer purchasing behavior
- Product performance
- Sales trends over time
- Category and product-level analysis
- Ranking and comparison of customers and products

The analysis was performed using PostgreSQL and included:

- Aggregations using `SUM()`, `COUNT()`, `AVG()`, `MIN()`, and `MAX()`
- Filtering using `WHERE` and `HAVING`
- Grouping using `GROUP BY`
- Joins between fact and dimension tables
- Common Table Expressions (CTEs)
- Subqueries
- Date and time functions
- Window functions such as:
  - `RANK()`
  - `DENSE_RANK()`
  - `ROW_NUMBER()`
  - `LAG()`
  - `LEAD()`
  - Running totals
- Conditional logic using `CASE`
- Customer and product segmentation

---

## 👁️ PostgreSQL Views

To simplify analysis and provide reusable datasets, PostgreSQL **Views** were created on top of the Gold Layer.

The views encapsulate commonly used analytical queries and allow business-level data to be accessed without repeatedly writing complex joins and calculations for **Customer** and **Product** analysis.

## 1. **Customer Report View**

### Purpose:

- This report consolidates key customer metrics and behaviors

### Highlights:

1. Gathers essential fields such as names, ages, and transaction details.
2. Aggregates customer-level metrics:
    - total orders
    - total sales
    - total quantity purchased
    - total products
    - lifespan ->diff of max and min of orderdate(first order to last order) - order_lifespan
3. Segments customers into categories (VIP, Regular, New) and age groups.
    - vip: customers with atleast 12 months of history and spending more than 5000
    - regular: customers with atleast 12 months of history but spending 5000 or less
    - new: customer with lifespan less than 12 months
4. Calculates valuable KPIs:
    - recency (since last order till now)
    - average order value(total_sales/total_orders)
    - average yearly spend(total_sales/order_life_span)

### Views Queries:

```sql
SELECT * FROM gold.customer_analysis_report; -- customer report view
 -- Source: gold, Schema: gold, View: customer_analysis_report
```


## 2. **Product Report View**

### Purpose:

- This report consolidates key product metrics and behaviors.

### Highlights:

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
     
### Views Queries:

```sql
SELECT * FROM gold.product_analysis_report; -- product report view
 -- Source: gold, Schema: gold, View: product_analysis_report
```


