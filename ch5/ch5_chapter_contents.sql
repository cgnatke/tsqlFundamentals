USE TSQL2012;

-----Derived Tables

SELECT *
FROM (SELECT custid, companyname
	  FROM Sales.Customers
	  WHERE country = N'USA') AS USACusts;

--you cannot use an alias in a GROUP BY clause

SELECT
	YEAR(orderdate) AS orderyear,
	COUNT(DISTINCT custid) AS numcusts
FROM Sales.Orders
GROUP BY orderyear;


-- use a derived table for inline aliasing form
SELECT orderyear, COUNT(DISTINCT custid) AS numcusts
FROM (SELECT YEAR(orderdate) AS orderyear, custid
	  FROM Sales.Orders) AS D
GROUP BY orderyear;


--using arguments

--number of distinct customers per year whose orders were handled by the input employee

DECLARE @empid AS INT = 3;

SELECT orderyear, COUNT(DISTINCT custid) AS numcusts
FROM (SELECT YEAR(orderdate) AS orderyear, custid
	  FROM Sales.Orders
	  WHERE empid = @empid) AS D
GROUP BY orderyear;


--Nesting
--nesting can be problematic when used in the contex of derived tables
--returns order years and the number of customers handled in each year only for years in which more than 70 customers were handled

--derived tables solution

SELECT orderyear, numcusts
FROM (SELECT orderyear, COUNT(DISTINCT custid) AS numcusts
	FROM (SELECT YEAR(orderdate) AS orderyear, custid
		  FROM Sales.Orders) AS D1
	GROUP BY orderyear) AS D2
WHERE numcusts > 70;

-- A simplied solution to avoid the nesting

SELECT YEAR(orderdate) AS orderyear, COUNT(DISTINCT custid) AS numcusts
FROM Sales.Orders
GROUP BY YEAR(orderdate)
HAVING COUNT(DISTINCT custid) > 70;

--Multiple References

--ANOTHER PROBELMATIC OF DERIVED TABLES is that the tables
--exist in the from clause so therefore the table does not exist until the outer query has run.
-- the derived table needs to be defined twice

SELECT Cur.orderyear, Cur.numcusts AS curnumcusts, Prv.numcusts AS prvnumcusts, Cur.numcusts - Prv.numcusts AS growth
FROM (SELECT YEAR(orderdate) AS orderyear,
		COUNT(DISTINCT custid) AS numcusts
		FROM Sales.Orders
		GROUP BY YEAR(orderdate)) AS Cur
	LEFT OUTER JOIN
		(SELECT YEAR(orderdate) AS orderyear,
			COUNT(DISTINCT custid) AS numcusts
			FROM Sales.Orders
			GROUP BY YEAR(orderdate)) AS Prv
	ON Cur.orderyear = Prv.orderyear + 1


--"The fact that you cannot refer to multiple instances of the same derived table forces you to maintain multiple copies of the same query definition.
--This leads to lengthy code that is hard to maintain and is prone to errors."

--Common Table Expressions (CTEs)
--CTEs are very similar to derived tables but with a few advantages

--syntax:

--WITH <CTE_Name>[(<target_column_list>)]
--AS
--(
--	<inner_query_defining_CTE>
--)
--<outer_query_against_CTE>;


--example of CTE called USACusts:

WITH USACusts AS
(
	SELECT custid, companyname
	FROM Sales.Customers
	WHERE country = N'USA'
)
SELECT * FROM USACusts;

--"As with all derived tables, as soon as the outer query fnishes, the CTE goes out of scope."

--Assigning Column Aliases in CTEs
--CTEs support inline and external

--INLINE ALIAS: <expression> AS <column_alias>;

WITH C AS
(
 SELECT YEAR(orderdate) AS orderyear, custid
 FROM Sales.Orders
 )

 SELECT orderyear, COUNT(DISTINCT custid) AS numcusts
 FROM C
 GROUP BY orderyear;


--OUTLINE ALIAS: 

WITH C(orderyear, custid) AS
(
	SELECT YEAR(orderdate), custid
	FROM Sales.Orders
)
SELECT orderyear, COUNT(DISTINCT custid) AS numcusts
FROM C
GROUP BY orderyear;

--Using Arguments in CTEs

DECLARE @empid AS INT = 3;

WITH C AS
(
	SELECT YEAR(orderdate) AS orderyear, custid
	FROM Sales.Orders
	WHERE empid = @empid
)
SELECT orderyear, COUNT(DISTINCT custid) AS numcusts
FROM C
GROUP BY orderyear;

--DEFINING multiple CTEs

WITH C1 AS
(
	SELECT YEAR(orderdate) AS orderyear, custid
	FROM Sales.Orders
),
C2 AS
(
	SELECT orderyear, COUNT(DISTINCT custid) AS numcusts
	FROM C1
	GROUP BY orderyear
)

SELECT orderyear, numcusts
FROM C2
WHERE numcusts > 70;


--Multiple References in CTEs
--The below CTE is defined once and called twice

WITH YearlyCount AS
(
	SELECT YEAR(orderdate) AS orderyear, COUNT(DISTINCT custid) AS numcusts
	FROM Sales.Orders
	GROUP BY YEAR(orderdate)
)
SELECT Cur.orderyear, Cur.numcusts AS curnumcusts, Prv.numcusts AS prvnumcusts, Cur.numcusts - Prv.numcusts AS growth
FROM YearlyCount AS Cur
	LEFT OUTER JOIN YearlyCount AS Prv
	ON Cur.orderyear = Prv.orderyear +1;


--Recursive CTEs
--syntax:

--with <CTE_Name>[(<target_column_list>)]
--AS
--(
--	<anchor_member>
--	UNION ALL
--	<recursive_member>
--)
--<outer_query_against_CTE>;


WITH EmpsCTE AS
(
	--anchor member
	SELECT empid, mgrid, firstname, lastname
	FROM HR.Employees
	WHERE empid = 2

	UNION ALL

	--recursive member
	SELECT C.empid, C.mgrid, C.firstname, C.lastname
	FROM EmpsCTE AS P
		JOIN HR.Employees AS C
		ON C.mgrid = P.empid
)
SELECT empid, mgrid, firstname, lastname
FROM EmpsCTE;


--Views and encryption

SELECT custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax
FROM Sales.Customers
WHERE country = N'USA';
GO


SELECT OBJECT_DEFINITION(OBJECT_ID('Sales.USACusts'));

CREATE VIEW Sales.USACusts

AS

SELECT custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax
FROM Sales.Customers
WHERE country = N'USA';
GO

ALTER VIEW Sales.USACusts WITH ENCRYPTION
AS
SELECT custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax
FROM Sales.Customers
WHERE country = N'USA';
GO

SELECT OBJECT_DEFINITION(OBJECT_ID('Sales.USACusts'));

--Inline table-Valued Functions

IF OBJECT_ID('dbo.GetCustOrders') IS NOT NULL
	DROP FUNCTION dbo.GetCustOrders;
GO
CREATE FUNCTION dbo.GetCustOrders
	(@cid AS INT) RETURNS TABLE
AS
RETURN
	SELECT orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress,
			shipcity, shipregion, shippostalcode, shipcountry
	FROM Sales.Orders
	WHERE custid = @cid;
GO

SELECT orderid, custid
FROM dbo.GetCustOrders(1) AS O;

--you can also refer to an inline TVF as part of a join:
--join the cust's order to the order details.

SELECT O.orderid, O.custid, OD.productid, OD.qty
FROM dbo.getcustorders(1) AS O
JOIN Sales.OrderDetails AS OD
ON O.orderid = OD.orderid;

--APPLY Operator
--APPLY IS NOT PART OF THE SQL standard.

--three most recent orders for each customer

SELECT C.custid, A.orderid, A.orderdate
FROM Sales.Customers AS C
	CROSS APPLY
		(SELECT TOP (3) orderid, empid, orderdate, requireddate
		 FROM Sales.Orders AS O
		 WHERE O.custid = C.custid
		 ORDER BY orderdate DESC, orderid DESC) AS A;






