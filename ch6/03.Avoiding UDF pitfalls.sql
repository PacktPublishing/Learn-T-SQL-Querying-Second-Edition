-- Learn T-SQL Querying
-- Chapter 6 - Discovering T-SQL Anti-patterns in Depth
-- Section - Avoiding UDF pitfalls

CREATE FUNCTION ufn_CategorizePrice (@Price money)
RETURNS NVARCHAR(50)
AS
BEGIN
	DECLARE @PriceCategory NVARCHAR(50)
	IF @Price < 100 SELECT @PriceCategory = 'Cheap'
	ELSE IF @Price BETWEEN 101 and 500 SELECT @PriceCategory = 'Mid Price'
	ELSE IF @Price BETWEEN 501 and 1000 SELECT @PriceCategory = 'Expensive'
	ELSE IF @Price > 1001 SELECT @PriceCategory = 'Unaffordable'
	RETURN @PriceCategory 
END;

SELECT dbo.ufn_CategorizePrice(UnitPrice), 
	SalesOrderID, SalesOrderDetailID, CarrierTrackingNumber, 
	OrderQty, ProductID, SpecialOfferID, UnitPrice, UnitPriceDiscount, 
	LineTotal, rowguid, ModifiedDate 
FROM Sales.SalesOrderDetail;

-- Object accesses system data, system catalogs or virtual system tables, in the local instance of SQL Server?
SELECT OBJECTPROPERTYEX(OBJECT_id('dbo.ufn_CategorizePrice'), 'SystemDataAccess') AS AccessesSystemData
-- Object accesses user data, user tables, in the local instance of SQL Server?
SELECT OBJECTPROPERTYEX(OBJECT_id('dbo.ufn_CategorizePrice'), 'UserDataAccess') AS AccessesUserData
-- The precision and determinism properties of the object can be verified by SQL Server?
SELECT OBJECTPROPERTYEX(OBJECT_id('dbo.ufn_CategorizePrice'), 'IsSystemVerified') AS HasBeenSystemVerified
GO

CREATE OR ALTER FUNCTION ufn_CategorizePrice (@Price money)
RETURNS NVARCHAR(50)
WITH SCHEMABINDING
AS
BEGIN
	DECLARE @PriceCategory NVARCHAR(50)
	IF @Price < 100 SELECT @PriceCategory = 'Cheap'
	ELSE IF @Price BETWEEN 101 and 500 SELECT @PriceCategory = 'Mid Price'
	ELSE IF @Price BETWEEN 501 and 1000 SELECT @PriceCategory = 'Expensive'
	ELSE IF @Price > 1001 SELECT @PriceCategory = 'Unaffordable'
	RETURN @PriceCategory 
END;

SELECT OBJECTPROPERTY(object_id, 'IsDeterministic'),
	OBJECTPROPERTY(object_id, 'IsSystemVerified'),
	OBJECTPROPERTY(object_id, 'SystemDataAccess'),
	OBJECTPROPERTY(object_id, 'UserDataAccess'),
	OBJECTPROPERTY(object_id, 'IsSystemVerified')
FROM sys.objects WHERE name = 'ufn_CategorizePrice';

CREATE OR ALTER FUNCTION dbo.ufn_GetTotalQuantity (@SalesOrderID INT)
RETURNS INT
WITH SCHEMABINDING
AS
BEGIN
DECLARE @Qty INT
SELECT @Qty = SUM(OrderQty)
FROM Sales.SalesOrderDetail
WHERE SalesOrderID = @SalesOrderID
RETURN (@Qty)
END;
GO

SELECT TOP 5000 *, 
	dbo.ufn_GetTotalQuantity (SalesOrderID) AS TotalQty
FROM Sales.SalesOrderHeader;

SELECT is_inlineable, inline_type
FROM sys.sql_modules 
WHERE object_id = OBJECT_ID('ufn_CategorizePrice');

