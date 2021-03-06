--Chapter contents below

USE TSQL2012;

DECLARE @maxid AS INT = (SELECT MAX(orderid) FROM Sales.Orders);

SELECT orderid, orderdate, empid, custid
FROM Sales.Orders
WHERE orderid = @maxid

---------------------
---scalar subquery (must return only one value) ----------
SELECT orderid, orderdate, empid, custid FROM Sales.Orders
WHERE orderid = (SELECT MAX(O.orderid) FROM Sales.Orders AS O);

--------------------

--this sub query is bad because it could potentially return more than 1 value.
--Although this sub query does not return more than one value, if it did, then the query would fail

SELECT orderid
FROM Sales.Orders
WHERE empid =
(select e.EMPID
FROM HR.Employees AS E
WHERE E.lastname LIKE N'B%');

--below is an example of a scalar subquery that returns more than one value... It will fail to run

SELECT orderid
FROM Sales.Orders
WHERE empid =
(select e.EMPID
FROM HR.Employees AS E
WHERE E.lastname LIKE N'D%');

--below is an example of the scalar subquery returning NULL. The query will return the empty set

SELECT orderid
FROM Sales.Orders
WHERE empid =
(select e.EMPID
FROM HR.Employees AS E
WHERE E.lastname LIKE N'A%');

------------------------
--SELF CONTAINED MULTIVALUED SUBQUERY EXAMPLES

--IN predicate form:
--<SCALAR_EXPRESSION> in (<MULTIVALUED SUBQUERY>)

SELECT orderid 
FROM Sales.Orders
WHERE empid IN
(SELECT E.empid
FROM HR.Employees AS E
WHERE E.lastname LIKE N'D%');

--Same result set using a join
SELECT O.orderid
FROM HR.Employees AS E
INNER JOIN Sales.Orders AS O
ON E.empid = O.empid
WHERE E.lastname LIKE N'D%';
--------------------------

--Orders placed by custs from US

SELECT custid, orderid, orderdate, empid
FROM Sales.Orders
WHERE custid IN
(SELECT C.custid
FROM Sales.Customers AS C
WHERE C.country = N'USA');

--Custs who did not place orders

SELECT custid, companyname
FROM Sales.Customers
WHERE custid NOT IN
(SELECT O.custid
FROM Sales.Orders AS O)

----------------------------

---create a table with order ids that have even numbered order ids
USE TSQL2012;

IF OBJECT_ID('dbo.Orders', 'U') IS NOT NULL DROP TABLE dbo.Orders
CREATE TABLE dbo.Orders(orderid INT NOT NULL CONSTRAINT PK_Orders PRIMARY KEY);

INSERT INTO dbo.Orders(orderid)
	SELECT orderid
	FROM Sales.Orders
	WHERE orderid % 2 = 0;


--All odd-numbered values between the minimum and maximum order IDs in the orders table

SELECT n
FROM dbo.Nums WHERE n BETWEEN (SELECT MIN(O.orderid) FROM dbo.Orders AS O)
					AND (SELECT MAX(O.orderid) FROM dbo.Orders AS O)
					AND n NOT IN (SELECT O.orderid FROM dbo.Orders AS O)


DROP TABLE dbo.Orders;
----------------------------
--Correlated Subqueries

USE TSQL2012;

--most current order of each customer

SELECT custid, orderid, orderdate, empid
FROM Sales.Orders AS O1
WHERE orderid =
(SELECT MAX(O2.orderid)
FROM Sales.Orders AS O2
WHERE O2.custid = O1.custid);

------------------------

--for each order the percentage that the current order value is of the total values of all of the customer's orders

SELECT orderid, custid, val,
CAST(100. * val / (SELECT SUM(O2.VAL)
					FROM Sales.OrderValues AS O2
					WHERE O2.custid = O1.custid)
	AS NUMERIC(5, 2)) AS pct
	FROM Sales.OrderValues AS O1
	ORDER BY custid, orderid;


--------

--EXISTS predicate


--customers from spain who actually placed an order
SELECT custid, companyname FROM Sales.Customers AS C
WHERE country = N'Spain'
	AND EXISTS
		(SELECT * FROM Sales.Orders AS o
		 WHERE O.custid = C.custid);


-- All customers from Spain who have not placed an order
SELECT custid, companyname
FROM Sales.Customers AS C
WHERE country = N'Spain'
	AND NOT EXISTS
	(SELECT * FROM Sales.Orders AS O
	 WHERE O.custid = C.custid);


----------------------------
--Returning previous or next values

--returning the previous order's id
SELECT orderid, orderdate, empid, custid,
	(SELECT MAX(O2.orderid)
	 FROM Sales.Orders AS O2
	 WHERE O2.orderid < O1.orderid) AS prevorderid
FROM Sales.Orders AS O1;


--returning the next order's id
SELECT orderid, orderdate, empid, custid,
	(SELECT MIN(O2.orderid)
	 FROM Sales.Orders AS O2
	 WHERE O2.orderid > O1.orderid) AS nextorderid
FROM Sales.Orders AS O1;

----------------------------------
--Using running Aggregates

SELECT orderyear, qty
FROM Sales.OrderTotalsByYear

--RETURN THE SUM OF THE QUANTITY UP TO THAT YEAR

SELECT orderyear, qty,
	(SELECT SUM(O2.qty)
	 FROM Sales.OrderTotalsByYear AS O2
	 WHERE O2.orderyear <= O1.orderyear) AS runqty
FROM Sales.OrderTotalsByYear AS O1
ORDER BY orderyear;

---------------------------------

----DEALING WITH MISBEHAVING SUBQUERIES

--NULL TROUBLE


INSERT INTO Sales.Orders
	(custid, empid, orderdate, requireddate, shippeddate, shipperid,freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
	VALUES(NULL,1,'20090212', '20090212', '20090212', 1, 123.00, N'abc', N'abc', N'abc', N'abc', N'abc', N'abc');


--this query is supposed to return customers who did not place orders
SELECT custid, companyname
FROM Sales.Customers
WHERE custid NOT IN(SELECT O.custid
					FROM Sales.Orders AS O);

---Lessons: 
--1)make sure the column cannot have NULL values(enforce NOT NULL)
--2)think about all three truth values tre, false, and unknown


--How to ignore NULL marks:
SELECT custid, companyname
FROM Sales.Customers
WHERE custid NOT IN(SELECT O.custid
					FROM Sales.Orders AS O
					WHERE O.custid IS NOT NULL);

--It would be safer to use NOT EXISTS THAN NOT NULL b/c of two-valued predicate logic

SELECT custid, companyname
FROM Sales.Customers
WHERE NOT EXISTS (SELECT *
				  FROM Sales.Orders
				  WHERE Sales.Orders.custid = Sales.Customers.custid);

DELETE FROM Sales.Orders WHERE custid IS NULL;

--------------------------------------------------------

--Substitution Errors in subquery column names

IF OBJECT_ID('Sales.MyShippers', 'U') IS NOT NULL
	DROP TABLE Sales.MyShippers;

CREATE TABLE Sales.MyShippers
(
shipper_id	INT				NOT NULL,
companyname NVARCHAR(40)	NOT NULL,
phone		NVARCHAR(24)	NOT NULL,
CONSTRAINT	PK_MyShippers	PRIMARY KEY(shipper_id)
)

INSERT INTO Sales.MyShippers(shipper_id, companyname, phone)
	VALUES(1, N'Shipper GVSUA', N'(503) 555-0137'),
		  (2, N'Shipper ETYNR', N'(425) 555-0136'),
		  (3, N'Shipper ZHISN', N'(415) 555-0138');


SELECT shipper_id, companyname
FROM Sales.MyShippers
WHERE shipper_id IN
	(SELECT shipper_id
	 FROM Sales.Orders
	 WHERE custid = 43);

--WHY DOES THIS QUERY RETURN ALL THREE shipper_id's? there should only be two returned...
--THE PROBLEM WITH THE ABOVE QUERY IS THAT THE shipper_id column does not exist in the Sales.Orders TABLE.... The subquery is using the shipper_id value from the outer query

--For example sake, here is the proper query:

SELECT shipper_id, companyname
FROM Sales.MyShippers
WHERE shipper_id IN
	(SELECT shipperid
	 FROM Sales.Orders
	 WHERE custid = 43);

----we can now see the substitution error made
--The query that was suppoed to be a self-contained subquery unintentionally became a correlated subquery

--a good pratice to avoid the above error:
SELECT shipper_id companyname
FROM Sales.MyShippers
WHERE shipper_id IN
	(SELECT O.shipper_id
	 FROM Sales.Orders AS O
	 WHERE O.custid = 43);

--see how a resolution error occured? It is a good idea to prefix the column names so that these errors appear immediately and do not run

--Here is the corrected code:

SELECT shipper_id, companyname
FROM Sales.MyShippers
WHERE shipper_id IN
	(SELECT O.shipperid
	 FROM Sales.Orders As O
	 WHERE O.custid = 43);

--CLEANUP 
IF OBJECT_ID('Sales.MyShippers', 'U') IS NOT NULL
	DROP TABLE Sales.MyShippers;