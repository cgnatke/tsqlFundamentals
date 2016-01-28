SELECT C.custid, C.companyname, CASE WHEN O.orderid IS NULL THEN 'NO' ELSE 'YES' END AS HasOrderOn20070212
FROM Sales.Customers AS C
LEFT OUTER JOIN Sales.Orders AS O
on C.Custid = O.custid
AND O.orderdate = '20070212'
ORDER BY custid
--WHERE orderdate = '20070212' 