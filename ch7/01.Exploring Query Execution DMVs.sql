-- Learn T-SQL Querying
-- Chapter 7 - Building diagnostic queries using DMVs and DMFs
-- Section - Exploring Query Execution DMVs

-- sys.dm_exec_session
SELECT session_id, login_time, host_name, program_name, login_name, status, last_request_start_time, db_name(database_id) AS [db_name]
FROM sys.dm_exec_sessions
WHERE session_id = 93;

-- sys.dm_exec_requests
SELECT r.session_id, r.start_time, s.program_name, r.status, r.command, r.sql_handle, r.statement_start_offset, r.statement_end_offset, r.database_id
FROM sys.dm_exec_requests r
INNER JOIN sys.dm_exec_sessions s ON s.session_id = r.session_id
WHERE r.session_id > 50 
   AND r.status IN ('running', 'runnable', 'suspended');

SELECT session_id, status, cpu_time, total_elapsed_time, logical_reads, reads, writes
FROM sys.dm_exec_requests
WHERE session_id > 50
   AND status IN ('running', 'runnable', 'suspended');

-- sys.dm_exec_sql_text
SELECT r.session_id, r.start_time, s.program_name, r.status, r.st.text AS statement_text, r.statement_start_offset, r.statement_end_offset, r.database_id
FROM sys.dm_exec_requests r
INNER JOIN sys.dm_exec_sessions s ON s.session_id = r.session_id
CROSS APPLY sys.dm_exec_sql_text(r.sql_handle) st
WHERE r.session_id > 50 
   AND r.status IN ('running', 'runnable', 'suspended');

SELECT *
FROM sys.dm_exec_sql_text(0x020000002EED8B2B6539C6D9CB85FAAA57145FECF54E1DA70000000000000000000000000000000000000000);

-- sys.dm_os_waiting_tasks
SELECT r.session_id, r.start_time, r.status, r.sql_handle,
	r.wait_type, r.wait_time, r.wait_resource
FROM sys.dm_exec_requests r
WHERE r.session_id > 50 
   AND r.status IN ('running', 'runnable', 'suspended');

SELECT r.session_id, t.exec_context_id, t.blocking_exec_context_id,	r.start_time, r.status, r.sql_handle, t.wait_type, t.wait_duration_ms
FROM sys.dm_exec_requests r
LEFT JOIN sys.dm_os_waiting_tasks t ON r.session_id = t.session_id
WHERE r.session_id > 50 
   AND r.status IN ('running', 'runnable', 'suspended')
ORDER BY t.exec_context_id;


