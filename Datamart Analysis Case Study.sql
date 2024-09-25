use case1;
 
select * from weekly_sales limit 10;

-- Data Cleansing

drop table clean_weekly_sales;
create table clean_weekly_sales as
select week_date,
week(week_date) as week_number,
month(week_date) as month_number,
year(week_date) as calendar_year,
region,platform,
case
when segment=null then 'Unknown'
else segment
end as segment,
case 
    when right(segment,1)='1' then 'Young Adults'
    when right(segment,1)='2' then 'Middle Aged'
	when right(segment,1) in ('3','4') then 'Retirees'
    else 'Unknown'
    end as age_band,
    
case
when left(segment,1)='C' then 'Couples'
when left(segment,1)='F' then 'Families'    
else 'Unknown'
end as demographic,
customer_type,transactions,sales,
round(sales/transactions,2) as 'avg_transaction'
from weekly_sales;

select * from clean_weekly_sales limit 10;

-- Data Exploration

-- Q1 Which week numbers are missing from the dataset?

create table seq100(x int auto_increment primary key);
insert into seq100 values (),(),(),(),(),(),(),(),(),();
insert into seq100 values (),(),(),(),(),(),(),(),(),();
insert into seq100 values (),(),(),(),(),(),(),(),(),();
insert into seq100 values (),(),(),(),(),(),(),(),(),();
insert into seq100 values (),(),(),(),(),(),(),(),(),();
insert into seq100 select x+50 from seq100;
select * from seq100;

create table seq52 as (select x from seq100 limit 52); 
select distinct x as week_day from seq52
where x not in (select distinct week_number from clean_weekly_sales);

select distinct week_number from clean_weekly_sales;

-- Q2 How many total transactions were there for each year in the dataset?

select calendar_year,
sum(transactions) as total_transactions
from clean_weekly_sales group by calendar_year;

-- Q3 What are the total sales for each region for each month?

select region,month_number,
sum(sales) as total_sales
from clean_weekly_sales
group by month_number,region;

-- Q4 What is the total count of transactions for each platform

select platform,
sum(transactions) as total_transactions from clean_weekly_sales
group by platform;

-- Q5 What is the percentage of sales for Retail vs Shopify for each month?

with cte_monthly_platform_sales as
(select month_number,calendar_year,platform,
sum(sales) as monthly_sales
from clean_weekly_sales
group by month_number,calendar_year,platform)

select month_number,calendar_year,
round(100*max(case when platform='Retail'
then monthly_sales else null end)/sum(monthly_sales),2) 
as retail_percentage,
round(100*max(case when platform='Shopify' 
then monthly_sales else null end)/ sum(monthly_sales),2)
as shopify_percentage
from cte_monthly_platform_sales
group by month_number,calendar_year;

-- Q6 What is the percentage of sales by demographic for each year in the dataset?

select calendar_year,demographic,
sum(sales) as yearly_sales,
round(100*sum(sales)/sum(sum(sales)) 
over (partition by demographic),2) as percentage
from clean_weekly_sales
group by calendar_year,demographic;

-- Q7 Which age_band and demographic values contribute the most to Retail sales?

select age_band,demographic,
sum(sales) as total_sales
from clean_weekly_sales
where platform='Retail'
group by age_band,demographic
order by total_sales desc;
