-- Learn T-SQL Querying
-- Chapter 9 - Comparative analysis of Query Plans
-- Section - Query Plan Comparison

CREATE OR ALTER PROCEDURE usp_GetSalesOrderDetailToDate @FromDate DATETIME
AS
SET NOCOUNT ON;
SELECT TOP 1500 h.SalesOrderID, h.RevisionNumber, h.OrderDate, 
	h.OnlineOrderFlag, h.PurchaseOrderNumber, h.DueDate, 
	h.ShipDate, h.Status, h.AccountNumber, h.CustomerID
FROM Sales.SalesOrderHeader AS h 
INNER JOIN Sales.SalesOrderDetail AS d ON h.SalesOrderID = d.SalesOrderID 
WHERE h.OrderDate >= @FromDate;

SELECT TOP 100 h.SalesOrderID, h.RevisionNumber, h.OrderDate, 
	h.OnlineOrderFlag, h.PurchaseOrderNumber, h.DueDate, 
	h.ShipDate, h.Status, h.AccountNumber, h.CustomerID 
FROM Sales.SalesOrderHeader AS h 
INNER JOIN Sales.SalesOrderDetail AS d ON h.SalesOrderID = d.SalesOrderID 
WHERE h.TotalDue > 1000;
GO

EXECUTE usp_GetSalesOrderDetailToDate '2014-3-28 00:00:00'
GO

ALTER DATABASE SCOPED CONFIGURATION CLEAR PROCEDURE_CACHE;
GO
EXEC usp_GetSalesOrderDetailToDate '2014-5-28 00:00:00'
GO
ALTER DATABASE SCOPED CONFIGURATION CLEAR PROCEDURE_CACHE;
GO
EXEC usp_GetSalesOrderDetailToDate '2013-5-28 00:00:00'
GO

ALTER PROCEDURE usp_GetSalesOrderDetailToDate @FromDate DATETIME
AS
SET NOCOUNT ON;
SELECT TOP 1500 h.SalesOrderID, h.RevisionNumber, h.OrderDate, 
	h.OnlineOrderFlag, h.PurchaseOrderNumber, h.DueDate, 
	h.ShipDate, h.Status, h.AccountNumber, h.CustomerID
FROM Sales.SalesOrderHeader AS h 
INNER JOIN Sales.SalesOrderDetail AS d ON h.SalesOrderID = d.SalesOrderID 
WHERE h.OrderDate >= @FromDate
OPTION (USE HINT('DISABLE_OPTIMIZER_ROWGOAL'));

SELECT TOP 100 h.SalesOrderID, h.RevisionNumber, h.OrderDate, 
	h.OnlineOrderFlag, h.PurchaseOrderNumber, h.DueDate, 
	h.ShipDate, h.Status, h.AccountNumber, h.CustomerID
FROM Sales.SalesOrderHeader AS h 
INNER JOIN Sales.SalesOrderDetail AS d ON h.SalesOrderID = d.SalesOrderID 
WHERE h.TotalDue > 1000;
GO

ALTER DATABASE SCOPED CONFIGURATION CLEAR PROCEDURE_CACHE;
GO

EXECUTE usp_GetSalesOrderDetailToDate '2014-3-28 00:00:00';
GO

SELECT t.name AS TableName, i.name AS IndexName, 
	i.type_desc, p.rows, a.total_pages, a.used_pages, 
	CONVERT(DECIMAL(19,2),ISNULL(a.used_pages,0))*8/1024 AS DataSizeMB,
	ips.index_depth, ips.avg_record_size_in_bytes
FROM sys.allocation_units AS a
INNER JOIN sys.partitions AS p ON p.hobt_id = a.container_id AND a.type = 1
INNER JOIN sys.indexes AS i ON i.object_id = p.object_id 
	AND i.index_id = p.index_id 
INNER JOIN sys.tables AS t ON t.object_id = p.object_id
CROSS APPLY sys.dm_db_index_physical_stats (DB_ID(), p.object_id, i.index_id, NULL, 'SAMPLED') AS ips
WHERE t.name = 'SalesOrderDetail';
GO
