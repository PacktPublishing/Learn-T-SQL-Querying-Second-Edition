-- Learn T-SQL Querying
-- Chapter 5 - Writing Elegant T-SQL Queries
-- Section - The Perils of SELECT *

SELECT *
	FROM Sales.SalesOrderHeader AS h
	INNER JOIN Sales.SalesOrderDetail AS d ON h.SalesOrderID = d.SalesOrderID
	INNER JOIN Production.Product AS p ON d.ProductId = p.ProductID
	WHERE h.OrderDate BETWEEN '2013-02-28 00:00:00.000' 
AND '2013-03-30 00:00:00.000';

SELECT p.ProductLine, p.[Name], h.OrderDate, 
h.SalesOrderID, d.OrderQty, d.LineTotal, h.TotalDue
FROM Sales.SalesOrderHeader AS h
INNER JOIN Sales.SalesOrderDetail AS d ON h.SalesOrderID = d.SalesOrderID
INNER JOIN Production.Product AS p ON d.ProductId = p.ProductID
WHERE h.OrderDate BETWEEN '2013-02-28 00:00:00.000' AND '2013-03-30 00:00:00.000';

CREATE NONCLUSTERED INDEX IX_OrderDate_TotalDue ON [Sales].[SalesOrderHeader] (
	[OrderDate]
)
INCLUDE ([TotalDue]);

CREATE NONCLUSTERED INDEX IX_SalesOrderID_ProductID_OrderQty_LineTotal ON [Sales].[SalesOrderDetail] (
	[SalesOrderID], 
	[ProductID]
)
INCLUDE (
	[OrderQty], 
	[LineTotal]
);
