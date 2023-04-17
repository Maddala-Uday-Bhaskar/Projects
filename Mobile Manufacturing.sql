--1.List all the states in which we have customers who have bought cellphones from 2005 till today.

	select  "state" from FACT_TRANSACTIONS t left join DIM_LOCATION l
	on t.IDLocation = l.IDLocation
	where year(t."Date") > 2005
	group by "state"
	having count(t.IDCustomer) >= 1
 
--2.What state in the US is buying the most 'Samsung' cell phones?

select top 1 "state"
from FACT_TRANSACTIONS t 
left join DIM_LOCATION l on t.IDLocation = l.IDLocation
left join DIM_MODEL m on t.IDModel = m.IDModel
left join DIM_MANUFACTURER dm on m.IDManufacturer = dm.IDManufacturer
where l.Country = 'US' and dm.Manufacturer_Name = 'Samsung'
group by "state"
order by count(t.IDCustomer) desc

--3.Show the number of transactions for each model per zip code per state.      

select "state","ZipCode",count([IDCustomer]) as No_Transactions from FACT_TRANSACTIONS t 
 left join DIM_LOCATION l
	on t.IDLocation = l.IDLocation
	group by "state","ZipCode"

--4.Show the cheapest cellphone Output should contain the price

select top 1 m.Model_Name, t.TotalPrice
from FACT_TRANSACTIONS t
left join DIM_MODEL as m on t.IDModel = m.IDModel
order by t.TotalPrice  

--5.Find out the avg price for each model in top 5 mfrs in terms of sales qty and order by avg price

select d.Model_Name, avg(t.TotalPrice) as avg_price
from FACT_TRANSACTIONS t left join DIM_MODEL d on t.IDModel = d.IDModel
where d.IDManufacturer in (
select top 5 d.IDManufacturer
from FACT_TRANSACTIONS t left join DIM_MODEL d on t.IDModel = d.IDModel
group by d.IDManufacturer
order by sum(t.Quantity) desc,avg(t.TotalPrice) desc
)
group by d.Model_Name

--6.List the names of the customers and the average amount spent in 2009, where the average is higher than 500

select c.Customer_Name, avg(t.TotalPrice) as average_spent
from FACT_TRANSACTIONS t left join DIM_CUSTOMER c on t.IDCustomer = c.IDCustomer
left join DIM_DATE dt on t.Date = dt.DATE
where dt.YEAR = 2009
group by c.Customer_Name
having avg(t.TotalPrice) > 500

--7.List if there is any model that was in the top 5 in terms of quantity, simultaneously in 2008, 2009 and 2010
select top 5 m.Model_name
from FACT_TRANSACTIONS t left join DIM_MODEL m on t.IDModel = m.IDModel
left join DIM_DATE dt on t.Date = dt.DATE
where dt.YEAR in (2008,2009,2010)
group by m.Model_Name
order by sum(t.Quantity) desc

--8.Show the manufacturer with the 2nd top sales in the year of 2009 and the manufacturer with the 2nd top 
--sales in the year of 2010 ?

select Manufacturer_name,"Year" from
(select m.Manufacturer_Name,dt.year, rank() over (partition by dt.year order by sum(t.TotalPrice) desc) rk
from  FACT_TRANSACTIONS t left join DIM_MODEL d on t.IDModel = d.IDModel
left join DIM_MANUFACTURER m on d.IDManufacturer = m.IDManufacturer
left join DIM_DATE dt on t.Date = dt.DATE
group by m.Manufacturer_Name,dt.YEAR
)as r
where rk = 2 and "year" in (2009,2010)

-- 9.Show the manufacturers that sold cellphones in 2010 but did not in 2009.
with sales_2009 as
( 
select m.Manufacturer_Name, sum(t.TotalPrice) as Sales
from  FACT_TRANSACTIONS t left join DIM_MODEL d on t.IDModel = d.IDModel
left join DIM_MANUFACTURER m on d.IDManufacturer = m.IDManufacturer
left join DIM_DATE dt on t.Date = dt.DATE
where dt.year = 2009
group by m.Manufacturer_Name
),
sales_2010 as
(
select m.Manufacturer_Name, sum(t.TotalPrice) as Sales
from  FACT_TRANSACTIONS t left join DIM_MODEL d on t.IDModel = d.IDModel
left join DIM_MANUFACTURER m on d.IDManufacturer = m.IDManufacturer
left join DIM_DATE dt on t.Date = dt.DATE
where dt.year = 2010
group by m.Manufacturer_Name
)
select s1.Manufacturer_Name
from sales_2010 s1 left join sales_2009 s2 on s1.Manufacturer_Name = s2.Manufacturer_Name
where s2.Manufacturer_Name is null

--10.Find top 100 customers and their average spend, average quantity by each year. Also find the percentage
--of change in their spend.

select Customer_Name, year, avg_spent, Avg_Qty from
(select c.Customer_Name, dt.year,
avg(t.TotalPrice) as avg_spent, 
avg(t.Quantity) as Avg_Qty 
, RANK() over (partition by dt.year order by avg(t.TotalPrice) desc) as Rnk
from FACT_TRANSACTIONS t left join DIM_CUSTOMER c on t.IDCustomer = c.IDCustomer
left join DIM_DATE dt on t.Date = dt.DATE
group by c.Customer_Name,dt.year
) as ct
where rnk between 1 and 100

	