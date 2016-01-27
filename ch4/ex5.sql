USE TSQL2012;

SELECT custid, orderid, orderdate, empid
FROM Sales.Orders AS O1
WHERE orderdate = (SELECT MAX(orderdate) FROM Sales.Orders AS O2 WHERE O1.custid = O2.custid)