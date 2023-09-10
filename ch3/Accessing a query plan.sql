-- Learn T-SQL Querying
-- Chapter 3 - Exploring Query Execution Plans
-- Section - Accessing a query plan

SELECT pp.FirstName, pp.LastName, pa.AddressLine1, pa.City, pa.PostalCode
FROM Person.Address AS pa
INNER JOIN Person.BusinessEntityAddress AS pbea ON pa.AddressID = pbea.AddressID
INNER JOIN Person.Person AS pp ON pbea.BusinessEntityID = pp.BusinessEntityID
WHERE pa.AddressID = 100;