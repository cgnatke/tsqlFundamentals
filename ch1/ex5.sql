SELECT TOP(3) shipcountry, AVG(freight) AS avgfreight
FROM Sales.Orders
where orderdate > '20061231' AND orderdate < '20080101'
GROUP BY shipcountry
ORDER BY avgfreight DESC;