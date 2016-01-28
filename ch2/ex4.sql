USE TSQL2012;


SELECT C.custid, C.companyname
FROM [TSQL2012].[Sales].[Customers] AS C
LEFT JOIN Sales.Orders AS O
ON c.custid = O.custid
WHERE O.custid IS NULL;