-- Total Revenue & Profit by Category
-- Which product categories drive the most revenue and profit?
SELECT * FROM retail_sales

SELECT
    category,
    SUM(total_sale) AS total_revenue,
    SUM(total_sale - cogs) AS total_profit
FROM retail_sales
GROUP BY category
ORDER BY total_revenue DESC;

-- Monthly Revenue Trend + MoM Growth
-- Are we growing month over month?

WITH monthly_sales AS (
    SELECT
		EXTRACT(year FROM sale_date) AS year,
        EXTRACT(month FROM sale_date) AS month,
        SUM(total_sale)::numeric AS revenue
    FROM retail_sales
    GROUP BY 1, 2
)
SELECT
    year,
	month,
    revenue,
    revenue - LAG(revenue) OVER (ORDER BY month) AS revenue_change,
    ROUND(
        100 * (revenue - LAG(revenue) OVER (ORDER BY month))
        / NULLIF(LAG(revenue) OVER (ORDER BY month), 0),
        2
    ) AS mom_growth_pct
FROM monthly_sales
ORDER BY year, month;

-- Day of Week Sales Performance
-- Which days perform best?
SELECT
	TO_CHAR(sale_date, 'Day') AS day_of_week,
	SUM(total_sale) AS total_revenue
FROM retail_sales
GROUP BY 1
ORDER BY total_revenue DESC;

-- Category Profit Margin Analysis
-- Which categories look good on revenue but bad on margins?

SELECT
    category,
    SUM(total_sale) AS revenue,
    SUM(total_sale - cogs) AS profit,
    100.0 * SUM(total_sale - cogs) / SUM(total_sale) AS profit_margin_pct
FROM retail_sales
GROUP BY category
ORDER BY profit_margin_pct ASC;

--Loss-Making Transactions
--Are we selling anything at a loss?

SELECT 
	category, cogs, total_sale,
	SUM(total_sale - cogs) AS profit
FROM retail_sales
WHERE total_sale < cogs
GROUP BY 1, 2, 3
ORDER BY profit 

--Top 10% Customers by Lifetime Value
--Who are our most valuable customers?

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

-- Gender-Based Spending Behavior
-- Do male and female customers spend differently?

SELECT
    gender,
    COUNT(*) AS transactions,
    AVG(total_sale) AS avg_transaction_value,
    SUM(total_sale) AS total_revenue
FROM retail_sales
GROUP BY gender;

-- Age Group × Category Preference
-- What do different age groups buy?

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

-- Average Basket Size by Category
-- Which categories are bought in bulk?

SELECT
    category,
    AVG(quantity) AS avg_units_per_transaction
FROM retail_sales
GROUP BY category
ORDER BY avg_units_per_transaction DESC;

-- Sales by Hour of Day
-- When do customers shop the most?

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

--Weekend vs Weekday Profitability
--Are weekends more profitable?

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

-- Rank Customers Within Each Category
-- Who are the top 5 customers per category?

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










