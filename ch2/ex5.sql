SELECT C.custid, C.companyname, O.orderid, O.orderdate
FROM Sales.Customers AS C
LEFT JOIN Sales.Orders AS O
on C.custid = O.custid
WHERE orderdate = '20070212'