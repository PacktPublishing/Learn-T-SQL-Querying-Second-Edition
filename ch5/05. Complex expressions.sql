-- Learn T-SQL Querying
-- Chapter 5 - Writing Elegant T-SQL Queries
-- Section - Complex expressions

SELECT ProductID, [UnitPrice], [UnitPriceDiscount],
	[UnitPrice] * (1 - [UnitPriceDiscount]) AS FinalUnitPrice,
	[UnitPriceDiscount] + 0.10 AS NewUnitPriceDiscount,
	[UnitPrice] * (1 - 0.30) AS NewFinalUnitPrice
FROM Sales.SalesOrderDetail
WHERE [UnitPriceDiscount] + 0.10 <= 0.30
GROUP BY ProductID, [UnitPrice], [UnitPriceDiscount];

SELECT ProductID, [UnitPrice], [UnitPriceDiscount],
	[UnitPrice] * (1 - [UnitPriceDiscount]) AS FinalUnitPrice,
	[UnitPriceDiscount] + 0.10 AS NewUnitPriceDiscount,
	[UnitPrice] * (1 - 0.30) AS NewFinalUnitPrice
FROM Sales.SalesOrderDetail 
WHERE [UnitPriceDiscount] <= 0.20
GROUP BY ProductID, [UnitPrice], [UnitPriceDiscount];

CREATE NONCLUSTERED INDEX IX_UnitePriceDiscount ON [Sales].[SalesOrderDetail] (
	[UnitPriceDiscount]
)
INCLUDE (
	[ProductID],
	[UnitPrice]
);
