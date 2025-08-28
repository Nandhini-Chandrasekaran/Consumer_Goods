--Task1

SELECT 
   Market
 FROM 
     dim_customer
 WHERE 
    customer = "Atliq Exclusive"    and 
    region = "APAC";

--Task2

with cte1 as (
SELECT
	COUNT(DISTINCT product_code) as unique_product_count_2020
FROM 
  fact_sales_monthly 
WHERE 
  fiscal_year=2020
),

cte2 as (
SELECT
	COUNT(DISTINCT product_code) as unique_product_count_2021
FROM 
  fact_sales_monthly 
WHERE 
  fiscal_year=2021
)
    
SELECT 
    *,
    round((unique_product_count_2021-unique_product_count_2020)/unique_product_count_2020*100,2) as pct_change
FROM cte1
JOIN cte2;

-- Task 3

SELECT 
	segment,
	count(product_code) as product_count
FROM 
	dim_product
GROUP BY 
	segment
ORDER BY 
	product_count desc;

-- Task 4

with unique_products as (
SELECT  
 	p.segment,
	count(distinct(case when fiscal_year=2020 then p.product_code end)) as product_count_2020,
	count(distinct(case when fiscal_year=2021 then p.product_code end)) as product_count_2021
FROM 
	dim_product p
JOIN 
	fact_sales_monthly s
ON 
	p.product_code=s.product_code
GROUP BY 
	p.segment
)
SELECT
  *,
	(product_count_2021 - product_count_2020) AS difference
FROM 
	unique_products
ORDER BY 	
	difference DESC;

-- Task 5
SELECT 
c.customer_code, c.customer,
(SELECT(avg(pre_invoice_discount_pct))) as avg_pid_pct
FROM 
dim_customer c
JOIN 
fact_pre_invoice_deductions p
ON 
p.customer_code = c.customer_code
WHERE 
p.fiscal_year = 2021 and c.market = 'India'
GROUP BY  customer
ORDER BY  avg_pid_pct desc
LIMIT 5;

--Task 6
WITH temp_table AS (
SELECT 
    monthname (date) AS months ,
    month(date) AS month_number, 
    year(date) AS year,
    (sold_quantity * gross_price)  AS gross_sales
 FROM 
	fact_sales_monthly s 
JOIN
    fact_gross_price g ON s.product_code = g.product_code
JOIN 
	dim_customer c ON s.customer_code=c.customer_code
 WHERE 
	customer="Atliq exclusive"
)
SELECT months,year, concat(round(sum(gross_sales)/1000000,2),"M") AS gross_sales FROM temp_table
GROUP BY 
	year,months
ORDER BY 
	year,month_number;

--Task 7
WITH temp_table AS (
SELECT 
    monthname (date) AS months ,
    month(date) AS month_number, 
    year(date) AS year,
    (sold_quantity * gross_price)  AS gross_sales
FROM 
	fact_sales_monthly s 
JOIN  
	fact_gross_price g 
ON s.product_code = g.product_code
JOIN 
	dim_customer c 
ON s.customer_code=c.customer_code
WHERE 
	customer="Atliq exclusive")
SELECT 
months,year, concat(round(sum(gross_sales)/1000000,2),"M") AS gross_sales 
FROM temp_table
GROUP BY year,months
ORDER BY year,month_number;

--Task 8
with tem_table as (
SELECT 
	date,
	CEIL (MONTH(DATE_ADD(date, INTERVAL 4 MONTH)) / 3) as Quarter,
	sold_quantity
FROM 
	fact_sales_monthly
WHERE 
	fiscal_year =2020)

SELECT 
	concat ( 'Q', Quarter) as Quarter,
	round(sum(sold_quantity)/1000000 , 2) as total_sold_quantity_mln
FROM tem_table
group by Quarter;


--Task 9

with temp_table as (
SELECT 
	c.channel,
	round(sum(s.sold_quantity*g.gross_price)/1000000,2) as gross_sales_mln
FROM 
	dim_customer c
JOIN 
	fact_sales_monthly s
ON 
	c.customer_code=s.customer_code
JOIN 
	fact_gross_price g
ON 
	g.product_code=s.product_code 
WHERE  
	s.fiscal_year = 2021
GROUP BY 
	c.channel
	)
SELECT *,
	gross_sales_mln*100/sum(gross_sales_mln) over() as percentage
FROM temp_table
ORDER BY percentage desc;


--Task 10
with temp_table as (
SELECT 
	p.division,p.product_code,p.product,
	sum(s.sold_quantity) as total_sold_quantity,
	rank() over (partition by division order by (sum(s.sold_quantity)) desc ) as rank_order
FROM 
	dim_product p
JOIN 
	fact_sales_monthly s
ON 
	p.product_code = s.product_code
WHERE 
	s.fiscal_year=2021
GROUP BY 
	product_code
	)
SELECT *
FROM temp_table
WHERE rank_order <=3;




