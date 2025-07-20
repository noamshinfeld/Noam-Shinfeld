--1
with cte 
as 
(select year(orderDate) as year, count(distinct month(orderDate)) as numberOfDistinctMonth,
	sum(Quantity*UnitPrice) as incomePerYear,
	(sum(Quantity*UnitPrice))/(count(distinct month(orderDate)))*12 as linearYearIncome
from [Sales].[Invoices] as i inner join [Sales].[InvoiceLines] as il
	on i.InvoiceID = il.InvoiceID inner join [Sales].[Orders] as o
	on i.OrderID = o.OrderID
group by year(orderDate))

select *,
(linearYearIncome / lag(linearYearIncome) over (order by year)-1)*100 as growthRate
from cte

--2
select * 
from
	(select year,Quarter,StockItemName,income,
	DENSE_RANK() over (partition by Quarter,year order by income desc) as DR
	from
		(select year(orderDate) as year, DATEPART(QUARTER,orderDate) AS Quarter, StockItemName, 
			   sum(il.Quantity*il.UnitPrice) as income
		from [Sales].[Invoices] as i inner join [Sales].[InvoiceLines] as il
			on i.InvoiceID = il.InvoiceID inner join [Sales].[Orders] as o
			on i.OrderID = o.OrderID inner join [Warehouse].[StockItems] as SI
			on SI.StockItemID = il.StockItemID
		group by  year(orderDate), DATEPART(QUARTER,orderDate), StockItemName) as a) as b
where b.DR <=5
order by 1,2

--3
select Top 10
si.StockItemID, si.StockItemName, sum(il.ExtendedPrice - il.TaxAmount) AS TotalProfit
from Sales.InvoiceLines as il inner join Warehouse.StockItems as si on il.StockItemID = si.StockItemID
GROUP BY si.StockItemID,si.StockItemName
ORDER BY TotalProfit DESC

--4
SELECT ROW_NUMBER() OVER (ORDER BY (RecommendedRetailPrice - UnitPrice) DESC) AS Rank,
StockItemID, StockItemName,RecommendedRetailPrice, UnitPrice, (RecommendedRetailPrice - UnitPrice) AS NominalProfit,
DENSE_RANK() OVER (ORDER BY (RecommendedRetailPrice - UnitPrice) DESC) AS DNR
FROM Warehouse.StockItems
WHERE ValidTo > GETDATE()
ORDER BY NominalProfit DESC;

--5
SELECT CONCAT(S.SupplierID, ' - ', S.SupplierName) AS SupplierDetails,
STRING_AGG(CONCAT(SI.StockItemID, ' ', SI.StockItemName), ' /,') AS ProductDetails
FROM Purchasing.Suppliers S INNER JOIN Warehouse.StockItems SI
ON S.SupplierID = SI.SupplierID
GROUP BY S.SupplierID, S.SupplierName
ORDER BY S.SupplierID;

--6
select Top 5
cust.CustomerID, CityName, CountryName, Continent, Region, sum(il.ExtendedPrice) as TotalExtendedPrice
from Sales.Customers as cust inner join Application.Cities as city on cust.DeliveryCityID = city.CityID
inner join Application.StateProvinces as st on city.StateProvinceID = st.StateProvinceID
inner join Application.Countries as co on st.CountryID = co.CountryID
inner join Sales.Invoices as i on cust.CustomerID = i.CustomerID
inner join Sales.InvoiceLines as il on i.InvoiceID = il.InvoiceID
group by cust.CustomerID, CityName, CountryName, Continent, Region
order by TotalExtendedPrice DESC;

--7
select*
from
(select OrderYear, convert(nvarchar,OrderMonth) as OrderMonth, format(MonthlyTotal,'N2') as MonthlyTotal, format(CumulativeTotal,'N2') as CumulativeTotal
from
(select *, sum(MonthlyTotal) over(partition by orderyear order by ordermonth rows between unbounded preceding and current row) as CumulativeTotal
from
(select year(orderdate) as OrderYear, month(orderdate) as OrderMonth, sum(Quantity*UnitPrice) as MonthlyTotal
from Sales.Orders o inner join Sales.Invoices i on o.OrderID=i.OrderID
		inner join Sales.InvoiceLines il on i.InvoiceID=il.InvoiceID
group by year(orderdate),  month(orderdate))a)b
union all
select OrderYear, OrderMonth, format(MonthlyTotal,'N2') as MonthlyTotal, format(CumulativeTotal,'N2') as CumulativeTotal
from
(select distinct OrderYear, 'Grand Total' as OrderMonth, sum(MonthlyTotal) over(partition by orderyear) as MonthlyTotal, sum(MonthlyTotal) over(partition by orderyear) as CumulativeTotal
from
(select year(orderdate) as OrderYear, month(orderdate) as OrderMonth, sum(Quantity*UnitPrice) as MonthlyTotal
from Sales.Orders o inner join Sales.Invoices i on o.OrderID=i.OrderID
		inner join Sales.InvoiceLines il on i.InvoiceID=il.InvoiceID
group by year(orderdate),  month(orderdate))a)b)c
order by OrderYear, case 
					when isnumeric(OrderMonth) = 1 then cast(OrderMonth as int)
					else 13 end

--8
SELECT 
    MONTH(OrderDate) AS OrderMonth,
    SUM(CASE WHEN YEAR(OrderDate) = 2013 THEN 1 ELSE 0 END) AS [2013],
    SUM(CASE WHEN YEAR(OrderDate) = 2014 THEN 1 ELSE 0 END) AS [2014],
    SUM(CASE WHEN YEAR(OrderDate) = 2015 THEN 1 ELSE 0 END) AS [2015],
    SUM(CASE WHEN YEAR(OrderDate) = 2016 THEN 1 ELSE 0 END) AS [2016]
FROM 
    Sales.Orders
GROUP BY 
    MONTH(OrderDate)
ORDER BY MONTH(OrderDate);

--9
WITH cte AS (
    SELECT 
        o.CustomerID,
        c.CustomerName, 
        OrderDate,
        LAG(OrderDate) OVER (PARTITION BY o.CustomerID ORDER BY OrderDate) AS prevOrder,
        MAX(OrderDate) OVER (PARTITION BY o.CustomerID) AS lastOrder,
        MAX(OrderDate) OVER () AS LastAllOrder,
        DATEDIFF(day, LAG(OrderDate) OVER (PARTITION BY o.CustomerID ORDER BY OrderDate), OrderDate) AS daysSinceLastOrder,
        DATEDIFF(day, MAX(OrderDate) OVER (PARTITION BY o.CustomerID), MAX(OrderDate) OVER ()) AS diff
    FROM sales.Customers AS c 
    INNER JOIN Sales.Orders AS o ON c.CustomerID = o.CustomerID
) 
SELECT 
    CustomerID,
    CustomerName,
    OrderDate,
    prevOrder, 
    diff,
    AVG(daysSinceLastOrder) OVER (PARTITION BY CustomerID) AS avgDaysBetweenOrders,
    CASE 
        WHEN AVG(daysSinceLastOrder) OVER (PARTITION BY CustomerID) > diff THEN 'active' 
        ELSE 'potential churn' 
    END AS status
FROM cte
WHERE CustomerID IN (24, 25)  -- שינוי ל-IN כדי לסנן רשימה של ערכים
ORDER BY 1;

--10
select *, FORMAT(CAST(customerCount AS DECIMAL(5, 2)) / totalCustCount * 100.0, 'N2') + '%' AS DistributionFactor
from 
(select CustomerCategoryName,count(distinct customerName) as customerCount,
sum(count(distinct customerName)) over () as totalCustCount
from
(select cc.CustomerCategoryName,case when CustomerName like 'Wingtip%' then 'Wingtip'
		when CustomerName like 'tailspin%' then 'tailspin'
		else CustomerName end as customerName
from sales.CustomerCategories as cc inner join sales.Customers as c
on cc.CustomerCategoryID = c.CustomerCategoryID) as a
group by CustomerCategoryName) as b

