-- 1. Count total customers
SELECT
    COUNT(customer_id) AS customer_count
FROM customers;

-- 2. Top 10 sellers by income
-- We use COUNT to calculate the number of transactions per seller,
-- SUM to calculate total revenue, JOIN to connect tables,
-- GROUP BY to group by seller, ORDER BY to sort descending, LIMIT to show top 10.
SELECT
    CONCAT(TRIM(e.first_name), ' ', TRIM(e.last_name)) AS seller,
    COUNT(s.sales_id) AS operations,
    SUM(p.price * s.quantity) AS income
FROM sales s
INNER JOIN employees e
    ON s.sales_person_id = e.employee_id
INNER JOIN products p
    ON s.product_id = p.product_id
GROUP BY
    e.first_name,
    e.last_name
ORDER BY income DESC
LIMIT 10;

-- 3. Sellers with average income below overall average
-- CTE calculates the overall average transaction value.
-- Then we compute each seller's average income and compare it to the global average.
-- Results are sorted ascending (worst to best).
WITH avg_all AS (
    SELECT
        AVG(p.price * s.quantity) AS avg_income_all
    FROM sales s
    INNER JOIN products p
        ON s.product_id = p.product_id
)
SELECT
    CONCAT(TRIM(e.first_name), ' ', TRIM(e.last_name)) AS seller,
    FLOOR(AVG(p.price * s.quantity)) AS average_income
FROM sales s
INNER JOIN employees e
    ON s.sales_person_id = e.employee_id
INNER JOIN products p
    ON s.product_id = p.product_id
CROSS JOIN avg_all
GROUP BY
    e.first_name,
    e.last_name,
    avg_all.avg_income_all
HAVING AVG(p.price * s.quantity) < avg_all.avg_income_all
ORDER BY average_income ASC;


-- 4. Daily income by seller and day of week
-- TRIM removes extra spaces, TO_CHAR converts date to day name,
-- SUM aggregates daily income, FLOOR rounds down, EXTRACT gets day-of-week number for sorting.
SELECT
    CONCAT(TRIM(e.first_name), ' ', TRIM(e.last_name)) AS seller,
    TRIM(TO_CHAR(s.sale_date, 'Day')) AS day_of_week,
    FLOOR(SUM(p.price * s.quantity)) AS income,
    EXTRACT(ISODOW FROM s.sale_date) AS day_num
FROM sales s
INNER JOIN employees e
    ON s.sales_person_id = e.employee_id
INNER JOIN products p
    ON s.product_id = p.product_id
GROUP BY
    e.first_name,
    e.last_name,
    TO_CHAR(s.sale_date, 'Day'),
    EXTRACT(ISODOW FROM s.sale_date)
ORDER BY
    day_num,
    seller;

-- 5. Customer age categories
-- CASE distributes customers into age groups,
-- COUNT(*) counts customers per group,
-- ORDER BY manually sorts categories (16–25, 26–40, 40+).
SELECT
    CASE
        WHEN age BETWEEN 16 AND 25 THEN '16-25'
        WHEN age BETWEEN 26 AND 40 THEN '26-40'
        ELSE '40+'
    END AS age_category,
    COUNT(*) AS age_count
FROM customers
GROUP BY
    CASE
        WHEN age BETWEEN 16 AND 25 THEN '16-25'
        WHEN age BETWEEN 26 AND 40 THEN '26-40'
        ELSE '40+'
    END
ORDER BY
    CASE
        WHEN age_category = '16-25' THEN 1
        WHEN age_category = '26-40' THEN 2
        ELSE 3
    END;

-- 6. Monthly income and unique customers
-- TO_CHAR formats date as YYYY-MM,
-- COUNT(DISTINCT) counts unique customers per month,
-- SUM calculates total monthly revenue.
-- Data is grouped by month and sorted chronologically.
SELECT
    TO_CHAR(s.sale_date, 'YYYY-MM') AS date,
    COUNT(DISTINCT s.customer_id) AS total_customers,
    SUM(p.price * s.quantity) AS income
FROM sales s
INNER JOIN products p
    ON s.product_id = p.product_id
GROUP BY
    TO_CHAR(s.sale_date, 'YYYY-MM')
ORDER BY date ASC;

-- 7. First sales with free products
-- CTE finds the earliest purchase date per customer.
-- Then we join to get customer/seller names and filter for $0 products.
-- Results are sorted by customer ID.
WITH first_sales AS (
    SELECT
        s.customer_id,
        MIN(s.sale_date) AS first_date
    FROM sales s
    INNER JOIN products p
        ON s.product_id = p.product_id
    GROUP BY s.customer_id
)
SELECT
    CONCAT(TRIM(c.first_name), ' ', TRIM(c.last_name)) AS customer,
    fs.first_date AS sale_date,
    CONCAT(TRIM(e.first_name), ' ', TRIM(e.last_name)) AS seller
FROM first_sales fs
INNER JOIN sales s
    ON fs.customer_id = s.customer_id
    AND fs.first_date = s.sale_date
INNER JOIN products p
    ON s.product_id = p.product_id
INNER JOIN customers c
    ON s.customer_id = c.customer_id
INNER JOIN employees e
    ON s.sales_person_id = e.employee_id
WHERE p.price = 0
ORDER BY c.customer_id;
