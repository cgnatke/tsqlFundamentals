SELECT custid, orderdate, orderid, ROW_NUMBER() OVER (PARTITION BY custid ORDER BY orderid) AS rownum
FROM Sales.Orders
ORDER BY custid, orderdate

--RIGHT ANSWER BELOWS (What's the difference any damn way?)

SELECT custid, orderdate, orderid, ROW_NUMBER() OVER (PARTITION BY custid ORDER BY orderdate, orderid) AS rownum
FROM Sales.Orders
ORDER BY custid, rownum;
