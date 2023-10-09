-- Learn T-SQL Querying
-- Chapter 9 - Comparative analysis of Query Plans
-- Section - Query Plan Analyzer

CREATE OR ALTER PROCEDURE usp_SalesTracking @UpdatedOn datetime
AS 
SET NOCOUNT ON;
SELECT *
FROM Sales.SalesOrderHeader AS soh 
INNER JOIN Sales.OrderTracking AS ot ON ot.SalesOrderID = soh.SalesOrderID
WHERE ot.EventDateTime >= @UpdatedOn;
GO

CREATE OR ALTER PROCEDURE usp_SalesTracking_Test @UpdatedOn datetime
AS 
SET NOCOUNT ON;
SELECT *
FROM Sales.SalesOrderHeader AS soh 
INNER JOIN Sales.OrderTracking AS ot ON ot.SalesOrderID = soh.SalesOrderID
WHERE ot.EventDateTime >= @UpdatedOn;
GO

EXECUTE usp_SalesTracking_Test '2014-6-30 00:00:00'
GO

ALTER DATABASE SCOPED CONFIGURATION SET PARAMETER_SNIFFING = OFF;
DBCC TRACEON (4136, -1);
