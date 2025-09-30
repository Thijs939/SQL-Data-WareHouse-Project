/*
=========================================================
Purpose:
--------
This script rebuilds and loads the Silver layer table 
`silver.crm_prd_info` from the Bronze layer source data.

Steps performed:
1. Drops the Silver table if it already exists.
2. Creates `silver.crm_prd_info` with product attributes 
   and an audit column (`dwh_create_date`) that defaults 
   to the current system time.
3. Loads data from Bronze.crm_prd_info with transformations:
   - Extracts category ID from `prd_key` (first 5 chars, 
     with '-' replaced by '_').
   - Derives cleaned `prd_key` from the remaining substring.
   - Ensures `prd_cost` is never null by replacing with 0.
   - Normalizes product line codes:
        'M' -> 'Mountain'
        'R' -> 'Road'
        'S' -> 'Other Sales'
        'T' -> 'Touring'
        else -> 'n/a'
   - Converts start/end dates into proper DATE values.
   - Calculates `prd_end_dt` as one day before the next 
     `prd_start_dt` for the same product (temporal validity).

Warning:
--------
- Running this script will DROP the existing 
  `silver.crm_prd_info` table and all its data.
- End dates (`prd_end_dt`) depend on the sequence of 
  `prd_start_dt`; incorrect ordering may produce invalid ranges.
- Product lines not matching the specified codes will 
  be mapped to 'n/a'.
- Null product costs will be replaced with 0, which may 
  not reflect true business values.
=========================================================
*/

IF OBJECT_ID ('silver.crm_prd_info', 'U') IS NOT NULL
    DROP TABLE silver.crm_prd_info;

CREATE TABLE silver.crm_prd_info (
    prd_id INT,
    cat_id NVARCHAR(50),
    prd_key NVARCHAR(50),
    prd_nm NVARCHAR(50),
    prd_cost INT,
    prd_line NVARCHAR(50),
    prd_start_dt DATE,
    prd_end_dt DATE,
    dwh_create_date DATETIME2 DEFAULT GETDATE()
);
INSERT INTO Silver.crm_prd_info(
prd_id,
cat_id,
prd_key,
prd_nm,
prd_cost,
prd_line,
prd_start_dt,
prd_end_dt
)

SELECT 
[prd_id],
REPLACE(SUBSTRING([prd_key], 1, 5), '-', '_') AS cat_id,
SUBSTRING([prd_key], 7, LEN(prd_key)) AS prd_key,
[prd_nm],
COALESCE([prd_cost], 0),
CASE UPPER(TRIM(prd_line))
	WHEN 'M' THEN 'Mountain'
	WHEN 'R' THEN 'Road'
	WHEN 'S' THEN 'Other Sales'
	WHEN 'T' THEN 'Touring'
	ELSE 'n/a' 
END prd_line,
CAST([prd_start_dt] AS DATE) prd_start_dt,
CAST(LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt)-1 AS DATE) AS prd_end_dt
FROM [DataWareHouse].[Bronze].[crm_prd_info]


