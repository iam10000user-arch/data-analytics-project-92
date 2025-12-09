SELECT COUNT(customer_id) AS customer_count FROM customers;
--We use COUNT function - calculate the total number of customers--
SELECT 
    CONCAT(TRIM(e.first_name), ' ', TRIM(e.last_name)) AS seller,
    COUNT(s.sales_id) AS operations,
    SUM(p.price * s.quantity) AS income
FROM sales s
INNER JOIN employees e ON s.sales_person_id = e.employee_id
JOIN products p ON s.product_id = p.product_id
GROUP BY e.first_name, e.last_name
ORDER BY income DESC
LIMIT 10;
--Here, we use the TRIM function to collect the employee's last name and first name, Count calculates the number of transactions for the seller, SUM calculates the total revenue--
--the JOIN function connects the tables, GROUP BY groups the results by seller, ORDER BY sorts the results from largest to smallest, and LIMIT shows only the first 10 results.--
WITH avg_all AS (
    SELECT 
        AVG(p.price * s.quantity) AS avg_income_all
    FROM sales s
    JOIN products p ON s.product_id = p.product_id
)
SELECT 
    CONCAT(TRIM(e.first_name), ' ', TRIM(e.last_name)) AS seller,
    FLOOR(AVG(p.price * s.quantity)) AS average_income
FROM sales s
JOIN employees e ON s.sales_person_id = e.employee_id
JOIN products p ON s.product_id = p.product_id,
     avg_all
GROUP BY e.first_name, e.last_name, avg_all.avg_income_all
HAVING AVG(p.price * s.quantity) < avg_all.avg_income_all
ORDER BY average_income ASC;
--Here, we use a CTE subquery to calculate the total average revenue for transactions, then we take all the sales and associate them with sellers and products. We use a subquery to access the average revenue for each company in each row.--
--Then, we calculate the average revenue for each seller. We use group by to group the sales by each seller, and we use having to compare the average revenue for each seller with the total average revenue.--
--Finally, we use order by to sort the list from worst to best.--
SELECT 
    CONCAT(TRIM(e.first_name), ' ', TRIM(e.last_name)) AS seller,
    TRIM(TO_CHAR(s.sale_date, 'Day')) AS day_of_week,
    FLOOR(SUM(p.price * s.quantity)) AS income,
    EXTRACT(ISODOW FROM s.sale_date) AS day_num
FROM sales s
JOIN employees e ON s.sales_person_id = e.employee_id
JOIN products p ON s.product_id = p.product_id
GROUP BY e.first_name, e.last_name, TO_CHAR(s.sale_date, 'Day'), EXTRACT(ISODOW FROM s.sale_date)
ORDER BY day_num, seller;
--Here we take the TRIM function to collect together the employee's last name and first name, TO_CHAR - converts the latz to days of the week, TRIM - removes unnecessary spaces, SUM - adds up everything for the day, FLOOR - rounds down to the nearest whole number.--
--EXTRACT - gives us the day of the week number, which is necessary for sorting, which we will do using ORDER BY at the end. Then we join the tables and group them by the necessary parameters, and sort them.--
SELECT 
    CASE 
        WHEN age BETWEEN 16 AND 25 THEN '16-25'
        WHEN age BETWEEN 26 AND 40 THEN '26-40'
        ELSE '40+'
    END AS age_category,
    COUNT(*) AS age_count
FROM customers
GROUP BY age_category
ORDER BY 
    CASE 
        WHEN age_category = '16-25' THEN 1
        WHEN age_category = '26-40' THEN 2
        ELSE 3
    END;
--CASE END - distributes customers by age category.--
--Then, we look at the number of customers in each category--
--Grouped by age categories--
--And we create the sorting manually by assigning a number to each category--
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
--TO_CHAR - date is converted to a number--
--COUNT DISTINCT - number of unique customers--
--Then we calculate the total revenue for the month--
--Join the tables--
--Group the data by month--
--And sort from 1 to the last month--
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
--Initially, we use a subquery to find the earliest purchase date--
--Then, we collect the names and surnames of the seller and the buyer--
--We join the tables and set conditions that the first purchase was a promotional offer--
--We sort the buyers by ID--





