-- Learn T-SQL Querying
-- Chapter 6 - Discovering T-SQL Anti-patterns in Depth
-- Section - Pitfalls of correlated sub-queries

SELECT wo.StockedQty, wo.WorkOrderID, wor.ActualCost
FROM Production.WorkOrder AS wo
INNER JOIN Production.WorkOrderRouting AS wor ON wo.WorkOrderID = wor.WorkOrderID 
WHERE wor.WorkOrderID = 12345;
SELECT wo.StockedQty, wo.WorkOrderID,
	(SELECT wor.ActualCost 
		FROM Production.WorkOrderRouting AS wor 
		WHERE wor.WorkOrderID = 12345)
FROM Production.WorkOrder AS wo
WHERE wo.WorkOrderID IN 
	(SELECT wor.WorkOrderID 
		FROM Production.WorkOrderRouting AS wor 
		WHERE wor.WorkOrderID = 12345);

