-- Learn T-SQL Querying
-- Chapter 1 - Understanding Query Processing
-- Section - The importance of parameters

-- Security
DECLARE @sql nvarchar(MAX);
SET @sql = N'INSERT Users (Name) VALUES (''' + '<user input>' + ''');';
EXECUTE (@sql);

INSERT Users (Name) VALUES ('Bob'); DROP TABLE Users; --');

EXECUTE sp_executesql @stmt = N'INSERT Users (Name) VALUES (@name)', @params = N'@name nvarchar(100)', @name = '<user input>'