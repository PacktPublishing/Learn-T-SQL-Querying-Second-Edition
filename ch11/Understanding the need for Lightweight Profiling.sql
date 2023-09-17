-- Learn T-SQL Querying
-- Chapter 11 - Troubleshooting Live Queries
-- Section - Understanding the need for Lightweight Profiling

-- Diagnostics available with Lightweight Profiling

-- The query_thread_profile XEvent
CREATE EVENT SESSION [PerfStats_Node] ON SERVER
ADD EVENT sqlserver.query_thread_profile(
	ACTION(sqlos.scheduler_id, sqlserver.database_id, sqlserver.is_system, 
sqlserver.plan_handle, sqlserver.query_hash_signed, sqlserver.query_plan_hash_signed, 
sqlserver.server_instance_name,sqlserver.session_id, sqlserver.session_nt_username, sqlserver.sql_text)
	)
	ADD TARGET package0.event_file(
		SET filename=N'C:\Temp\PerfStats_Node.xel', 
max_file_size=(50), max_rollover_files=(2)
	)
WITH (MAX_MEMORY=4096 KB, EVENT_RETENTION_MODE=ALLOW_SINGLE_EVENT_LOSS, 
MAX_DISPATCH_LATENCY=30 SECONDS, MAX_EVENT_SIZE=0 KB, MEMORY_PARTITION_MODE=NONE, 
	TRACK_CAUSALITY=OFF,STARTUP_STATE=OFF); 

ALTER EVENT SESSION [PerfStats_Node] ON SERVER STATE = start;  
GO  

SELECT COUNT(*)
FROM Sales.SalesOrderDetail AS sod
INNER JOIN Sales.SalesOrderHeader AS soh ON soh.SalesOrderID = sod.SalesOrderID
GROUP BY soh.Status;
GO

ALTER EVENT SESSION [PerfStats_Node] ON SERVER STATE = stop;  
GO

SELECT qp.query_plan 
FROM sys.dm_exec_query_stats qs
CROSS APPLY sys.dm_exec_query_plan(qs.plan_handle) qp
WHERE CAST(qs.query_plan_hash AS BIGINT) = -4407577682464253461;

-- The query_thread_profile XEvent
CREATE EVENT SESSION [PerfStats_LWP_Plan_Single] ON SERVER
ADD EVENT sqlserver.query_plan_profile(
	ACTION(sqlos.scheduler_id, sqlserver.database_id, sqlserver.is_system, 
sqlserver.plan_handle, sqlserver.query_hash_signed, sqlserver.query_plan_hash_signed, 
sqlserver.server_instance_name,sqlserver.session_id, sqlserver.session_nt_username, sqlserver.sql_text)
	)
	ADD TARGET package0.event_file(
		SET filename=N'C:\Temp\PerfStats_LWP_Plan_Single.xel', 
max_file_size=(50), max_rollover_files=(2)
	)
WITH (MAX_MEMORY=4096 KB, EVENT_RETENTION_MODE=ALLOW_SINGLE_EVENT_LOSS, 
MAX_DISPATCH_LATENCY=30 SECONDS, MAX_EVENT_SIZE=0 KB, MEMORY_PARTITION_MODE=NONE, TRACK_CAUSALITY=OFF,STARTUP_STATE=OFF);

CREATE OR ALTER PROCEDURE [Sales].[CountSalesOrderByStatus]
AS
SELECT COUNT(*)
FROM Sales.SalesOrderDetail AS sod
INNER JOIN Sales.SalesOrderHeader AS soh 
	ON soh.SalesOrderID = sod.SalesOrderID
GROUP BY soh.Status;

EXEC sp_create_plan_guide   
@name = N'Guide1',  
@stmt = 'SELECT COUNT(*)
FROM Sales.SalesOrderDetail AS sod
INNER JOIN Sales.SalesOrderHeader AS soh 
	ON soh.SalesOrderID = sod.SalesOrderID
GROUP BY soh.Status;',  
@type = N'OBJECT',  
@module_or_batch = N'Sales.CountSalesOrderByStatus',  
@params = NULL,  
@hints = N'OPTION (USE HINT (''QUERY_PLAN_PROFILE''))';

ALTER EVENT SESSION [PerfStats_LWP_Plan_Single] ON SERVER STATE = start;  
GO   

EXEC Sales.CountSalesOrderByStatus;
GO

ALTER EVENT SESSION [PerfStats_LWP_Plan_Single] ON SERVER STATE = stop;  
GO

-- The query_post_execution_plan_profile XEvent
CREATE EVENT SESSION [PerfStats_LWP_Plan_All] ON SERVER
ADD EVENT sqlserver.query_post_execution_plan_profile(
	ACTION(sqlos.scheduler_id, sqlserver.database_id, sqlserver.is_system, 
sqlserver.plan_handle, sqlserver.query_hash_signed, sqlserver.query_plan_hash_signed, 
sqlserver.server_instance_name,sqlserver.session_id, sqlserver.session_nt_username, sqlserver.sql_text)
	)
	ADD TARGET package0.event_file(
		SET filename=N'C:\Temp\PerfStats_LWP_Plan_All.xel', 
max_file_size=(50), max_rollover_files=(2)
	)
WITH (MAX_MEMORY=4096 KB, EVENT_RETENTION_MODE=ALLOW_SINGLE_EVENT_LOSS, 
MAX_DISPATCH_LATENCY=30 SECONDS, MAX_EVENT_SIZE=0 KB, MEMORY_PARTITION_MODE=NONE, 
	TRACK_CAUSALITY=OFF,STARTUP_STATE=OFF); 

ALTER EVENT SESSION [PerfStats_LWP_Plan_All] ON SERVER STATE = start;  
GO   

SELECT COUNT(*)
FROM Sales.SalesOrderDetail AS sod
INNER JOIN Sales.SalesOrderHeader AS soh 
	ON soh.SalesOrderID = sod.SalesOrderID
GROUP BY soh.Status;
GO

ALTER EVENT SESSION [PerfStats_LWP_Plan_All] ON SERVER STATE = stop;  
GO

-- The sys.dm_exec_query_statistics_xml DMF
SELECT e.[BusinessEntityID], p.[Title], p.[FirstName],
	p.[MiddleName], p.[LastName], p.[Suffix], e.[JobTitle],
	pp.[PhoneNumber], pnt.[Name] AS [PhoneNumberType],
	ea.[EmailAddress], p.[EmailPromotion], a.[AddressLine1],
	a.[AddressLine2], a.[City], sp.[Name] AS [StateProvinceName],
	a.[PostalCode], cr.[Name] AS [CountryRegionName], p.[AdditionalContactInfo]
FROM [HumanResources].[Employee] AS e
INNER JOIN [Person].[Person] AS p
	ON RTRIM(LTRIM(p.[BusinessEntityID])) = RTRIM(LTRIM(e.[BusinessEntityID]))
INNER JOIN [Person].[BusinessEntityAddress] AS bea
	ON RTRIM(LTRIM(bea.[BusinessEntityID])) = RTRIM(LTRIM(e.[BusinessEntityID]))
INNER JOIN [Person].[Address] AS a
	ON RTRIM(LTRIM(a.[AddressID])) = RTRIM(LTRIM(bea.[AddressID]))
INNER JOIN [Person].[StateProvince] AS sp
	ON RTRIM(LTRIM(sp.[StateProvinceID])) = RTRIM(LTRIM(a.[StateProvinceID]))
INNER JOIN [Person].[CountryRegion] AS cr
	ON RTRIM(LTRIM(cr.[CountryRegionCode])) = RTRIM(LTRIM(sp.[CountryRegionCode]))
LEFT OUTER JOIN [Person].[PersonPhone] AS pp
	ON RTRIM(LTRIM(pp.BusinessEntityID)) = RTRIM(LTRIM(p.[BusinessEntityID]))
LEFT OUTER JOIN [Person].[PhoneNumberType] AS pnt
	ON RTRIM(LTRIM(pp.[PhoneNumberTypeID])) = RTRIM(LTRIM(pnt.[PhoneNumberTypeID]))
LEFT OUTER JOIN [Person].[EmailAddress] AS ea
	ON RTRIM(LTRIM(p.[BusinessEntityID])) = RTRIM(LTRIM(ea.[BusinessEntityID]));

SELECT er.session_id, er.start_time, er.status, er.database_id,
	er.wait_type, er.last_wait_type, er.cpu_time, er.total_elapsed_time,
	er.logical_reads, er.granted_query_memory, er.dop, 
	st.text, qsx.query_plan
FROM sys.dm_exec_requests AS er
CROSS APPLY sys.dm_exec_sql_text(plan_handle) AS st
CROSS APPLY sys.dm_exec_query_statistics_xml(session_id) AS qsx;

-- The sys.dm_exec_query_plan_stats DMF
ALTER DATABASE SCOPED CONFIGURATION SET LAST_QUERY_PLAN_STATS = ON;
GO

SELECT TOP 1000 * 
FROM [dbo].[DimProduct] AS dp
INNER JOIN [dbo].[DimProductCategory] AS dpc ON dp.ProductSubcategoryKey = dpc.ProductCategoryKey;

SELECT qps.dbid, st.text, qps.query_plan, 
	cp.refcounts, cp.usecounts, cp.cacheobjtype, cp.objtype
FROM sys.dm_exec_cached_plans AS cp
CROSS APPLY sys.dm_exec_sql_text(plan_handle) AS st
CROSS APPLY sys.dm_exec_query_plan_stats(plan_handle) AS qps
WHERE st.text LIKE '%SELECT TOP 1000%';

SELECT qps.dbid, st.text, qps.query_plan,
	qs.last_dop, qs.last_elapsed_time, qs.last_execution_time, 
	qs.last_grant_kb, qs.last_used_grant_kb, qs.last_logical_reads, 
	qs.last_logical_writes, qs.last_physical_reads,
	qs.last_rows, qs.last_spills, qs.last_worker_time
FROM sys.dm_exec_query_stats AS qs
OUTER APPLY sys.dm_exec_sql_text(plan_handle) AS st
OUTER APPLY sys.dm_exec_query_plan_stats(plan_handle) AS qps
WHERE st.text LIKE '--%';

