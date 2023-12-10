-- Learn T-SQL Querying
-- Chapter 6 - Discovering T-SQL Anti-patterns in Depth
-- Section - Implicit conversions

CREATE TABLE [Production].[Product_Narrow](
	[ProductID] [int] NOT NULL,
	[Name] [varchar](50) NOT NULL,
	[ProductNumber] [varchar](25) NOT NULL,
	[Color] [varchar](15) NULL,
	[StandardCost] [money] NOT NULL,
	[ListPrice] [money] NOT NULL,
	[Size] [varchar](5) NULL,
	[SizeUnitMeasureCode] [char](3) NULL,
	[WeightUnitMeasureCode] [char](3) NULL,
	[Weight] [decimal](8, 2) NULL,
	[Class] [char](2) NULL,
	[Style] [char](2) NULL,
	[ProductSubcategoryID] [int] NULL,
	[ProductModelID] [int] NULL,
 CONSTRAINT [PK_Product_Narrow_ProductID] PRIMARY KEY CLUSTERED (
	[ProductID] ASC
));
GO

INSERT Production.Product_Narrow 
		(ProductID, Name, ProductNumber, Color, StandardCost, ListPrice, Size, SizeUnitMeasureCode
		, WeightUnitMeasureCode, Weight, Class, Style, ProductSubcategoryID, ProductModelID)
SELECT ProductID, Name, ProductNumber, Color, StandardCost, ListPrice, Size, SizeUnitMeasureCode
		, WeightUnitMeasureCode, Weight, Class, Style, ProductSubcategoryID, ProductModelID
FROM Production.Product;
CREATE UNIQUE NONCLUSTERED INDEX [AK_Product_Narrow_Name] ON [Production].[Product_Narrow]
(
	[Name] ASC
);

EXEC sp_executesql N'SELECT ProductID, Name, ListPrice, StandardCost
FROM Production.Product
	WHERE Name = @ProductName'
		, N'@ProductName VARCHAR(50)', 'Long-Sleeve Logo Jersey, XL';

EXEC sp_executesql N'SELECT ProductID, Name, ListPrice, StandardCost
			FROM Production.Product
			WHERE Name = @ProductName'
			, N'@ProductName nvarchar(50)', N'Long-Sleeve Logo Jersey, XL';

EXEC sp_executesql N'SELECT ProductID, Name, ListPrice, StandardCost
			FROM Production.Product_Narrow
			WHERE Name = @ProductName'
			, N'@ProductName nvarchar(50)', N'Long-Sleeve Logo Jersey, XL';

EXEC sp_executesql N'SELECT ProductID, Name, ListPrice, StandardCost
			FROM Production.Product_Narrow
			WHERE Name = @ProductName'
			, N'@ProductName varchar(50)', 'Long-Sleeve Logo Jersey, XL';

