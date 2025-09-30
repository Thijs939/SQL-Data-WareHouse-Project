/*
===================================
Create Database and Schemas
===================================

Script Purpose:
    This script creates a new database 'DataWareHouse' after checking if it already exists.
    If the database exists the database is dropped and recreated. Additionally, the script sets up three schemas 
    within the database: 'Bronze', 'Silver', 'Gold'.

WARNING:
    Running this script will drop the entire 'DataWareHouse' database if it exists.
    All Data in the database will be permanetly deleted.
/*



USE master;
GO
  
-- Drop and recreate the 'DataWareHouse' database
IF EXISTS (SELECT 1 FROM  sys.databases WHERE name = 'DataWareHouse')
BEGIN
  DROP DATABASE DataWareHouse;
END;
GO


CREATE DATABASE DataWareHouse;
GO
  
USE DataWareHouse;
GO

-- Create Schemas
CREATE SCHEMA Bronze;
GO
CREATE SCHEMA Silver;
GO
CREATE SCHEMA Gold;
GO
