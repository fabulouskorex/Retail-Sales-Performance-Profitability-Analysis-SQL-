# 🛒 Retail Sales Performance & Profitability Analysis (SQL)

## Project Overview

This project demonstrates **end-to-end SQL analysis** on a retail sales dataset, answering **real business questions** typically asked by stakeholders in **Finance, Marketing, Operations, and Executive leadership**.

The goal is to showcase **practical, interview-ready SQL skills** using PostgreSQL, including:

* Advanced aggregations
* Window functions
* Time-series analysis
* Customer segmentation
* Profitability & risk analysis

This project is designed as a **portfolio-quality GitHub project** suitable for **Data Analyst / Business Analyst / Financial Analyst** roles.

---

## Business Context

Retail leadership wants to understand:

* Which products and customers drive revenue and profit
* How sales performance changes over time
* Whether certain transactions or categories pose profitability risks
* How customer demographics affect buying behavior

As a **Data Analyst**, you are tasked with answering these questions **using SQL only**.

---

## Dataset Description

**Table name:** `retail_sales`

| Column Name    | Description                |
| -------------- | -------------------------- |
| sale_date      | Date of transaction        |
| sale_time      | Time of transaction        |
| customer_id    | Unique customer identifier |
| gender         | Customer gender            |
| age            | Customer age               |
| category       | Product category           |
| quantity       | Units purchased            |
| price_per_unit | Price per unit             |
| cogs           | Cost of goods sold         |
| total_sale     | Total transaction value    |

---

## Tools & Skills Used

* **PostgreSQL**
* SQL (CTEs, Window Functions, Aggregations)
* Business Analytics
* Financial Metrics (Revenue, Profit, Margin)

---

## Key Business Questions & SQL Solutions

### 1️⃣ Revenue & Profit by Category
*Which product categories drive the most revenue and profit?*

```sql
SELECT
    category,
    SUM(total_sale) AS total_revenue,
    SUM(total_sale - cogs) AS total_profit
FROM retail_sales
GROUP BY category
ORDER BY total_revenue DESC;
```

---

### 2️⃣ Monthly Revenue Trend & MoM Growth
*Are we growing month over month?*

```sql
WITH monthly_sales AS (
    SELECT
        DATE_TRUNC('month', sale_date) AS month,
        SUM(total_sale) AS revenue
    FROM retail_sales
    GROUP BY 1
)
SELECT
    month,
    revenue,
    revenue - LAG(revenue) OVER (ORDER BY month) AS revenue_change,
    ROUND(
        100.0 * (revenue - LAG(revenue) OVER (ORDER BY month))
        / NULLIF(LAG(revenue) OVER (ORDER BY month), 0), 2
    ) AS mom_growth_pct
FROM monthly_sales
ORDER BY month;
```

---

### 3️⃣ Day of Week Sales Performance
*Which days perform best?*

```sql
SELECT
	TO_CHAR(sale_date, 'Day') AS day_of_week,
	SUM(total_sale) AS total_revenue
FROM retail_sales
GROUP BY 1
ORDER BY total_revenue DESC;
```

---

### 4️⃣ Category Profit Margin Analysis
*Which categories look good on revenue but bad on margins?*

```sql
SELECT
    category,
    SUM(total_sale) AS revenue,
    SUM(total_sale - cogs) AS profit,
    100.0 * SUM(total_sale - cogs) / SUM(total_sale) AS profit_margin_pct
FROM retail_sales
GROUP BY category
ORDER BY profit_margin_pct ASC;
```

---

### 5️⃣ Loss-Making Transactions
*Are we selling anything at a loss?*

```sql
SELECT 
	category, cogs, total_sale,
	SUM(total_sale - cogs) AS profit
FROM retail_sales
WHERE total_sale < cogs
GROUP BY 1, 2, 3
ORDER BY profit 
```

---


### 6️⃣ Age Group × Category Preference
*What do different age groups buy?*

```sql
SELECT
    CASE
        WHEN age < 25 THEN 'Under 25'
        WHEN age BETWEEN 25 AND 34 THEN '25–34'
        WHEN age BETWEEN 35 AND 44 THEN '35–44'
        WHEN age BETWEEN 45 AND 54 THEN '45–54'
        ELSE '55+'
    END AS age_group,
    category,
    SUM(total_sale) AS revenue
FROM retail_sales
GROUP BY 1, 2
ORDER BY age_group, revenue DESC;
```
### Gender-Based Spending Behaviour
*Do male and female customers spend differently?*

```sql
SELECT
    gender,
    COUNT(*) AS transactions,
    AVG(total_sale) AS avg_transaction_value,
    SUM(total_sale) AS total_revenue
FROM retail_sales
GROUP BY gender;
```
---

### 7️⃣ Sales Performance by Time of Day
*When do customers shop the most?*

```sql
WITH hourly_sale
AS
(
SELECT *,
	CASE 
	WHEN EXTRACT(HOUR FROM sale_time) < 12 THEN 'Morning'
	WHEN EXTRACT(HOUR FROM sale_time) BETWEEN 12 AND 17 THEN 'Afternoon'
		ELSE 'Evening'
	END AS shift
FROM retail_sales
)
SELECT shift,
	SUM(total_sale) AS revenue
FROM hourly_sale
GROUP BY shift 
ORDER BY revenue DESC;
```

---

### 8️⃣ Weekend vs Weekday Profitability
*Are weekends more profitable?*

```sql
SELECT
    CASE
        WHEN EXTRACT(DOW FROM sale_date) IN (0,6) THEN 'Weekend'
        ELSE 'Weekday'
    END AS day_type,
    SUM(total_sale) AS revenue,
    SUM(total_sale - cogs) AS profit
FROM retail_sales
GROUP BY day_type
ORDER BY profit DESC;
```

---

### 9️⃣ Rank Customers Within Each Category
*Who are the top 5 customers per category?*

```sql
WITH customer_category_spend AS (
    SELECT
        category,
        customer_id,
        SUM(total_sale) AS total_spent
    FROM retail_sales
    GROUP BY category, customer_id
),
ranked_customers AS (
    SELECT
        category,
        customer_id,
        total_spent,
        DENSE_RANK() OVER (
            PARTITION BY category
            ORDER BY total_spent DESC
        ) AS category_rank
    FROM customer_category_spend
)
SELECT
    category,
    customer_id,
    total_spent,
    category_rank
FROM ranked_customers
WHERE category_rank <= 5
ORDER BY category, category_rank;
```

---

### 🔟 Average Sales Performance by Month
*Best-selling month in each year?*

```sql
SELECT year, month, avg_sale
FROM
(
SELECT
	EXTRACT(year FROM sale_date) AS year, 
	EXTRACT(month FROM sale_date) AS month,
	AVG(total_sale) AS avg_sale,
	RANK() OVER(PARTITION BY EXTRACT(year FROM sale_date) ORDER BY AVG(total_sale) DESC) AS rank
FROM retail_sales
	GROUP BY 1, 2
	ORDER BY 1, 3 DESC 
) 
WHERE rank = 1
```

---

## Key Insights 

* A small number of customers generate a disproportionate share of revenue
* Certain high-revenue categories have thin margins
* Weekdays outperform weekends in total revenue
* Electronics category drives the most revenue
* 

---

## How to Run This Project

1. Load the dataset into PostgreSQL
2. Create the `retail_sales` table
3. Run queries in the order presented
4. Optionally visualize results in Tableau / Power BI

---

## Future Enhancements

* Add dashboards (Tableau / Power BI)
* Create stored procedures
* Add indexes & performance tuning
* Simulate fraud detection or anomaly alerts

---

## 👤 Author

**Korede Olaosun**
Data Analyst | SQL | Finance & Business Analytics

---

⭐ If you find this project useful, feel free to star the repository!
