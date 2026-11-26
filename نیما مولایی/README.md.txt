# Enterprise Retail BI & Data Warehouse

## Project Overview

A complete Business Intelligence project covering data warehousing,
ETL development, data modeling, DAX analytics, and Power BI dashboarding.

## Architecture

Source Data
    ↓
Staging (SQL Server)
    ↓
SSIS ETL
    ↓
Data Warehouse
    ↓
Star Schema
    ↓
Power BI
    ↓
Executive Dashboard

## Data Warehouse

### Dimensions
- DimCustomer
- DimProduct
- DimDate

### Facts
- FactSales
- FactReturns

## ETL

ETL was developed using SQL Server Integration Services (SSIS).

Main package:
- ETL_Master.dtsx

## Data Model

The Power BI model follows a Star Schema design.

## Analytics

The project includes analysis of:

- Revenue
- Profit
- Profit Margin
- Orders
- Average Order Value
- Returns
- Return Rate
- Sales Channels
- Payment Methods
- Discounts
- Inventory
- Overstock
- Low Stock

## Data Quality

The following validations were performed:

- Referential Integrity
- Missing Dimension Keys
- Duplicate Transaction IDs
- Fact and Dimension Row Counts
- ETL Load Validation

## Tools

- SQL Server
- T-SQL
- SSIS
- Power BI
- DAX
- Power Query
- Data Warehousing