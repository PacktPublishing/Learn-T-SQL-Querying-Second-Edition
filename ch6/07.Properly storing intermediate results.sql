-- Learn T-SQL Querying
-- Chapter 6 - Discovering T-SQL Anti-patterns in Depth
-- Section - Properly storing intermediate results

-- Using table variables and temporary tables
DECLARE @Sales_TV TABLE (
	SalesPersonID int NOT NULL, 
	TotalSales money, 
	SalesYear smallint
); 
-- Populate the first Table Variable
INSERT INTO @Sales_TV
SELECT SalesPersonID, SUM(TotalDue) AS TotalSales, 
	YEAR(OrderDate) AS SalesYear 
FROM Sales.SalesOrderHeader 
WHERE SalesPersonID IS NOT NULL 
GROUP BY SalesPersonID, YEAR(OrderDate);
-- Define the second Table Variable, which stores sales quota data by year for each salesperson. 
DECLARE @Sales_Quota_TV TABLE (
	BusinessEntityID int NOT NULL, 
	SalesQuota money, 
	SalesQuotaYear smallint
); 
INSERT INTO @Sales_Quota_TV
SELECT BusinessEntityID, SUM(SalesQuota) AS SalesQuota, 
	YEAR(QuotaDate) AS SalesQuotaYear 
FROM Sales.SalesPersonQuotaHistory 
GROUP BY BusinessEntityID, YEAR(QuotaDate) 
-- Define the outer query by referencing columns from both Table Variables. 
SELECT CONCAT(FirstName, ' ', LastName) AS SalesPerson, SalesYear, 
 FORMAT(TotalSales,'C','en-us') AS TotalSales, SalesQuotaYear, 
 FORMAT (SalesQuota,'C','en-us') AS SalesQuota, 
 FORMAT (TotalSales -SalesQuota, 'C','en-us') AS Amt_Above_or_Below_Quota 
FROM @Sales_TV AS Sales_TV 
INNER JOIN @Sales_Quota_TV AS Sales_Quota_TV 
	ON Sales_Quota_TV.BusinessEntityID = Sales_TV.SalesPersonID 
	AND Sales_TV.SalesYear = Sales_Quota_TV.SalesQuotaYear 
INNER JOIN Person.Person 
	ON Person.BusinessEntityID = Sales_Quota_TV.BusinessEntityID
ORDER BY SalesPersonID, SalesYear;

DROP TABLE IF EXISTS #Sales_TT;
CREATE TABLE #Sales_TT (
	SalesPersonID int NOT NULL, 
	TotalSales money, 
	SalesYear smallint
); 
-- Populate the first Temp Table
INSERT INTO #Sales_TT
SELECT SalesPersonID, SUM(TotalDue) AS TotalSales, 
	YEAR(OrderDate) AS SalesYear 
FROM Sales.SalesOrderHeader 
WHERE SalesPersonID IS NOT NULL 
GROUP BY SalesPersonID, YEAR(OrderDate);
-- Define the second Temp Table, which stores sales quota data by year for each sales person. 
DROP TABLE IF EXISTS #Sales_Quota_TT;
CREATE TABLE #Sales_Quota_TT (
	BusinessEntityID int NOT NULL, 
	SalesQuota money, 
	SalesQuotaYear smallint
); 
INSERT INTO #Sales_Quota_TT
SELECT BusinessEntityID, SUM(SalesQuota) AS SalesQuota, 
	YEAR(QuotaDate) AS SalesQuotaYear 
FROM Sales.SalesPersonQuotaHistory 
GROUP BY BusinessEntityID, YEAR(QuotaDate) 
-- Define the outer query by referencing columns from both Temp Tables. 
SELECT CONCAT(FirstName, ' ', LastName) AS SalesPerson, SalesYear, 
 FORMAT(TotalSales,'C','en-us') AS TotalSales, SalesQuotaYear, 
 FORMAT (SalesQuota,'C','en-us') AS SalesQuota, 
 FORMAT (TotalSales -SalesQuota, 'C','en-us') AS Amt_Above_or_Below_Quota 
FROM #Sales_TT AS Sales_TT 
INNER JOIN #Sales_Quota_TT AS Sales_Quota_TT 
	ON Sales_Quota_TT.BusinessEntityID = Sales_TT.SalesPersonID 
	AND Sales_TT.SalesYear = Sales_Quota_TT.SalesQuotaYear 
INNER JOIN Person.Person 
	ON Person.BusinessEntityID = Sales_Quota_TT.BusinessEntityID
ORDER BY SalesPersonID, SalesYear;

-- Using Common Table Expressions (CTEs)
WITH Sales_CTE (SalesPersonID, SalesOrderID, SalesYear)
AS 
( 
 SELECT SalesPersonID, SalesOrderID, YEAR(OrderDate) AS SalesYear 
 FROM Sales.SalesOrderHeader 
 WHERE SalesPersonID IS NOT NULL 
) 
SELECT SalesPersonID, COUNT(SalesOrderID) AS TotalSales, SalesYear 
FROM Sales_CTE 
GROUP BY SalesYear, SalesPersonID 
ORDER BY SalesPersonID, SalesYear; 
GO 
SELECT SalesPersonID, COUNT(SalesOrderID) AS TotalSales, 
YEAR(OrderDate) AS SalesYear 
FROM Sales.SalesOrderHeader 
WHERE SalesPersonID IS NOT NULL
GROUP BY YEAR(OrderDate), SalesPersonID 
ORDER BY SalesPersonID, SalesYear; 
GO

WITH Sales_CTE (SalesPersonID, TotalSales, SalesYear)
AS 
-- Define the first CTE query. 
( 
 SELECT SalesPersonID, SUM(TotalDue) AS TotalSales, 
		YEAR(OrderDate) AS SalesYear 
 FROM Sales.SalesOrderHeader 
 WHERE SalesPersonID IS NOT NULL 
 GROUP BY SalesPersonID, YEAR(OrderDate) 
) 
, 
-- Define the second CTE query, which returns sales quota data by year for each sales person. 
Sales_Quota_CTE (BusinessEntityID, SalesQuota, SalesQuotaYear) 
AS 
( 
	SELECT BusinessEntityID, SUM(SalesQuota) AS SalesQuota, 
		YEAR(QuotaDate) AS SalesQuotaYear 
	FROM Sales.SalesPersonQuotaHistory 
	GROUP BY BusinessEntityID, YEAR(QuotaDate) 
) 
-- Define the outer query by referencing columns from both CTEs and a Table. 
SELECT CONCAT(FirstName, ' ', LastName) AS SalesPerson, SalesYear, 
 FORMAT(TotalSales,'C','en-us') AS TotalSales, SalesQuotaYear, 
 FORMAT (SalesQuota,'C','en-us') AS SalesQuota, 
 FORMAT (TotalSales -SalesQuota, 'C','en-us') AS Amt_Above_or_Below_Quota 
FROM Sales_CTE 
INNER JOIN Sales_Quota_CTE 
ON Sales_Quota_CTE.BusinessEntityID = Sales_CTE.SalesPersonID 
	AND Sales_CTE.SalesYear = Sales_Quota_CTE.SalesQuotaYear 
INNER JOIN Person.Person 
ON Person.BusinessEntityID = Sales_Quota_CTE.BusinessEntityID
ORDER BY SalesPersonID, SalesYear;

SELECT WO.WorkOrderID, WO.ProductID, WO.OrderQty, WO.StockedQty, 
WO.ScrappedQty, WO.StartDate, WO.EndDate, WO.DueDate, 
WO.ScrapReasonID, WO.ModifiedDate, WOR.WorkOrderID, 
	WOR.ProductID, WOR.LocationID
FROM Production.WorkOrder AS WO 
LEFT JOIN Production.WorkOrderRouting AS WOR
ON WO.WorkOrderID = WOR.WorkOrderID AND WOR.WorkOrderID = 12345;

;WITH cte AS (
SELECT WorkOrderID, ProductID, LocationID 
FROM Production.WorkOrderRouting WHERE WorkOrderID = 12345
)
SELECT WO.WorkOrderID, WO.ProductID, WO.OrderQty, WO.StockedQty, 
WO.ScrappedQty, WO.StartDate, WO.EndDate, WO.DueDate, 
WO.ScrapReasonID, WO.ModifiedDate, WOR.WorkOrderID, 
	WOR.ProductID, WOR.LocationID
FROM Production.WorkOrder AS WO LEFT JOIN cte AS WOR
ON WO.WorkOrderID = WOR.WorkOrderID 
GO

