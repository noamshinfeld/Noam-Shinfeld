--1
select top 5 
    p.[Name] AS ProductName, SUM(sod.LineTotal) AS TotalSales
from SalesOrderDetail sod
inner join Product p ON sod.ProductID = p.ProductID
group by p.[Name]
order by TotalSales DESC

--2
select pc.[Name] as CategoryName, AVG(sod.unitprice) as AvgUnitePrice
from SalesOrderDetail sod
inner join Product p on sod.ProductID = p.ProductID
inner join ProductSubcategory psc on p.ProductSubcategoryID = psc.ProductSubcategoryID
inner join ProductCategory pc on psc.ProductCategoryID = pc.ProductCategoryID
where pc.[Name] in ('bike', 'components')
group by pc.[Name]
order by AvgUnitePrice DESC

--3
select p.[Name], SUM(sod.OrderQty) as TotalQtyOrder
from SalesOrderDetail sod
inner join Product p on sod.ProductID = p.productID
inner join ProductSubcategory psc on p.ProductSubcategoryID = psc.ProductSubcategoryID
inner join ProductCategory pc on psc.ProductCategoryID = pc.ProductCategoryID
where pc.[Name] not in ('Clothing', 'components')
group by p.[Name]

--4
select top 3
soh.TerritoryID, SUM(soh.TotalDue) as SumOfTotalDue
from SalesTerritory st
inner join SalesOrderHeader soh on st.TerritoryID = soh.TerritoryID
group by soh.TerritoryID
order by SUM(soh.TotalDue) desc


--5
select c.CustomerID, firstName+' '+lastName as FullName 
from Customer c left join Person p on c.CustomerID = p.BusinessEntityID
where c.CustomerID not in(select soh.CustomerID from SalesOrderHeader soh)
order by CustomerID

--6
DELETE from SalesTerritory
where TerritoryID not in (select distinct TerritoryID from SalesPerson)

--7
insert into SalesTerritory (TerritoryID, [Name], CountryRegionCode, [Group], SalesYTD, SalesLastYear,CostYTD,CostLastYear,rowguid,ModifiedDate)
select  TerritoryID,[Name], CountryRegionCode, [Group], SalesYTD, SalesLastYear,CostYTD,CostLastYear,rowguid,ModifiedDate
from SalesTerritory
where TerritoryID not in (select TerritoryID from SalesTerritory)

--8
select c.CustomerID, FirstName+' '+LastName as FullName, COUNT(soh.salesOrderID) as OrderCount
from Customer c
inner join Person p on c.PersonID = p.BusinessEntityID
inner join SalesOrderHeader soh on c.CustomerID = soh.CustomerID
group by c.CustomerID, FirstName,LastName
having COUNT(soh.salesOrderID) > 20

--9
select [groupName], COUNT(DepartmentID) as DepartmentCount
from Department
group by [groupName]
having COUNT(DepartmentID) > 2 

--10
select e.BusinessEntityID, FirstName+' '+LastName, d.[Name] as DepName, s.[Name] as ShiftType, edh.StartDate
from EmployeeDepartmentHistory edh
inner join Department d on edh.DepartmentID = d.DepartmentID
inner join [Shift] s on edh.ShiftID = s.ShiftID
inner join Employee e on edh.BusinessEntityID = e.BusinessEntityID
inner join Person p on e.BusinessEntityID = p.BusinessEntityID
where edh.StartDate > '2010' and d.[GroupName] in ('quality assurance', 'Manufacturing')