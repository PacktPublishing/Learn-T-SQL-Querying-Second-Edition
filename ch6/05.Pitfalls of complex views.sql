-- Learn T-SQL Querying
-- Chapter 6 - Discovering T-SQL Anti-patterns in Depth
-- Section - Pitfalls of complex views

CREATE OR ALTER VIEW [HumanResources].[vEmployeeNew]
AS 
SELECT e.[BusinessEntityID], p.[Title], p.[FirstName], p.[MiddleName],
	p.[LastName], p.[Suffix], e.[JobTitle], pp.[PhoneNumber],
	pnt.[Name] AS [PhoneNumberType], ea.[EmailAddress], p.[EmailPromotion],
	a.[AddressLine1], a.[AddressLine2], a.[City], sp.[Name] AS [StateProvinceName],
	a.[PostalCode], cr.[Name] AS [CountryRegionName] 
FROM [HumanResources].[Employee] AS e
INNER JOIN [Person].[Person] AS p
ON p.[BusinessEntityID] = e.[BusinessEntityID]
INNER JOIN [Person].[BusinessEntityAddress] AS bea 
ON bea.[BusinessEntityID] = e.[BusinessEntityID] 
INNER JOIN [Person].[Address] AS a 
ON a.[AddressID] = bea.[AddressID]
INNER JOIN [Person].[StateProvince] AS sp 
ON sp.[StateProvinceID] = a.[StateProvinceID]
INNER JOIN [Person].[CountryRegion] AS cr 
ON cr.[CountryRegionCode] = sp.[CountryRegionCode]
INNER JOIN [Person].[PersonPhone] AS pp
ON pp.BusinessEntityID = p.[BusinessEntityID]
INNER JOIN [Person].[PhoneNumberType] AS pnt
ON pp.[PhoneNumberTypeID] = pnt.[PhoneNumberTypeID]
INNER JOIN [Person].[EmailAddress] AS ea
ON p.[BusinessEntityID] = ea.[BusinessEntityID];

SELECT Title, FirstName, MiddleName, LastName, Suffix, JobTitle
FROM [HumanResources].[vEmployeeNew];

SELECT Title, FirstName, MiddleName, LastName, Suffix, JobTitle
FROM HumanResources.Employee AS e
INNER JOIN [Person].[Person] AS pp ON e.BusinessEntityID = pp.BusinessEntityID;

CREATE OR ALTER VIEW [HumanResources].[vEmployeeNew]
WITH SCHEMABINDING
AS 
SELECT e.[BusinessEntityID], p.[Title], p.[FirstName], p.[MiddleName],
	p.[LastName], p.[Suffix], e.[JobTitle], pp.[PhoneNumber],
	pnt.[Name] AS [PhoneNumberType], ea.[EmailAddress], p.[EmailPromotion],
	a.[AddressLine1], a.[AddressLine2], a.[City], sp.[Name] AS [StateProvinceName],
	a.[PostalCode], cr.[Name] AS [CountryRegionName] 
FROM [HumanResources].[Employee] AS e
INNER JOIN [Person].[Person] AS p
ON p.[BusinessEntityID] = e.[BusinessEntityID]
INNER JOIN [Person].[BusinessEntityAddress] AS bea 
ON bea.[BusinessEntityID] = e.[BusinessEntityID] 
INNER JOIN [Person].[Address] AS a 
ON a.[AddressID] = bea.[AddressID]
INNER JOIN [Person].[StateProvince] AS sp 
ON sp.[StateProvinceID] = a.[StateProvinceID]
INNER JOIN [Person].[CountryRegion] AS cr 
ON cr.[CountryRegionCode] = sp.[CountryRegionCode]
INNER JOIN [Person].[PersonPhone] AS pp
ON pp.BusinessEntityID = p.[BusinessEntityID]
INNER JOIN [Person].[PhoneNumberType] AS pnt
ON pp.[PhoneNumberTypeID] = pnt.[PhoneNumberTypeID]
INNER JOIN [Person].[EmailAddress] AS ea
ON p.[BusinessEntityID] = ea.[BusinessEntityID];

CREATE UNIQUE CLUSTERED INDEX IX_vEmployeeNew
ON [HumanResources].[vEmployeeNew] (
	[BusinessEntityID]
);

SELECT Title, FirstName, MiddleName, LastName, Suffix, JobTitle
FROM [HumanResources].[vEmployeeNew] WITH (NOEXPAND);

