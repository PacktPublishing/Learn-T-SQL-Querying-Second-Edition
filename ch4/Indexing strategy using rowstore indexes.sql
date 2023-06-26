-- Learn T-SQL Querying
-- Chapter 4 - Indexing for T-SQL Performance
-- Section - Indexing strategy using rowstore indexes

-- Best practices for non-clustered indexes
-- -- Key column order
SELECT LastName, FirstName, MiddleName, BusinessEntityID
FROM Person.Person
WHERE LastName = N'Smith';

SELECT LastName, FirstName, MiddleName, BusinessEntityID
FROM Person.Person
WHERE FirstName = N'John';

SELECT LastName, FirstName, MiddleName, BusinessEntityID
FROM Person.Person
WHERE FirstName = N'John' and LastName = N'Smith';

CREATE NONCLUSTERED INDEX IX_Person_LastName 
ON Person.Person (LastName)
INCLUDE(FirstName, MiddleName);

SELECT LastName, FirstName, MiddleName, BusinessEntityID
FROM Person.Person
WITH (INDEX (IX_Person_LastName))
WHERE FirstName = N'John' AND LastName = N'Smith';

SELECT LastName, FirstName, MiddleName, BusinessEntityID
FROM Person.Person
WHERE PersonType = N'SP' 
AND LastName LIKE N'S%';

CREATE NONCLUSTERED INDEX IX_Person_LastName_PersonType 
ON Person.Person (LastName , PersonType);

SET STATISTICS IO ON;

CREATE NONCLUSTERED INDEX IX_Person_PersonType_LastName 
ON Person.Person (PersonType, LastName);

-- -- Covering indexes
SELECT LastName, FirstName, MiddleName, BusinessEntityID
FROM Person.Person
WHERE PersonType = N'SP' 
AND LastName LIKE N'S%';

CREATE NONCLUSTERED INDEX IX_Person_PersonType_LastName 
ON Person.Person (PersonType, LastName)
INCLUDE (FirstName, MiddleName)
WITH (DROP_EXISTING = ON);

-- -- Filtered Indexes
SELECT ProductAssemblyID, p.Name AS ProductName, ComponentID, comp.Name AS DiscontinuedComponent, StartDate, EndDate
FROM Production.BillOfMaterials AS bom 
	LEFT JOIN Production.Product AS p ON bom.ProductAssemblyID = p.ProductID
	LEFT JOIN Production.Product AS comp ON bom.ComponentID = comp.ProductID
WHERE EndDate IS NOT NULL
AND StartDate BETWEEN '01/01/2010' AND '12/31/2010';

CREATE NONCLUSTERED INDEX IX_BillOfMaterials_StartDate_EndDate 
ON Production.BillOfMaterials (StartDate, EndDate);

CREATE NONCLUSTERED INDEX IX_BillOfMaterials_StartDate_Filtered 
ON Production.BillOfMaterials (StartDate) 
INCLUDE (EndDate) 
WHERE (EndDate IS NOT NULL);



