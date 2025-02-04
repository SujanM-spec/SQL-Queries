/*Q1 . What is the total sales?

2. What is the total profit?

What is the total cost amount?

Q4. What is the sales per year?

Q5. What is the average sales per customers?*/

select
	isnull(cast(year(s.ShipDate) as varchar),'Grand_Total') as [Year on Sold],
	sum(s.SalesAmount) as [Total sales] ,
	sum(s.TotalProductCost) as [Total Product Cost],
	sum(s.SalesAmount) - sum(s.TotalProductCost) as [Total Profit],
	count(distinct s.CustomerKey) as Number_of_Customers,
	(sum(s.SalesAmount))/(count(s.CustomerKey)) as Sales_avg_per_customers
from 
	[dbo].[FactInternetSales]s
group by rollup
	(year(ShipDate))
		
order by
	year(ShipDate) desc;

/*Q6. What is the number of products in each category?*/

select
	count(p.EnglishProductName) as Number_of_English_Product,
	isnull(pc.EnglishProductCategoryName,'None') as Product_Name
from [dbo].[DimProduct]p
	left join[dbo].[DimProductSubcategory] psc on p.ProductSubcategoryKey=psc.ProductSubcategoryKey
	left join[dbo].[DimProductCategory]pc on psc.ProductCategoryKey=pc.ProductCategoryKey
group by
	Pc.EnglishProductCategoryName
order by 
	count(p.EnglishProductName) asc;

	/*Q7. Top 10 Customers with the highest purchase*/

select 
top 10
	sum(s.SalesAmount) as [Total sales] ,
	case
	when MiddleName is null then Concat(FirstName,' ',LastName)
	else concat (FirstName,' ',MiddleName,' ',LastName)
	end as Customer_Name
from 
	[dbo].[FactInternetSales]s
	left join [dbo].[DimCustomer]c on s.CustomerKey=c.CustomerKey
	group by 
		case
		when MiddleName is null then Concat(FirstName,' ',LastName)
		else concat (FirstName,' ',MiddleName,' ',LastName)
		end
	order by 
		sum(s.SalesAmount) desc;

--Q8. Top 10 Customers with the highest order--

select 
top 10
	count(s.OrderDate) as Number_of_orders,
		case
		when MiddleName is null then Concat(FirstName,' ',LastName)
		else concat (FirstName,' ',MiddleName,' ',LastName)
		end as Customer_Name
from 
	[dbo].[FactInternetSales]s
	left join [dbo].[DimCustomer]c on s.CustomerKey=c.CustomerKey
	group by 	
		case
		when MiddleName is null then Concat(FirstName,' ',LastName)
		else concat (FirstName,' ',MiddleName,' ',LastName)
		end 
	order by 
		count(s.OrderDate) desc;

--	Q9. Top 10 Employees with the highest sale--

select
top 10
	sum(s.SalesAmount) as [Total sales] ,
	case
	when MiddleName is null then Concat(FirstName,' ',LastName)
	else concat (FirstName,' ',MiddleName,' ',LastName)
	end as Employee_Name
from
	[dbo].[FactInternetSales]s
	left join [dbo].[DimEmployee]e on s.SalesTerritoryKey=e.SalesTerritoryKey
group by 
	case
	when MiddleName is null then Concat(FirstName,' ',LastName)
	else concat (FirstName,' ',MiddleName,' ',LastName)
	end ;

--Q10. Top 10 most sale products--

select 
	top 10
	count(s.ProductKey) as Top_Sale_Product,
	p.EnglishProductName
from 
	[dbo].[FactInternetSales]s
	left join [dbo].[DimProduct]p on s.ProductKey=p.ProductKey
group by
	p.EnglishProductName
order by
	Count(s.ProductKey) desc;

--Q11. What is the total customer--

select
	count(c.Customerkey) as Total_Customer
from
	[dbo].[DimCustomer]c;

--Q12. What is the total transaction?--

select
	sum(s.SalesAmount)-Sum(s.TaxAmt)+Sum(s.Freight) as Total_Transcation
from
	[dbo].[FactInternetSales]s;

--Q14. Ranking customers by sales--

select 
	row_number() over (order by sum(s.SalesAmount) desc) as [Rank],
	sum(s.SalesAmount) as [Total sales] ,
	case
	when MiddleName is null then Concat(FirstName,' ',LastName)
	else concat (FirstName,' ',MiddleName,' ',LastName)
	end as Customer_Name
from 
	[dbo].[FactInternetSales]s
	left join [dbo].[DimCustomer]c on s.CustomerKey=c.CustomerKey
	group by 
		case
		when MiddleName is null then Concat(FirstName,' ',LastName)
		else concat (FirstName,' ',MiddleName,' ',LastName)
		end
	order by
		sum(s.SalesAmount) desc;



