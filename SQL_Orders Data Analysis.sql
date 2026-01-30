CREATE DATABASE master;

use master;

create table df_orders(
order_id int primary key,
order_date date,
ship_mode varchar(20),
segment varchar(20),
country varchar(20),
city varchar(20),
state varchar(20),
postal_code varchar(20),
region varchar(20),
category varchar(20),
sub_category varchar(20),
product_id varchar(50),
quantity int,
discount decimal(10,2),
sale_price decimal(10,2),
profit decimal(10,2));

SELECT * FROM df_orders;


-- find top 10 highest revenue generating products

select product_id,
SUM(quantity) as total_quantity_sold,
SUM(sale_price * quantity) as total_revenue
from df_orders
group by product_id
order by total_revenue desc
limit 10;


-- find top 5 highest selling products in each region

WITH CTE as (
select  region,product_id,
SUM(sale_price * quantity) as total_revenue
from df_orders
group by region,product_id),
rnk_sales as (
select  region,product_id,total_revenue,
dense_rank() OVER(partition by region order by total_revenue desc) as rnk
from CTE
)
select * from rnk_sales where rnk <= 5;

-- find month over month growth comparison for 2022 and 2023 

WITH cte as(
select year(order_date) as order_year,
month(order_date) as order_month,
SUM(sale_price * quantity) as sales
from df_orders
group by year(order_date),month(order_date)
order by year(order_date),month(order_date)
)
select order_month,
SUM(CASE WHEN order_year = 2022 THEN sales ELSE 0 END) AS sales_2022,
SUM(CASE WHEN order_year = 2023 THEN sales ELSE 0 END) AS sales_2023
from cte
group by order_month
order by order_month;

-- for which category which month has highest sales

WITH CTE AS(
select category, date_format(order_date, '%Y-%m') as order_year_month,
SUM(sale_price * quantity) as sales 
from df_orders
group by category,order_year_month
order by category,order_year_month
),
month_highest_sales as(
select category, order_year_month,sales,
RANK() OVER(PARTITION BY category order by sales desc) as rnk_month
from CTE)
select category, order_year_month,sales,rnk_month
from month_highest_sales
where rnk_month = 1;

-- which sub category has highest growth by profit in 2023 vs 2022

WITH CTE AS(
select sub_category,
SUM(CASE WHEN year(order_date) = 2022 THEN profit ELSE 0 END) AS profit_2022,
SUM(CASE WHEN year(order_date) = 2023 THEN profit ELSE 0 END) AS profit_2023
from df_orders
group by sub_category
)
select sub_category,
profit_2022,profit_2023,
(profit_2023 - profit_2022) as abosolute_growth,
((profit_2023 - profit_2022) / NULLIF(profit_2022, 0)) * 100 AS growth_percentage
from CTE
ORDER BY growth_percentage DESC
LIMIT 1;

select * from df_orders;