-- Learn T-SQL Querying
-- Chapter 5 - Writing Elegant T-SQL Queries
-- Section - Best practices for T-SQL querying

-- Joining tables
SELECT p.ProductID, p.Name, wo.StockedQty, wor.WorkOrderID 
FROM Production.WorkOrder AS wo
INNER JOIN Production.Product AS p ON wo.ProductID = p.ProductID
INNER JOIN Production.WorkOrderRouting AS wor ON wo.WorkOrderID = wor.WorkOrderID 
WHERE p.ProductID = 771 AND wor.WorkOrderID = 852;

SELECT p.ProductID, p.Name, wo.StockedQty, wor.WorkOrderID 
FROM Production.WorkOrder AS wo
INNER JOIN Production.Product AS p ON wo.ProductID = p.ProductID
	AND p.ProductID = 771
INNER JOIN Production.WorkOrderRouting AS wor ON wo.WorkOrderID = wor.WorkOrderID 
	AND wor.WorkOrderID = 852;

SELECT wo.StockedQty, wor.WorkOrderID 
FROM Production.WorkOrder AS wo
LEFT JOIN Production.WorkOrderRouting AS wor ON wo.WorkOrderID = wor.WorkOrderID 
WHERE wor.WorkOrderID = 12345;

SELECT wo.StockedQty, wor.WorkOrderID 
FROM Production.WorkOrder AS wo
LEFT JOIN Production.WorkOrderRouting AS wor ON wo.WorkOrderID = wor.WorkOrderID 
WHERE wo.WorkOrderID = 12345;

