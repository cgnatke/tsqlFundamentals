SELECT orderid, SUM(qty*unitprice) AS totalvalue
FROM Sales.OrderDetails
GROUP BY orderid
HAVING SUM(qty*unitprice) > 10000.00
ORDER BY totalvalue DESC


--SELECT DISTINCT orderid
--FROM Sales.OrderDetails