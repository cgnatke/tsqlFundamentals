--CHAPTER 6: Set Operators

--Form of a query with a set operator:

--input query1
--<set_operator>
--input query2
--order by

--union operator

USE TSQL2012;

SELECT country, region, city FROM HR.Employees
UNION ALL
SELECT country, region, city FROM Sales.Customers

--b/c UNION ALL does not eliminate duplicates, these results are a multiset

USE TSQL2012;
SELECT country, region, city FROM HR.Employees
UNION
SELECT country, region, city FROM Sales.Customers

--the duplicates are removed, therefore we have a set


--Intersect operator

--Intersect distinct set operator

SELECT country, region, city FROM HR.Employees
INTERSECT
SELECT country, region, city FROM Sales.Customers

--if the location appears at least once in the employees table and at least once
--in the customers table, the location is returned

--TODO create this same result with an inner join to show the 
--difference in null evaluation

SELECT DISTINCT E.country, E.region, E.city
FROM HR.Employees AS E
INNER JOIN Sales.Customers AS C
ON E.country = C.country AND E.region = C.region AND E.city = C.city

--the above result set only has two rows because the join compared
--two null values, which evaluated to UNKNOWN... This is the adv of the INTERSECT operator

--Intersect all (multiset)
--T-SQL has not implimented this part of the SQL standard

--The alternative solution is to use ROW_NUMBER to numbe rof occurances of each
--row in the input query. 
