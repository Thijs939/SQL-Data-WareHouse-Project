/*
Script Purpose:
  The Bronze.load_bronze stored procedure automates the refresh of the Bronze layer in
  the data warehouse.

  It clears (TRUNCATE) all Bronze CRM and ERP tables.

  It bulk loads fresh source data from local CSV files located in the
  datasets\source_crm and datasets\source_erp folders.

  It logs the execution duration for each table load, as well as the total batch runtime.

  It provides basic error handling, printing an error message if any step fails.

WARNING:
  Data loss risk: All tables are truncated before loading. Running this procedure will
  permanently delete existing data in the Bronze tables and replace it with new source
  data.

*/

CREATE OR ALTER PROCEDURE Bronze.load_bronze 
AS
BEGIN
    DECLARE 
        @start_time DATETIME, 
        @end_time DATETIME, 
        @batch_start_time DATETIME, 
        @batch_end_time DATETIME;

    BEGIN TRY
        SET @batch_start_time = GETDATE();
        PRINT '=============================================';
        PRINT 'Loading Bronze Layer';
        PRINT '=============================================';

        -------------------------------
        -- Load CRM Tables
        -------------------------------
        PRINT '=============================================';
        PRINT 'Loading CRM Tables';
        PRINT '=============================================';

        -- crm_cust_info
        SET @start_time = GETDATE();
        TRUNCATE TABLE Bronze.crm_cust_info;

        BULK INSERT Bronze.crm_cust_info
        FROM '[Your Path Here]\source_crm\cust_info.csv'
        WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', TABLOCK);

        SET @end_time = GETDATE();
        PRINT 'Load Duration Table cust_info: ' 
              + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';


        -- crm_prd_info
        SET @start_time = GETDATE();
        TRUNCATE TABLE Bronze.crm_prd_info;

        BULK INSERT Bronze.crm_prd_info
        FROM '[Your Path Here]\source_crm\prd_info.csv'
        WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', TABLOCK);

        SET @end_time = GETDATE();
        PRINT 'Load Duration Table prd_info: ' 
              + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';


        -- crm_sales_details
        SET @start_time = GETDATE();
        TRUNCATE TABLE Bronze.crm_sales_details;

        BULK INSERT Bronze.crm_sales_details
        FROM '[Your Path Here]\source_crm\sales_details.csv'
        WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', TABLOCK);

        SET @end_time = GETDATE();
        PRINT 'Load Duration Table sales_details: ' 
              + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';


        -------------------------------
        -- Load ERP Tables
        -------------------------------
        PRINT '=============================================';
        PRINT 'Loading ERP Tables';
        PRINT '=============================================';

        -- erp_cust_az12
        SET @start_time = GETDATE();
        TRUNCATE TABLE Bronze.erp_cust_az12;

        BULK INSERT Bronze.erp_cust_az12
        FROM '[Your Path Here]\source_erp\az12.csv'
        WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', TABLOCK);

        SET @end_time = GETDATE();
        PRINT 'Load Duration Table cust_az12: ' 
              + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';


        -- erp_loc_a101
        SET @start_time = GETDATE();
        TRUNCATE TABLE Bronze.erp_loc_a101;

        BULK INSERT Bronze.erp_loc_a101
        FROM '[Your Path Here]\source_erp\LOC_A101.csv'
        WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', TABLOCK);

        SET @end_time = GETDATE();
        PRINT 'Load Duration Table loc_a101: ' 
              + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';


        -- erp_px_cat_g1v2
        SET @start_time = GETDATE();
        TRUNCATE TABLE Bronze.erp_px_cat_g1v2;

        BULK INSERT Bronze.erp_px_cat_g1v2
        FROM '[Your Path Here]\source_erp\PX_CAT_G1V2.csv'
        WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', TABLOCK);

        SET @end_time = GETDATE();
        PRINT 'Load Duration Table px_cat_g1v2: ' 
              + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';


        -------------------------------
        -- Finish
        -------------------------------
        SET @batch_end_time = GETDATE();
        PRINT '=============================================';
        PRINT 'Total Load Duration: ' 
              + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' seconds';
        PRINT '=============================================';

    END TRY
    BEGIN CATCH
        PRINT '=============================================';
        PRINT 'ERROR OCCURRED DURING LOADING BRONZE LAYER';
        PRINT 'Error Message: ' + ERROR_MESSAGE();
        PRINT '=============================================';
    END CATCH
END;
