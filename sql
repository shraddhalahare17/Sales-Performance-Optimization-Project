-- Create the main sales table
CREATE TABLE sales_data (
    SaleID INT PRIMARY KEY AUTO_INCREMENT,
    SaleDate DATE,
    Region VARCHAR(100),
    Store VARCHAR(100),
    Product VARCHAR(100),
    Category VARCHAR(100),
    UnitsSold INT,
    UnitPrice DECIMAL(10,2),
    Revenue DECIMAL(12,2)
);

-- Optional: Create product lookup (if needed)
CREATE TABLE products (
    Product VARCHAR(100) PRIMARY KEY,
    Category VARCHAR(100)
);

-- Optional: Create store lookup (if needed)
CREATE TABLE store_info (
    Store VARCHAR(100) PRIMARY KEY,
    Region VARCHAR(100)
);

-- Remove rows with any NULL values
DELETE FROM sales_data
WHERE 
    SaleDate IS NULL OR
    Region IS NULL OR
    Store IS NULL OR
    Product IS NULL OR
    UnitsSold IS NULL OR
    UnitPrice IS NULL;

-- Remove duplicates (if SaleID is not unique)
DELETE FROM sales_data
WHERE SaleID NOT IN (
    SELECT MIN(SaleID)
    FROM sales_data
    GROUP BY SaleDate, Region, Store, Product, UnitsSold, UnitPrice
);

-- Update Revenue if not already present
UPDATE sales_data
SET Revenue = UnitsSold * UnitPrice
WHERE Revenue IS NULL OR Revenue = 0;

-- Standardize region names (example)
UPDATE sales_data
SET Region = 'North'
WHERE Region IN ('NORTH', 'north', 'N');

-- Optional: ensure date format is consistent
SELECT 
    SaleID, SaleDate
FROM sales_data
WHERE STR_TO_DATE(SaleDate, '%Y-%m-%d') IS NULL;

-- Total revenue and units sold by region
CREATE VIEW region_summary AS
SELECT 
    Region,
    SUM(UnitsSold) AS TotalUnits,
    SUM(Revenue) AS TotalRevenue
FROM sales_data
GROUP BY Region;

-- Monthly sales trend
CREATE VIEW monthly_sales AS
SELECT 
    DATE_FORMAT(SaleDate, '%Y-%m') AS SaleMonth,
    SUM(Revenue) AS MonthlyRevenue,
    SUM(UnitsSold) AS MonthlyUnits
FROM sales_data
GROUP BY SaleMonth
ORDER BY SaleMonth;

-- Top performing stores
CREATE VIEW top_stores AS
SELECT 
    Store,
    Region,
    SUM(Revenue) AS TotalRevenue,
    SUM(UnitsSold) AS TotalUnits
FROM sales_data
GROUP BY Store, Region
ORDER BY TotalRevenue DESC;
