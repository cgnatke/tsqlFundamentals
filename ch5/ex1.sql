
use TSQL2012;

--exersise 1-1:
--write a query that returns the maximum value in the orderdate column for each employee

select empid, MAX(orderdate) AS maxorderdate
from Sales.Orders
GROUP BY Empid


--exercise 1-2: (redo)
--Encapsulate the query from ex 1-1 in a derived tbl.
--Write a join query between the derived tbl and the
--Orders tbl to return the orders with the maximum order date for each employee

--empid, orderdate, orderid, custid
SELECT LO.empid, LO.maxorderdate, Sales.Orders.orderid, Sales.Orders.custid
FROM
(SELECT empid, MAX(orderdate) AS maxorderdate
from Sales.Orders
GROUP BY Empid
) AS LO
INNER JOIN Sales.Orders
ON LO.empid = Sales.Orders.empid
AND LO.maxorderdate = Sales.Orders.orderdate

ORDER BY maxorderdate

--exercise 2-1
--write a query that calculates a row number for each
--order based on orderdate, orderid ordering

SELECT orderid, orderdate, custid, empid, ROW_NUMBER() OVER (ORDER BY orderdate, orderid)
FROM Sales.Orders

--exercise 2-2:
--write a query that returns rows with row numbers 11-20
--based on the row number definition in ex 2-1
-- use a cte to encapsulate the code from 2-1

WITH OrdersRN AS

(SELECT orderid, orderdate, custid, empid, ROW_NUMBER() OVER (ORDER BY orderdate, orderid) AS rownum
FROM Sales.Orders) 

SELECT *  FROM OrdersRN WHERE rownum > 10 and rownum < 21;

--3
-- write a solution using a recursive CTE that returns the managements chain leading to ZOYA Dolgopyatova (empid 9)

WITH empListCTE AS
(
--anchor member
SELECT empid, mgrid, firstname, lastname
FROM HR.Employees
WHERE empid = 9

UNION ALL

--recursive member
SELECT P.empid, P.mgrid, P.firstname, P.lastname
from empListCTE AS C
JOIN HR.Employees AS P
ON C.mgrid = P.empid
)

SELECT empid, mgrid, firstname, lastname
FROM empListCTE


GO

--exercise 4

CREATE VIEW Sales.VEmpOrders

AS

SELECT empid, YEAR(orderdate) AS orderyear, SUM(qty) AS qty
FROM Sales.Orders
INNER JOIN Sales.OrderDetails
ON Sales.Orders.orderid = Sales.OrderDetails.orderid
GROUP BY empid, YEAR(orderdate)


GO

SELECT * FROM Sales.VEmpOrders ORDER BY empid, orderyear;

--ex. 4-2

SELECT EO.empid, EO.orderyear, EO.qty, (SELECT SUM(qty) FROM Sales.VEmpOrders WHERE orderyear <= EO.orderyear AND EO.empid = empid) AS runqty 
FROM Sales.VEmpOrders AS EO
ORDER BY empid, orderyear;


--ex. 5-1:
--create an inline function that accepts as input a supplier ID (@supid AS INT)
--and a requested number of products (@n AS INT). The function should return @n
--products with the highest unit prices that are supplied by the specified supplier ID.

GO 

CREATE FUNCTION Production.TopProducts
	(@supid AS INT, @n AS INT) RETURNS TABLE
AS
RETURN
	SELECT TOP(@n) productid, productname, unitprice 
	FROM PRODUCTION.Products
	where Production.Products.supplierid = @supid
	ORDER BY unitprice DESC;
GO


SELECT * FROM Production.TopProducts(5, 2);

--cleanup
IF OBJECT_ID('Production.TopProducts') IS NOT NULL
	DROP Function Production.TopProducts

--5-2
--Using CROSS APPLY and the function created in 4-1,
-- return for each supplier the two most expensive products

SELECT supplierid, companyname, A.productid, A.productname, A.unitprice
FROM Production.Suppliers AS S
CROSS APPLY Production.TopProducts(S.supplierid, 2) AS A;

	
IF OBJECT_ID('Sales.VEmpOrders') IS NOT NULL
	DROP VIEW Sales.VEmpOrders;
IF OBJECT_ID('Production.TopProducts') IS NOT NULL
	DROP FUNCTION Production.TopProducts;


