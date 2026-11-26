# Enterprise Retail BI & Data Warehouse

An end-to-end Business Intelligence project built with SQL Server, SSIS, Data Warehousing, Power BI, and DAX.

## Project Overview

This project simulates a real-world retail BI environment, starting from source data and continuing through staging, ETL, dimensional modeling, analytics, and executive reporting.

The goal is to transform raw retail data into a reliable analytical model and provide business insights through an interactive Power BI dashboard.

## Architecture

```text
Source Data
    ↓
Staging Layer
    ↓
SSIS ETL
    ↓
Data Warehouse
    ↓
Star Schema
    ↓
Power BI Data Model
    ↓
DAX Analytics
    ↓
Executive Dashboard
```

## Data Warehouse

The warehouse follows a Star Schema architecture.

### Dimension Tables

- DimCustomer
- DimProduct
- DimDate

### Fact Tables

- FactSales
- FactReturns

## ETL

ETL processes were implemented using SQL Server Integration Services (SSIS).

Main package:

```text
ETL_Master.dtsx
```

The ETL process loads and transforms data from the staging layer into the dimensional warehouse.

## Power BI Data Model

The Power BI model uses a Star Schema with:

- Customer dimension
- Product dimension
- Date dimension
- Sales fact
- Returns fact

Relationships were configured using one-to-many relationships from dimensions to fact tables.

## DAX Analytics

Key business measures include:

- Total Revenue
- Total Profit
- Total Orders
- Profit Margin
- Average Order Value
- Total Returns
- Total Refund
- Return Rate
- Revenue per Customer
- Orders per Customer
- Total Stock
- Stock Status
- Overstock Analysis

## Business Analysis

The dashboard provides analysis across several business areas:

### Sales Performance

- Revenue and profit
- Monthly sales trends
- Product performance
- Sales channels
- Payment methods
- Discount analysis

### Customer Analysis

- Customer distribution
- Revenue by country
- Profitability by country
- Revenue per customer
- Orders per customer

### Returns Analysis

- Return volume
- Refund amount
- Return rate
- Products with high return rates

### Inventory Analysis

- Stock levels
- Reorder points
- Low-stock products
- Overstocked products

## Data Quality & Validation

The following validation checks were performed:

- Fact and dimension row-count validation
- Referential integrity checks
- Missing dimension key checks
- Duplicate transaction checks
- ETL execution validation
- Power BI relationship validation

## Technologies

- SQL Server
- T-SQL
- SQL Server Integration Services (SSIS)
- Data Warehousing
- Star Schema
- Power BI
- DAX
- Power Query

## Project Structure

```text
Enterprise-Retail-BI/
│
├── README.md
│
├── SQL/
│
├── SSIS/
│   └── ETL_Master.dtsx
│
├── PowerBI/
│   └── Enterprise_Retail_BI.pbix
│
└── Screenshots/
```

## Dashboard

The Power BI dashboard contains three main analytical areas:

- Executive Overview
- Product & Inventory
- Customer & Sales

Screenshots of the dashboard are available in the `Screenshots` folder.

## Key Outcome

The project demonstrates an end-to-end BI workflow from raw data ingestion and ETL to dimensional modeling, analytical DAX measures, data validation, and interactive business reporting.
