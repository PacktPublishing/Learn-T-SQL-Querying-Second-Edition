-- Learn T-SQL Querying
-- Chapter 4 - Indexing for T-SQL Performance
-- Section - Understanding Predicate SARGability

-- Predicate Pushdown
SELECT FirstName, LastName 
FROM Person.Person
WHERE LastName like 'S%'
AND FirstName = 'John';

SELECT FirstName, LastName 
FROM Person.Person 
WHERE LastName = 'Smith' 
AND FirstName like 'J%';

