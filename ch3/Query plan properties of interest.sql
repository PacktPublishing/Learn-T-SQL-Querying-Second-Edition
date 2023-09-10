-- Learn T-SQL Querying
-- Chapter 3 - Exploring Query Execution Plans
-- Section - Query plan properties of interest

-- Plan-level Properties
SELECT *
FROM Sales.SalesOrderDetail AS sod
INNER JOIN Production.Product AS p ON sod.ProductID = p.ProductID
ORDER BY Style DESC
OPTION (MAXDOP 1);

-- Set Options
SET ANSI_NULLS ON
GO
SELECT *
FROM Sales.SalesOrderDetail AS sod
INNER JOIN Production.Product AS p ON sod.ProductID = p.ProductID
WHERE SellEndDate = NULL
ORDER BY Style DESC
OPTION (MAXDOP 1);
GO

SET ANSI_NULLS OFF
GO
SELECT *
FROM Sales.SalesOrderDetail AS sod
INNER JOIN Production.Product AS p ON sod.ProductID = p.ProductID
WHERE SellEndDate = NULL
ORDER BY Style DESC
OPTION (MAXDOP 1);
GO

SET ANSI_NULLS ON
GO
SELECT *
FROM Sales.SalesOrderDetail AS sod
INNER JOIN Production.Product AS p ON sod.ProductID = p.ProductID
WHERE SellEndDate IS NULL
ORDER BY Style DESC
OPTION (MAXDOP 1);
GO

SET ANSI_NULLS OFF
GO

-- Query Time Stats
CREATE FUNCTION ufn_CategorizePrice (@Price money)
RETURNS NVARCHAR(50)
AS
BEGIN
	DECLARE @PriceCategory NVARCHAR(50)
	IF @Price < 100 SELECT @PriceCategory = 'Cheap'
	IF @Price BETWEEN 101 and 500 SELECT @PriceCategory = 'Mid Price'
	IF @Price BETWEEN 501 and 1000 SELECT @PriceCategory = 'Expensive'
	IF @Price > 1001 SELECT @PriceCategory = 'Unaffordable'
	RETURN @PriceCategory 
END;

SELECT dbo.ufn_CategorizePrice(UnitPrice), 
	SalesOrderID, SalesOrderDetailID, CarrierTrackingNumber, 
	OrderQty, ProductID, SpecialOfferID, UnitPrice, UnitPriceDiscount, 
	LineTotal, rowguid, ModifiedDate 
FROM Sales.SalesOrderDetail;

-- Missing Indexes
SELECT p.FirstName, p.LastName, c.AccountNumber
FROM Person.Person p
INNER JOIN Sales.Customer c ON c.PersonID = p.BusinessEntityID
WHERE p.FirstName = 'Robert';

-- Parameter List
CREATE OR ALTER PROCEDURE usp_SalesProds (@P1 NVARCHAR(10))
AS
SELECT *
FROM Sales.SalesOrderDetail AS sod
INNER JOIN Production.Product AS p ON sod.ProductID = p.ProductID
WHERE SalesOrderID = @P1
ORDER BY Style DESC
GO

EXEC usp_SalesProds @P1 = 49879
GO
EXEC usp_SalesProds @P1 = 48766
GO

DECLARE @P1 int; 
EXEC sp_prepare @P1 output, 
 N'@P1 int', 
 N'SELECT *
FROM Sales.SalesOrderDetail AS sod
INNER JOIN Production.Product AS p ON sod.ProductID = p.ProductID
WHERE SalesOrderID = @P1
ORDER BY Style DESC
OPTION (MAXDOP 1);'; 

SELECT @P1;
GO

EXEC sp_execute 1, N'49879'; 
GO

EXEC sp_execute 1, N'48766';
GO

EXEC sp_unprepare 1; 
GO

-- Plan Affecting Convert
CREATE TABLE #tmpSales (SalesOrderID CHAR(10) PRIMARY KEY CLUSTERED);
INSERT INTO #tmpSales
SELECT TOP 1000 SalesOrderID FROM Sales.SalesOrderHeader;
GO
SELECT * FROM #tmpSales WHERE SalesOrderID = 44360;

-- Unmatched Indexes
CREATE NONCLUSTERED INDEX FIProductAccessories ON Production.Product (ProductSubcategoryID, ListPrice) INCLUDE (Name )
WHERE ProductSubcategoryID >= 27 AND ProductSubcategoryID <= 36;
GO
DECLARE @i int = 33
SELECT Name, ProductSubcategoryID, ListPrice
FROM Production.Product
WHERE ProductSubcategoryID = @i AND ListPrice > 25.00;

SELECT Name, ProductSubcategoryID, ListPrice
FROM Production.Product
WHERE ProductSubcategoryID = 33 AND ListPrice > 25.00;

DECLARE @i int = 33, @sqlcmd NVARCHAR(500)
SELECT @sqlcmd = 'SELECT Name, ProductSubcategoryID, ListPrice FROM Production.Product WHERE ProductSubcategoryID = ' + CAST(@i AS NVARCHAR(5)) + ' AND ListPrice > 25.00;'
EXECUTE sp_executesql @sqlcmd;

-- Operator-Level Properties
SELECT *
FROM Sales.SalesOrderDetail AS sod
INNER JOIN Production.Product AS p ON sod.ProductID = p.ProductID
WHERE p.ProductID BETWEEN 850 AND 860
ORDER BY Style DESC
OPTION (USE HINT('ENABLE_PARALLEL_PLAN_PREFERENCE'));

-- Estimate Rows Without Row Goal
SELECT TOP (100) * 
FROM Sales.SalesOrderHeader AS s 
INNER JOIN Sales.SalesOrderDetail AS d ON s.SalesOrderID = d.SalesOrderID 
WHERE s.TotalDue > 1000;

-- Columns With No Statistics
USE [master]
GO
ALTER DATABASE [AdventureWorks] SET AUTO_CREATE_STATISTICS OFF
GO

SELECT [CarrierTrackingNumber]
FROM Sales.SalesOrderDetail
WHERE [OrderQty] > 10
ORDER BY OrderQty;
GO
ALTER DATABASE [AdventureWorks] SET AUTO_CREATE_STATISTICS ON
GO

-- No Join Predicate
SELECT * 
FROM Sales.SalesOrderHeader AS h, 
	Sales.SalesOrderDetail AS d,
	Production.Product AS p
WHERE h.SalesOrderID = 49879;

SELECT *
FROM Sales.SalesOrderHeader AS h
INNER JOIN Sales.SalesOrderDetail AS d ON h.SalesOrderID = d.SalesOrderID
INNER JOIN Production.Product AS p ON d.ProductId = p.ProductID
WHERE h.SalesOrderID = 49879;

