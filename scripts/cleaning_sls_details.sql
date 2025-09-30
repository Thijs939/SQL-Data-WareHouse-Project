/*
-----------------------------------------------------------------------------------
 Script:   silver_crm_sales_details_load.sql
 Purpose:  To update and populate the Silver layer table [silver].[crm_sales_details]
           from the Bronze layer source [DataWareHouse].[Bronze].[crm_sales_details].

 Details:
   1. Drops the target table if it exists, then recreates it with standardized schema.
   2. Performs transformations and data quality checks during insert:
      - Converts order, ship, and due dates into valid DATE format.
        * Invalid or malformed dates (0 or not 8 digits long) are set to NULL.
      - Ensures sales values are consistent with quantity × absolute price.
        * If source sales are missing, invalid, or inconsistent, they are recalculated.
      - Ensures valid price values.
        * If price is missing or <= 0, it is derived from sales ÷ quantity.

 Warnings / Considerations:
   - Dropping the table will permanently remove existing data in [silver].[crm_sales_details].
   - Invalid date strings are silently converted to NULL (may result in missing values).
   - If sales and price values are both invalid, fallback logic may still produce NULLs.
   - Ensure data types in the Bronze source align with the casting logic used here.
   - Any data quality issues not covered by the CASE logic will flow into Silver unchanged.
-----------------------------------------------------------------------------------
*/

IF OBJECT_ID ('silver.crm_sales_details', 'U') IS NOT NULL
    DROP TABLE silver.crm_sales_details;

CREATE TABLE silver.crm_sales_details (
    sls_ord_num NVARCHAR(50),
    sls_prd_key NVARCHAR(50),
    sls_cust_id INT,
    sls_order_dt DATE,
    sls_ship_dt DATE,
    sls_due_dt DATE,
    sls_sales INT,
    sls_quantity INT,
    sls_price INT,
    dwh_create_date DATETIME2 DEFAULT GETDATE()
);

INSERT INTO Silver.crm_sales_details(
	sls_ord_num,
    sls_prd_key,
    sls_cust_id,
    sls_order_dt,
    sls_ship_dt,
    sls_due_dt,
    sls_sales,
    sls_quantity,
    sls_price
)

SELECT
	 [sls_ord_num]
	,[sls_prd_key]
	,[sls_cust_id]
	,
	CASE 
		WHEN sls_order_dt = 0 OR LEN(sls_order_dt) != 8 THEN NULL
		ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)
	END AS 
	sls_order_dt,

	CASE 
		WHEN sls_ship_dt = 0 OR LEN(sls_ship_dt) != 8 THEN NULL
		ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE)
	END AS 
	sls_ship_dt,

	CASE 
		WHEN sls_due_dt = 0 OR LEN(sls_due_dt) != 8 THEN NULL
		ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE)
	END AS
	 sls_due_dt
	,CASE 
		WHEN sks_sales IS NULL OR sks_sales <=0 OR sks_sales != sls_quantity * ABS(sls_price)
		THEN sls_quantity * ABS(sls_price)
		ELSE sks_sales
	 END sls_sales
	,[sls_quantity]
	,CASE 
		WHEN sls_price IS NULL OR sls_price <= 0
		THEN sks_sales / NULLIF(sls_quantity, 0)
		ELSE sls_price
	 END sls_price
  FROM [DataWareHouse].[Bronze].[crm_sales_details]

