-- Learn T-SQL Querying
-- Chapter 7 - Building diagnostic queries using DMVs and DMFs
-- Section - Exploring Query Plan Cache DMVs

-- sys.dm_exec_query_stats
SELECT st.text, qs.plan_handle, qs.last_execution_time, qs.execution_count, qs.total_worker_time AS total_cpu_time,
qs.total_worker_time/qs.execution_count AS average_cpu_time, qs.total_logical_reads, qs.total_logical_reads/qs.execution_count AS average_logical_reads, qs.total_elapsed_time, (qs.total_elapsed_time/qs.execution_count)/1000000 AS average_elapsed_time_sec
FROM sys.dm_exec_query_stats qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) st
WHERE qs.sql_handle = 0x0200000022D4D930BD648A1C5BA9320D2448C8F7CFCEF3D60000000000000000000000000000000000000000;

-- sys.dm_exec_procedure_stats
CREATE OR ALTER PROCEDURE uspGetEmployeeByDepartment @Department nvarchar(50) 
AS
SELECT *
FROM HumanResources.vEmployeeDepartment
WHERE Department = @Department
IF @Department = N'Engineering'
	WAITFOR DELAY '00:00:10'
GO

SELECT object_name(object_id, database_id) AS proc_name, plan_handle, execution_count, min_elapsed_time, max_elapsed_time
FROM sys.dm_exec_procedure_stats
WHERE object_id = object_id('uspgetEmployeeByDepartment');

SELECT st.text, qs.statement_start_offset, qs.statement_end_offset, qs.execution_count, qs.min_elapsed_time, qs.max_elapsed_time
FROM sys.dm_exec_query_stats qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) st
WHERE plan_handle = 0x05001E008116D84AA0BC768B1F02000001000000000000000000000000000000000000000000000000000000;

-- sys.dm_exec_query_plan
SELECT query_plan
FROM sys.dm_exec_query_plan(0x05001E008116D84AA0BC768B1F02000001000000000000000000000000000000000000000000000000000000);

SELECT query_plan
FROM sys.dm_exec_text_query_plan(0x05001E008116D84AA0BC768B1F02000001000000000000000000000000000000000000000000000000000000, 152, 316);

-- sys.dm_exec_cached_plans
SELECT TOP 10 plan_handle, usecounts, size_in_bytes, objtype, query_plan
FROM sys.dm_exec_cached_plans
CROSS APPLY sys.dm_exec_query_plan(plan_handle)
ORDER BY size_in_bytes DESC;


