-- Learn T-SQL Querying
-- Chapter 6 - Discovering T-SQL Anti-patterns in Depth
-- Section - Avoiding unnecessary sort operations

-- UNION ALL versus UNION
SELECT 'Customer' AS ContactType, p.FirstName, p.LastName, e.EmailAddress
FROM Sales.Customer c
INNER JOIN Person.Person p ON c.PersonID = p.BusinessEntityID
INNER JOIN Person.EmailAddress e ON e.BusinessEntityID = p.BusinessEntityID
WHERE EmailPromotion > 0
UNION
SELECT 'Vendor' AS ContactType, v.FirstName, v.LastName, v.EmailAddress
FROM Purchasing.vVendorWithContacts v
WHERE EmailPromotion > 0;

-- SELECT DISTINCT
SELECT c.Name AS Category, s.Name AS SubCategory
FROM Production.Product p
INNER JOIN Production.ProductSubcategory s 
ON p.ProductSubcategoryID = s.ProductSubcategoryID
INNER JOIN Production.ProductCategory c 
ON s.ProductCategoryID = c.ProductCategoryID
WHERE p.DiscontinuedDate IS NULL;

SELECT DISTINCT c.Name AS Category, s.Name AS SubCategory
FROM Production.Product p
INNER JOIN Production.ProductSubcategory s 
ON p.ProductSubcategoryID = s.ProductSubcategoryID
INNER JOIN Production.ProductCategory c 
ON s.ProductCategoryID = c.ProductCategoryID
WHERE p.DiscontinuedDate IS NULL;

SELECT c.Name AS Category, s.Name AS SubCategory
FROM Production.ProductSubcategory s 
INNER JOIN Production.ProductCategory c 
ON s.ProductCategoryID = c.ProductCategoryID
WHERE s.ProductSubcategoryID IN (SELECT ProductSubcategoryID 
					FROM Production.Product
					WHERE DiscontinuedDate IS NULL);

-- SELECT TOP 1 with ORDER BY
SELECT TOP 1 soh.CustomerID, SalesPersonID, SubTotal, OrderDate, cust.LastName as CustomerLastName, cust.FirstName as CustomerFirstName
FROM Sales.SalesOrderHeader soh
INNER JOIN sales.Customer c ON c.CustomerID = soh.CustomerID
LEFT JOIN Person.Person cust ON cust.BusinessEntityID = c.CustomerID
ORDER BY SubTotal DESC;

SELECT soh.CustomerID, SalesPersonID, SubTotal, OrderDate, cust.LastName as CustomerLastName, cust.FirstName as CustomerFirstName
FROM Sales.SalesOrderHeader soh
INNER JOIN sales.Customer c ON c.CustomerID = soh.CustomerID
LEFT JOIN Person.Person cust ON cust.BusinessEntityID = c.CustomerID
WHERE SubTotal = (SELECT MAX(SubTotal) FROM Sales.SalesOrderHeader);


