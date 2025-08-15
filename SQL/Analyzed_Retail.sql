-- ANALYZE THE DATASET

SELECT * 
FROM CleanedRetail

-- Beside are some questions to answer

-- 1. Total Orders
SELECT COUNT(DISTINCT InvoiceNo) as Num_of_orders
FROM CleanedRetail;

-- 2. Total Revenue
Select ROUND(SUM(TotalPrice), 2) as Revenue
FROM CleanedRetail;

-- 3. Total Revenue by Year and Quarter
SELECT 
    YEAR(InvoiceDate) AS Year,
    DATEPART(QUARTER, InvoiceDate) AS Quarter,
    ROUND(SUM(TotalPrice), 2) AS Revenue
FROM CleanedRetail
GROUP BY 
    YEAR(InvoiceDate), 
    DATEPART(QUARTER, InvoiceDate)
ORDER BY 
    Year, 
    Quarter;

-- 4. Total Revenue by Year and Month
SELECT 
    YEAR(InvoiceDate) AS Year,
    DATEPART(MONTH, InvoiceDate) AS Month,
    ROUND(SUM(TotalPrice), 2) AS Revenue
FROM CleanedRetail
GROUP BY 
    YEAR(InvoiceDate), 
    DATEPART(MONTH, InvoiceDate)
ORDER BY 
    Year, 
    Month;

-- 5. Total Revenue by Countries
SELECT TOP 10 Country, ROUND(SUM(TotalPrice), 2) as Revenue
	FROM CleanedRetail
	GROUP BY Country
	ORDER BY Revenue DESC;

-- 6. Highest value customers by total spend
SELECT TOP 10 CustomerID, ROUND(SUM(TotalPrice), 2) as Revenue
FROM CleanedRetail
GROUP BY CustomerID
ORDER BY Revenue DESC

-- 7.Num of orders, num of customers and avg paid price by Country
SELECT TOP 10 Country,
          COUNT(DISTINCT InvoiceNo) AS Num_of_orders,
          COUNT(DISTINCT CustomerId) AS Num_of_customers,
          ROUND(AVG(TotalPrice), 2) AS Avg_Payment
    FROM  CleanedRetail
GROUP BY  Country
ORDER BY  Num_of_orders DESC,		
          Num_of_customers DESC;

-- 8. Num of orders by Date
SELECT TOP 10
	InvoiceDate as date,
	COUNT(DISTINCT InvoiceNo) as Number_Of_Orders
FROM CleanedRetail
GROUP BY InvoiceDate
ORDER BY Number_Of_Orders DESC;

-- 9. Total Item Sold by Product
SELECT TOP 10
	StockCode,
	Description,
	CONCAT(StockCode, ' - ', Description) AS ProductLabel,
	SUM(Quantity) AS Item_sold
FROM CleanedRetail
WHERE Description IS NOT NULL
GROUP BY StockCode, Description
ORDER BY SUM(Quantity) DESC;

-- RFM Analysis
-- RFM (Recency, Frequency, Monetary) analysis is a customer segmentation technique used in Marketing and Business Analytics
-- It helps identify customers based on their purchase behaviour

-- Recency (R) : How recently a customer made a purchase.
-- Frequency (F): How often a customer makes purchases.
-- Monetary Value (M): How much a customer spends in total.

-- Steps to RFM
-- 1. Calculate the R,F,M of each customer
-- 2. Calculate the score based on their behaviour
-- 3. Customer segment 

SELECT MAX(InvoiceDate) FROM CleanedRetail;

DECLARE @MaxDateAfter DATE = '2011-12-10';
WITH rfm_base AS (
    SELECT
        CustomerID,
        DATEDIFF(DAY, MAX(InvoiceDate), @MaxDateAfter) AS Recency,
        COUNT(DISTINCT InvoiceNo) AS Frequency,
        SUM(TotalPrice) AS Monetary
    FROM CleanedRetail
    GROUP BY CustomerID
),
rfm_score AS (
    SELECT 
        CustomerID, 
        Recency, 
        Frequency, 
        Monetary,
        NTILE(5) OVER(ORDER BY Recency ASC) AS recency_score,
        NTILE(5) OVER(ORDER BY Frequency DESC) AS frequency_score,
        NTILE(5) OVER(ORDER BY Monetary DESC) AS monetary_score
    FROM rfm_base
)
SELECT
    CustomerID, 
    recency_score,
    frequency_score,
    monetary_score,
    CASE 
        WHEN recency_score = 5 AND frequency_score = 5 AND monetary_score = 5 
            THEN 'Champions'
        WHEN recency_score >= 4 AND frequency_score >= 4 AND monetary_score >= 4
            THEN 'Loyal Customer'
        WHEN recency_score = 5 AND frequency_score <= 2 AND monetary_score >= 4
            THEN 'New Customer'
        WHEN recency_score = 5 AND frequency_score >= 4 AND monetary_score <= 3
            THEN 'Frequently Customer'
        WHEN recency_score BETWEEN 3 AND 4 AND frequency_score BETWEEN 3 AND 4 
             AND monetary_score BETWEEN 3 AND 4
            THEN 'Potential Loyalists'
        WHEN recency_score <= 2 AND frequency_score >= 4 AND monetary_score >= 4
            THEN 'High Value at Risk'
		WHEN recency_score >= 4 AND frequency_score BETWEEN 2 AND 3 AND monetary_score >= 4
			THEN 'Recent - High Spend'
		WHEN recency_score BETWEEN 3 AND 4 AND frequency_score >= 4 AND monetary_score <= 3
			THEN 'Frequent - Low Spend'
		WHEN recency_score = 5 AND frequency_score = 3 AND monetary_score BETWEEN 2 AND 3
			THEN 'New - Moderate Value'
        WHEN recency_score <= 2 AND frequency_score <= 2 AND monetary_score <= 2
            THEN 'Lost'
        ELSE 'Other'
    END AS customer_segment
INTO RFM_Table
FROM rfm_score
ORDER BY recency_score DESC,
         frequency_score DESC,
         monetary_score DESC;

SELECT * FROM RFM_Table
ORDER BY recency_score DESC,
         frequency_score DESC,
         monetary_score DESC;

-- Customer segment Distribution
SELECT customer_segment, 
	   COUNT(*) AS Num_of_customers
FROM RFM_Table
WHERE customer_segment != 'Other'
GROUP BY customer_segment
ORDER BY COUNT(*) DESC;

-- SUMMARY for segment
-- The largest group is Lost customers (988), shows that many customers are inactive and need re-engagement
-- Loyal Customer and Champions still are on strong form, although Champions sit at 204 customers
-- Potential Loyalists are high, meaning more strategies focus on them
-- High Value at Risk are one to keep an eyes on, they need to be on track
-- We have many frequent customers

-- Customer Lifetime Value
-- CLV - Predicts the net profit a business can expect to earn from a customer throughout their lifespan
-- The formula is : CLV = (Average Purchase Value x Average Purchase Frequency) x Average Customer Lifespan
-- With breakdown below
-- Average Purchase Value = Total Revenue / Total Orders
-- Average Purchase Frequency = Total Orders / Total Unique Customers
-- Average Customer Lifespan = Sum of individual Customer Lifespans / Total Unique Customers
-- Since the Average Lifespan = 0 is too much
-- We will DATEDIFF on each CustomerID to find their lifespan, then we will take average of all CustomerID Lifespan

-- Avg Purchase Value
SELECT TOP 10 * FROM CleanedRetail;
WITH APV as (
	SELECT
		ROUND(SUM(TotalPrice) / COUNT(DISTINCT InvoiceNo), 2) as Avg_Purchase_Value
	FROM CleanedRetail
), 
APF as (
	SELECT
		ROUND(COUNT(DISTINCT InvoiceNo) / COUNT(DISTINCT CustomerID), 2) as Avg_Purchase_Frequency
	FROM CleanedRetail
),
ACL as (
	SELECT 
	ROUND(AVG(Customer_lifespan), 2) as Avg_Customer_Lifespan
	FROM (
		SELECT 
		CustomerID,
		DATEDIFF(DAY, MIN(InvoiceDate), MAX(InvoiceDate)) as Customer_lifespan
		FROM CleanedRetail
		GROUP BY CustomerID
	) as subquery
)
SELECT
	apv.Avg_Purchase_Value,
	apf.Avg_Purchase_Frequency,
	acl.Avg_Customer_Lifespan,
	(apv.Avg_Purchase_Value * apf.Avg_Purchase_Frequency * acl.Avg_Customer_Lifespan) as CLV
FROM APV apv
CROSS JOIN APF apf
CROSS JOIN ACL acl;

-- With CLV count as 228732.4 
-- We know that a Customer is expected so spend an amount of 228732 on their full cycle of the business
	
