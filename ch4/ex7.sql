SELECT custid, companyname
FROM Sales.Customers
WHERE custid IN (
SELECT DISTINCT custid 
FROM Sales.Orders
INNER JOIN Sales.Orderdetails
ON Sales.Orders.Orderid = Sales.OrderDetails.orderid 
where productid = 12
);