USE TSQL2012;

SELECT E.empid, DATEADD(day, N.n, '20090611') AS dt
FROM HR.Employees AS E
CROSS JOIN dbo.Nums AS N
WHERE N.n < 6
ORDER BY empid