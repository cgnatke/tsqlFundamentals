USE TSQL2012;

SELECT empid, FirstName, lastname
FROM HR.Employees
WHERE empid NOT IN (SELECT empid
				  FROM Sales.Orders
				  WHERE orderdate >= '20080501')