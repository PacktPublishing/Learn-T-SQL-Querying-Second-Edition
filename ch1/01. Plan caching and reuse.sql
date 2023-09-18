-- Learn T-SQL Querying
-- Chapter 1 - Understanding Query Processing
-- Section - Plan caching and reuse

-- Ad-hoc plan caching
EXECUTE (N'SELECT LastName, FirstName, MiddleName 
FROM Person.Person 
WHERE PersonType = N''EM'';');
GO

-- * Parameterization
DECLARE @PersonType AS nchar(2) = N'EM';
SELECT LastName, FirstName, MiddleName
FROM Person.Person 
WHERE PersonType = @PersonType;
GO

-- ** Simple parameterization
SELECT LastName, FirstName, MiddleName
FROM Person.Person
WHERE BusinessEntityID = 5;
GO

-- ** Forced parameterization
SELECT LastName, FirstName, MiddleName
FROM Person.Person
WHERE PersonType = N'EM' AND BusinessEntityID IN (5, 7, 13, 17, 19);
GO

-- * The sp_executesql procedure
EXECUTE sp_executesql @stmt = N'SELECT LastName, 
FirstName, MiddleName 
FROM Person.Person 
WHERE PersonType = @PersonType;',
@params = N'@PersonType nchar(2)',
@PersonType = N'EM';
GO
