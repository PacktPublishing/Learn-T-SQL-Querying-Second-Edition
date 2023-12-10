-- Learn T-SQL Querying
-- Chapter 6 - Discovering T-SQL Anti-patterns in Depth
-- Section - Avoiding unnecessary overhead with stored procedures

CREATE OR ALTER PROCEDURE [dbo].[uspStocksPerWorkOrder] @WorkOrderID [int]
AS
BEGIN
SET NOCOUNT ON;
	SELECT wo.StockedQty, wor.WorkOrderID 
	FROM Production.WorkOrder AS wo
	LEFT JOIN Production.WorkOrderRouting AS wor 
ON wo.WorkOrderID = wor.WorkOrderID 
	WHERE wo.WorkOrderID = @WorkOrderID;
END;

-- ostress is an external tool, but we'll insert the code here for reference. Run this command from the command line where you have the ostress tool installed
-- ostress.exe -S<my_server_name> -E -dAdventureWorks -Q"EXEC [dbo].[uspStocksPerWorkOrder] 117" -n10 -r1000

CREATE OR ALTER PROCEDURE [dbo].[uspStocksPerWorkOrder] @WorkOrderID [int]
AS
BEGIN
SET NOCOUNT ON;
	IF @WorkOrderID IS NOT NULL
	BEGIN
		SELECT wo.StockedQty, wor.WorkOrderID 
		FROM Production.WorkOrder AS wo
		LEFT JOIN Production.WorkOrderRouting AS wor 
ON wo.WorkOrderID = wor.WorkOrderID 
		WHERE wo.WorkOrderID = @WorkOrderID;
	END;
END;


