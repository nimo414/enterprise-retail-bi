use new 

CREATE SCHEMA stg;

CREATE SCHEMA dw;

CREATE SCHEMA ctl;

ALTER SCHEMA stg TRANSFER dbo.customers
ALTER SCHEMA stg TRANSFER dbo.products;
ALTER SCHEMA stg TRANSFER dbo.transactions;
ALTER SCHEMA stg TRANSFER dbo.inventory;
ALTER SCHEMA stg TRANSFER dbo.returns;
ALTER SCHEMA stg TRANSFER dbo.price_history;
ALTER SCHEMA stg TRANSFER dbo.supplier_costs;
ALTER SCHEMA stg TRANSFER dbo.marketing_spend;


SELECT 'customers' AS TableName, COUNT(*) AS TotalRows
FROM stg.customers

UNION ALL

SELECT 'products', COUNT(*)
FROM stg.products

UNION ALL

SELECT 'transactions', COUNT(*)
FROM stg.transactions

UNION ALL

SELECT 'inventory', COUNT(*)
FROM stg.inventory

UNION ALL

SELECT 'returns', COUNT(*)
FROM stg.returns

UNION ALL

SELECT 'price_history', COUNT(*)
FROM stg.price_history

UNION ALL

SELECT 'supplier_costs', COUNT(*)
FROM stg.supplier_costs

UNION ALL

SELECT 'marketing_spend', COUNT(*)
FROM stg.marketing_spend;

select 
COUNT(*) as f,
count (distinct transaction_id) as h,
COUNT(*) - count (distinct transaction_id) as b
from stg.transactions

SELECT COUNT(*) AS CategoryMismatch
FROM stg.transactions t
JOIN stg.products p
    ON t.product_id = p.product_id
WHERE t.category <> p.category;



SELECT
    TABLE_NAME,
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH,
    IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'stg'
ORDER BY TABLE_NAME, ORDINAL_POSITION;


create table dw.dimcustomer
(
  CustomerKey INT IDENTITY (1,1) PRIMARY KEY ,
  CustomerID NVARCHAR(50) NOT NULL,

    FirstName NVARCHAR(50),
    LastName NVARCHAR(50),
    Country NVARCHAR(50),
    Currency NVARCHAR(50),
    Age INT,
    Gender NVARCHAR(50),

    RegistrationDate DATETIME2,
    IsPremium BIT,
    EmailVerified BIT,

    StartDate DATE NOT NULL,
    EndDate DATE NOT NULL,
    IsCurrent BIT NOT NULL
);

INSERT INTO dw.DimCustomer
(
    CustomerID,
    FirstName,
    LastName,
    Country,
    Currency,
    Age,
    Gender,
    RegistrationDate,
    IsPremium,
    EmailVerified,
    StartDate,
    EndDate,
    IsCurrent
)
SELECT
    customer_id,
    first_name,
    last_name,
    country,
    currency,
    age,
    gender,
    registration_date,
    is_premium,
    email_verified,
    CAST(registration_date AS DATE),
    '9999-12-31',
    1
FROM stg.customers;

SELECT 
COUNT(*) as countt,
COUNT(DISTINCT CustomerID),
COUNT(DISTINCT CustomerKey),
COUNT(CASE WHEN IsCurrent=1 then 1 else 0 end)
FROM dw.dimcustomer



CREATE TABLE dw.dimproduct
(
 ProductKey INT IDENTITY (1,1) Primary KEY,
     ProductID NVARCHAR(50) NOT NULL,

    ProductName NVARCHAR(50),
    Category NVARCHAR(50),
    Brand NVARCHAR(50),

    UnitPriceUSD DECIMAL(18,2),
    UnitCostUSD DECIMAL(18,2),
    WeightKG DECIMAL(10,3),

    IsActive BIT,
    LaunchDate DATETIME2,

    StartDate DATE NOT NULL,
    EndDate DATE NOT NULL,
    IsCurrent BIT NOT NULL
);

INSERT INTO dw.DimProduct
(
    ProductID,
    ProductName,
    Category,
    Brand,
    UnitPriceUSD,
    UnitCostUSD,
    WeightKG,
    IsActive,
    LaunchDate,
    StartDate,
    EndDate,
    IsCurrent
)
SELECT
    product_id,
    name,
    category,
    brand,
    CAST(unit_price_usd AS DECIMAL(18,2)),
    CAST(unit_cost_usd AS DECIMAL(18,2)),
    CAST(weight_kg AS DECIMAL(10,3)),
    is_active,
    launch_date,
    CAST(launch_date AS DATE),
    '9999-12-31',
    1
FROM stg.products;



SELECT 
COUNT(*) ,
COUNT(DISTINCT ProductID),
COUNT(DISTINCT ProductKey),
COUNT(CASE WHEN IsCurrent=1 THEN 1 ELSE 0 END)
FROM dw.dimProduct



SELECT
    COUNT(*) AS TotalRows,
    COUNT(DISTINCT transaction_id) AS UniqueTransactions,
    COUNT(DISTINCT customer_id) AS UniqueCustomers,
    COUNT(DISTINCT product_id) AS UniqueProducts
FROM stg.transactions;


create table dw.dimdate 
( 
 DateKey INT PRIMARY KEY ,
 FullDate DATE NOT NULL ,
 Year INT NOT NULL ,
 Quarter INT NOT NULL, 
 MonthNumber INT NOT NULL , 
 MonthName NVARCHAR(20) NOT NULL , 
    YearMonth CHAR(7) NOT NULL,
    WeekNumber INT NOT NULL,
    DayOfMonth INT NOT NULL,
    DayName NVARCHAR(20) NOT NULL,
    IsWeekend BIT NOT NULL
);


SELECT 
MIN(CAST([date]as DATE)) as mindate,
MAX(CAST([date]as DATE)) as maxdate
FROM stg.transactions

INSERT INTO dw.DimDate
(
    DateKey,
    FullDate,
    Year,
    Quarter,
    MonthNumber,
    MonthName,
    YearMonth,
    WeekNumber,
    DayOfMonth,
    DayName,
    IsWeekend
)
SELECT
    CONVERT(INT, CONVERT(CHAR(8), d, 112)) AS DateKey,
    d AS FullDate,
    YEAR(d) AS Year,
    DATEPART(QUARTER, d) AS Quarter,
    MONTH(d) AS MonthNumber,
    DATENAME(MONTH, d) AS MonthName,
    CONVERT(CHAR(7), d, 120) AS YearMonth,
    DATEPART(WEEK, d) AS WeekNumber,
    DAY(d) AS DayOfMonth,
    DATENAME(WEEKDAY, d) AS DayName,
    CASE
        WHEN DATEPART(WEEKDAY, d) IN (1, 7) THEN 1
        ELSE 0
    END AS IsWeekend
FROM
(
    SELECT DATEADD(DAY, n, '2022-01-01') AS d
    FROM
    (
        SELECT TOP (1096)
            ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) - 1 AS n
        FROM sys.all_objects a
        CROSS JOIN sys.all_objects b
    ) x
) dates;

SELECT
    COUNT(*) AS TotalDates,
    MIN(FullDate) AS MinDate,
    MAX(FullDate) AS MaxDate
FROM dw.DimDate;
SELECT TOP 10 *
FROM dw.DimDate
ORDER BY FullDate;


SELECT
    COUNT(*) AS TotalRows,
    COUNT(CASE WHEN TRY_CONVERT(INT, quantity) IS NULL THEN 1 END) AS InvalidQuantity,
    MIN(TRY_CONVERT(INT, quantity)) AS MinQuantity,
    MAX(TRY_CONVERT(INT, quantity)) AS MaxQuantity
FROM stg.transactions;


SELECT
    COUNT(*) AS TotalRows,
    COUNT(CASE WHEN TRY_CONVERT(DECIMAL(18,2), unit_price_usd) IS NULL THEN 1 END) AS InvalidUnitPrice,
    COUNT(CASE WHEN TRY_CONVERT(DECIMAL(18,2), revenue_usd) IS NULL THEN 1 END) AS InvalidRevenue,
    COUNT(CASE WHEN TRY_CONVERT(DECIMAL(18,2), cost_usd) IS NULL THEN 1 END) AS InvalidCost,
    COUNT(CASE WHEN TRY_CONVERT(DECIMAL(18,2), profit_usd) IS NULL THEN 1 END) AS InvalidProfit,
    COUNT(CASE WHEN TRY_CONVERT(DECIMAL(18,2), shipping_cost_usd) IS NULL THEN 1 END) AS InvalidShipping
FROM stg.transactions;



CREATE TABLE dw.FactSales
(
    SalesKey INT IDENTITY(1,1) PRIMARY KEY,

    TransactionID NVARCHAR(50) NOT NULL,

    CustomerKey INT NOT NULL,
    ProductKey INT NOT NULL,
    DateKey INT NOT NULL,

    Quantity INT NOT NULL,

    UnitPriceAtSale DECIMAL(18,2) NOT NULL,
    DiscountPct DECIMAL(9,4) NOT NULL,

    RevenueUSD DECIMAL(18,2) NOT NULL,
    CostUSD DECIMAL(18,2) NOT NULL,
    ProfitUSD DECIMAL(18,2) NOT NULL,
    ShippingCostUSD DECIMAL(18,2) NOT NULL,

    Channel NVARCHAR(50),
    PaymentMethod NVARCHAR(50),
    Status NVARCHAR(50),

    CONSTRAINT FK_FactSales_Customer
        FOREIGN KEY (CustomerKey)
        REFERENCES dw.DimCustomer(CustomerKey),

    CONSTRAINT FK_FactSales_Product
        FOREIGN KEY (ProductKey)
        REFERENCES dw.DimProduct(ProductKey),

    CONSTRAINT FK_FactSales_Date
        FOREIGN KEY (DateKey)
        REFERENCES dw.DimDate(DateKey)
);

SELECT TOP 20
    t.transaction_id,
    t.customer_id,
    c.CustomerKey,
    t.product_id,
    p.ProductKey,
    CAST(t.[date] AS DATE) AS SaleDate,
    d.DateKey
FROM stg.transactions t
LEFT JOIN dw.DimCustomer c
    ON t.customer_id = c.CustomerID
LEFT JOIN dw.DimProduct p
    ON t.product_id = p.ProductID
LEFT JOIN dw.DimDate d
    ON CAST(t.[date] AS DATE) = d.FullDate;



	INSERT INTO dw.FactSales
(
    TransactionID,
    CustomerKey,
    ProductKey,
    DateKey,
    Quantity,
    UnitPriceAtSale,
    DiscountPct,
    RevenueUSD,
    CostUSD,
    ProfitUSD,
    ShippingCostUSD,
    Channel,
    PaymentMethod,
    Status
)
SELECT
    t.transaction_id,
    c.CustomerKey,
    p.ProductKey,
    d.DateKey,

    TRY_CONVERT(INT, t.quantity),

    CAST(t.unit_price_usd AS DECIMAL(18,2)),
    CAST(t.discount_pct AS DECIMAL(9,4)),
    CAST(t.revenue_usd AS DECIMAL(18,2)),
    CAST(t.cost_usd AS DECIMAL(18,2)),
    CAST(t.profit_usd AS DECIMAL(18,2)),
    CAST(t.shipping_cost_usd AS DECIMAL(18,2)),

    t.channel,
    t.payment_method,
    t.status

FROM stg.transactions t

INNER JOIN dw.DimCustomer c
    ON t.customer_id = c.CustomerID

INNER JOIN dw.DimProduct p
    ON t.product_id = p.ProductID

INNER JOIN dw.DimDate d
    ON CAST(t.[date] AS DATE) = d.FullDate;

	SELECT
    COUNT(*) AS FactRows,
    COUNT(DISTINCT TransactionID) AS UniqueTransactions,
    SUM(RevenueUSD) AS TotalRevenue,
    SUM(CostUSD) AS TotalCost,
    SUM(ProfitUSD) AS TotalProfit
FROM dw.FactSales;


SELECT
    COUNT(*) AS TotalTransactions,
    SUM(Quantity) AS TotalQuantity,
    SUM(RevenueUSD) AS TotalRevenue,
    SUM(CostUSD) AS TotalCost,
    SUM(ProfitUSD) AS TotalProfit,
    AVG(RevenueUSD) AS AvgTransactionRevenue,
    AVG(ProfitUSD) AS AvgTransactionProfit
FROM dw.FactSales;



DELETE FROM dw.dimproduct

SELECT 
ProductName

FROM DW.dimproduct


SELECT COUNT(*) AS NotFoundDates
FROM stg.transactions t
LEFT JOIN dw.DimDate d
    ON CAST(t.[date] AS DATE) = d.FullDate
WHERE d.DateKey IS NULL;



SELECT
    COUNT(*) AS TotalRows,
    COUNT(CustomerKey) AS CustomerKeys,
    COUNT(ProductKey) AS ProductKeys,
    COUNT(DateKey) AS DateKeys
FROM dw.FactSales;



CREATE TABLE dw.FactReturns
(
    ReturnKey INT IDENTITY(1,1) PRIMARY KEY,
    ReturnID NVARCHAR(50) NOT NULL,
    TransactionID NVARCHAR(50) NOT NULL,

    CustomerKey INT NOT NULL,
    ProductKey INT NOT NULL,
    DateKey INT NOT NULL,

    RefundAmountUSD DECIMAL(18,2) NOT NULL,
    Reason NVARCHAR(100),
    Restocked BIT,

    CONSTRAINT FK_FactReturns_Customer
        FOREIGN KEY (CustomerKey)
        REFERENCES dw.DimCustomer(CustomerKey),

    CONSTRAINT FK_FactReturns_Product
        FOREIGN KEY (ProductKey)
        REFERENCES dw.DimProduct(ProductKey),

    CONSTRAINT FK_FactReturns_Date
        FOREIGN KEY (DateKey)
        REFERENCES dw.DimDate(DateKey)
);







SELECT
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'stg'
  AND TABLE_NAME = 'returns'
  AND COLUMN_NAME = 'return_date';



SELECT
    COUNT(*) AS TotalRows,
    COUNT(DISTINCT ReturnID) AS UniqueReturns,
    COUNT(CustomerKey) AS CustomerKeys,
    COUNT(ProductKey) AS ProductKeys,
    COUNT(DateKey) AS DateKeys,
    SUM(RefundAmountUSD) AS TotalRefund
FROM dw.FactReturns;
SELECT
    'DimCustomer' AS TableName,
    COUNT(*) AS TotalRows
FROM dw.DimCustomer

UNION ALL

SELECT 'DimProduct', COUNT(*)
FROM dw.DimProduct

UNION ALL

SELECT 'DimDate', COUNT(*)
FROM dw.DimDate

UNION ALL

SELECT 'FactSales', COUNT(*)
FROM dw.FactSales

UNION ALL

SELECT 'FactReturns', COUNT(*)
FROM dw.FactReturns;




BEGIN TRY
    BEGIN TRANSACTION;

    -- حذف داده‌های Fact
    DELETE FROM dw.FactSales;
    DELETE FROM dw.FactReturns;

    -- حذف داده‌های Dimension
    DELETE FROM dw.DimCustomer;
    DELETE FROM dw.DimProduct;

    -- ریست کردن کلیدهای Identity
    DBCC CHECKIDENT ('dw.FactSales', RESEED, 0);
    DBCC CHECKIDENT ('dw.FactReturns', RESEED, 0);
    DBCC CHECKIDENT ('dw.DimCustomer', RESEED, 0);
    DBCC CHECKIDENT ('dw.DimProduct', RESEED, 0);

    COMMIT TRANSACTION;

    PRINT N'تمام داده‌های DWH پاک شدند.';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    THROW;
END CATCH;
GO



















































