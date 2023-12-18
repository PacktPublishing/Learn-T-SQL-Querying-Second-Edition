-- Learn T-SQL Querying
-- Chapter 7 - Building diagnostic queries using DMVs and DMFs
-- Section - Troubleshooting common scenarios with DMV queries 

-- Investigating blocking
SELECT s.session_id, s.last_request_end_time, ISNULL(r.status,s.status) AS status, s.database_id, r.blocking_session_id, r.wait_type, r.wait_time, r.wait_resource, s.open_transaction_count
FROM sys.dm_exec_sessions s 
LEFT JOIN sys.dm_exec_requests r ON r.session_id = s.session_id
WHERE s.is_user_process = 1;

SELECT object_name(p.object_id) AS [object_name], p.index_id, i.name AS index_name, partition_number
FROM sys.partitions p
INNER JOIN sys.indexes i ON i.object_id = p.object_id AND i.index_id = p.index_id
WHERE p.hobt_id = 72057594048086016;

SELECT * 
FROM sys.dm_db_page_info (26,1,157921,'LIMITED');  

-- Cached query plan issues
-- Single use plans
SELECT qs.query_hash, Query_Count = COUNT(DISTINCT sql_handle), Executions = SUM(execution_count), CPU = SUM(qs.total_worker_time), Reads = SUM(qs.total_logical_reads)	, Duration = SUM(qs.total_elapsed_time), Sample_Query = MAX(st.text)
FROM sys.dm_exec_query_stats qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) st
GROUP BY qs.query_hash
HAVING COUNT(DISTINCT sql_handle) > 5 --> Can be any number, depending on our tolerance for duplicate queries
ORDER BY Query_Count DESC;

SELECT p.BusinessEntityID, p.FirstName, p.LastName, e.EmailAddress
FROM Person.Person p
INNER JOIN Person.EmailAddress e ON p.BusinessEntityID = e.BusinessEntityID
WHERE PersonType = 'IN' AND EmailPromotion = 1;

ALTER DATABASE CURRENT SET PARAMETERIZATION FORCED WITH NO_WAIT;

EXEC sys.sp_configure N'optimize for ad hoc workloads', N'1';
GO
RECONFIGURE WITH OVERRIDE;
GO

-- Cached query plan issues
-- Finding resource intensive queries
SELECT st.[text], qp.query_plan, q.*
FROM
(SELECT TOP 10 [execution_count],
[total_worker_time]/[execution_count] AS [Avg_CPU_Time],
[total_elapsed_time]/[execution_count] AS [Avg_Duration],
[total_logical_reads]/[execution_count] AS [Avg_Logical_Reads],
ISNULL([Total_grant_kb]/[execution_count], -1) AS [Avg_Grant_KB],
ISNULL([Total_used_grant_kb]/[execution_count], -1) AS [Avg_Used_Grant_KB],
plan_handle, sql_handle 
FROM sys.dm_exec_query_stats WITH (NOLOCK)
ORDER BY [Avg_CPU_Time] DESC
) AS q
OUTER APPLY sys.dm_exec_query_plan(q.plan_handle) AS qp
OUTER APPLY sys.dm_exec_sql_text(q.sql_handle) AS st;

-- Cached query plan issues
-- Queries with excessive memory grants
SELECT st.[text], qp.query_plan, q.*
FROM
(SELECT TOP 10 [execution_count], 
[total_worker_time]/[execution_count] AS [Avg_CPU_Time],
[total_elapsed_time]/[execution_count] AS [Avg_Duration],
[total_logical_reads]/[execution_count] AS [Avg_Logical_Reads], 
ISNULL([Total_grant_kb]/[execution_count], -1) AS [Avg_Grant_KB],
ISNULL([Total_used_grant_kb]/[execution_count], -1) AS [Avg_Used_Grant_KB],
COALESCE((([Total_used_grant_kb] * 100.00) / NULLIF([Total_grant_kb],0)), 0) AS [Grant2Used_Ratio],
plan_handle, sql_handle 
FROM sys.dm_exec_query_stats WITH (NOLOCK)
WHERE total_grant_kb/execution_count > 1024	AND execution_count > 1
ORDER BY [Grant2Used_Ratio] 
) AS q
OUTER APPLY sys.dm_exec_query_plan(q.plan_handle) AS qp
OUTER APPLY sys.dm_exec_sql_text(q.sql_handle) AS st;

-- Mining XML Query Plans
-- Plans with Missing Indexes
SELECT DB_NAME(d.database_id) as [database_name], OBJECT_NAME(d.object_id, d.database_id) AS object_name, total_cost_savings = ROUND(s.avg_total_user_cost * s.avg_user_impact * (s.user_seeks + s.user_scans),0) /100, s.avg_total_user_cost, s.avg_user_impact, s.user_seeks, s.user_scans, d.equality_columns, d.inequality_columns, d.included_columns
FROM sys.dm_db_missing_index_groups g
INNER JOIN sys.dm_db_missing_index_group_stats s on s.group_handle = g.index_group_handle 
INNER JOIN sys.dm_db_missing_index_details d on d.index_handle = g.index_handle
ORDER BY total_cost_savings DESC;

WITH XMLNAMESPACES (DEFAULT 'http://schemas.microsoft.com/sqlserver/2004/07/showplan'),
PlanMissingIndexes AS (SELECT query_plan, cp.usecounts, cp.refcounts, cp.plan_handle
FROM sys.dm_exec_cached_plans cp WITH (NOLOCK)
CROSS APPLY sys.dm_exec_query_plan(cp.plan_handle) tp
WHERE cp.cacheobjtype = 'Compiled Plan' AND tp.query_plan.exist('//MissingIndex')=1)
SELECT c1.value('(//MissingIndex/@Database)[1]', 'sysname') AS database_name,
c1.value('(//MissingIndex/@Schema)[1]', 'sysname') AS [schema_name],
c1.value('(//MissingIndex/@Table)[1]', 'sysname') AS [table_name],
c1.value('@StatementText', 'VARCHAR(4000)') AS sql_text,
c1.value('@StatementId', 'int') AS StatementId, pmi.usecounts, pmi.refcounts, 
c1.value('(//MissingIndexGroup/@Impact)[1]', 'FLOAT') AS impact,
REPLACE(c1.query('for $group in //ColumnGroup for $column in $group/Column where $group/@Usage="EQUALITY" return string($column/@Name)').value('.', 'varchar(max)'),'] [', '],[') AS equality_columns,
REPLACE(c1.query('for $group in //ColumnGroup for $column in $group/Column where $group/@Usage="INEQUALITY" return string($column/@Name)').value('.', 'varchar(max)'),'] [', '],[') AS inequality_columns,
REPLACE(c1.query('for $group in //ColumnGroup for $column in $group/Column where $group/@Usage="INCLUDE" return string($column/@Name)').value('.', 'varchar(max)'),'] [', '],[') AS include_columns,	pmi.query_plan, 	pmi.plan_handle
FROM PlanMissingIndexes pmi
CROSS APPLY pmi.query_plan.nodes('//StmtSimple') AS q1(c1)
WHERE pmi.usecounts > 1
ORDER BY c1.value('(//MissingIndexGroup/@Impact)[1]', 'FLOAT') DESC
OPTION(RECOMPILE, MAXDOP 1); 

-- Mining XML Query Plans
-- Plans with Warnings
WITH XMLNAMESPACES (DEFAULT 'http://schemas.microsoft.com/sqlserver/2004/07/showplan'),
WarningSearch AS (SELECT qp.query_plan, cp.usecounts, cp.objtype, wn.query('.') AS StmtSimple, cp.plan_handle
FROM sys.dm_exec_cached_plans cp WITH (NOLOCK)
CROSS APPLY sys.dm_exec_query_plan(cp.plan_handle) qp
CROSS APPLY qp.query_plan.nodes('//StmtSimple') AS p(wn)
WHERE wn.exist('//Warnings') = 1 AND wn.exist('@QueryHash') = 1)
SELECT StmtSimple.value('StmtSimple[1]/@StatementText', 'VARCHAR(4000)') AS sql_text,
StmtSimple.value('StmtSimple[1]/@StatementId', 'int') AS StatementId,
CASE WHEN c2.exist('@UnmatchedIndexes[. = "1"]') = 1 THEN 'UnmatchedIndexes' 
WHEN (c4.exist('@ConvertIssue[. = "Cardinality Estimate"]') = 1 OR c4.exist('@ConvertIssue[. = "Seek Plan"]') = 1) THEN 'ConvertIssue_' + c4.value('@ConvertIssue','sysname') END AS warning, ws.objtype, ws.usecounts, ws.query_plan, ws.plan_handle
FROM WarningSearch ws
CROSS APPLY StmtSimple.nodes('//QueryPlan') AS q1(c1)
CROSS APPLY c1.nodes('./Warnings') AS q2(c2)
CROSS APPLY c1.nodes('./RelOp') AS q3(c3)
OUTER APPLY c2.nodes('./PlanAffectingConvert') AS q4(c4)
OPTION(RECOMPILE, MAXDOP 1);

WITH XMLNAMESPACES (DEFAULT 'http://schemas.microsoft.com/sqlserver/2004/07/showplan'), 
WarningSearch AS (SELECT qp.query_plan, cp.usecounts, cp.objtype, wn.query('.') AS StmtSimple, cp.plan_handle
FROM sys.dm_exec_cached_plans cp WITH (NOLOCK)
CROSS APPLY sys.dm_exec_query_plan(cp.plan_handle) qp
CROSS APPLY qp.query_plan.nodes('//StmtSimple') AS p(wn)
WHERE wn.exist('//Warnings') = 1 AND wn.exist('@QueryHash') = 1)
SELECT StmtSimple.value('StmtSimple[1]/@StatementText', 'VARCHAR(4000)') AS sql_text,
StmtSimple.value('StmtSimple[1]/@StatementId', 'int') AS StatementId,
c1.value('@PhysicalOp','sysname') AS physical_op,
c1.value('@LogicalOp','sysname') AS logical_op,
CASE WHEN c2.exist('@NoJoinPredicate[. = "1"]') = 1 THEN 'NoJoinPredicate' 
WHEN c3.exist('@Database') = 1 THEN 'ColumnsWithNoStatistics' END AS warning, ws.objtype, ws.usecounts, ws.query_plan, ws.plan_handle
FROM WarningSearch ws
CROSS APPLY StmtSimple.nodes('//RelOp') AS q1(c1)
CROSS APPLY c1.nodes('./Warnings') AS q2(c2)
OUTER APPLY c2.nodes('./ColumnsWithNoStatistics/ColumnReference') AS q3(c3)
OPTION(RECOMPILE, MAXDOP 1);

-- Mining XML Query Plans
-- Plans with Implicit Conversions
WITH XMLNAMESPACES (DEFAULT 'http://schemas.microsoft.com/sqlserver/2004/07/showplan'), 
Convertsearch AS (SELECT qp.query_plan, cp.usecounts, cp.objtype, cp.plan_handle, cs.query('.') AS StmtSimple
FROM sys.dm_exec_cached_plans cp WITH (NOLOCK)
CROSS APPLY sys.dm_exec_query_plan(cp.plan_handle) qp
CROSS APPLY qp.query_plan.nodes('//StmtSimple') AS p(cs)
WHERE cp.cacheobjtype = 'Compiled Plan' 
AND cs.exist('@QueryHash') = 1 	
AND cs.exist('.//ScalarOperator[contains(@ScalarString, "CONVERT_IMPLICIT")]') = 1
AND cs.exist('.[contains(@StatementText, "Convertsearch")]') = 0)
SELECT c2.value('@StatementText', 'VARCHAR(4000)') AS sql_text,
c2.value('@StatementId', 'int') AS StatementId,
c3.value('@ScalarString[1]','VARCHAR(4000)') AS expression,
ss.usecounts, ss.query_plan, ss.plan_handle
FROM Convertsearch ss
CROSS APPLY query_plan.nodes('//StmtSimple') AS q2(c2)
CROSS APPLY c2.nodes('.//ScalarOperator[contains(@ScalarString, "CONVERT_IMPLICIT")]') AS q3(c3)
OPTION(RECOMPILE, MAXDOP 1);

-- Mining XML Query Plans
-- Plans with Lookups
WITH XMLNAMESPACES (DEFAULT 'http://schemas.microsoft.com/sqlserver/2004/07/showplan'),
Lookupsearch AS (SELECT qp.query_plan, cp.usecounts, ls.query('.') AS StmtSimple, cp.plan_handle
FROM sys.dm_exec_cached_plans cp (NOLOCK)
CROSS APPLY sys.dm_exec_query_plan(cp.plan_handle) qp
CROSS APPLY qp.query_plan.nodes('//StmtSimple') AS p(ls)
WHERE cp.cacheobjtype = 'Compiled Plan'
AND ls.exist('//IndexScan[@Lookup = "1"]') = 1
AND ls.exist('@QueryHash') = 1)
SELECT StmtSimple.value('StmtSimple[1]/@StatementText', 'VARCHAR(4000)') AS sql_text,
StmtSimple.value('StmtSimple[1]/@StatementId', 'int') AS StatementId, c1.value('@NodeId','int') AS node_id,
c2.value('@Database','sysname') AS database_name,
c2.value('@Schema','sysname') AS [schema_name],
c2.value('@Table','sysname') AS table_name,
'Lookup - ' + c1.value('@PhysicalOp','sysname') AS physical_operator, c2.value('@Index','sysname') AS index_name, c3.value('@ScalarString','VARCHAR(4000)') AS predicate, ls.usecounts, ls.query_plan, ls.plan_handle
FROM Lookupsearch ls
CROSS APPLY query_plan.nodes('//RelOp') AS q1(c1)
CROSS APPLY c1.nodes('./IndexScan/Object') AS q2(c2)
OUTER APPLY c1.nodes('./IndexScan//ScalarOperator[1]') AS q3(c3)
-- Below attribute is present either in Index Seeks or RID Lookups so it can reveal a Lookup is executed
WHERE c1.exist('./IndexScan[@Lookup = "1"]') = 1 
AND c2.value('@Schema','sysname') <> '[sys]'
OPTION(RECOMPILE, MAXDOP 1);


