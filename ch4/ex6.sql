SELECT custid, companyname
FROM Sales.Customers
WHERE custid IN (SELECT Sales.Orders.custid 
				 FROM Sales.Orders 
				 WHERE orderdate <'20090101' AND orderdate >= '20070101'
				 GROUP BY Sales.Orders.custid
				 HAVING MAX(Sales.Orders.orderdate) < '20080101')