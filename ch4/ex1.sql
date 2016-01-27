USE TSQL2012;

SELECT orderid, orderdate, custid, empid
FROM Sales.Orders AS O1
WHERE orderdate IN (SELECT MAX(orderdate)
				  FROM Sales.Orders AS O2)