-- 1. Count total customers
SELECT COUNT(*) AS customers_count
FROM customers;

-- 2. Top 10 sellers by income
-- We use COUNT to calculate the number of transactions per seller,
-- SUM to calculate total revenue, JOIN to connect tables,
-- GROUP BY to group by seller, ORDER BY to sort descending
--LIMIT to show top 10.
SELECT
    CONCAT(
        TRIM(employees.first_name),
        ' ',
        TRIM(employees.last_name)
    ) AS seller,
    COUNT(sales.sales_id) AS operations,
    SUM(products.price * sales.quantity) AS income
FROM sales
INNER JOIN employees
    ON sales.sales_person_id = employees.employee_id
INNER JOIN products
    ON sales.product_id = products.product_id
GROUP BY
    employees.first_name,
    employees.last_name
ORDER BY
    income DESC
LIMIT 10;

-- 3. Sellers with average income below overall average
-- CTE calculates the overall average transaction value.
-- Then we compute each seller's average income 
--and compare it to the global average.
-- Results are sorted ascending (worst to best).
WITH per_seller AS (
    SELECT
        CONCAT(TRIM(e.first_name), ' ', TRIM(e.last_name)) AS seller,
        SUM(p.price * s.quantity) AS total_income,
        COUNT(*) AS operations,
        AVG(p.price * s.quantity) AS avg_income
    FROM sales AS s
    INNER JOIN employees AS e ON s.sales_person_id = e.employee_id
    INNER JOIN products AS p ON s.product_id = p.product_id
    GROUP BY seller
),

overall AS (
    SELECT AVG(avg_income) AS avg_all
    FROM per_seller
)

SELECT
    per_seller.seller,
    FLOOR(per_seller.avg_income) AS average_income
FROM per_seller
CROSS JOIN overall
WHERE per_seller.avg_income < overall.avg_all
ORDER BY average_income ASC;

-- 4. Daily income by seller and day of week
-- TRIM removes extra spaces, TO_CHAR converts date to day name,
-- SUM aggregates daily income, FLOOR rounds down
--EXTRACT gets day-of-week number for sorting.
SELECT
    CONCAT(
        TRIM(employees.first_name),
        ' ',
        TRIM(employees.last_name)
    ) AS seller,
    TRIM(TO_CHAR(sales.sale_date, 'Day')) AS day_of_week,
    FLOOR(SUM(products.price * sales.quantity)) AS income,
    EXTRACT(ISODOW FROM sales.sale_date) AS day_num
FROM sales
INNER JOIN employees
    ON sales.sales_person_id = employees.employee_id
INNER JOIN products
    ON sales.product_id = products.product_id
GROUP BY
    employees.first_name,
    employees.last_name,
    TO_CHAR(sales.sale_date, 'Day'),
    EXTRACT(ISODOW FROM sales.sale_date)
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
    TO_CHAR(sales.sale_date, 'YYYY-MM') AS sale_month,
    COUNT(DISTINCT sales.customer_id) AS total_customers,
    SUM(products.price * sales.quantity) AS total_income
FROM sales
INNER JOIN products ON sales.product_id = products.product_id
GROUP BY
    TO_CHAR(sales.sale_date, 'YYYY-MM')
ORDER BY
    sale_month ASC;

-- 7. First sales with free products
-- CTE finds the earliest purchase date per customer.
-- Then we join to get customer/seller names and filter for $0 products.
-- Results are sorted by customer ID.
WITH first_sales AS (
    SELECT
        sales.customer_id,
        MIN(sales.sale_date) AS first_date
    FROM sales
    INNER JOIN products
        ON sales.product_id = products.product_id
    GROUP BY sales.customer_id
)

SELECT
    first_sales.first_date AS sale_date,
    CONCAT(
        TRIM(customers.first_name),
        ' ',
        TRIM(customers.last_name)
    ) AS customer,
    CONCAT(
        TRIM(employees.first_name),
        ' ',
        TRIM(employees.last_name)
    ) AS seller
FROM first_sales
INNER JOIN sales
        ON first_sales.customer_id = sales.customer_id
        AND first_sales.first_date = sales.sale_date
INNER JOIN products
        ON sales.product_id = products.product_id
INNER JOIN customers
        ON sales.customer_id = customers.customer_id
INNER JOIN employees
        ON sales.sales_person_id = employees.employee_id
WHERE products.price = 0
ORDER BY customers.customer_id;

