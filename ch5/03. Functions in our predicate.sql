-- Learn T-SQL Querying
-- Chapter 5 - Writing Elegant T-SQL Queries
-- Section - Functions in our predicate

SELECT SalesOrderID, OrderDate 
FROM Sales.SalesOrderHeader
WHERE YEAR(OrderDate) = 2013 AND MONTH(OrderDate) = 7; 

CREATE NONCLUSTERED INDEX IX_OrderDate ON Sales.SalesOrderHeader ( 
	OrderDate 
);

DECLARE @start DATETIME = '07/01/2013', @end DATETIME = '07/31/2013'
SELECT SalesOrderID, OrderDate 
FROM Sales.SalesOrderHeader
WHERE OrderDate BETWEEN @start AND @end;

DECLARE @start DATETIME = '07/01/2013', @end DATETIME = '07/31/2013'
SELECT SalesOrderID, OrderDate 
FROM Sales.SalesOrderHeader
WHERE OrderDate BETWEEN @start AND @end
OPTION (RECOMPILE);

EXECUTE sp_executesql @stmt = N'SELECT SalesOrderID, OrderDate FROM Sales.SalesOrderHeader
WHERE OrderDate BETWEEN @start AND @end;'
			, @params = N'@start DATETIME, @end DATETIME'
			, @start = '07/01/2013', @end = '07/31/2013';


