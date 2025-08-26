Task1;

SELECT 
   Market
 FROM 
     dim_customer
 WHERE 
    customer = "Atliq Exclusive“    and 
    region = "APAC";

Task2;

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

Task 3;

SELECT 
	segment,
	count(product_code) as product_count
FROM 
	dim_product
GROUP BY 
	segment
ORDER BY 
	product_count desc;

Task 4;

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

Task 5;



