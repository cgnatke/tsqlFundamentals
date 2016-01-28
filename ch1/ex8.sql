USE TSQL2012;

SELECT custid, region
FROM Sales.Customers
--ORDER BY ISNULL(region, 'zz') ASC, region
--OR:
ORDER BY CASE WHEN region IS NULL THEN 1 ELSE 0 END, region


;