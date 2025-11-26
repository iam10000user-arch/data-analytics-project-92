"select count(customer_id) as customer_count from customers;"
Äàííûé çàïðîñ èñïîëüçóåò àãðåãèðóþùóþ ôóíêöèþ Count äëÿ ïîñ÷åò ïîëüçîâàòåëåé

SELECT 
    CONCAT(TRIM(e.first_name), ' ', TRIM(e.last_name)) AS seller,
    COUNT(s.sales_id) AS operations,
    SUM(p.price * s.quantity) AS income
FROM sales s
JOIN employees e ON s.sales_person_id = e.employee_id
JOIN products p ON s.product_id = p.product_id
GROUP BY e.first_name, e.last_name
ORDER BY income DESC
LIMIT 10;
Здесь мы берем функцию TRIM чтобы собрать вместе фамилию и имя сотрудника, Count считает количество сделок для продавца, SUM - общую выручку
функция JOIN состыкует таблицы меж собой, GROUP BY - группировка по продавцам, ORDER BY - сортировка от большего к меньшему, LIMIT - показывает только первые 10 результатов.

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
Здесь мы используем подзапрос CTE для вычисления общей средней выручки по сделкам, далее берем все продажи и связываем их с продавцами и товарами. В ходе этого полключаем подзапрос, чтобы в каждой строчке иметь доступ к средней выручке по компании.
Затем считаем среднюю выручку для каждого продавца. Group by - для группорировки продажи по каждому продавцу, а HAVING - сравнение средней выручки продавца с общей средней.
  И order by - упорядочивает список от худшего к лучшему

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

Здесь мы берем функцию TRIM чтобы собрать вместе фамилию и имя сотрудника, TO_CHAR - преобразует латц в дни недели, TRIM - убирвет ненужные пробелы, SUM - складывает все за день,FLOOR - округляет до целого в меньшую сторону.
EXTRACT - дает нам номер дня недели, необходимо для сортировки, котрую сделаем с помощью ORDER BY в конце. Потом джойним таблицы и группируем по необходимым параметрам, проводим сортировку.


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

CASE END - распределяет покупателей по возрастным категориям.
  Потом, смотрим кол-во покупателей в каждой категории
Группируем по возрастным категориям
И сортировку мы создаем вручную, по присваивая каждой категории свой номер


SELECT 
    TO_CHAR(s.sale_date, 'YYYY-MM') AS date,
    COUNT(DISTINCT s.customer_id) AS total_customers,
    SUM(p.price * s.quantity) AS income
FROM sales s
JOIN products p ON s.product_id = p.product_id
GROUP BY TO_CHAR(s.sale_date, 'YYYY-MM')
ORDER BY date ASC;

TO_СHAR - дата превращается в число
COUNT DISTINCT - кол-во уникальных покупателей
Потом считаем суммарную выручку за месяц
Джойним таблицы
Группируем данные по месяцам
И сортируем от 1 до последнего месяца

WITH first_sales AS (
    SELECT 
        s.customer_id,
        MIN(s.sale_date) AS first_date
    FROM sales s
    JOIN products p ON s.product_id = p.product_id
    GROUP BY s.customer_id
)
SELECT 
    CONCAT(TRIM(c.first_name), ' ', TRIM(c.last_name)) AS customer,
    fs.first_date AS sale_date,
    CONCAT(TRIM(e.first_name), ' ', TRIM(e.last_name)) AS seller
FROM first_sales fs
JOIN sales s ON fs.customer_id = s.customer_id AND fs.first_date = s.sale_date
JOIN products p ON s.product_id = p.product_id
JOIN customers c ON s.customer_id = c.customer_id
JOIN employees e ON s.sales_person_id = e.employee_id
WHERE p.price = 0
ORDER BY c.customer_id;
Изначально используем подзапрос, находим самую ранную дату покупки
Потом собираем имя и фамилию продавца и покупателя
Джойним таблицы
ставим условия, что первая покупка была акционной
И сортируем покупателей по ID

