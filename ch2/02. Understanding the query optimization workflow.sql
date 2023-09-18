-- Learn T-SQL Querying
-- Chapter 2 - Mechanics of the Query Optimizer
-- Section - Understanding the query optimization workflow

-- The Trivial Plan stage

-- -- SELECT ... INTO
SELECT NationalIDNumber, JobTitle, MaritalStatus 
	INTO HumanResources.Employee2 
	FROM HumanResources.Employee; 

-- -- INSERT ... INTO
INSERT INTO HumanResources.Employee2 
	SELECT NationalIDNumber, JobTitle, MaritalStatus 
	FROM HumanResources.Employee  
	WHERE BusinessEntityID < 10; 

-- -- INSERT ... VALUES
INSERT INTO HumanResources.Employee2 
VALUES (87656896, 'CIO', 'M');

-- Full Optimization
SELECT pp.FirstName, pp.LastName, pa.AddressLine1, pa.City, pa.PostalCode 
FROM Person.Address AS pa 
INNER JOIN Person.BusinessEntityAddress AS pbea ON pa.AddressID = pbea.AddressID 
INNER JOIN Person.Person AS pp ON pbea.BusinessEntityID = pp.BusinessEntityID 
WHERE pa.AddressID = 100; 

