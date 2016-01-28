USE TSQL2012;

SELECT empid, firstname, lastname, titleofcourtesy, 
CASE 
	WHEN titleofcourtesy like '%M%s.%'	THEN 'Female'
	--ALTERNATIVELY:
	--WHEN titleofcourtesy IN('Ms.', 'Mrs.') THEN 'Female'
	WHEN titleofcourtesy = 'Mr.' THEN 'Male'
	ELSE 'Unknown'

END AS gender
FROM [TSQL2012].[HR].[Employees]

  ;