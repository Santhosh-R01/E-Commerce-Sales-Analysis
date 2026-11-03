create database ECommerce_Analytics

use ECommerce_Analytics

exec sp_rename 'order','orders'

select top(10) * from customer
select top(10) * from ecomm
select top(10) * from orders
select top(10) * from product
select top(10) * from stat

select count(*) from customer
select count(*) from ecomm
select count(*) from orders
select count(*) from product
select count(*) from stat

-- Check total rows and missing IDs

select count(*) as total_rows,count(order_id)as order_id,count(product_id) as product_id from orders

-- Check orders containing multiple rows

select order_id,count(*) as order_count from orders group by order_id having count(*) > 1

select * from orders where order_id = 'ORD-594273'

--Check for duplicate Order ID + Product ID combinations

select order_id,product_id,count(*) as duplicate_count 
from orders 
group by order_id,product_id 
having count(*) > 1

--Check one combination

select * from orders where order_id = 'ORD-795044' and product_id = 'PROD-000004'

--Check for exact duplicate rows

select order_id,product_id,quantity,unit_price,discount_percentage,discount_amount,gross_sales,tax_amount,shipping_cost,net_sales,product_cost,
		profit,count(*) total
from orders 
group by order_id,product_id,quantity,unit_price,discount_percentage,discount_amount,gross_sales,tax_amount,shipping_cost,net_sales,product_cost,
		profit
having count(*) > 1;

--Validate Quantity

select count(*) as total
from orders 
where quantity <= 0 

--Validate Unit Price

select * from orders

select count(*) as total from orders where unit_price <= 0

--Validate Discount Percentage Range

select count(*)as total from orders where discount_percentage < 0 or discount_percentage > 1

--Validate Discount Amount

select count(*) as total from orders where discount_amount < 0 or discount_amount > gross_sales

--Validate Tax Amount

select count(*) as total from orders where tax_amount < 0

--Validate Shipping Cost

select count(*) as total from orders where shipping_cost < 0

--Validate Net Sales

select count(*) as total from orders where net_sales < 0

--Validate Product Cost

select count(*) as total from orders where product_cost < 0

--Validate Gross Sales

select count(*) as total from orders where gross_sales < 0

--Validate Gross Sales Calculation

select count(*) from orders
where round(quantity * unit_price,2) != round(gross_sales,2)

--Validate Discount Amount Calculation 

select count(*) from orders 
where round(gross_sales * discount_percentage,2) != round(discount_amount,2)

--Discount Calculation Mismatch

select quantity,unit_price,gross_sales,discount_percentage,round(discount_amount,2) as stored_discount,
round(gross_sales * discount_percentage,2) as calculated_discount
from orders 
where round(gross_sales * discount_percentage,2) != round(discount_amount,2)

--Validate Net Sales Calculation

select count(*)from orders where round(gross_sales - discount_amount + tax_amount + shipping_cost,2) != round(net_sales,2)

--Investigate the Net Sales Difference

select order_id,round(net_sales,2) as net_sales, 
round((gross_sales - discount_amount + tax_amount + shipping_cost),2) as calculated_net_sales
from orders 
where round((gross_sales - discount_amount + tax_amount + shipping_cost),2) != round(net_sales,2)

--Validate Profit Calculation

select order_id,round(profit,2) as profit,round((net_sales - product_cost - shipping_cost),2) as calculated_profit 
from orders 
where round((net_sales - product_cost - shipping_cost),2) != round(profit,2)


--Discount Percentage Pattern
--Unique Discount Percentage Check

select  count(distinct discount_percentage) from orders

--Discount Percentage Distribution Analysis

select distinct discount_percentage from orders 
order by discount_percentage desc

--Discount Percentage Frequency Analysis

select discount_percentage,count(*) from orders
group by discount_percentage order by count(*) desc

--Find the Maximum Difference

select max(abs((discount_amount / gross_sales) - discount_percentage)) as abs_value from orders

--Check the Actual Discount Rate

select order_id,gross_sales,discount_amount,discount_percentage,(discount_amount / gross_sales) as cal_rate from orders
where round((discount_amount / gross_sales),4) = round(discount_percentage,4)

--Count All Matching Records

select count(*) from orders
where round((discount_amount / gross_sales),2) = round(discount_percentage,2)

--Investigate the 1,966 Exceptions

select order_id,gross_sales,discount_amount,discount_percentage,(discount_amount / gross_sales) as cal_rate from orders
where round((discount_amount / gross_sales),2) != round(discount_percentage,2)

--Orders Financial Validation

select count(*) from orders 
where round((gross_sales - discount_amount + tax_amount + shipping_cost),2) != round(net_sales,2)

--Profit Calculation Validation
select * from orders

select count(*) from orders 
where round(net_sales - product_cost - shipping_cost,2) != round(profit,2)

--Check Negative Profit Records

select order_id,gross_sales,discount_amount,tax_amount,shipping_cost,net_sales,product_cost,profit from orders
where profit < 0

--Find the low & Highest Loss

select min(profit) as profit from orders 
where profit < 0

select max(profit) as profit from orders 
where profit < 0

--Find the Average Profit

select * from orders

select avg(profit) as avg_profit from orders

--Total Profit

select sum(profit) as total_profit from orders -- so the sum of total profit is 82698038.5568595

select total_profit from stat -- total profit from statistics table is 76146395.76 . the profit difference is 6,551,642.80

--Investigate Negative Profit

select sum(profit) as neg_profit from orders 
where profit < 0    -- negative profit is -544540.389535226

--Investigate Cancelled Orders

select count(delivery_status) as cancel_count from ecomm
where delivery_status = 'Cancelled' -- 24557 orders were cancelled

--Cancelled Orders' Profit Impact

select sum(o.profit) as canel_profit from orders o join ecomm e on o.order_id = e.order_id
where e.delivery_status = 'Cancelled'   -- cancelled profit is 17533953.3093782

--Analyze All Delivery Statuses (transactions)

select count(delivery_status) as total_tran from ecomm -- total transaction count is 138116

--Validate the 138,116 Transaction Count

select delivery_status ,count(delivery_status) as total_trans from ecomm 
group by delivery_status

--Compare profit at order level

with cte as (select order_id,sum(profit) as order_level from orders 
group by order_id )
select sum(order_level) as total_profit from cte

--Check profit by delivery_status

select e.delivery_status,sum(o.profit) as profit from ecomm e join orders o on e.order_id = o.order_id 
group by e.delivery_status

--Profit Analysis by Return Status

select e.return_status,sum(o.profit) from orders o join ecomm e on o.order_id = e.order_id 
group by e.return_status

--Check Profit by Order Status Combination

select e.return_status,e.delivery_status,sum(o.profit) from orders o join ecomm e on o.order_id = e.order_id 
group by e.return_status,e.delivery_status

--Inspect order_status Values

select order_status,count(order_status) from ecomm 
group by order_status

--Compare order_status with delivery_status

select order_status,delivery_status,count(*) from ecomm
group by order_status,delivery_status

--Compare Profit by order_status

select e.order_status,sum(o.profit) from orders o join ecomm e on o.order_id = e.order_id 
group by e.order_status

--Check Profit Directly From ecomm

select sum(profit) as total_profit from ecomm 

--Compare orders.profit vs ecomm.profit

select o.order_id,o.profit,e.profit from orders o join ecomm e on o.order_id = e.order_id

--Check the Grain of orders

select count(*),count(distinct order_id) from orders

--Verify Profit Reconciliation at Order Level

select o.order_id,sum(o.profit) as order_profit , sum(e.profit) as ecomm_profit from orders o join ecomm e 
on o.order_id = e.order_id
group by o.order_id  -- the order_id is not unique

--Check orders

select count(*),count(distinct order_id) from orders

select order_id,product_id from orders 
group by order_id,product_id having count(*) > 1

--Check ecomm

select count(*),count(distinct order_id) from ecomm

select count(*)as duplicate_order_id from (select order_id from ecomm 
group by order_id having count(*) > 1
) as duplicate

--Validate Table Grain Before Joining Tables

select order_id,count(*) order_row_count from orders
group by order_id order by order_row_count desc

--Validate Order Matching Between orders and ecomm

--Orders missing from ecomm

select count(distinct o.order_id)  from orders o left join ecomm e on o.order_id = e.order_id
where e.order_id is null

--Ecomm orders missing from orders

select count(distinct e.order_id)  from ecomm e left join orders o on e.order_id = o.order_id
where o.order_id is null   -- This results confirms that every order_id in orders exists in ecomm

--Create an Order-Level orders Summary

select * from orders

select order_id,sum(net_sales) as total_net,sum(profit) as total_profit,sum(quantity) as total_quantity,count(*) as line_item from orders
group by order_id

--Create the Order-Level Dataset

select order_id,sum(net_sales) as total_net,sum(profit) as total_profit,sum(quantity) as total_quantity,count(*) as line_item 
into #order_summary from orders
group by order_id

select count(*) as total_rows,count(distinct order_id) as distinct_orders from #order_summary

select order_id,count(*) as total_rows from #order_summary
group by order_id having count(*) > 1   -- no duplicates

--Create the Combined Order-Level Dataset

select o.order_id,o.total_net,o.total_profit AS orders_profit,o.total_quantity,o.line_item,e.profit AS ecomm_profit,
		e.delivery_status,e.return_status,e.campaign_name,e.customer_rating,e.review_sentiment
from #order_summary o join ecomm e on o.order_id = e.order_id

select count(*) as total_rows from #order_summary o join ecomm e on o.order_id = e.order_id

--Check for Duplicate Orders After Join

select o.order_id,count(*) as row_count from #order_summary o join ecomm e on o.order_id = e.order_id
group by o.order_id having count(*) >1

--Create the Final Analysis Dataset

select o.order_id,e.order_date,o.total_net,o.total_profit AS orders_profit,o.total_quantity,o.line_item,e.profit AS ecomm_profit,
		e.delivery_status,e.return_status,e.campaign_name,e.customer_rating,e.review_sentiment 
into #analysis_data
from #order_summary o join ecomm e on o.order_id = e.order_id

--Validate #analysis_data

select count(*),count(distinct order_id) from #analysis_data

select order_id,count(*) as row_count from #analysis_data 
group by order_id having count(*) > 1

select min(order_date) as first_date,max(order_date) as last_date,count(*) as row_count from #analysis_data

--Analyze Profit by Delivery Status

select delivery_status ,count(order_id) as order_count,sum(ecomm_profit) as total_profit from #analysis_data 
group by delivery_status 

select * from #analysis_data

--Analyze Average Profit by Delivery Status

select delivery_status ,count(order_id) as order_count,avg(ecomm_profit) as avg_profit from #analysis_data 
group by delivery_status 


--Analyze Profit by Return Status

select return_status,count(order_id) as order_count,sum(ecomm_profit) as total_profit,avg(ecomm_profit) as avg_profit 
from #analysis_data 
group by return_status

--Analyze Campaign Performance

select campaign_name,count(order_id) as order_count,sum(ecomm_profit) as total_profit,avg(ecomm_profit) as avg_profit 
from #analysis_data 
group by campaign_name

--Analyze Customer Rating vs Profit

select customer_rating,count(order_id) as order_count,sum(ecomm_profit) as total_profit,avg(ecomm_profit) as avg_profit 
from #analysis_data 
group by customer_rating order by customer_rating 

--Analyze Review Sentiment vs Profit

select review_sentiment,count(order_id) as order_count,sum(ecomm_profit) as total_profit,avg(ecomm_profit) as avg_profit 
from #analysis_data 
group by review_sentiment 

--Analyze Profit by Year

select year(order_date) as order_year,count(order_id) as order_count,sum(ecomm_profit) as total_profit,avg(ecomm_profit) as avg_profit 
from #analysis_data 
group by year(order_date) order by order_year

--Monthly Sales & Profit Trend

select month(order_date) as order_month,count(order_id) as order_count,sum(ecomm_profit) as total_profit,avg(ecomm_profit) as avg_profit 
from #analysis_data 
group by month(order_date) order by order_month

--Monthly Sales vs Profit

select month(order_date) as order_month,count(order_id) as order_count,sum(total_net) as total_net_sales,
sum(ecomm_profit) as total_profit,avg(ecomm_profit) as avg_profit 
from #analysis_data 
group by month(order_date) order by order_month

--Monthly Profit Margin

select month(order_date) as order_month,count(order_id) as order_count,sum(total_net) as total_net_sales,
sum(ecomm_profit) as total_profit,avg(ecomm_profit) as avg_profit,(sum(ecomm_profit) / sum(total_net) * 100) as profit_margin
from #analysis_data 
group by month(order_date) order by order_month

--Discount vs Profit Margin

select month(order_date) as order_month,count(order_id) as order_count,sum(total_net) as total_net_sales,
sum(ecomm_profit) as total_profit,avg(ecomm_profit) as avg_profit,(sum(ecomm_profit) / sum(total_net) * 100) as profit_margin
from #analysis_data 
group by month(order_date) 

--Order-Level Discount Analysis & Validation

select order_id,count(distinct discount_percentage) as discount_types
from orders
group by order_id having count(distinct discount_percentage) > 1;

select order_id,avg(discount_percentage) as avg_discount
from orders
group by order_id;

select count(*) as order_count
from (select order_id from orders group by order_id ) as order_discount;

--Add Average Discount to Order-Level Data

--Adding new column

alter table #analysis_data add avg_discount decimal(10,4)

--Update the column with order-level average discount

update a set a.avg_discount = d.avg_discount 
from #analysis_data a join (select order_id,avg(discount_percentage) as avg_discount from orders group by order_id) d
on a.order_id = d.order_id

--Validate

select count(*) as total_orders , count(avg_discount) as avg_discount from #analysis_data

--min,max and avg discount

select min(avg_discount) as min_discount,max(avg_discount) as max_discount,avg(avg_discount) as avg_discount
from #analysis_data

--Create Discount Bucketss

alter table #analysis_data add discount_bucket varchar(100)

update #analysis_data set discount_bucket = case when avg_discount = 0 then 'No Discount'
			when avg_discount > 0 and avg_discount <= 0.10 then 'Low discount'
			when avg_discount > 0.10 and avg_discount <= 0.20 then 'Moderate discount'
			when avg_discount > 0.20 and avg_discount <= 0.30 then 'Higher discount'
			when avg_discount > 0.30 and avg_discount <= 0.40 then 'High discount'
			else 'Very high discount' end 

--Discount Bucket Distribution

select discount_bucket,count(order_id) as order_count from #analysis_data group by discount_bucket order by order_count desc

--Discount vs Profitability

select * from #analysis_data

select discount_bucket,count(*) as order_count,sum(total_net) as total_net_sales ,sum(ecomm_profit) as total_profit,
avg(ecomm_profit) as avg_profit,(sum(ecomm_profit)/sum(total_net) * 100) as profit_margin
from #analysis_data
group by discount_bucket order by order_count desc

--Product/Category Analysis

--Validate Order Net Sales Before Category Profit Allocation

select count(*) as total_orders,
	sum(case when total_net = 0 then 1 else 0 end) as zero_net_orders,
	sum(case when total_net < 0 then 1 else 0 end) as negative_net_orders
from #analysis_data

--Allocate Official Profit to Product Categories

select o.order_id,o.product_id,p.product_category,o.net_sales,a.ecomm_profit,a.total_net,(o.net_sales / a.total_net) as sales_share,
    (a.ecomm_profit * (o.net_sales / a.total_net)) as allocated_profit
into #category_profit
from orders o
join product p
    on o.product_id = p.product_id
join #analysis_data a
    on o.order_id = a.order_id;

select * from #category_profit

--Category summary

select product_category,count(distinct order_id) as order_count,sum(net_sales) as total_net_sales,sum(allocated_profit) as total_profit
from #category_profit
group by product_category
order by total_profit desc;

--Validate Category Profit Against Official Profit

select * from #category_profit

select sum(allocated_profit) as total_allocated_profit,(select sum(ecomm_profit) from #analysis_data) as official_total_profit,
(sum(allocated_profit) - (select sum(ecomm_profit) from #analysis_data)) as difference from #category_profit

--Calculate Category Profit Margin

select product_category,count(distinct order_id) as order_count,sum(net_sales) as total_net_sales,sum(allocated_profit) as total_profit,
(sum(allocated_profit) / sum(net_sales)) * 100 as profit_margin
from #category_profit
group by product_category
order by total_profit desc;

--Product-Level Analysis

select product_id,count(order_id)as order_count,sum(net_sales) as total_sales,
sum(allocated_profit) as total_profit,(sum(allocated_profit) / sum(net_sales))*100 as profit_margin
from #category_profit  
group by product_id

--Product-Level Sales and Profit Performance

select * from #category_profit

with product_summary as (select product_id,sum(net_sales) as total_sales,sum(allocated_profit) as total_profit 
from #category_profit
group by product_id)
select 'Highest total sales' as metrics,product_id,total_sales,total_profit from product_summary
where total_sales = (select max(total_sales) from product_summary)

union all

select 'Highest total profit' as metrics,product_id,total_sales,total_profit from product_summary
where total_profit = (select max(total_profit) from product_summary)

union all

select 'lowest total sales' as metrics,product_id,total_sales,total_profit from product_summary
where total_sales = (select min(total_sales) from product_summary)

union all

select 'lowest total profit' as metrics,product_id,total_sales,total_profit from product_summary
where total_profit = (select min(total_profit) from product_summary)

--Product Profit Margin Analysis

with profit_summary as (select product_id,sum(net_sales) as total_sales,sum(allocated_profit) as total_profit ,
(sum(allocated_profit) / sum(net_sales)) * 100 as total_profit_margin
from #category_profit 
group by product_id)
select 'Highest profit margin' as metrics , product_id,total_sales,total_profit,total_profit_margin from profit_summary
where total_profit_margin = (select max(total_profit_margin) from profit_summary)

union all

select 'lowest profit margin' as metrics , product_id,total_sales,total_profit,total_profit_margin from profit_summary
where total_profit_margin = (select min(total_profit_margin) from profit_summary)

--Order Value Analysis

select * from #analysis_data

select avg(total_net) as avg_order_value,min(total_net) as minimum_order_value,max(total_net) as maximum_order_value
from #analysis_data --AOV ($1,393.02) doesn't match the official AOV ($1,282.50).

--Revenue and AOV Reconciliation Analysis

select sum(gross_sales) as order_gross,sum(discount_amount) as order_dis,sum(tax_amount) as order_tax,sum(shipping_cost) as order_ship,
sum(net_sales) as order_net,sum(product_cost) as order_product,sum(profit) as order_profit
from orders 

select sum(gross_sales) as ecomm_gross,sum(discount_amount) as ecomm_dis,sum(tax_amount) as ecomm_tax,sum(shipping_cost) as ecomm_ship,
sum(net_sales ) as ecomm_net,sum(product_cost) as ecomm_product,sum(profit) as ecomm_profit
from ecomm  -- The difference is not caused by AOV itself.
			-- The underlying values in orders are higher than ecomm across every major financial field.

--Find why orders and ecomm differ

with order_summary as
(select order_id,sum(gross_sales) as order_gross,sum(discount_amount) as order_discount,sum(tax_amount) as order_tax,
sum(shipping_cost) as order_shipping,sum(net_sales) as order_net,sum(product_cost) as order_cost,sum(profit) as order_profit
from orders
group by order_id )
select o.order_id,o.order_gross,e.gross_sales as ecomm_gross,o.order_discount,e.discount_amount as ecomm_discount,o.order_net,
e.net_sales as ecomm_net,o.order_profit,e.profit as ecomm_profit
from order_summary o join ecomm e on o.order_id = e.order_id -- some orders have a real difference ex : ORD-652783 

--Identify those orders

with order_summary as
(select order_id,sum(gross_sales) as order_gross,sum(discount_amount) as order_discount,sum(tax_amount) as order_tax,
sum(shipping_cost) as order_shipping,sum(net_sales) as order_net,sum(product_cost) as order_cost,sum(profit) as order_profit
from orders
group by order_id )
select o.order_id,o.order_gross,e.gross_sales as ecomm_gross,o.order_discount,e.discount_amount as ecomm_discount,o.order_net,
e.net_sales as ecomm_net,o.order_profit,e.profit as ecomm_profit
from order_summary o join ecomm e on o.order_id = e.order_id 
where o.order_net != e.net_sales

--separate real differences from floating-point differences

with order_summary as
(select order_id,sum(gross_sales) as order_gross,sum(discount_amount) as order_discount,sum(tax_amount) as order_tax,
sum(shipping_cost) as order_shipping,sum(net_sales) as order_net,sum(product_cost) as order_cost,sum(profit) as order_profit
from orders
group by order_id )
select o.order_id,o.order_gross,e.gross_sales as ecomm_gross,o.order_discount,e.discount_amount as ecomm_discount,o.order_net,
e.net_sales as ecomm_net,o.order_profit,e.profit as ecomm_profit
from order_summary o join ecomm e on o.order_id = e.order_id 
where abs(o.order_net - e.net_sales) > 0.01

--Order Financial Reconciliation & Mismatch Analysis

with order_summary as 
	(select order_id,sum(net_sales) as order_net from orders group by order_id),
mismatched_orders as 
	(select o.order_id,o.order_net,e.net_sales as ecomm_net from ecomm e join order_summary o on e.order_id = o.order_id
	 where abs(o.order_net - e.net_sales) > 0.01)
select m.order_id,m.order_net,m.ecomm_net,e.return_status,e.delivery_status from mismatched_orders m join ecomm e 
on m.order_id = e.order_id	

--Order-Level Financial Mismatch Investigation

select product_id,quantity,unit_price,gross_sales,discount_amount,tax_amount,net_sales,product_cost,profit from orders 
where order_id = 'ORD-150153'

select gross_sales,discount_amount,tax_amount,net_sales,product_cost,profit from ecomm 
where order_id = 'ORD-150153' --check whether all 7 product_id values from ORD-150153 exist in the product table.

--Find the Pattern

with cte as 
	(select order_id,count(*) as line_items,sum(net_sales) as order_net,sum(profit) as order_profit 
	from orders 
	group by order_id),
cte2 as
	(select c.order_id,c.line_items,c.order_net,c.order_profit,e.net_sales as ecomm_net,e.profit as ecomm_profit 
	from cte c join ecomm e on c.order_id = e.order_id)
select order_id,line_items,order_net,order_profit,ecomm_net,ecomm_profit, (order_net - ecomm_net) as net_diff ,
(order_profit - ecomm_profit) as profit_diff
from cte2 
where abs(order_net - ecomm_net) > 0.01

--check whether the difference comes from specific columns

select product_id,quantity,unit_price,discount_percentage,gross_sales,discount_amount,tax_amount,shipping_cost,net_sales,product_cost,profit
from orders
where order_id = 'ORD-652783'

select gross_sales,discount_amount,tax_amount,shipping_cost,net_sales,product_cost,profit
from ecomm
where order_id = 'ORD-652783'

--All orders net sales = 6419.61
--Ecomm net sales      = 4497.43
--Difference           = 1922.18

select product_id,net_sales,profit
from orders
where order_id = 'ORD-652783'
order by net_sales desc -- ecom takes the 1st 4 products

--compare the 4 included lines with the 4 excluded lines 

select o.product_id,p.product_category,o.quantity,o.unit_price,o.discount_percentage,o.discount_amount,o.gross_sales,o.tax_amount,
    o.shipping_cost,o.net_sales,o.product_cost,o.profit
from orders o join product p on o.product_id = p.product_id
where o.order_id = 'ORD-652783'
order by o.product_id --there is no obvious pattern based on product category , Because electronics appears in both groups

--included products						--excluded products 

PROD-000032 — Electronics				PROD-000027 — Electronics
PROD-000211 — Fashion					PROD-000554 — Books & Media
PROD-000645 — Automotive				PROD-000763 — Health & Wellness
PROD-000932 — Baby & Kids				PROD-000856 — Pet Supplies

--Investigating the Difference Between Orders and Ecomm Totals

select order_id,order_status,payment_status,delivery_status,return_status from ecomm 
where order_id = 'ORD-652783' -- so ecomm is not removing returned or cancelled products.

--we will use another item to find the pattern
--Let's use ORD-537228 as the next example because it has only 3 line items

select product_id,quantity,unit_price,discount_percentage,gross_sales,discount_amount,tax_amount,shipping_cost,net_sales,product_cost,profit
from orders
where order_id = 'ORD-537228'

select gross_sales,discount_amount,tax_amount,shipping_cost,net_sales,product_cost,profit
from ecomm
where order_id = 'ORD-537228' -- ecomm takes the 1st product only

--Compare Product-Level Data from Orders 

select order_id,product_id,quantity,net_sales,profit from orders 
where order_id = 'ORD-537228'

--Compare Order-Level Data from Ecomm

select order_id,quantity,net_sales,profit from ecomm 
where order_id = 'ORD-537228'

--Aggregate Product-Level Data and Compare with Ecomm -- Order ID: ORD-537228

select * from orders

select order_id,sum(quantity) as total_quantity,sum(net_sales) as total_net_sales,sum(profit) as total_profit 
from orders where order_id = 'ORD-537228' group by order_id

select order_id,quantity,net_sales,profit from ecomm where order_id = 'ORD-537228'

--Calculate the difference between the aggregated orders values and the ecomm values for ORD-537228.

select o.order_id,sum(o.quantity) as order_qty,e.quantity as ecomm_qty,sum(o.quantity) - e.quantity as qty_diff,
		sum(o.net_sales) as order_net,e.net_sales as ecomm_net,sum(o.net_sales) - e.net_sales as net_diff,
		sum(o.profit) as order_profit,e.profit as ecomm_profit,sum(o.profit) - e.profit as profit_diff
from orders o join ecomm e on o.order_id = e.order_id
where o.order_id = 'ORD-537228'
group by o.order_id,e.quantity,e.net_sales,e.profit

--Validate the Pattern Across Other Orders

select o.order_id,sum(o.quantity) as order_qty,e.quantity as ecomm_qty,sum(o.quantity) - e.quantity as qty_diff,
		sum(o.net_sales) as order_net,e.net_sales as ecomm_net,sum(o.net_sales) - e.net_sales as net_diff,
		sum(o.profit) as order_profit,e.profit as ecomm_profit,sum(o.profit) - e.profit as profit_diff
from orders o join ecomm e on o.order_id = e.order_id
where o.order_id = 'ORD-652783'
group by o.order_id,e.quantity,e.net_sales,e.profit

--Validate More Orders & Identify Orders with Net Sales Mismatches

select o.order_id,sum(o.quantity) as order_qty,e.quantity as ecomm_qty,sum(o.quantity) - e.quantity as qty_diff,
		sum(o.net_sales) as order_net,e.net_sales as ecomm_net,sum(o.net_sales) - e.net_sales as net_diff,
		sum(o.profit) as order_profit,e.profit as ecomm_profit,sum(o.profit) - e.profit as profit_diff
from orders o join ecomm e on o.order_id = e.order_id
group by o.order_id,e.quantity,e.net_sales,e.profit
having abs(sum(o.net_sales) - e.net_sales) > 0.01

--Summarize Net Sales Mismatches

select count(*) as mismatched_orders,sum(abs(net_diff)) as total_net_sales_difference
from (
    select o.order_id,sum(o.net_sales) as order_net,e.net_sales as ecomm_net,sum(o.net_sales) - e.net_sales as net_diff
    from orders o join ecomm e on o.order_id = e.order_id
    group by o.order_id, e.net_sales
    having abs(sum(o.net_sales) - e.net_sales) > 0.01
	) as mismatches --total mismatched orders - 11,226 , amount - 15264613.5514293

--Investigate the Net Sales Mismatches

--orders with the largest net-sales differences

select max(net_diff) as largest_net_sale_diff 
from (
    select o.order_id,sum(o.net_sales) as order_net,e.net_sales as ecomm_net,sum(o.net_sales) - e.net_sales as net_diff
    from orders o join ecomm e on o.order_id = e.order_id
    group by o.order_id, e.net_sales
    having abs(sum(o.net_sales) - e.net_sales) > 0.01
	) as mismatches

--which order has this $11,139.31 difference

select top 1 o.order_id,sum(o.net_sales) as order_net,e.net_sales as ecomm_net,sum(o.net_sales) - e.net_sales as net_diff
from orders o join ecomm e on o.order_id = e.order_id 
group by o.order_id,e.net_sales
having abs(sum(o.net_sales) - e.net_sales) > 0.01
order by net_diff desc

--check the order id 'ORD-182458'

select order_id,product_id,quantity,net_sales,profit 
from orders where order_id = 'ORD-182458'

select order_id,quantity,net_sales,profit 
from ecomm where order_id = 'ORD-182458'

--Check Whether Ecomm Contains a Subset of Orders Data

select o1.order_id,o1.product_id as product_1,o2.product_id as product_2,o1.net_sales as net_1,o2.net_sales as net_2,
	   o1.net_sales + o2.net_sales as combined_net,e.net_sales as ecomm_net
from orders o1 join orders o2 on o1.order_id = o2.order_id and o1.product_id < o2.product_id join ecomm e on o1.order_id = e.order_id
where o1.order_id = 'ORD-182458' and abs((o1.net_sales + o2.net_sales) - e.net_sales) < 0.01;

--Final Financial Reconciliation — Overall Difference

select sum(o.net_sales) as orders_net_sales,sum(e.net_sales) as ecomm_net_sales,
sum(o.net_sales) - sum(e.net_sales) as net_sales_difference, 
sum(o.profit) as orders_profit,sum(e.profit) as ecomm_profit,
sum(o.profit) - sum(e.profit) as profit_difference
from orders o join ecomm e on o.order_id = e.order_id

--creating net and profit one row matches

select distinct
    o.order_id
into #all_one_row_both_matches
from orders o
join ecomm e
    on o.order_id = e.order_id
where abs(o.net_sales - e.net_sales) < 0.01
  and abs(o.profit - e.profit) < 0.01;

select count(*) as one_row_both_matches
from #all_one_row_both_matches;

--creating net and profit two row matches

select distinct o1.order_id
into #all_two_row_both_matches
from orders o1
join orders o2 on o1.order_id = o2.order_id
   and o1.product_id < o2.product_id
join ecomm e on o1.order_id = e.order_id
where o1.order_id not in (select order_id from #all_one_row_both_matches)
and abs((o1.net_sales + o2.net_sales) - e.net_sales) < 0.01
and abs((o1.profit + o2.profit) - e.profit) < 0.01;

select count(*) as two_row_both_matches
from #all_two_row_both_matches;

--creating net and profit three row matches

select distinct o1.order_id
into #all_three_row_both_matches
from orders o1
join orders o2 on o1.order_id = o2.order_id
   and o1.product_id < o2.product_id
join orders o3 on o2.order_id = o3.order_id
   and o2.product_id < o3.product_id
join ecomm e on o1.order_id = e.order_id
where o1.order_id not in (select order_id from #all_one_row_both_matches)
and o1.order_id not in (select order_id from #all_two_row_both_matches)
and abs((o1.net_sales + o2.net_sales + o3.net_sales) - e.net_sales) < 0.01
and abs((o1.profit + o2.profit + o3.profit) - e.profit) < 0.01;

select count(*) as three_row_both_matches
from #all_three_row_both_matches;

--creating net and profit four row matches

select distinct o1.order_id
into #all_four_row_both_matches
from orders o1
join orders o2 on o1.order_id = o2.order_id
   and o1.product_id < o2.product_id
join orders o3 on o2.order_id = o3.order_id
   and o2.product_id < o3.product_id
join orders o4 on o3.order_id = o4.order_id
   and o3.product_id < o4.product_id
join ecomm e on o1.order_id = e.order_id
where o1.order_id not in (select order_id from #all_one_row_both_matches)
and o1.order_id not in (select order_id from #all_two_row_both_matches)
and o1.order_id not in (select order_id from #all_three_row_both_matches)
and abs((o1.net_sales + o2.net_sales + o3.net_sales + o4.net_sales) - e.net_sales) < 0.01
and abs((o1.profit + o2.profit + o3.profit + o4.profit) - e.profit) < 0.01;

select count(*) as four_row_both_matches
from #all_four_row_both_matches;

--creating net and profit five row matches

select distinct o1.order_id
into #all_five_row_both_matches
from orders o1
join orders o2 on o1.order_id = o2.order_id
   and o1.product_id < o2.product_id
join orders o3 on o2.order_id = o3.order_id
   and o2.product_id < o3.product_id
join orders o4 on o3.order_id = o4.order_id
   and o3.product_id < o4.product_id
join orders o5 on o4.order_id = o5.order_id
   and o4.product_id < o5.product_id
join ecomm e on o1.order_id = e.order_id
where o1.order_id not in ( select order_id from #all_one_row_both_matches )
and o1.order_id not in ( select order_id from #all_two_row_both_matches )
and o1.order_id not in ( select order_id from #all_three_row_both_matches )
and o1.order_id not in ( select order_id from #all_four_row_both_matches)
and abs((o1.net_sales + o2.net_sales + o3.net_sales + o4.net_sales + o5.net_sales) - e.net_sales) < 0.01
and abs((o1.profit + o2.profit + o3.profit + o4.profit + o5.profit) - e.profit) < 0.01;

select count(*) as five_row_both_matches
from #all_five_row_both_matches;

--------------------------------

select COLUMN_NAME,DATA_TYPE
from INFORMATION_SCHEMA.COLUMNS
where TABLE_NAME = 'ecomm' 

--combine all matched rows

select order_id, 1 AS match_rows 
into #all_order_matches
from #all_one_row_both_matches

union all

select order_id, 2 as match_rows from #all_two_row_both_matches

union all

select order_id, 3 as match_rows from #all_three_row_both_matches

union all

select order_id, 4 as match_rows from #all_four_row_both_matches

union all

select order_id, 5 as match_rows from #all_five_row_both_matches;

select match_rows,count(*) as order_count
from #all_order_matches
group by match_rows order by match_rows;

--Combine the five groups

select order_id, match_rows
into #final_order_matches
from #all_order_matches

select count(*) as total_rows,count(distinct order_id) as unique_orders
from #all_order_matches

--Insert 1-row matches in new table

select
    a.order_id,
    1 as match_rows,
    o1.product_id as product_1_id,o1.quantity as product_1_quantity,o1.net_sales as product_1_net_sales,o1.profit as product_1_profit
into #matched_product_details
from #all_one_row_both_matches a
join orders o1 on a.order_id = o1.order_id
join ecomm e on a.order_id = e.order_id
where ABS(o1.net_sales - e.net_sales) < 0.01 and ABS(o1.profit - e.profit) < 0.01;

select count(*) as total_rows
from #matched_product_details;

select * from #matched_product_details

--Insert 2-row matches

alter table #matched_product_details
add
    product_2_id nvarchar(50),product_2_quantity int,product_2_net_sales float,product_2_profit float

insert into #matched_product_details (
    order_id,
    match_rows,
    product_1_id,product_1_quantity,product_1_net_sales,product_1_profit,
    product_2_id,product_2_quantity,product_2_net_sales,product_2_profit
)
select
    a.order_id,
    2,
    o1.product_id,o1.quantity,o1.net_sales,o1.profit,
    o2.product_id,o2.quantity,o2.net_sales,o2.profit
from #all_two_row_both_matches a
join orders o1
    on a.order_id = o1.order_id
join orders o2
    on o1.order_id = o2.order_id
   and o1.product_id < o2.product_id
join ecomm e
    on a.order_id = e.order_id
where ABS(o1.net_sales + o2.net_sales - e.net_sales) < 0.01 and ABS(o1.profit + o2.profit - e.profit) < 0.01

select match_rows,count(*) as order_count
from #matched_product_details
group by match_rows order by match_rows;

--Insert 3-row matches

alter table #matched_product_details
add product_3_id nvarchar(50),product_3_quantity int,product_3_net_sales float,product_3_profit float

insert into #matched_product_details (
    order_id,
    match_rows,
    product_1_id,product_1_quantity,product_1_net_sales,product_1_profit,
    product_2_id,product_2_quantity,product_2_net_sales,product_2_profit,
    product_3_id,product_3_quantity,product_3_net_sales,product_3_profit
)
select
    a.order_id,
    3,
    o1.product_id,o1.quantity,o1.net_sales,o1.profit,
    o2.product_id,o2.quantity,o2.net_sales,o2.profit,
    o3.product_id,o3.quantity,o3.net_sales,o3.profit
from #all_three_row_both_matches a
join orders o1 on a.order_id = o1.order_id
join orders o2 on o1.order_id = o2.order_id
   and o1.product_id < o2.product_id
join orders o3 on o2.order_id = o3.order_id
   and o2.product_id < o3.product_id
join ecomm e on a.order_id = e.order_id
where ABS(o1.net_sales + o2.net_sales + o3.net_sales - e.net_sales) < 0.01 and ABS(o1.profit + o2.profit + o3.profit - e.profit) < 0.01

select match_rows,count(*) as order_count
from #matched_product_details
group by match_rows order by match_rows;

--Add Product 4 columns

alter table #matched_product_details
add product_4_id nvarchar(50),product_4_quantity int,product_4_net_sales float,product_4_profit float

--Insert 4-row matches

insert into #matched_product_details (
    order_id,
    match_rows,
    product_1_id, product_1_quantity, product_1_net_sales, product_1_profit,
    product_2_id, product_2_quantity, product_2_net_sales, product_2_profit,
    product_3_id, product_3_quantity, product_3_net_sales, product_3_profit,
    product_4_id, product_4_quantity, product_4_net_sales, product_4_profit
)
select
    a.order_id,
    4,
    o1.product_id, o1.quantity, o1.net_sales, o1.profit,
    o2.product_id, o2.quantity, o2.net_sales, o2.profit,
    o3.product_id, o3.quantity, o3.net_sales, o3.profit,
    o4.product_id, o4.quantity, o4.net_sales, o4.profit
from #all_four_row_both_matches a
join orders o1 on a.order_id = o1.order_id
join orders o2 on o1.order_id = o2.order_id
   and o1.product_id < o2.product_id
join orders o3 on o2.order_id = o3.order_id
   and o2.product_id < o3.product_id
join orders o4 on o3.order_id = o4.order_id
   and o3.product_id < o4.product_id
join ecomm e on a.order_id = e.order_id
where ABS(o1.net_sales + o2.net_sales + o3.net_sales + o4.net_sales - e.net_sales) < 0.01
and ABS(o1.profit + o2.profit + o3.profit + o4.profit - e.profit) < 0.01

select match_rows,count(*) as order_count
from #matched_product_details
group by match_rows order by match_rows;

--Add Product 5 columns

alter table #matched_product_details
add product_5_id nvarchar(50),product_5_quantity int,product_5_net_sales float,product_5_profit float

--Insert the 5-row matches

insert into #matched_product_details (
    order_id,
    match_rows,
    product_1_id, product_1_quantity, product_1_net_sales, product_1_profit,
    product_2_id, product_2_quantity, product_2_net_sales, product_2_profit,
    product_3_id, product_3_quantity, product_3_net_sales, product_3_profit,
    product_4_id, product_4_quantity, product_4_net_sales, product_4_profit,
    product_5_id, product_5_quantity, product_5_net_sales, product_5_profit
)
select
    a.order_id,
    5,
    o1.product_id, o1.quantity, o1.net_sales, o1.profit,
    o2.product_id, o2.quantity, o2.net_sales, o2.profit,
    o3.product_id, o3.quantity, o3.net_sales, o3.profit,
    o4.product_id, o4.quantity, o4.net_sales, o4.profit,
    o5.product_id, o5.quantity, o5.net_sales, o5.profit
from #all_five_row_both_matches a
join orders o1 on a.order_id = o1.order_id
join orders o2 on o1.order_id = o2.order_id
   and o1.product_id < o2.product_id
join orders o3 on o2.order_id = o3.order_id
   and o2.product_id < o3.product_id
join orders o4 on o3.order_id = o4.order_id
   and o3.product_id < o4.product_id
join orders o5 on o4.order_id = o5.order_id
   and o4.product_id < o5.product_id
join ecomm e on a.order_id = e.order_id
where ABS(o1.net_sales + o2.net_sales + o3.net_sales + o4.net_sales + o5.net_sales - e.net_sales) < 0.01
and ABS(o1.profit + o2.profit + o3.profit + o4.profit + o5.profit - e.profit) < 0.01;

select match_rows,count(*) as order_count
from #matched_product_details
group by match_rows order by match_rows;

select count(*) as total_rows,count(distinct order_id) as unique_orders
from #matched_product_details;

--Create the final reconciliation table

 select e.*,m.match_rows,
    m.product_1_id,m.product_1_quantity,m.product_1_net_sales,m.product_1_profit,
    m.product_2_id,m.product_2_quantity,m.product_2_net_sales,m.product_2_profit,
    m.product_3_id,m.product_3_quantity,m.product_3_net_sales,m.product_3_profit,
    m.product_4_id,m.product_4_quantity,m.product_4_net_sales,m.product_4_profit,
    m.product_5_id,m.product_5_quantity,m.product_5_net_sales,m.product_5_profit,

  coalesce(m.product_1_net_sales, 0)
    + coalesce(m.product_2_net_sales, 0)+ coalesce(m.product_3_net_sales, 0)
    + coalesce(m.product_4_net_sales, 0)+ coalesce(m.product_5_net_sales, 0)as calculated_net_sales,

  coalesce(m.product_1_profit, 0)
   + coalesce(m.product_2_profit, 0)+ coalesce(m.product_3_profit, 0)
   + coalesce(m.product_4_profit, 0)+ coalesce(m.product_5_profit, 0)as calculated_profit,

 (coalesce(m.product_1_net_sales, 0)+ coalesce(m.product_2_net_sales, 0)
  + coalesce(m.product_3_net_sales, 0)+ coalesce(m.product_4_net_sales, 0)
  + coalesce(m.product_5_net_sales, 0)) - e.net_sales as net_sales_difference,

 (coalesce(m.product_1_profit, 0)+ coalesce(m.product_2_profit, 0)+ coalesce(m.product_3_profit, 0)
   + coalesce(m.product_4_profit, 0)+ coalesce(m.product_5_profit, 0)) - e.profit as profit_difference

into final_order_product
from ecomm e join #matched_product_details m on e.order_id = m.order_id;

--checking final net and profit total

select sum(net_sales) as ecomm_net,sum(profit) as ecomm_profit,
sum(product_1_net_sales) + sum(product_2_net_sales) + sum(product_3_net_sales) + sum(product_4_net_sales) + sum(product_5_net_sales) 
as final_net,
sum(product_1_profit) + sum(product_2_profit) + sum(product_3_profit) + sum(product_4_profit) + sum(product_5_profit) as final_profit
from final_order_product

--Business Insights & Recommendations

--Customer Analysis

--Top 5 Customers by Revenue

select * from ecomm

select top 5 customer_id,customer_name,sum(net_sales) as customer_revenue from ecomm
group by customer_id,customer_name order by sum(net_sales) desc

--Top 5 Customers by Profit

select top 5 customer_id,customer_name,sum(profit) as customer_profit from ecomm
group by customer_id,customer_name order by sum(profit) desc

--Top 5 customers by profit margin

select top 5 customer_id,customer_name,sum(net_sales) as customer_revenue,sum(profit) as customer_profit,
(sum(profit)/sum(net_sales)*100) as profit_margin from ecomm 
group by customer_id,customer_name order by sum(profit)/sum(net_sales)*100 desc

--top 5 Customer Order Frequency

select top 5 customer_id,customer_name,count(order_id) as order_count from ecomm
group by customer_id,customer_name order by count(order_id) desc 

--Product Analysis

--Top 5 Products by Revenue

 select * from final_order_product

 with product_revenue as (select product_1_id as product_id,product_1_net_sales as revenue from final_order_product
 union all
 select product_2_id,product_2_net_sales from final_order_product
 union all
 select product_3_id,product_3_net_sales from final_order_product
 union all
 select product_4_id,product_4_net_sales from final_order_product
 union all
 select product_5_id,product_5_net_sales from final_order_product)
 select top 5 product_id,sum(revenue) as total_revenue from product_revenue
 group by product_id order by total_revenue desc

 --Top 5 Products by Profit

 select * from final_order_product

 with product_profit as (select product_1_id as product_id,product_1_profit as profit from final_order_product 
 union all
 select product_2_id ,product_2_profit from final_order_product 
 union all
 select product_3_id ,product_3_profit from final_order_product 
 union all
 select product_4_id ,product_4_profit from final_order_product 
 union all
 select product_5_id ,product_5_profit from final_order_product )
 select top 5 product_id,sum(profit) as total_profit from product_profit 
 group by product_id order by total_profit desc

 --Bottom 5 products by profit

  with product_profit as (select product_1_id as product_id,product_1_profit as profit from final_order_product 
 union all
 select product_2_id ,product_2_profit from final_order_product 
 union all
 select product_3_id ,product_3_profit from final_order_product 
 union all
 select product_4_id ,product_4_profit from final_order_product 
 union all
 select product_5_id ,product_5_profit from final_order_product )
 select top 5 product_id,sum(profit) as total_profit from product_profit 
 where product_id is not null
 group by product_id order by total_profit 

--Bottom 5 Products by Revenue

 with product_revenue as (select product_1_id as product_id,product_1_net_sales as revenue from final_order_product
 union all
 select product_2_id,product_2_net_sales from final_order_product
 union all
 select product_3_id,product_3_net_sales from final_order_product
 union all
 select product_4_id,product_4_net_sales from final_order_product
 union all
 select product_5_id,product_5_net_sales from final_order_product)
 select top 5 product_id,sum(revenue) as total_revenue from product_revenue
 where product_id is not null
 group by product_id order by total_revenue 

 --Top 5 Product Profit Margin Analysis

 with profit_margin as (
 select product_1_id as product_id,product_1_net_sales as net_sales,product_1_profit as profit from final_order_product
 union all
 select product_2_id ,product_2_net_sales ,product_2_profit  from final_order_product
 union all
 select product_3_id ,product_3_net_sales ,product_3_profit  from final_order_product
 union all
 select product_4_id ,product_4_net_sales ,product_4_profit  from final_order_product
 union all
 select product_5_id ,product_5_net_sales ,product_5_profit  from final_order_product)
 select top 5 product_id,sum(profit)/sum(net_sales) * 100 as profit_margin from profit_margin
 where product_id is not null
 group by product_id order by profit_margin desc

 --Bottom 5 Products by Profit Margin

  with profit_margin as (
 select product_1_id as product_id,product_1_net_sales as net_sales,product_1_profit as profit from final_order_product
 union all
 select product_2_id ,product_2_net_sales ,product_2_profit  from final_order_product
 union all
 select product_3_id ,product_3_net_sales ,product_3_profit  from final_order_product
 union all
 select product_4_id ,product_4_net_sales ,product_4_profit  from final_order_product
 union all
 select product_5_id ,product_5_net_sales ,product_5_profit  from final_order_product)
 select top 5 product_id,sum(profit)/sum(net_sales) * 100 as profit_margin from profit_margin
 where product_id is not null
 group by product_id order by profit_margin 

 --Business Questions

 --Q1.Which product categories generate the highest revenue and profit?

 with high_rev_pro as (select product_1_id as product_id,product_1_net_sales as net_sales,product_1_profit as profit from final_order_product
 union all
 select product_2_id,product_2_net_sales,product_2_profit from final_order_product
 union all
 select product_3_id,product_3_net_sales,product_3_profit from final_order_product
 union all
 select product_4_id,product_4_net_sales,product_4_profit from final_order_product
 union all
 select product_5_id,product_5_net_sales,product_5_profit from final_order_product),
 pro_cat as (select p.product_category,sum(h.net_sales) as total_net_sales,sum(h.profit) as total_profit from high_rev_pro h join product p on h.product_id = p.product_id
 group by product_category ),
 ranking as (select *,rank() over(order by total_net_sales desc) as revenue_rank,
 rank() over(order by total_profit desc) as profit_rank from pro_cat)
 select * from ranking where revenue_rank = 1 or profit_rank = 1 order by revenue_rank,profit_rank

--Q2.Which are the top 5 most profitable products?

 with high_pro as (select product_1_id as product_id,product_1_net_sales as net_sales,product_1_profit as profit from final_order_product
 union all
 select product_2_id,product_2_net_sales,product_2_profit from final_order_product
 union all
 select product_3_id,product_3_net_sales,product_3_profit from final_order_product
 union all
 select product_4_id,product_4_net_sales,product_4_profit from final_order_product
 union all
 select product_5_id,product_5_net_sales,product_5_profit from final_order_product)
 select top 5 product_id,sum(profit) as profit from high_pro
 group by product_id order by profit desc

--Q3.Which delivery statuses are associated with the highest and lowest profit?

select delivery_status,count(*) as order_count,sum(profit) as total_profit,avg(profit) as avg_profit from ecomm
group by delivery_status order by total_profit desc

--Q4.How do discounts affect profit?

with discount as (select order_id, discount_amount * 100 / nullif(gross_sales,0) as discount_percentage,profit from ecomm)
select case when discount_percentage = 0 then 'No Discount'
when discount_percentage < 10 then 'Low Discount'
when discount_percentage < 20 then 'Medium Discount'
when discount_percentage < 30 then 'High Discount'
else 'Very High Discount' end as discount_category,
count(*) as total_rows,sum(profit) as total_profit,avg(profit) as avg_profit from discount
group by case when discount_percentage = 0 then 'No Discount'
when discount_percentage < 10 then 'Low Discount'
when discount_percentage < 20 then 'Medium Discount'
when discount_percentage < 30 then 'High Discount'
else 'Very High Discount' end 
order by total_profit desc

--Q5.Which regions generate the highest sales and profit?

select region,sum(gross_sales) as total_sales,sum(profit) as total_profit,avg(profit) as avg_profit from ecomm 
group by region order by total_profit desc

--Q5.Which product categories have the highest return rates?

with pro_id as (select order_id,product_1_id as product_id from final_order_product 
where product_1_id is not null
union all
select order_id,product_2_id from final_order_product
where product_2_id is not null
union all
select order_id,product_3_id from final_order_product
where product_3_id is not null
union all
select order_id,product_4_id from final_order_product
where product_4_id is not null
union all
select order_id,product_5_id from final_order_product
where product_5_id is not null),
return_cat as (
select p.product_category,p1.order_id,e.return_status from product p join pro_id p1 on p.product_id = p1.product_id 
join ecomm e on p1.order_id = e.order_id)
select product_category,count(*) as total_products,
sum(case when return_status = 'Returned' then 1 else 0 end) as returned_products,
sum(case when return_status = 'Returned' then 1.0 else 0 end) * 100.0 / nullif(count(*),0) as returned_rate from return_cat
group by product_category order by returned_rate desc