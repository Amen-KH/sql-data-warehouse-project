--very important  Check : checking for duplicates in customers 
SELECT cst_id , COUNT(*) FROM
(SELECT 
ci.cst_id,
ci.cst_key,
ci.cst_firstname,
ci.cst_lastname,
ci.cst_marital_status,
ci.cst_gndr,
ci.cst_create_date,
ca.bdate,
ca.gen,
la.cntry
FROM silver.crm_cust_info ci
LEFT JOIN silver.erp_cust_az12 ca 
ON ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 la
ON ci.cst_key = la.cid) t GROUP BY cst_id
HAVING COUNT(*) > 1*/

/* check for prd_key duplicates 
SELECT product_number , COUNT(*) FROM (
SELECT
    pn.prd_id       AS product_id,
    pn.prd_key      AS product_number,
    pn.prd_nm       AS product_name,
    pn.cat_id       AS category_id,
    pc.cat          AS category,
    pc.subcat       AS subcategory,
    pc.maintenance  AS maintenance,
    pn.prd_cost     AS cost,
    pn.prd_line     AS product_line,
    pn.prd_start_dt AS start_date
FROM silver.crm_prd_info pn
LEFT JOIN silver.erp_px_cat_g1v2 pc
    ON pn.cat_id = pc.id
WHERE pn.prd_end_dt IS NULL-- select only the current data 
)t GROUP BY product_number
HAVING COUNT(*) > 1 


--Data Integration 
SELECT DISTINCT 
ci.cst_gndr,
ca.gen,
CASE WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr --CRM IS THE MASTER for gender info
	 ELSE COALESCE(ca.gen,'n/a')
END AS new_gen
FROM silver.crm_cust_info ci
LEFT JOIN silver.erp_cust_az12 ca 
ON ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 la
ON ci.cst_key = la.cid
ORDER BY 1,2

--Foreign key integrity (Dimensions ) --> run this check after creating all the dim /dact tables in the gold layer , do it for each dim with the fact 
SELECT  
*
FROM gold.fact_sales f 
LEFT JOIN gold.dim_customers c 
ON c.customer_key = f.customer_key
WHERE c.customer_key IS NULL
