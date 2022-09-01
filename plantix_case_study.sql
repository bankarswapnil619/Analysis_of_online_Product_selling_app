-- Plantix Partner app allows Retailers to order supplies online.
/*there are 3 tables. The login_logs table contains information about users
logging in. The sales orders table contains information about orders made and the
sales_orders_items contains the specifics of each order. You have been provided with data
for July 2021 and July 2022.*/

-- creating database 
create database plantix_casestudy;

-- selecting that database for use
Use plantix_casestudy;
select database();

-- Creating tables

create table sales_orders( order_id int,
fk_buyer_id int,
fk_depot_id int,
sales_order_status varchar(20),
creation_time time);


create table sales_orders_items( order_item_id int,
fk_product_id int,
fk_order_id int,
ordered_quantity int,
order_quantity_accepted int,
rate decimal(10,2));


create table login_logs(login_log_id int,
user_id int,
login_time datetime);


select * from sales_orders;   -- contains 5columns and 13630 rows
describe sales_orders;


select * from sales_orders_items;    -- contains 6 columns and 20488 rows
describe sales_orders_items;

select * from login_logs;        -- contains 3 columns and 666357 rows
describe login_logs;


--                                                ###   1. studying sales_orders table ###
-- 1.1 Total sales_order placed
select count(*) Total_sales_order_placed
from  sales_orders;    -- 13630

-- 1.2 Total no of unique buyers in both year
select count(distinct(fk_buyer_id)) Total_unique_buyers from sales_orders;  -- 4832

-- 1.3 Total no of unique buyers by year
select year(date(creation_time)) as year,count(distinct(fk_buyer_id)) Total_unique_buyers
from  sales_orders
group by year;

-- 1.4 perecentage increased in buyer 
with cte as (select 
(select count(distinct(fk_buyer_id)) 
from  sales_orders) Total_unique_buyers,
(select count(distinct(fk_buyer_id)) 
from  sales_orders
where year(date(creation_time))=2021) Total_unique_buyers_year2021,
(select count(distinct(fk_buyer_id)) Total_unique_buyers
from  sales_orders
where year(date(creation_time))=2022) Total_unique_buyers_year2022)
select Total_unique_buyers,Total_unique_buyers_year2021,Total_unique_buyers_year2022 ,((Total_unique_buyers_year2022-Total_unique_buyers_year2021)/Total_unique_buyers*100) as Percentage_increase_in_buyers_in_year2022
from cte;

-- 1.5 Total sales order by status
select sales_order_status,count(*) Orders
from  sales_orders
group by sales_order_status;

-- 1.6 Total order status by year
select year(date(creation_time)) as year,sales_order_status,count(*) orders
from  sales_orders
group by sales_order_status, year;

-- 1.7 comparing Total orders placed vs shipped orders vs rejected orders
select year(creation_time) year,count(*) as Total_order_by_year,
sum(case when sales_order_status='Shipped' then 1 else 0 end) as Shipped_Orders_Qty,
sum( case when sales_order_status='Rejected' then 1 else 0 end) as rejected_Orders_Qty
from sales_orders
group by year;

-- 1.8 Overall percentage of order Rejected/Shipped
select sum( case when sales_order_status='Rejected' then 1 else 0 end)/count(*)*100 as Overall_percentage_of_order_rejected,
sum(case when sales_order_status='Shipped' then 1 else 0 end)/count(*)*100  as Overall_percentage_of_order_shipped
from sales_orders;

-- 1.9 Order status percenatge of total orders by years
select year(creation_time) year,sum( case when sales_order_status='Rejected' then 1 else 0 end)/count(*)*100 as rejected_quantity,
sum(case when sales_order_status='Shipped' then 1 else 0 end)/count(*)*100  as Shipped_quantity
from sales_orders
group by year;

-- 1.10 Order status by Day of week
select dayname((creation_time)) day ,count(*) as Total_order_placed,
sum(case when sales_order_status='Shipped' then 1 else 0 end) as Shipped_Orders_Qty,
sum( case when sales_order_status='Rejected' then 1 else 0 end) as Rejected_Orders_Qty
from sales_orders
group by day
order by Total_order_placed DESC;

-- 1.11 Order status % by Day of week
select dayname((creation_time)) day ,sum( case when sales_order_status='Rejected' then 1 else 0 end)/count(*)*100 as 'Rejected_quantity%',
sum(case when sales_order_status='Shipped' then 1 else 0 end)/count(*)*100  as 'Shipped_quantity%'
from sales_orders
group by day;

-- 1.12  Buyers with no of orders placed and their status
SELECT fk_buyer_id, count(*) as"No_of_orders_Placed",
sum(case when  sales_order_status= 'Shipped' then 1 else 0 end) Shipped_Orders_Qty,
sum(case when  sales_order_status= 'Rejected' then 1 else 0 end) Rejected_Orders_Qty
from sales_orders
group by fk_buyer_id 
order by No_of_orders_Placed DESC;

-- 1.13 Depot with total no of unique buyers
select fk_depot_id, count(distinct(fk_buyer_id)) as "Total_no_of_unique_buyers"
from sales_orders
group by fk_depot_id
order by Total_no_of_unique_buyers desc;

-- 1.14 Depots with Total Orders and their status
select fk_depot_id,count(order_id) Total_order_placed, 
sum(case when  sales_order_status= 'Shipped' then 1 else 0 end) Total_order_shipped,
sum(case when  sales_order_status= 'Rejected' then 1 else 0 end) Total_order_Rejected
from sales_orders
group by fk_depot_id
order by fk_depot_id;

-- 1.15 Depots with Order status by percentage of total orders
select fk_depot_id,
sum(case when  sales_order_status= 'Shipped' then 1 else 0 end)/ count(*)*100 'Shipped_quantity%',
sum(case when  sales_order_status= 'Rejected' then 1 else 0 end)/ count(*)*100 'Rejected_quantity%'
from sales_orders
group by fk_depot_id
order by fk_depot_id;

-- 1.16  Order placed and their status by Time slot of 1hr
select concat(hour(time(creation_time)),'-', hour(time(creation_time))+1) as Time_slot,count(*) as "order_placed",
sum(case when  sales_order_status= 'Shipped' then 1 else 0 end) Total_order_shipped,
sum(case when  sales_order_status= 'Rejected' then 1 else 0 end) Total_order_Rejected
from sales_orders
group by Time_slot
order by order_placed DESC;

-- 1.17 Order placed and their status prcentage  by Time slot of 1hr
select concat(hour(time(creation_time)),'-', hour(time(creation_time))+1) as time_slot,count(*) as "order_placed",
sum(case when  sales_order_status= 'Shipped' then 1 else 0 end)/ count(*)*100 'Shipped_quantity%',
sum(case when  sales_order_status= 'Rejected' then 1 else 0 end)/ count(*)*100 'Rejected_quantity%'
from sales_orders
group by time_slot
order by time_slot ;

--                                            ### 2.Sales_orders_items Study ###
-- 2.1 Count to total Products of both years
select count(distinct (fk_product_id)) Total_products
from sales_orders_items;

-- 2.2 Count to total Products by year
select year(o.creation_time) year,count(distinct (fk_product_id)) Total_products
from sales_orders_items i join sales_orders o on o.order_id=i.fk_order_id
group by year;

-- 2.3 Product with max quantity ordered
select fk_product_id,sum(Ordered_quantity) as total_quantity_ordered
from sales_orders_items
group by fk_product_id
order by total_quantity_ordered desc
limit 5;

-- 2.4 Product with Total quantity Ordered,Oders accepted quantity and % of getting rejected
select fk_product_id,sum(Ordered_quantity) as total_quantity_ordered,sum(order_quantity_accepted) 'Accepted_quantity', 
((sum(Ordered_quantity)-sum(order_quantity_accepted))/sum(Ordered_quantity))*100 '%_of_quantity_Rejected'
from sales_orders_items
group by fk_product_id
order by total_quantity_ordered desc
limit 5;

-- 2.5 top 2 selling product of 2021
select year(o.creation_time) year,fk_product_id,sum(Ordered_quantity) as total_quantity_ordered,sum(order_quantity_accepted) 'Accepted_quantity', 
((sum(Ordered_quantity)-sum(order_quantity_accepted))/sum(Ordered_quantity))*100 '%_of_quantity_Rejected'
from sales_orders_items i join sales_orders o on o.order_id=i.fk_order_id 
group by fk_product_id,year
having year=2021
order by total_quantity_ordered desc
limit 2;

-- 2.6 top 2  selling product of 2022
select year(o.creation_time) year,fk_product_id,sum(Ordered_quantity) as total_quantity_ordered,sum(order_quantity_accepted) 'Accepted_quantity', 
((sum(Ordered_quantity)-sum(order_quantity_accepted))/sum(Ordered_quantity))*100 '%_of_quantity_Rejected'
from sales_orders_items i join sales_orders o on o.order_id=i.fk_order_id 
group by fk_product_id,year
having year=2022
order by total_quantity_ordered desc
limit 2;


-- 2.7 Product with their quantity getting 100% acceptance/products whose order Getting Shipped always
select fk_product_id,
sum(ordered_quantity) total_quantity_ordered,sum(order_quantity_accepted) Quantity_accepted,
sum(order_quantity_accepted)/sum(ordered_quantity)*100 Percent_of_total_quantity_accepted
from sales_orders_items
group by fk_product_id
having Percent_of_total_quantity_accepted= 100;

-- 2.8 count of produts whose order getting 100% acceptance/products whose order Getting Shipped always
with cte as(select fk_product_id,
sum(ordered_quantity) total_quantity_ordered,sum(order_quantity_accepted) Quantity_accepted,
sum(order_quantity_accepted)/sum(ordered_quantity)*100 total_Percent_of_quantity_accepted
from sales_orders_items
group by fk_product_id
having total_Percent_of_quantity_accepted= 100)
select count(*) 'Products_with_100%_order_Accepted'
from cte;

-- 2.9 Products with 0% acceptance / products whose order Getting Rejected always
select fk_product_id,
sum(ordered_quantity) total_quantity_ordered,sum(order_quantity_accepted) Quantity_accepted,
sum(order_quantity_accepted)/sum(ordered_quantity)*100 total_Percent_of_quantity_accepted
from sales_orders_items
group by fk_product_id
having total_Percent_of_quantity_accepted= 0;

-- 2.10 Count of Products with 0% acceptance/ products whose order Getting Rejected always
with cte as(select fk_product_id,
sum(ordered_quantity) total_quantity_ordered,sum(order_quantity_accepted) Quantity_accepted,
sum(order_quantity_accepted)/sum(ordered_quantity)*100 total_Percent_of_quantity_accepted
from sales_orders_items
group by fk_product_id
having total_Percent_of_quantity_accepted= 0)
select count(*) 'Products_with_100%_order_Rejected'
from cte;

-- 2.11 count_of_100%_rejected_product/products whose order Getting Rejected always  by year
with cte as(select fk_product_id,year(o.creation_time) year,
sum(ordered_quantity) total_quantity_ordered,sum(order_quantity_accepted) Quantity_accepted,
sum(order_quantity_accepted)/sum(ordered_quantity)*100 total_Percent_of_quantity_accepted
from sales_orders_items i join sales_orders o on o.order_id=i.fk_order_id 
group by fk_product_id
having total_Percent_of_quantity_accepted= 0)
select year,count(*) 'Products_with_100%_order_Rejected'
from cte
group by year;

-- 2.12 Percentage_of_Products_with_100%_order_Rejected both year
with cte as(select fk_product_id,
sum(ordered_quantity) total_quantity_ordered,sum(order_quantity_accepted) Quantity_accepted,
sum(order_quantity_accepted)/sum(ordered_quantity)*100 total_Percent_of_quantity_accepted
from sales_orders_items
group by fk_product_id
having total_Percent_of_quantity_accepted= 0)
select count(*)/(select count(distinct (fk_product_id)) Total_products
from sales_orders_items)*100 'Percentage_of_Products_with_100%_order_Rejected'
from cte;

-- 2.13  Percentage_of_Products_with_100%_order_Rejected by year

with cte as(select fk_product_id,year(o.creation_time) year,
sum(ordered_quantity) total_quantity_ordered,sum(order_quantity_accepted) Quantity_accepted,
sum(order_quantity_accepted)/sum(ordered_quantity)*100 total_Percent_of_quantity_accepted
from sales_orders_items i join sales_orders o on o.order_id=i.fk_order_id 
group by fk_product_id
having total_Percent_of_quantity_accepted= 0)
select year,count(*)'Products_with_100%_order_Rejected',(select count(distinct (fk_product_id)) Total_products
from sales_orders_items i join sales_orders o on o.order_id=i.fk_order_id and year(o.creation_time)=year) Total_products_by_year,
count(*)/(select count(distinct (fk_product_id)) Total_products
from sales_orders_items i join sales_orders o on o.order_id=i.fk_order_id and year(o.creation_time)=year)*100 'Percentage_of_Products_with_100%_order_Rejected'
from cte 
group by year;
-- no of product whose order always getting rejected are decresed by 12% in year 2022    i.e.34-22=12

--                                              ### 3.study of Login_logs ### 
-- 3.1 count of total login attempt
select count(login_log_id) Total_logins_both_year from login_logs;

-- 3.2 count of logins by year and incresed %
select 
(select count(login_log_id) unique_users) Total_logins,
(select count(login_log_id) users from login_logs where year(login_time)=2021) Total_login_in_year_2021,
(select count(login_log_id) users from login_logs where year(login_time)=2022) Total_login_in_year_2022,
(((select count(login_log_id) users from login_logs where year(login_time)=2022)-
(select count(login_log_id) users from login_logs where year(login_time)=2021))/
(select count(login_log_id) unique_users)*100 ) as 'increase_%_login_in_year_2022'
from login_logs;

-- 3.3 count of unique users
select count(distinct user_id) unique_users
from login_logs;               -- 20282

-- 3.4 count of unique users by year
select year(login_time) year,count( distinct user_id) users
from login_logs
group by year;

 -- 3.5 % of  unique users by year
select 
(select count(distinct user_id) unique_users) Total_unique_users,
(select count( distinct user_id) users from login_logs where year(login_time)=2021) users_of_year_2021,
(select count( distinct user_id) users from login_logs where year(login_time)=2022) users_of_year_2022,
(((select count( distinct user_id) users from login_logs where year(login_time)=2022)-
(select count( distinct user_id) users from login_logs where year(login_time)=2021))/
(select count(distinct user_id) unique_users)*100 ) as '%_increase_in_unique_users'
from login_logs;
-- Users incresed by 10.63 % by year 2022

-- 3.6 Top 5 users with login_attempts
select user_id,count(*) login_attempts
from login_logs
group by user_id
order by login_attempts desc
limit 5;

-- 3.7 total login_attempts by year
select year(login_time) year, count(login_log_id) Total_logins_both_year 
from login_logs
group by year;

-- 3.8 percentage of increase in login by year 2022
select 
(select count(login_log_id) Total_logins_both_year  from login_logs) Total_logins,
(select count(login_log_id) Total_logins_both_year  from login_logs where year(login_time)=2021) Total_logins_in_2021,
(select count(login_log_id) Total_logins_both_year  from login_logs where year(login_time)=2022)  Total_logins_in_2022,
(((select count(login_log_id) Total_logins_both_year  from login_logs where year(login_time)=2022)
-(select count(login_log_id) Total_logins_both_year  from login_logs where year(login_time)=2021))/
(select count(login_log_id) Total_logins_both_year  from login_logs) *100) as 'login_%_increase_by_year_2022';

-- login increased in year 2022 by 18.60%

-- 3.9 Top 5 login attempts by date
select date(login_time) Date,count(*) login_attempts
from login_logs
group by Date
order by login_attempts DESC;

-- 3.10 date with most login attempts
select date(login_time) Date,count(*) login_attempts
from login_logs
group by Date
order by login_attempts desc
limit 1;

-- 3.11 top day with max login attempts
select dayname(login_time) Day,count(*) login_attempts
from login_logs
group by Day
order by login_attempts desc
limit 1;
-- Friday having most login attempt

-- 3.12 Time slot hr with login attempt
with cte as (SELECT *, date(login_time) Date
, concat(hour(time(login_time)),'-', hour(time(login_time))+1) Time_slot
 FROM login_logs)
 select Time_slot ,count(*) login_attempt
 from cte
 group by Time_slot
 order by Time_slot;

-- 3.13 Time slot/hr with max login attempt
with cte as (SELECT *, date(login_time) Date
, concat(hour(time(login_time)),'-', hour(time(login_time))+1) Time_slot
 FROM login_logs)
 select Time_slot ,count(*) login_attempt
 from cte
 group by Time_slot
 order by login_attempt DESC
 limit 1;
-- max login attempt happed at 6AM-7AM time slot

--                                            ### Questions answers ###
-- 1. avg app visit(login) per day
select (count(*)/count( distinct date(login_time))) app_visit_per_day
from login_logs;

-- 2. app_visit_per_day by year
with cte as (
select
(select (count(*)/count( distinct date(login_time))) 
from login_logs) Overall_app_visit_per_day,
(select (count(*)/count( distinct date(login_time))) 
from login_logs
where year(login_time)=2021) app_visit_per_day_year_2021,
(select (count(*)/count( distinct date(login_time))) 
from login_logs
where year(login_time)=2022) app_visit_per_day_year_2022)
select Overall_app_visit_per_day,app_visit_per_day_year_2021,app_visit_per_day_year_2022,
(app_visit_per_day_year_2022-app_visit_per_day_year_2021)/Overall_app_visit_per_day*100 as Percentage_increase_in_login_per_day_yr2022
from cte;
--  App visit(login) per day increased by 37.18 % by year 2022

-- 3. total sales
select sum( order_quantity_accepted * rate) Total_sales
from sales_orders_items;

-- 4. total sales per year
select year(o.creation_time) year,sum( i.order_quantity_accepted * i.rate) Total_sales
from sales_orders o
join sales_orders_items i on o.order_id=i.fk_order_id
group by year;

-- 5. percentage increased in total sales 
with cte as (select 
(select sum( order_quantity_accepted * rate) 
from sales_orders_items) as Total_sales,
(select sum( i.order_quantity_accepted * i.rate)
from sales_orders o
join sales_orders_items i on o.order_id=i.fk_order_id
where year(o.creation_time) =2021) as Total_sales_of_year_2021,
(select sum( i.order_quantity_accepted * i.rate)
from sales_orders o
join sales_orders_items i on o.order_id=i.fk_order_id
where year(o.creation_time) =2022) as Total_sales_of_year_2022)
select Total_sales,Total_sales_of_year_2021,Total_sales_of_year_2022,(Total_sales_of_year_2022-Total_sales_of_year_2021)/ Total_sales *100 as 'Percentage_%_in_sales_in_year_2022'
from cte;

-- 6. Sales_per_day_overall
select sum( i.order_quantity_accepted * i.rate)/ count(distinct(date(o.creation_time))) as Sale_per_day
from sales_orders o
join sales_orders_items i on o.order_id=i.fk_order_id;

-- 7.sales_per_day_yearwise and increased_sales_per_day_%_by_year_2022
with cte as (select
(select sum( i.order_quantity_accepted * i.rate)/ count(distinct(date(o.creation_time))) 
from sales_orders o
join sales_orders_items i on o.order_id=i.fk_order_id)as overall_Sale_per_day,
(select sum( i.order_quantity_accepted * i.rate)/ count(distinct(date(o.creation_time))) 
from sales_orders o
join sales_orders_items i on o.order_id=i.fk_order_id
where year(o.creation_time) =2021)as Sale_per_day_year_2021,
(select sum( i.order_quantity_accepted * i.rate)/ count(distinct(date(o.creation_time))) 
from sales_orders o
join sales_orders_items i on o.order_id=i.fk_order_id
where year(o.creation_time) =2022 )as Sale_per_day_year_2022)
select overall_Sale_per_day,Sale_per_day_year_2021,Sale_per_day_year_2022,
(Sale_per_day_year_2022-Sale_per_day_year_2021)/overall_Sale_per_day*100 as "increased_sales_per_day_%_by_year_2022"
from cte;

-- 8. Percentage sales order  increased %
with cte as (
select 
(select count(*) 
from sales_orders) as sales_orders_overall,
(select count(*) 
from sales_orders
where year(creation_time)=2021 )as sales_orders_yr_2021,
(select count(*) 
from sales_orders
where year(creation_time)=2022) as sales_orders_yr_2022)
select sales_orders_overall,sales_orders_yr_2021,sales_orders_yr_2022,
(sales_orders_yr_2022-sales_orders_yr_2021)/sales_orders_overall*100 as 'increased_%_by_year_2022'
from cte;

-- 9. sales Orders per day
select (count(*)/ 
count( distinct date(creation_time))) sales_orders_per_day
from sales_orders;

-- 10. sales Orders per day per year,increased percentage
with cte as (
select 
(select (count(*)/ 
count( distinct date(creation_time))) 
from sales_orders) as sales_orders_per_day_overall,
(select (count(*)/ 
count( distinct date(creation_time))) 
from sales_orders
where year(creation_time)=2021 )as sales_orders_per_day_yr_2021,
(select (count(*)/ 
count( distinct date(creation_time))) 
from sales_orders
where year(creation_time)=2022) as sales_orders_per_day_yr_2022)
select sales_orders_per_day_overall,sales_orders_per_day_yr_2021,sales_orders_per_day_yr_2022,
(sales_orders_per_day_yr_2022-sales_orders_per_day_yr_2021)/sales_orders_per_day_overall*100 as 'increased_%_by_year_2022'
from cte;




