/*
============================================================
Quality Checks
============================================================

Script Purpose:
   This script performs various quality checks for data consistency, accuracy,
   and standardization across the 'silver' schemas. It includes checks for:
   - Null or duplicate primary keys.
   - Unwanted spaces in string fields.
   - Data standardization and consistency.
   - Invalid date ranges and orders.
   - Data consistency between related fields.

Usage Notes:
   - Run these checks after data loading Silver Layer.
   - Investigate and resolve any discrepancies found during the checks.
============================================================
*/



--QUALITY CHECKS (Validation ) silver.crm_prd_info 

--check for Nulls or duplicates in PK 
SELECT 
prd_id,
COUNT(*)
FROM silver.crm_prd_info
GROUP BY prd_id 
HAVING COUNT(*) > 1 OR prd_id IS NULL 

-- Check for unwanted spaces 
SELECT prd_nm
FROM silver.crm_prd_info
WHERE prd_nm !=TRIM(prd_nm)

--Check for NULLs or Negative Numbers 
SELECT prd_cost 
FROM silver.crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL

--Data Standardization & Consistency 
SELECT DISTINCT prd_line 
FROM silver.crm_prd_info

--Check for Invalid Date orders 
SELECT *
FROM silver.crm_prd_info
WHERE prd_end_dt < prd_start_dt

SELECT *
FROM silver.crm_prd_info

--Data Quality Checks silver.crm_sales_details 

--Checking for unwanted spacing
SELECT 
sls_ord_num,
sls_prd_key,
sls_cust_id,
sls_order_dt,
sls_ship_dt,
sls_due_dt,
sls_sales,
sls_quantity,
sls_price
FROM bronze.crm_sales_details
WHERE sls_ord_num != TRIM(sls_ord_num)

--checking for the integrity of product key 
SELECT 
sls_ord_num,
sls_prd_key,
sls_cust_id,
sls_order_dt,
sls_ship_dt,
sls_due_dt,
sls_sales,
sls_quantity,
sls_price
FROM bronze.crm_sales_details
WHERE sls_prd_key NOT IN (SELECT prd_key FROM silver.crm_prd_info)

-- Checking for negative numbers or zeros because they can't be cast to a date 

SELECT
NULLIF(sls_order_dt,0) sls_order_dt
FROM bronze.crm_sales_details 
WHERE sls_order_dt <=0 
OR LEN(sls_order_dt) != 8 --can't be converted to a date 
OR sls_order_dt >20500101 --out of business range 
OR sls_order_dt < 19000101 --out of business range 

--check for invalid date orders ( the order dates must  be earlier than the shipping and due date ) 
SELECT 
*
FROM bronze.crm_sales_details
WHERE sls_order_dt > sls_ship_dt OR sls_order_dt > sls_due_dt

--sum of sales = quantity * price , negative, zeros , NULLs are not allowed 
SELECT DISTINCT
sls_sales,
sls_quantity,
sls_price
FROM bronze.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price 
OR sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL 
OR sls_sales <= 0 OR sls_quantity <= 0 OR sls_price <= 0 
ORDER BY sls_sales,sls_quantity,sls_price
