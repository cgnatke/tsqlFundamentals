SELECT Sales.Customers.custid, COUNT(DISTINCT Sales.orders.orderid) as numorders, SUM(Sales.orderdetails.qty) as totalqty
FROM Sales.Customers 
LEFT JOIN Sales.Orders
ON Sales.Customers.custid = Sales.Orders.custid
INNER JOIN Sales.OrderDetails
ON Sales.Orders.Orderid = Sales.orderdetails.orderid
WHERE Sales.Customers.country = 'USA'
GROUP BY Sales.Customers.custid
