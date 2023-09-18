-- Learn T-SQL Querying
-- Chapter 5 - Writing Elegant T-SQL Queries
-- Section - NULL means unknown

SELECT p.ProductID,
p.Name AS ProductName,
c.Name AS Category,
s.Name AS SubCategory
FROM Production.Product p
LEFT JOIN Production.ProductSubcategory s 
ON p.ProductSubcategoryID = s.ProductSubcategoryID
INNER JOIN Production.ProductCategory c 
ON ISNULL(s.ProductCategoryID, 5) = c.ProductCategoryID
ORDER BY Category, SubCategory;

SELECT p.ProductID,
p.Name AS ProductName,
ISNULL(c.Name, 'Parts') AS Category,
s.Name AS SubCategory
FROM Production.Product p
LEFT JOIN Production.ProductSubcategory s 
ON p.ProductSubcategoryID = s.ProductSubcategoryID
INNER JOIN Production.ProductCategory c 
ON s.ProductCategoryID = c.ProductCategoryID
ORDER BY Category, SubCategory;

CREATE NONCLUSTERED INDEX [IX_Product_ProductSubcategoryID] ON [Production].[Product] (
	[ProductSubcategoryID]
)
INCLUDE (
[Name]
);

