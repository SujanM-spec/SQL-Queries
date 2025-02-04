/*Create a query with the following columns:
1. PurchaseOrderID, from Purchasing.PurchaseOrderDetail
2. PurchaseOrderDetailID, from Purchasing.PurchaseOrderDetail
3. OrderQty, from Purchasing.PurchaseOrderDetail
4. UnitPrice, from Purchasing.PurchaseOrderDetail
5. LineTotal, from Purchasing.PurchaseOrderDetail
6. OrderDate, from Purchasing.PurchaseOrderHeader
7. A derived column, aliased as “OrderSizeCategory”, calculated via CASE logic as follows:
o When OrderQty > 500, the logic should return “Large”
o When OrderQty > 50 but <= 500, the logic should return “Medium”
o Otherwise, the logic should return “Small”
8. The “Name” field from Production.Product, aliased as “ProductName”
9. The “Name” field from Production.ProductSubcategory, aliased as “Subcategory”; if this value is
NULL, return the string “None” instead
10. The “Name” field from Production.ProductCategory, aliased as “Category”; if this value is NULL,
return the string “None” instead
Only return rows where the order date occurred in December of ANY year. The
MONTH function should provide a helpful shortcut h*/

select 
	pod.PurchaseOrderID,
	pod.PurchaseOrderDetailID,
	pod.OrderQty,
	pod.UnitPrice,
	pod.LineTotal,
	poh.OrderDate,
	case 
	when OrderQty > '500' then 'Lagre'
	when OrderQty between  '51' and '500' then 'Medium'
	else 'small'
	end as OrderSizeCategory,
	Order_Month=MONTH(poh.OrderDate),
		pp.Name as ProductName,
		

	isnull(ps.Name,'None') as Subcategory,
	isnull(pc.Name,'None') as Category	

from
	Purchasing.PurchaseOrderDetail pod
	left join Purchasing.PurchaseOrderHeader as poh 
	on pod.PurchaseOrderID=poh.PurchaseOrderID
	inner join [Production].[Product] pp on pod.ProductID = pp.ProductID
	left join [Production].[ProductSubcategory] ps on pp.ProductSubcategoryID=ps.ProductSubcategoryID
	left join  [Production].[ProductCategory] pc on ps.ProductCategoryID=pc.ProductCategoryID
	Where Month(poh.OrderDate)=12
	order by OrderQty asc;

/*The Sales data in our AdventureWorks database is structured almost identically to our Purchasing data.
It is so similar, in fact, that we can actually align columns from several of the Sales and Purchasing tables
to create a unified dataset in which some rows pertain to Sales, and some to Purchasing. Note that we
are talking about combining data by columns rather than by rows here – think UNION.
So with that said, your second challenge is to enhance your query from Challenge 1 by “stacking” it with
the corresponding Sales data. That may seem daunting, but it is actually WAY easier than it sounds! It
turns out that our two Purchasing tables from the Exercise 1 query map to an equivalent Sales table:
• Purchasing.PurchaseOrderDetail maps to Sales.SalesOrderDetail
• Purchasing.PurchaseOrderHeader maps to Sales.SalesOrderHeader*/	
	
select
	pod.PurchaseOrderID as orderID,
	pod.PurchaseOrderDetailID as orderdetailID,
	pod.OrderQty,
	pod.UnitPrice,
	pod.LineTotal
from 
	[Purchasing].[PurchaseOrderDetail] pod
where 
	LineTotal>1

union

select 
	sod.SalesOrderID,
	sod.SalesOrderDetailID,
	sod.OrderQty,
	sod.UnitPrice,
	sod.LineTotal
from
	[Sales].[SalesOrderDetail] sod

where
	LineTotal>1
order by LineTotal asc;

select
	poh.RevisionNumber,
	poh.OrderDate,
	poh.Status,
	poh.ShipMethodID,
	poh.ShipDate,
	poh.SubTotal,
	poh.TaxAmt,
	poh.Freight,
	poh.TotalDue,
	poh.ModifiedDate
from
	Purchasing.PurchaseOrderHeader poh
where
	Status > 1

union

select 
	soh.RevisionNumber,
	soh.OrderDate,
	soh.Status,
	soh.ShipMethodID,
	soh.ShipDate,
	soh.SubTotal,
	soh.TaxAmt,
	soh.Freight,
	soh.TotalDue,
	soh.ModifiedDate
from 
	Sales.SalesOrderHeader soh
where
	Status > 1
	order by Status asc;


/*Create a query with the following columns:
11. BusinessEntityID, from Person.Person
12. PersonType, from Person.Person
13. A derived column, aliased as “FullName”, that combines the first, last, and middle names from
Person.Person.
o There should be exactly one space between each of the names.
o If “MiddleName” is NULL and you try to “add” it to the other two names, the result will
be NULL, which isn’t what you want.
o You could use ISNULL to return an empty string if the middle name is NULL, but then
you’d end up with an extra space between first and last name – a space we would have
needed if we had a middle name to work with.
o So what we really need is to apply conditional, IF/THEN type logic; if middle name is
NULL, we just need a space between first name and last name. If not, then we need a
space, the middle name, and then another space. See if you can accomplish this with a
CASE statement.
14. The “AddressLine1” field from Person.Address; alias this as “Address”.
15. The “City” field from Person.Address
16. The “PostalCode” field from Person.Address
17. The “Name” field from Person.StateProvince; alias this as “State”.
18. The “Name” field from Person.CountryRegion; alias this as “Country”.
Only return rows where person type (from Person.Person) is “SP”, OR the postal code begins with a
“9” AND the postal code is exactly 5 characters long AND the country (i.e., “Name” from
Person.CountryRegion) is “United States”. */

select 
	pp.BusinessEntityID,
	pp.PersonType,
	case
	when MiddleName is null then Concat(FirstName,' ',LastName)
	else concat (FirstName,' ',MiddleName,' ',LastName)
	end as FullName,
	pa.AddressLine1 as Address,
	pa.City,
	left (pa.PostalCode,5) as PostalCode,
	sp.Name as State,
	cr.Name as Country

from Person.Person pp
	left join [Person].[Address] pa on pp.ModifiedDate=pa.ModifiedDate
	left join Person.StateProvince sp on pa.StateProvinceID=sp.StateProvinceID
	left join Person.CountryRegion cr on sp.CountryRegionCode=cr.CountryRegionCode
where
PersonType ='SP'
or
PostalCode like '9%'
and
 cr.Name='United States';


/* Enhance your query from Exercise 3 as follows:
1. Join in the HumanResources.Employee table to Person.Person on BusinessEntityID. Note that
many people in the Person.Person table are not employees, and we don’t want to limit our
output to just employees, so choose your join type accordingly.
2. Add the “JobTitle” field from HumanResources.Employee to our output. If it is NULL (as it will be
for people in our Person.Person table who are not employees, return “None”.
3. Add a derived column, aliased as “JobCategory”, that returns different categories based on the
value in the “JobTitle” column as follows:
o If the job title contains the words “Manager”, “President”, or “Executive”, return
“Management”. Applying wildcards with LIKE could be a helpful approach here.
o If the job title contains the word “Engineer”, return “Engineering”.
o If the job title contains the word “Production”, return “Production”.
o If the job title contains the word “Marketing”, return “Marketing”.
o If the job title is NULL, return “NA”.
o If the job title is one of the following exact strings (NOT patterns), return “Human
Resources”: “Recruiter”, “Benefits Specialist”, OR “Human Resources Administrative
Assistant”. You could use a series of ORs here, but the IN keyword could be a nice
shortcut.
o As a default case when none of the other conditions are true, return “Other”.*/
 
 select distinct
	isnull(e.JobTitle,'None') as Jobtitle,
	case
	 when e.JobTitle like '%Manager%'
	 or e.JobTitle like '%President%'
	 or e.JobTitle like '%Executive%' then 'Management'
	 when e.Jobtitle like '%Engineer%' then 'Engineering'
	 when e.JobTitle like '%Production%' then 'Production'
	 when e.JobTitle like '%Marketing%' then 'Marketing'
	 when e.JobTitle is null then 'NA'
	 when e.JobTitle in ('Recruiter','Benefits Specialist','Human Resources Administrative Assistant') then 'Human Resources'
	 else 'Other'
	 end as JobCategory
 from HumanResources.Employee e
 full join Person.Person pp on e.BusinessEntityID=pp.BusinessEntityID;

/* Select the number of days remaining until the end of the current month; that is, the difference in days
between the current date and the last day of the current month.
Your solution should be dynamic: it should work no matter what day, month, or year you run it, which
means it needs to calculate the end of the current month based on the current date.*/

 SELECT
	EOMONTH(GETDATE(),0) As [End of Month Date],
	GETDATE() as [Current Date],
	DIFF= DATEDIFF(DAY, EOMONTH(GETDATE(),0), GETDATE());