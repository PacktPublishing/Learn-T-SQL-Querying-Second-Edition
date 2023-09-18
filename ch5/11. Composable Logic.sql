-- Learn T-SQL Querying
-- Chapter 5 - Writing Elegant T-SQL Queries
-- Section - Composable Logic

CREATE OR ALTER PROCEDURE usp_GetSalesPersonOrders @SalesPerson INT NULL
AS
BEGIN
	SELECT SalesOrderID,
p.FirstName AS SalesFirstName,
p.LastName AS SalesLastName
	FROM Sales.SalesOrderHeader AS soh
	LEFT JOIN Person.Person AS p ON soh.SalesPersonID = p.BusinessEntityID
	WHERE @SalesPerson IS NULL OR SalesPersonID = @SalesPerson;
END;

SELECT SalesOrderID, p.FirstName as SalesFirstName, p.LastName as SalesLastName
FROM Sales.SalesOrderHeader AS soh
LEFT JOIN Person.Person AS p ON soh.SalesPersonID = p.BusinessEntityID
WHERE SalesPersonID = @SalesPerson;

SELECT SalesOrderID, p.FirstName as SalesFirstName, p.LastName as SalesLastName
FROM Sales.SalesOrderHeader AS soh
LEFT JOIN Person.Person p ON soh.SalesPersonID = p.BusinessEntityID;

EXECUTE usp_GetSalesPersonOrders @SalesPerson = 279;

EXECUTE usp_GetSalesPersonOrders @SalesPerson = NULL;

CREATE OR ALTER PROCEDURE usp_GetSalesPersonOrders_better @SalesPerson INT NULL
AS
BEGIN
	IF @SalesPerson IS NULL
	BEGIN
		SELECT SalesOrderID,
p.FirstName AS SalesFirstName,
p.LastName AS SalesLastName
		FROM Sales.SalesOrderHeader AS soh
		LEFT JOIN Person.Person AS p 
ON soh.SalesPersonID = p.BusinessEntityID
	END
	ELSE
	BEGIN
		SELECT SalesOrderID,
p.FirstName AS SalesFirstName,
p.LastName AS SalesLastName
		FROM Sales.SalesOrderHeader AS soh
		LEFT JOIN Person.Person AS p 
ON soh.SalesPersonID = p.BusinessEntityID
		WHERE SalesPersonID = @SalesPerson;
	END
END;

