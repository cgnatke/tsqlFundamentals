use TSQL2012


SELECT C.custid, C.companyname, O.orderid, o.orderdate
  FROM [TSQL2012].[Sales].[Customers]AS C
  LEFT JOIN Sales.Orders As O
  ON C.custid = O.custid