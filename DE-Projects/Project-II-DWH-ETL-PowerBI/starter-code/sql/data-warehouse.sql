-- ================================================================
-- VI DU, CU THE VOI CHU DE SALES (BAN HANG)
-- (Day la code mau huong dan Star Schema DDL, hoc vien can 
--  tuy chinh theo bai toan va thiet ke cua minh)
-- ================================================================
-- PROJECT II: DATA WAREHOUSE - Star Schema DDL
-- Chủ đề: Sales (Bán hàng)
-- ================================================================

-- =============================================
-- STAGING DATABASE
-- =============================================
CREATE DATABASE StagingDB;
GO
USE StagingDB;
GO

-- Staging tables (mirror of source)
CREATE TABLE stg_Orders (
    OrderID INT,
    CustomerID INT,
    OrderDate DATETIME,
    Status NVARCHAR(50),
    TotalAmount DECIMAL(18,2),
    ShippingAddress NVARCHAR(500),
    LoadDate DATETIME DEFAULT GETDATE(),
    SourceSystem NVARCHAR(50) DEFAULT 'OLTP'
);

CREATE TABLE stg_Products (
    ProductID INT,
    CategoryID INT,
    ProductName NVARCHAR(200),
    CategoryName NVARCHAR(100),
    Price DECIMAL(18,2),
    LoadDate DATETIME DEFAULT GETDATE()
);

CREATE TABLE stg_Customers (
    CustomerID INT,
    FullName NVARCHAR(150),
    Email NVARCHAR(100),
    City NVARCHAR(100),
    Gender NVARCHAR(10),
    LoadDate DATETIME DEFAULT GETDATE()
);

-- TODO: Thêm staging tables khác
GO

-- =============================================
-- DATA WAREHOUSE DATABASE
-- =============================================
CREATE DATABASE SalesDWH;
GO
USE SalesDWH;
GO

-- =============================================
-- DIMENSION TABLES
-- =============================================

-- DimDate (Date Dimension - Pre-populate)
CREATE TABLE DimDate (
    DateKey INT PRIMARY KEY,           -- YYYYMMDD format
    FullDate DATE NOT NULL,
    DayOfWeek INT,
    DayName NVARCHAR(15),
    DayOfMonth INT,
    WeekOfYear INT,
    MonthNumber INT,
    MonthName NVARCHAR(15),
    Quarter INT,
    QuarterName NVARCHAR(5),
    Year INT,
    IsWeekend BIT,
    IsHoliday BIT DEFAULT 0,
    FiscalYear INT,
    FiscalQuarter INT
);
GO

-- Populate DimDate (5 years: 2020-2025)
;WITH DateCTE AS (
    SELECT CAST('2020-01-01' AS DATE) AS dt
    UNION ALL
    SELECT DATEADD(DAY, 1, dt)
    FROM DateCTE
    WHERE dt < '2025-12-31'
)
INSERT INTO DimDate
SELECT 
    CONVERT(INT, FORMAT(dt, 'yyyyMMdd')) AS DateKey,
    dt AS FullDate,
    DATEPART(WEEKDAY, dt) AS DayOfWeek,
    DATENAME(WEEKDAY, dt) AS DayName,
    DAY(dt) AS DayOfMonth,
    DATEPART(WEEK, dt) AS WeekOfYear,
    MONTH(dt) AS MonthNumber,
    DATENAME(MONTH, dt) AS MonthName,
    DATEPART(QUARTER, dt) AS Quarter,
    'Q' + CAST(DATEPART(QUARTER, dt) AS VARCHAR) AS QuarterName,
    YEAR(dt) AS Year,
    CASE WHEN DATEPART(WEEKDAY, dt) IN (1, 7) THEN 1 ELSE 0 END AS IsWeekend,
    0 AS IsHoliday,
    CASE WHEN MONTH(dt) >= 4 THEN YEAR(dt) ELSE YEAR(dt) - 1 END AS FiscalYear,
    CASE 
        WHEN MONTH(dt) BETWEEN 4 AND 6 THEN 1
        WHEN MONTH(dt) BETWEEN 7 AND 9 THEN 2
        WHEN MONTH(dt) BETWEEN 10 AND 12 THEN 3
        ELSE 4
    END AS FiscalQuarter
FROM DateCTE
OPTION (MAXRECURSION 0);
GO

-- DimProduct
CREATE TABLE DimProduct (
    ProductKey INT IDENTITY(1,1) PRIMARY KEY,
    ProductID INT NOT NULL,               -- Natural Key
    ProductName NVARCHAR(200) NOT NULL,
    Category NVARCHAR(100),
    SubCategory NVARCHAR(100),
    Brand NVARCHAR(100),
    UnitPrice DECIMAL(18,2),
    -- SCD Type 2 columns
    EffectiveDate DATE DEFAULT GETDATE(),
    ExpirationDate DATE DEFAULT '9999-12-31',
    IsCurrent BIT DEFAULT 1
);
GO

-- DimCustomer
CREATE TABLE DimCustomer (
    CustomerKey INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID INT NOT NULL,              -- Natural Key
    CustomerName NVARCHAR(150),
    Email NVARCHAR(100),
    City NVARCHAR(100),
    Region NVARCHAR(100),
    Segment NVARCHAR(50),
    FirstPurchaseDate DATE,
    -- SCD Type 1 (overwrite)
    LastUpdated DATETIME DEFAULT GETDATE()
);
GO

-- DimStore (nếu có nhiều cửa hàng/kênh bán)
CREATE TABLE DimStore (
    StoreKey INT IDENTITY(1,1) PRIMARY KEY,
    StoreID INT,
    StoreName NVARCHAR(100),
    StoreType NVARCHAR(50),
    City NVARCHAR(100),
    Region NVARCHAR(100),
    OpenDate DATE
);
GO

-- TODO: Thêm dimensions khác theo thiết kế

-- =============================================
-- FACT TABLE
-- =============================================
CREATE TABLE FactSales (
    SalesKey BIGINT IDENTITY(1,1) PRIMARY KEY,
    DateKey INT NOT NULL FOREIGN KEY REFERENCES DimDate(DateKey),
    ProductKey INT NOT NULL FOREIGN KEY REFERENCES DimProduct(ProductKey),
    CustomerKey INT NOT NULL FOREIGN KEY REFERENCES DimCustomer(CustomerKey),
    StoreKey INT FOREIGN KEY REFERENCES DimStore(StoreKey),
    OrderID INT,
    Quantity INT,
    UnitPrice DECIMAL(18,2),
    Discount DECIMAL(5,2) DEFAULT 0,
    TotalAmount DECIMAL(18,2),
    Cost DECIMAL(18,2),
    Profit AS (TotalAmount - ISNULL(Cost, 0)),  -- Computed column
    -- ETL Metadata
    ETLLoadDate DATETIME DEFAULT GETDATE(),
    ETLBatchID INT
);
GO

-- =============================================
-- INDEXES for Performance
-- =============================================
CREATE NONCLUSTERED INDEX IX_FactSales_DateKey ON FactSales(DateKey);
CREATE NONCLUSTERED INDEX IX_FactSales_ProductKey ON FactSales(ProductKey);
CREATE NONCLUSTERED INDEX IX_FactSales_CustomerKey ON FactSales(CustomerKey);
GO

-- =============================================
-- SAMPLE DAX MEASURES (for Power BI reference)
-- =============================================
/*
Total Revenue = SUM(FactSales[TotalAmount])

Total Profit = SUM(FactSales[Profit])

Profit Margin = DIVIDE([Total Profit], [Total Revenue], 0)

YoY Growth = 
    VAR CurrentYear = [Total Revenue]
    VAR PreviousYear = CALCULATE([Total Revenue], SAMEPERIODLASTYEAR(DimDate[FullDate]))
    RETURN DIVIDE(CurrentYear - PreviousYear, PreviousYear, 0)

Running Total = 
    CALCULATE(
        [Total Revenue],
        FILTER(
            ALLSELECTED(DimDate[FullDate]),
            DimDate[FullDate] <= MAX(DimDate[FullDate])
        )
    )

Avg Order Value = DIVIDE([Total Revenue], DISTINCTCOUNT(FactSales[OrderID]), 0)
*/
