-- Learn T-SQL Querying
-- Chapter 8 - Building XEvent profiler traces
-- Section - Introducing XEvents

CREATE EVENT SESSION [NewApplicationQueryTrace] ON SERVER 
ADD EVENT sqlserver.rpc_completed(
    ACTION(sqlserver.client_app_name)
    WHERE ([sqlserver].[is_system]=(0))),
ADD EVENT sqlserver.sql_batch_completed(
    ACTION(sqlserver.client_app_name)
    WHERE ([sqlserver].[is_system]=(0)))
ADD TARGET package0.event_file(SET filename=N'NewApplicationQueryTrace')
GO

ALTER EVENT SESSION NewApplicationQueryTrace ON SERVER  
STATE = start;  
GO

ALTER EVENT SESSION NewApplicationQueryTrace ON SERVER  
STATE = stop;  
GO

