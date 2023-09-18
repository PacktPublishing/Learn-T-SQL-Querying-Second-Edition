-- Learn T-SQL Querying
-- Chapter 5 - Writing Elegant T-SQL Queries
-- Section - Inequality logic

SELECT BusinessEntityID, FirstName, LastName
FROM Person.Person
WHERE PersonType NOT IN ('EM','SP','IN','VC','GC');

SELECT BusinessEntityID, FirstName, LastName
FROM Person.Person
WHERE PersonType = 'SC';

CREATE NONCLUSTERED INDEX [IX_Person_PersonType] ON [Person].[Person] (
	[PersonType] ASC
)
INCLUDE ( 	
	[BusinessEntityID],
	[FirstName],
	[LastName]
);

