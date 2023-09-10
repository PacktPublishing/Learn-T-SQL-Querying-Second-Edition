-- Learn T-SQL Querying
-- Chapter 3 - Exploring Query Execution Plans
-- Section - Query plan operators of interest

-- Table Scan
SELECT * FROM DatabaseLog;

-- Clustered Index Scan
SELECT * FROM Person.Person;

-- NonClustered Index Scan
SELECT LastName, FirstName
FROM Person.Person
WHERE FirstName = N'Andrew';

-- NonClustered Index Seek
SELECT LastName, FirstName
FROM Person.Person
WHERE LastName = N'Maxwell';

-- Clustered Index Seek
SELECT LastName, FirstName
FROM Person.Person
WHERE BusinessEntityID = 5;

-- RID Lookup
SELECT *
FROM DatabaseLog
WHERE DatabaseLogID = 5;

-- Key Lookup
SELECT *
FROM Person.Person
WHERE LastName = N'Maxwell';

-- Columnstore Index Scan
SELECT *
FROM FactResellerSalesXL_CCI
WHERE SalesAmount > 10000;

-- Nested Loops Join
SELECT p.LastName, p.FirstName, e.JobTitle
FROM Person.Person AS p 
LEFT JOIN HumanResources.Employee AS e ON p.BusinessEntityID = e.BusinessEntityID
WHERE p.LastName = N'Maxwell';

-- Merge Join
SELECT h.AccountNumber, d.ProductID, d.OrderQty
FROM Sales.SalesOrderHeader AS h
INNER JOIN Sales.SalesOrderDetail AS d ON h.SalesOrderID = d.SalesOrderID;

-- Hash Match Join
SELECT s.*, c.AverageRate
FROM FactResellerSales AS s
INNER JOIN FactCurrencyRate AS c ON c.CurrencyKey = s.CurrencyKey AND c.DateKey = s.OrderDateKey
OPTION (MAX_GRANT_PERCENT = 0.01);

-- Adaptive Join
USE [master]
GO
ALTER DATABASE [AdventureWorksDW] SET COMPATIBILITY_LEVEL = 140
GO

USE [AdventureWorksDW]
GO

SELECT s.ProductKey, SUM(s.OrderQuantity) AS SumOrderQuantity, 
	AVG(s.UnitPrice) AS AvgUnitPrice, AVG(s.DiscountAmount) AS AvgDiscountAmount, 
	c.AverageRate
FROM FactResellerSalesXL_CCI AS s 
INNER JOIN FactCurrencyRate AS c ON c.CurrencyKey = s.CurrencyKey AND c.DateKey = s.OrderDateKey
GROUP BY s.ProductKey, c.AverageRate
OPTION (FORCE ORDER);

-- Spools
SELECT WO.WorkOrderID, WO.ProductID, WO.OrderQty, WO.StockedQty, 
WO.ScrappedQty, WO.StartDate, WO.EndDate, WO.DueDate, 
WO.ScrapReasonID, WO.ModifiedDate, WOR.WorkOrderID, 
	WOR.ProductID, WOR.LocationID
FROM Production.WorkOrder AS WO 
LEFT JOIN Production.WorkOrderRouting AS WOR
ON WO.WorkOrderID = WOR.WorkOrderID AND WOR.WorkOrderID = 12345;

SELECT WO.WorkOrderID, WO.ProductID, WO.OrderQty, WO.StockedQty, WO.ScrappedQty, WO.StartDate, 
	WO.EndDate, WO.DueDate, WO.ScrapReasonID, WO.ModifiedDate, WOR.WorkOrderID, 
	WOR.ProductID, WOR.LocationID
FROM Production.WorkOrder AS WO LEFT JOIN Production.WorkOrderRouting AS WOR
ON WO.WorkOrderID = WOR.WorkOrderID 
AND WOR.WorkOrderID = 12345
OPTION (NO_PERFORMANCE_SPOOL);

-- Sorts
SELECT *
FROM FactResellerSalesXL_PageCompressed s
ORDER BY ProductKey;

-- Stream Aggregation
SELECT SalesOrderID, COUNT(*) AS ItemCount
FROM Sales.SalesOrderDetail
GROUP BY SalesOrderID;

-- Hash Aggregation
SELECT p.Name AS ProductName, SUM(OrderQty) AS TotalProductSales
FROM Sales.SalesOrderDetail sod
INNER JOIN Production.Product p on p.ProductID = sod.ProductID
GROUP BY p.Name;

