USE TSQL2012;

--all orders placed by customer(s) who placed the highest number of orders

SELECT custid, orderid, orderdate, empid
FROM Sales.Orders AS O1
WHERE custid IN (SELECT O2.custid
				 FROM Sales.Orders AS O2
				 GROUP BY custid
				 HAVING COUNT(orderid) = (SELECT TOP(1) count(orderid) AS numorders FROM Sales.Orders GROUP BY custid ORDER BY numorders DESC)
				 )
ORDER BY O1.custid


--- alternative solution below

--this query gives me the cust ID(s) which placed the highest number of orders... We will use it as a sub query
SELECT TOP (1) WITH TIES O.custid
FROM Sales.Orders AS O
GROUP BY O.custid
ORDER BY COUNT(*) DESC;

-- here is the subquery used into the outer query to complete the problem

SELECT custid, orderid, orderdate, empid
FROM Sales.Orders
WHERE custid IN 
	(SELECT TOP (1) WITH TIES O.custid
	 FROM Sales.Orders AS O
	 GROUP BY O.custid
	 ORDER BY COUNT(*) DESC);



