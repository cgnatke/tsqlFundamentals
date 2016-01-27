SELECT custid, ordermonth, qty, (SELECT SUM(qty) 
								 FROM Sales.CustOrders AS CO2
								 WHERE CO1.ordermonth >= CO2.ordermonth 
								 AND CO1.custid = CO2.custid) AS runqty 
FROM Sales.CustOrders AS CO1
ORDER BY custid