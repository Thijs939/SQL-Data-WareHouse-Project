/*
Script Purpose:
  It truncates (completely clears) the target tables in the Bronze schema.

  Then it uses BULK INSERT to load raw data directly from local CSV files located in the
  datasets folder (source_crm and source_erp).

  This process ensures the Bronze tables always contain the latest snapshot of the
  source system data.

Warning:
  Destructive operation: The script uses TRUNCATE TABLE, which deletes all data in the
  listed tables before inserting new records. Running this will permanently remove any
  existing data in those tables.

/*

TRUNCATE TABLE Bronze.crm_cust_info;

BULK INSERT Bronze.crm_cust_info
FROM '[Path To File]\cust_info.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    TABLOCK
);

TRUNCATE TABLE [Bronze].[crm_prd_info];

BULK INSERT [Bronze].[crm_prd_info]
FROM '[Path To File]\prd_info.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    TABLOCK
);

TRUNCATE TABLE [Bronze].[crm_sales_details];

BULK INSERT [Bronze].[crm_sales_details]
FROM '[Path To File]\sales_details.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    TABLOCK
);

TRUNCATE TABLE [Bronze].[erp_cust_az12];

BULK INSERT [Bronze].[erp_cust_az12]
FROM '[Path To File]\az12.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    TABLOCK
);

TRUNCATE TABLE [Bronze].[erp_loc_a101];

BULK INSERT [Bronze].[erp_loc_a101]
FROM '[Path To File]\LOC_A101.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    TABLOCK
);

TRUNCATE TABLE [Bronze].[erp_px_cat_g1v2];

BULK INSERT [Bronze].[erp_px_cat_g1v2]
FROM '[Path To File]\PX_CAT_G1V2.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    TABLOCK
);
