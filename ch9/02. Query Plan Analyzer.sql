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

