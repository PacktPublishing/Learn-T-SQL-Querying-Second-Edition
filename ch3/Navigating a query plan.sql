-- Learn T-SQL Querying
-- Chapter 3 - Exploring Query Execution Plans
-- Section - Navigating a query plan

SELECT p.Title + ' ' + p.FirstName + ' ' + p.LastName AS FullName, 
	c.AccountNumber, s.Name AS StoreName
FROM Person.Person p
INNER JOIN Sales.Customer c ON c.PersonID = p.BusinessEntityID
INNER JOIN Sales.Store s ON s.BusinessEntityID = c.StoreID
WHERE p.LastName = 'Koski';

