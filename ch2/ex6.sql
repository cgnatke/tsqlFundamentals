SELECT C.custid, C.companyname, O.orderid, O.orderdate
FROM Sales.Customers AS C
LEFT OUTER JOIN Sales.Orders AS O
on C.Custid = O.custid
AND O.orderdate = '20070212'
--WHERE orderdate = '20070212' 