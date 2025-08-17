# UCI_Online_Retail
# Project Overview
This project is for learning purposed with Data Cleaning, Exploratory with SQL and Visualize via Power BI to uncover key metrics and insights for customers, product and sales pattern.

# About dataset
- Source: UCI Machine Learning Repository
- Size: 541909 Values
- Data Name: Online Retail 
- Time Period: 01/12/2010 and 09/12/2011
- Description: This is a transactional data set which contains all the transactions occurring between 01/12/ 2010 and 09/12/2011 for a UK-based and registered non-store online retail.The company mainly sells unique all-occasion gifts. Many customers of the company are wholesalers.

## Dataset is included in Data folder or 👉 [here](https://archive.ics.uci.edu/dataset/352/online+retail)

# Objectives
- Data Cleaning: Handled missing/null values.
- Product and Sales Insights: Discovered some time-analysis over Product and Revenue on business.
- Customer Insights: Analyzed purchasing behaviour, performing RFM Analysis.

# Questions
- Total Orders
- Total Revenue
- Total Revenue by Year and Quarter
- Total Revenue by Year and Month
- Highest value customers by total spend
- Num of orders, num of customers and avg paid price by Country
- Total Item Sold by Product

# Customer Lifetime Value
CLV - Predicts the net profit a business can expect to earn from a customer throughout their lifespan with the formula is: CLV = (Average Purchase Value x Average Purchase Frequency) x Average Customer Lifespan

# RFM Analysis
RFM (Recency, Frequency, Monetary) analysis is a customer segmentation technique used in Marketing and Business Analytics, tt helps identify customers based on their purchase behaviour with three attributes.
- Recency (R) : How recently a customer made a purchase.
- Frequency (F): How often a customer makes purchases.
- Monetary Value (M): How much a customer spends in total.

# Proposed
After the analyze, we can summary and proposed some key insights for business
- The Products have seen a large gap with (35K - 54K - 81K).
- United Kingdom emerge as not only the highest spenders but also highest in frequency, making efforts on United Kingdom and explore more on Netherlands and Ireland.
- The largest group is Lost customers (988), shows that many customers are inactive and need re-engagement
- Loyal Customer and Champions still are on strong form, although Champions sit at 204 customers
- Potential Loyalists are high, meaning more strategies focus on them
- High Value at Risk are one to keep an eyes on, they need to be on track
- We have many frequent customers
- CLV is at 228732.4, means that a Customer is expected so spend an amount of 228732 on their full cycle of the business

# Visualization
![RFM Analysis](./Assets/SUMMARY_PAGE_1.png)

![RFM Analysis](./Assets/SUMMARY_PAGE_2.png)