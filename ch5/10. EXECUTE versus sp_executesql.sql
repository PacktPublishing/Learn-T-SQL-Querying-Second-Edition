-- Learn T-SQL Querying
-- Chapter 5 - Writing Elegant T-SQL Queries
-- Section - EXECUTE versus sp_executesql

DECLARE @sql nvarchar(MAX), @JobTitle nvarchar(50) = N'Sales Representative';

SET @sql = 'SELECT e.BusinessEntityID, p.FirstName, p.LastName
FROM HumanResources.Employee e
INNER JOIN Person.Person p ON p.BusinessEntityID = e.BusinessEntityID
WHERE e.JobTitle = N''' + @JobTitle + '''';

EXECUTE (@sql);

SELECT st.text, qs.sql_handle, qs.execution_count
FROM sys.dm_exec_query_stats qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) st
WHERE qs.query_hash = 0x3A17ADF596F7D5C9;

DECLARE @sql nvarchar(MAX), @JobTitle nvarchar(50) = N'Sales Representative';

SET @sql = 'SELECT e.BusinessEntityID, p.FirstName, p.LastName
FROM HumanResources.Employee e
INNER JOIN Person.Person p ON p.BusinessEntityID = e.BusinessEntityID
WHERE e.JobTitle = @p1';

EXEC sp_executesql @sql, N'@p1 nvarchar(50)', @JobTitle;

