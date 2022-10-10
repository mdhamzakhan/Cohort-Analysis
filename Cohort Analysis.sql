-- Overview
select * from onre;

select (country)
from onre group by country

select customerid from onre
group by customerid

-- Number of Countries = 38
-- Number of CustomerId = 4373
-- 135,080 null values in cID are null
-- Not Null Cids = 406829
Select * from onre where customerid is null

-- Removing Null CustomerIDs
with onre1 as 
(
	Select * from onre where customerid <> 0
),
-- Removing negative quatity and price
Onre2 as 
(
	select * from onre1
	where Quantity >0 and UnitPrice>0
),
-- Removing Duplicates
--5125 Duplicate values
 Dflag as 
 (
 select * , ROW_NUMBER() over(partition by InvoiceNo,StockCode , quantity order by InvoiceDate) as dflag from Onre2
 )
select *
into #online_retail_main
from Dflag
where dflag = 1


-------------------------------------------
-- Clean Data Overview
select * from #online_retail_main

--- Cohort Analysis
select customerid, min(InvoiceDate) first_purchased_date,
DATEFROMPARTS(YEAR(min(invoicedate)), month(min(invoicedate)),1) as cohort_date
into #cohort 
from #online_retail_main
group by CustomerID

select * from #cohort

-- Creating Cohort Index
select m3.*, cohort_index = year_Diff*12 + month_diff+1
into #cohort_retention
from 
(
	select m2.*, (invoice_year-cohort_year) year_Diff, (invoice_month-cohort_month) month_diff
	from (
		select m1.*,cohort_date, YEAR(m1.InvoiceDate) as invoice_year, month(m1.InvoiceDate) as invoice_month, YEAR(c.cohort_date) cohort_year, month(c.cohort_date) cohort_month
		from #online_retail_main m1 inner join #cohort c
		on m1.CustomerID =c.CustomerID ) m2 )  m3

--- Overviewing and extracting data for tableau
select * from #cohort_retention
---drop table #cohort_retention
drop table #cohort_pivot
select *
into #cohort_pivot
from(
	select distinct
	CustomerID,
	cohort_date,
	cohort_index
	from #cohort_retention
	)tbl
pivot(
Count(CustomerID)
for Cohort_Index In
(
[1],
[2],
[3],
[4],
[5],
[6],
[7],
[8],
[9],
[10],
[11],
[12],
[13])
)as pivot_table
select *
from #cohort_pivot
order by cohort_Date
select cohort_Date ,
(1.0 * [1]/[1] * 100) as [1],
1.0 * [2]/[1] * 100 as [2],
1.0 * [3]/[1] * 100 as [3],
1.0 * [4]/[1] * 100 as [4],
1.0 * [5]/[1] * 100 as [5],
1.0 * [6]/[1] * 100 as [6],
1.0 * [7]/[1] * 100 as [7],
1.0 * [8]/[1] * 100 as [8],
1.0 * [9]/[1] * 100 as [9],
1.0 * [10]/[1] * 100 as [10],
1.0 * [11]/[1] * 100 as [11],
1.0 * [12]/[1] * 100 as [12],
1.0 * [13]/[1] * 100 as [13]
from #cohort_pivot
order by cohort_date