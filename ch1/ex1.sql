SELECT orderid, orderdate, custid, empid
FROM Sales.Orders
WHERE Sales.Orders.orderdate >= '20070601' AND Sales.Orders.orderdate < '20070701' -- the order was in june 2007
ORDER BY orderdate;