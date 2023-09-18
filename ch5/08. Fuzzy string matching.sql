-- Learn T-SQL Querying
-- Chapter 5 - Writing Elegant T-SQL Queries
-- Section - Fuzzy string matching

SELECT ProductID, Name AS ProductName, ProductNumber
FROM Production.Product
WHERE Name LIKE '%Flat Washer%';

SELECT ProductID, Name AS ProductName, ProductNumber
FROM Production.Product
WHERE Name LIKE 'Flat Washer%';

