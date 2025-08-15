SELECT * FROM Online_Retail;
EXEC sp_help 'Online_Retail';

-- DATA QUALITY REPORT
-- The dataset consists of 541909 rows and 8 columns
-- InvoiceNo, StockCode, Description, Quantity, InvoiceDate, UnitPrice, CustomerID and Country.
-- Begin Cleaning

-- 1. Checking for null values
SELECT COUNT(*) FROM Online_Retail;
SELECT 
    SUM(CASE WHEN InvoiceNo IS NULL THEN 1 ELSE 0 END) AS null_InvoiceNo,
    SUM(CASE WHEN StockCode IS NULL THEN 1 ELSE 0 END) AS null_StockCode,
    SUM(CASE WHEN Description IS NULL THEN 1 ELSE 0 END) AS null_Description,
    SUM(CASE WHEN Quantity IS NULL THEN 1 ELSE 0 END) AS null_Quantity,
    SUM(CASE WHEN InvoiceDate IS NULL THEN 1 ELSE 0 END) AS null_InvoiceDate,
    SUM(CASE WHEN UnitPrice IS NULL THEN 1 ELSE 0 END) AS null_UnitPrice,
    SUM(CASE WHEN CustomerID IS NULL THEN 1 ELSE 0 END) AS null_CustomerID,
    SUM(CASE WHEN Country IS NULL THEN 1 ELSE 0 END) AS null_Country
FROM Online_Retail;

-- SUMMARY 
-- Description - 1454 Null values

-- Unit price - 2 Null values

-- CustomerID - 135080 Null values


-- 2. Checking for cancel invoice, InvoiceNo start with C
SELECT * FROM Online_Retail
WHERE InvoiceNo NOT LIKE 'C%' AND Quantity < 0;

SELECT * FROM Online_Retail
WHERE InvoiceNo LIKE 'C%'

SELECT COUNT(*) FROM Online_Retail
WHERE InvoiceNo LIKE 'C%';

-- SUMMARY
-- 9288 cancel Invoice


-- Since the CustomerID null values is too large, making it hard to analyze 
-- We will remove these rows to ensure data integrity
-- 3. Drop rows if CustomerID is null
DELETE FROM Online_Retail
WHERE CustomerID IS NULL;


-- For the sake of simplicity when importing, we decided to set Quantity and InvoiceDate as text
-- Now, we will convert it back
-- 4. Convert from text 
-- ALTER TABLE to NVARCHAR
ALTER TABLE Online_Retail
ALTER COLUMN Quantity NVARCHAR(50);
ALTER TABLE Online_Retail
ALTER COLUMN InvoiceDate NVARCHAR(50);

-- UPDATE to its Data Type
-- With InvoiceDate, we decided to keep only the date
UPDATE Online_Retail
SET Quantity = CAST(Quantity AS INT)
WHERE ISNUMERIC(Quantity) = 1;
UPDATE Online_Retail
SET InvoiceDate = CONVERT(DATE, InvoiceDate, 101)
WHERE ISDATE(InvoiceDate) = 1;

-- ALTER THE COLUMN
ALTER TABLE Online_Retail
ALTER COLUMN Quantity INT;
ALTER TABLE Online_Retail
ALTER COLUMN InvoiceDate DATE;

-- From the dataset it is also clear that a product related StockCode contains 5 digits.
-- Checking for those StockCode
SELECT *
FROM Online_Retail
WHERE StockCode LIKE '%[A-Z]%' AND StockCode LIKE '%[0-9]%';

SELECT *
FROM Online_Retail
WHERE StockCode LIKE '%[A-Z]%';

SELECT *
FROM Online_Retail
WHERE StockCode NOT LIKE '%[^0-9]%'
  AND LEN(StockCode) > 5;


-- 5. Drop any rows that StockCode is < 5 or > 5 digits
DELETE FROM Online_Retail
WHERE LEN(LTRIM(RTRIM(StockCode))) <> 5;


-- With the dataset comes with no Status, etc: Canceled, Shipped,...
-- We will create one column for it
-- 6. Adding flag for canceled and shipped status
ALTER TABLE Online_Retail
ADD OrderStatus VARCHAR(20)

UPDATE Online_Retail
SET OrderStatus = CASE 
					WHEN InvoiceNo LIKE 'C%' THEN 'Canceled'
					ELSE 'Shipped'
				  END;
SELECT * FROM Online_Retail WHERE OrderStatus = 'Canceled';

-- We have no outliers at this point
-- So before move on to analyze, count the canceled orders at here
SELECT
	COUNT(*) AS Num_of_cancels
FROM Online_Retail 
WHERE OrderStatus = 'Canceled';


-- CREATE VIEW TO ANALYZE THE DATASET
-- Checking that Cancel, since we don't want to include them in
CREATE OR ALTER VIEW CleanedRetail AS 
SELECT
	InvoiceNo,
	StockCode,
	Description,
	Quantity, 
	InvoiceDate,
	UnitPrice,
	CustomerID,
	Country,
	Quantity * UnitPrice as TotalPrice,
	OrderStatus
FROM Online_Retail
WHERE 
	InvoiceNo NOT LIKE 'C%'
	AND ISNUMERIC(Quantity) = 1
	AND ISNUMERIC(UnitPrice) = 1

-- Checking after create view to ensure
SELECT COUNT(*)
FROM CleanedRetail

SELECT MIN(InvoiceDate), MAX(InvoiceDate)
FROM CleanedRetail;

SELECT * FROM CleanedRetail
WHERE CustomerID IS NULL;

SELECT * FROM CleanedRetail
WHERE LEN(StockCode) <> 5;

SELECT * FROM CleanedRetail
WHERE InvoiceNo LIKE 'C%';

SELECT * FROM CleanedRetail 
WHERE Quantity < 0;

SELECT TOP 10 Country, ROUND(SUM(TotalPrice), 2) as Revenue
	FROM CleanedRetail
	GROUP BY Country
	ORDER BY Revenue DESC;


