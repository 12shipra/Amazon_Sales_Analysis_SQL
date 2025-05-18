Create Database Amazon;

use Amazon;

Create table Amazon_sales
(Invoice_id varchar(20) PRIMARY KEY, 
Branch Varchar(10) NOT NULL,
City Varchar(30) NOT NULL,
Customer_type Varchar(30) NOT NULL,
Gender Varchar(30) NOT NULL,
Product_line Varchar(30) NOT NULL,
Unit_price Decimal(10,2) NOT NULL,
Quantity INT NOT NULL,
Tax Float(6,4) NOT NULL,
Total Decimal (10,2),
Date datetime NOT NULL,
Time timestamp NOT NULL,
Payment_mode Varchar(20) NOT NULL,
Cogs Decimal(10,2) NOT NULL,
Gross_margin_percentage Float(11,9) NOT NULL,
Gross_income Decimal(10,2) NOT NULL,
Rating Float(2,1));

select * from Amazon_sales;

## Some questions based on (Revenue and  Product analysis, Customer behavior and Branch performance) ##

# 1: Total revenue by each Product_line?

Select 
Product_line,
round(sum(Total)) as Total_revenue 
from Amazon_sales
group by Product_line 
order by Total_revenue desc;

# 2: Find, in which month revenue  is very High?

Select 
monthname(date) as monthname,
round(sum(total)) as Total_revenue
from Amazon_sales
group by monthname(date)
order by Total_revenue limit 1;

# 3: Total number of products ordered, in each month, by product_line?

select 
Product_line,
monthname(date) as Month_name,
sum(quantity) as Total_order 
from Amazon_sales
group by Product_line,monthname(date)
order by Total_order desc;

# 4: Number of transactions and  product ordered based on customer segment?  

Select 
customer_type,
count(*) as Number_of_transaction,
sum(quantity) as Product_order
from Amazon_sales
group by customer_type
order by Product_order desc;

# 5: In each Branch, how many times of order, in weekdays and weekend(Saturdat,Sunday)?  

Select
Branch,
dayname(Date) as day_name,
count(*) as total_order
from Amazon_sales
group by Branch,dayname(Date)
order by Branch, total_order desc;

# 6: On which particular time customers are more active? 

select 
Time_of_day,
count(*) as Number_of_order
from 
(select time,
case when time between "00:00:00:am"  and "12:00:00:am" then "Morning"
when time between "12:01:00:pm" and "4:00:00:pm" then "Afternoon"
else "Evening" 
end as Time_of_day
from Amazon_sales) as Time_of_day
group by Time_of_day
order by Number_of_order desc;


## Feature Engineering ##

## Time of day ##

select time,
case when time between "00:00:00:am"  and "12:00:00:am" then "Morning"
when time between "12:01:00:pm" and "4:00:00:pm" then "Afternoon"
else "Evening" 
end as Time_of_day
from Amazon_sales;

Alter table Amazon_sales add column Time_of_day varchar(20);

Update Amazon_sales set Time_of_day=(case 
when time between "00:00:00:am"  and "12:00:00:am" then "Morning"
when time between "12:01:00:pm" and "4:00:00:pm" then "Afternoon"
else "Evening" end);  

## Month_name ##

Select monthname(date) from Amazon_sales;

Alter table Amazon_sales add column Month_name varchar(10);

Update Amazon_sales set Month_name=monthname(date);

## Day_name ##

Select dayname(date) from Amazon_sales;

Alter table Amazon_sales add column Day_name varchar(20);

Update Amazon_sales set Day_name=dayname(date);


## Some Business Problems ##

# 1: What is the count of distinct cities in the dataset?
Select count(distinct(city)) as Total_city from Amazon_sales;

# 2: For each branch, what is the corresponding city?
Select Branch,City from Amazon_sales
group by Branch,City;

# 3: What is the count of distinct product lines in the dataset?
Select count(distinct(Product_line)) as Type_of_product
from Amazon_sales;

# 4: Which payment method occurs most frequently?
Select Payment,count(*) as Number_of_payment_by_each_mode
from Amazon_sales group by Payment
order by Number_of_payment_by_each_mode desc;

# 5: Which product line has the highest demand?
Select Product_line,sum(quantity) as Total_order_by_each_product
from Amazon_sales group by Product_line
order by Total_order_by_each_product desc;

# 6: How much revenue is generated each month?
Select date_format(Date,"%Y-%m") as year_month_name,
round(sum(total)) as total_revenue
from Amazon_sales group  by date_format(Date,"%Y-%m");

# 7: In which month did the cost of goods sold reach its peak?
Select month_name,sum(cogs) as Total_cogs
from Amazon_sales group by month_name 
order by Total_cogs desc limit 1;

# 8: In which city was the highest revenue recorded?
Select City,round(sum(total)) as Revenue_by_each_city
from Amazon_sales group by City 
order by Revenue_by_each_city desc
limit 1;

# 9: For each product line, add a column indicating "Good" if its sales are above average, otherwise "Bad"?
Select product_line,Total,
case when Quantity>(select avg(Quantity) 
from Amazon_sales) then "Good"
else "Bad " end as Sales_category
from Amazon_sales;

# 10: Identify the branch that exceeded the average number of products sold.?
WITH overall_avg AS (
    SELECT AVG(Quantity) AS avg_quantity_overall
    FROM Amazon_sales),
branch_avg AS (
    SELECT Branch, AVG(Quantity) AS avg_quantity_branch
    FROM Amazon_sales
    GROUP BY Branch
)
SELECT b.Branch, b.avg_quantity_branch
FROM branch_avg b
JOIN overall_avg o
  ON b.avg_quantity_branch > o.avg_quantity_overall;

# 11: Which product line is most frequently associated with each gender?
Select Gender,Product_line,
Rank() over(order by Number_of_order desc)
as Rank_wise
from 
(Select Gender,Product_line,count(*) as Number_of_order
from Amazon_sales group by Gender,Product_line) as Order_table;

# 12: Calculate the average rating for each product line.?
Select Product_line,Avg(rating) as Averege_rating_by_each_product
from Amazon_sales group by Product_line;

#13: Count the sales occurrences for each time of day on every weekday.
Select Day_name,Time_of_day,count(*) as Number_of_order
from Amazon_sales group by Day_name,Time_of_day
order by Number_of_order desc;

# 14: Identify the customer type contributing the highest revenue.?
Select Customer_type,round(sum(total)) as Revenue
from Amazon_sales group by Customer_type 
order by Revenue desc;

# 15: What is the count of distinct customer types in the dataset?
Select count(distinct(customer_type)) as unique_customer_type
from Amazon_sales;

# 15: What is the count of distinct payment methods in the dataset?
Select count(distinct(payment)) as Payment_mode
from Amazon_sales;

# 16: Which customer type occurs most frequently?
Select Customer_type,count(*) as More_active
from Amazon_sales group by Customer_type
order by More_active desc limit 1;

# 17: Identify the customer type with the highest purchase frequency?
Select Customer_type,sum(quantity) as Total_order
from Amazon_sales group by Customer_type
order by Total_order desc;

# 18: Determine the predominant gender among customers?
Select Gender,count(*) as Number_od_order
from Amazon_sales group by Gender
order by Number_od_order desc;

# 19: Examine the distribution of genders within each branch?
Select Gender,Branch,count(*) as Male_and_Female_each_branch
from Amazon_sales group by Gender,Branch
order by Gender;

# 20: Identify the time of day when customers provide the most ratings?
Select Time_of_day,count(rating) as Rating 
from Amazon_sales group by Time_of_day
order by Rating desc;

# 21: Determine the time of day with the highest customer ratings for each branch?
Select Branch,Time_of_day,count(rating) as Rating
from Amazon_sales group by Branch,Time_of_day
order by Rating desc;

# 22: Identify the day of the week with the highest average ratings?
Select Day_name,Avg(rating) as Average_rating
from Amazon_sales group by Day_name
order by Average_rating desc limit 1;

# 23: Determine the day of the week with the highest average ratings for each branch?
Select Branch,Day_name,round(Avg(rating),2) as Average_rating
from Amazon_sales group by Branch, Day_name
order by Average_rating limit 3;






