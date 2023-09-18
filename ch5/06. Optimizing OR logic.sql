-- Learn T-SQL Querying
-- Chapter 5 - Writing Elegant T-SQL Queries
-- Section - Optimizing OR logic

SELECT ProductID, [UnitPrice], [UnitPriceDiscount],
	[UnitPrice] * (1 - [UnitPriceDiscount]) AS FinalUnitPrice,
	[UnitPriceDiscount] + 0.10 AS NewUnitPriceDiscount,
	[UnitPrice] * (1 - 0.30) AS NewFinalUnitPrice
FROM Sales.SalesOrderDetail
WHERE ProductID = 770 
	OR UnitPrice = 3399.99
GROUP BY ProductID, [UnitPrice], [UnitPriceDiscount]

SELECT ProductID, [UnitPrice], [UnitPriceDiscount],
	[UnitPrice] * (1 - [UnitPriceDiscount]) AS FinalUnitPrice,
	[UnitPriceDiscount] + 0.10 AS NewUnitPriceDiscount,
	[UnitPrice] * (1 - 0.30) AS NewFinalUnitPrice
FROM Sales.SalesOrderDetail
WHERE ProductID = 770
GROUP BY ProductID, [UnitPrice], [UnitPriceDiscount]
UNION
SELECT ProductID, [UnitPrice], [UnitPriceDiscount],
	[UnitPrice] * (1 - [UnitPriceDiscount]) AS FinalUnitPrice,
	[UnitPriceDiscount] + 0.10 AS NewUnitPriceDiscount,
	[UnitPrice] * (1 - 0.30) AS NewFinalUnitPrice
FROM Sales.SalesOrderDetail
WHERE UnitPrice = 3399.99
GROUP BY ProductID, [UnitPrice], [UnitPriceDiscount];

CREATE NONCLUSTERED INDEX IX_UnitPrice ON [Sales].[SalesOrderDetail] (
	[UnitPrice]
)
INCLUDE (
	[ProductID],
	[UnitPriceDiscount]
);

CREATE NONCLUSTERED INDEX IX_SalesOrderDetail_ProductID ON [Sales].[SalesOrderDetail] (
	[ProductID] 
)
INCLUDE (
	[UnitPrice],
	[UnitPriceDiscount]
)
WITH DROP_EXISTING;
