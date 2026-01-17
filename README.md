# 🛒 Retail Sales Performance & Profitability Analysis (SQL)

## 📌 Project Overview

This project demonstrates **end-to-end SQL analysis** on a retail sales dataset, answering **real business questions** typically asked by stakeholders in **Finance, Marketing, Operations, and Executive leadership**.

The goal is to showcase **practical, interview-ready SQL skills** using PostgreSQL, including:

* Advanced aggregations
* Window functions
* Time-series analysis
* Customer segmentation
* Profitability & risk analysis

This project is designed as a **portfolio-quality GitHub project** suitable for **Data Analyst / Business Analyst / Financial Analyst** roles.

---

## 🧠 Business Context

Retail leadership wants to understand:

* Which products and customers drive revenue and profit
* How sales performance changes over time
* Whether certain transactions or categories pose profitability risks
* How customer demographics affect buying behavior

As a **Data Analyst**, you are tasked with answering these questions **using SQL only**.

---

## 🗂 Dataset Description

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

## 🛠 Tools & Skills Used

* **PostgreSQL**
* SQL (CTEs, Window Functions, Aggregations)
* Business Analytics
* Financial Metrics (Revenue, Profit, Margin)

---

## 📊 Key Business Questions & SQL Solutions

### 1️⃣ Revenue & Profit by Category

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

### 3️⃣ Category Profit Margin Analysis

```sql
SELECT
    category,
    SUM(total_sale) AS revenue,
    SUM(total_sale - cogs) AS profit,
    ROUND(100.0 * SUM(total_sale - cogs) / SUM(total_sale), 2) AS profit_margin_pct
FROM retail_sales
GROUP BY category
ORDER BY profit_margin_pct ASC;
```

---

### 4️⃣ Top 10% Customers by Lifetime Value

```sql
WITH customer_spend AS (
    SELECT
        customer_id,
        SUM(total_sale) AS lifetime_value
    FROM retail_sales
    GROUP BY customer_id
),
ranked_customers AS (
    SELECT *,
           NTILE(10) OVER (ORDER BY lifetime_value DESC) AS decile
    FROM customer_spend
)
SELECT *
FROM ranked_customers
WHERE decile = 1;
```

---

### 5️⃣ Customer Demographics Analysis (Gender)

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

### 6️⃣ Age Group × Category Preference

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

---

### 7️⃣ Sales Performance by Hour

```sql
SELECT
    EXTRACT(HOUR FROM sale_time) AS hour,
    SUM(total_sale) AS revenue
FROM retail_sales
GROUP BY hour
ORDER BY hour;
```

---

### 8️⃣ Weekend vs Weekday Profitability

```sql
SELECT
    CASE
        WHEN EXTRACT(DOW FROM sale_date) IN (0,6) THEN 'Weekend'
        ELSE 'Weekday'
    END AS day_type,
    SUM(total_sale) AS revenue,
    SUM(total_sale - cogs) AS profit
FROM retail_sales
GROUP BY day_type;
```

---

### 9️⃣ Detect Abnormally High Transactions

```sql
WITH category_avg AS (
    SELECT
        category,
        AVG(total_sale) AS avg_sale
    FROM retail_sales
    GROUP BY category
)
SELECT
    r.*,
    c.avg_sale
FROM retail_sales r
JOIN category_avg c ON r.category = c.category
WHERE r.total_sale > 3 * c.avg_sale;
```

---

### 🔟 Profitability Risk Scoring (Advanced)

```sql
SELECT
    *,
    (
        CASE WHEN total_sale - cogs < 5 THEN 2 ELSE 0 END +
        CASE WHEN quantity > 5 THEN 1 ELSE 0 END +
        CASE WHEN total_sale > 500 THEN 1 ELSE 0 END
    ) AS risk_score
FROM retail_sales
WHERE (
    CASE WHEN total_sale - cogs < 5 THEN 2 ELSE 0 END +
    CASE WHEN quantity > 5 THEN 1 ELSE 0 END +
    CASE WHEN total_sale > 500 THEN 1 ELSE 0 END
) >= 3;
```

---

## 📈 Key Insights (Example)

* A small number of customers generate a disproportionate share of revenue
* Certain high-revenue categories have thin margins
* Weekends outperform weekdays in total revenue
* A subset of transactions pose profitability risks

---

## 🚀 How to Run This Project

1. Load the dataset into PostgreSQL
2. Create the `retail_sales` table
3. Run queries in the order presented
4. Optionally visualize results in Tableau / Power BI

---

## 📌 Future Enhancements

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
