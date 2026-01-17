
CREATE TABLE sales
(
    transactions_id INT PRIMARY KEY,
    sale_date DATE,	
    sale_time TIME,
    customer_id INT,	
    gender VARCHAR(10),
    age INT,
    category VARCHAR(35),
    quantity INT,
    price_per_unit FLOAT,	
    cogs FLOAT,
    total_sale FLOAT
);



SELECT * FROM sales;


-----Business Question:-----------

--Q1.What is the total revenue and total profit of the company?

SELECT 
    SUM(total_sale) AS total_revenue,
    SUM(total_sale - cogs) AS total_profit
FROM sales;


--Business Insight:
This shows overall financial performance.
If total profit is positive, the company is running in profit; otherwise, it needs cost or pricing optimization

--Q2.How do sales change month by month?

SELECT 
    DATE_TRUNC('month', sale_date) AS month,
    SUM(total_sale) AS monthly_sales
FROM sales
GROUP BY month
ORDER BY month;


--Business Insight:
This helps identify peak and low sales months and supports seasonal planning and inventory management.


--Q3.Which products generate the highest revenue?

SELECT 
    category,
    SUM(total_sale) AS category_revenue
FROM sales
GROUP BY category
ORDER BY category_revenue DESC;


--Business Insight:
High-revenue categories should receive more marketing and stock focus.

--Q4.Which category is most profitable?

SELECT 
    category,
    SUM(total_sale - cogs) AS category_profit
FROM sales
GROUP BY category
ORDER BY category_profit DESC;


--Business Insight:
Some categories may have high sales but low profit.
This analysis helps focus on high-margin categories.

--Q5.Who are the highest value customers?

SELECT 
    customer_id,
    SUM(total_sale) AS total_spent
FROM sales
GROUP BY customer_id
ORDER BY total_spent DESC
LIMIT 10;


--Business Insight:
Top customers contribute a major portion of revenue and should be targeted with loyalty programs.

--Q6.How is cumulative revenue growing over time?
SELECT 
    sale_date,
    total_sale,
    SUM(total_sale) OVER (ORDER BY sale_date) AS running_total_sales
FROM sales
ORDER BY sale_date;


--Business Insight:
Running total shows long-term growth pattern and supports forecasting.

--Q7.What is the ranking of categories based on total sales?

SELECT 
    category,
    SUM(total_sale) AS total_revenue,
    RANK() OVER (ORDER BY SUM(total_sale) DESC) AS category_rank
FROM sales
GROUP BY category;


--Business Insight:
Ranking helps management quickly identify best and worst performing categories.

--Q8.What is the monthly growth rate of sales?

WITH monthly_sales AS (
    SELECT 
        DATE_TRUNC('month', sale_date) AS month,
        SUM(total_sale) AS total_sales
    FROM sales
    GROUP BY month
)
SELECT 
    month,
    total_sales,
    LAG(total_sales) OVER (ORDER BY month) AS previous_month_sales,
    ROUND(
        (total_sales - LAG(total_sales) OVER (ORDER BY month)) * 100.0 /
        LAG(total_sales) OVER (ORDER BY month), 2
    ) AS growth_percentage
FROM monthly_sales
ORDER BY month;

--Business Insight:
Positive growth means business is expanding; negative growth indicates need for strategy change.


--Q9.What is the month-to-month growth rate of sales?
WITH monthly_sales AS (
    SELECT 
        DATE_TRUNC('month', Order_Date) AS Month,
        SUM(Sales) AS Total_Sales
    FROM retail_sales
    GROUP BY Month
)
SELECT 
    Month,
    Total_Sales,
    LAG(Total_Sales) OVER (ORDER BY Month) AS Previous_Month_Sales,
    ROUND(
        (Total_Sales - LAG(Total_Sales) OVER (ORDER BY Month)) 
        * 100.0 / LAG(Total_Sales) OVER (ORDER BY Month), 2
    ) AS Growth_Percentage
FROM monthly_sales
ORDER BY Month;


--Business Insight:
This shows whether the business is growing or declining each month.
Positive growth indicates successful sales strategy, while negative growth signals the need for corrective action.


--Q10.Write a SQL query to create each shift and number of orders (Example Morning <12, Afternoon Between 12 & 17, Evening >17):

WITH hourly_sale
AS
(
SELECT *,
    CASE
        WHEN EXTRACT(HOUR FROM sale_time) < 12 THEN 'Morning'
        WHEN EXTRACT(HOUR FROM sale_time) BETWEEN 12 AND 17 THEN 'Afternoon'
        ELSE 'Evening'
    END as shift
FROM sales
)
SELECT 
    shift,
    COUNT(*) as total_orders    
FROM hourly_sale
GROUP BY shift
