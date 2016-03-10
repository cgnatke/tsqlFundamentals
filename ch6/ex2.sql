SELECT custid, empid
FROM Sales.Orders
WHERE orderdate >= '1/1/2008' AND orderdate < '2/1/2008'

EXCEPT

SELECT custid, empid
FROM Sales.Orders
WHERE  orderdate >= '2/1/2008' AND orderdate < '3/1/2008'

