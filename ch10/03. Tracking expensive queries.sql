-- Learn T-SQL Querying
-- Chapter 10 - Tracking performance history with Query Store
-- Section - Tracking expensive queries

SELECT TOP 25 q.query_id, qt.query_sql_text,   
    SUM(rs.count_executions) AS total_execution_count,
	AVG(rs.avg_rowcount) AS avg_rowcount,
	CAST(AVG(rs.avg_duration/1000) AS decimal(8,2)) AS avg_duration_ms,
	CAST(AVG(rs.avg_cpu_time/1000) AS decimal(8,2)) AS avg_cpu_time_ms,
	CAST(AVG(rs.avg_query_max_used_memory/8) AS decimal(8,2)) AS avg_query_max_used_memory_KB,
	CAST(AVG(rs.avg_physical_io_reads/8) AS decimal(8,2)) AS avg_physical_io_reads_KB,
	CAST(AVG(rs.avg_logical_io_reads/8) AS decimal(8,2)) AS avg_logical_io_reads_KB,
	CAST(AVG(rs.avg_logical_io_writes/8) AS decimal(8,2)) AS avg_logical_io_writes_KB
FROM sys.query_store_query_text AS qt   
INNER JOIN sys.query_store_query AS q ON qt.query_text_id = q.query_text_id   
INNER JOIN sys.query_store_plan AS p  ON q.query_id = p.query_id   
INNER JOIN sys.query_store_runtime_stats AS rs ON p.plan_id = rs.plan_id  
WHERE execution_type = 0
GROUP BY q.query_id, qt.query_sql_text  
ORDER BY avg_cpu_time_ms DESC;

SELECT TOP 25 q.query_id, qt.query_sql_text, wait_category_desc,
	SUM(ws.total_query_wait_time_ms) AS total_query_wait_time_ms,
	AVG(ws.avg_query_wait_time_ms) AS avg_query_wait_time_ms
FROM sys.query_store_query_text AS qt   
INNER JOIN sys.query_store_query AS q ON qt.query_text_id = q.query_text_id   
INNER JOIN sys.query_store_plan AS p  ON q.query_id = p.query_id   
INNER JOIN sys.query_store_wait_stats AS ws ON p.plan_id = ws.plan_id 
WHERE ws.wait_category_desc NOT IN ('Unknown', 'Idle') AND ws.execution_type = 0
GROUP BY q.query_id, qt.query_sql_text, ws. wait_category_desc
ORDER BY avg_query_wait_time_ms DESC;

CREATE NONCLUSTERED INDEX IX_SalesOrderDetail_ProductID ON [Sales].[SalesOrderDetail] (
	[ProductID] ASC
)
INCLUDE (
	[OrderQty],
	[UnitPrice],
	[UnitPriceDiscount]
) WITH DROP_EXISTING;

