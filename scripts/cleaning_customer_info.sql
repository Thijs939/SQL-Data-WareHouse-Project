/*
=========================================================
Purpose:
--------
This script loads cleaned and standardized customer data 
from the Bronze layer into the Silver layer.

Transformations applied:
- Trims leading/trailing spaces from first and last names.
- Standardizes marital status:
    'S' -> 'Single'
    'M' -> 'Married'
    else -> 'n/a'
- Standardizes gender:
    'F' -> 'Female'
    'M' -> 'Male'
    else -> 'n/a'
- Keeps only the most recent record per customer (based on 
  cst_create_date) using ROW_NUMBER.

Source: Bronze.crm_cust_info
Target: Silver.crm_cust_info

Warning:
--------
- Existing data in Silver.crm_cust_info may be duplicated 
  if this script is run multiple times without clearing the 
  table first.
- Records with invalid or missing marital status or gender 
  will be mapped to 'n/a'.
- Only the latest record per customer is kept; older records 
  are discarded.
=========================================================
*/




INSERT INTO Silver.crm_cust_info(
       [cst_id]
      ,[cst_key]
      ,[cst_firstname]
      ,[cst_lastname]
      ,[cst_marital_status]
      ,[cst_gndr]
      ,[cst_create_date]
)
SELECT
    cst_id,
    cst_key,
    TRIM(cst_firstname) AS cst_firstname,
    TRIM(cst_lastname) AS cst_lastname,
        CASE
         WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
         WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
         ELSE 'n/a'
        END cst_marital_status,
        CASE
          WHEN UPPER(cst_gndr) = 'F' THEN 'Female'
          WHEN UPPER(cst_gndr) = 'M' THEN 'Male'
          ELSE 'n/a'
        END cst_gndr,
    cst_create_date
FROM(
SELECT
    *,
    ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS Flag_last
FROM Bronze.crm_cust_info
WHERE cst_id IS NOT NULL)t
WHERE Flag_last = 1



