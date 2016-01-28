SELECT empid, firstname, lastname
FROM HR.Employees
WHERE LEN(lastname) - LEN(REPLACE(lastname, 'a', '')) > 1

--ALTERNATE SOLUTION BELOWS

SELECT empid, firstname, lastname
FROM HR.Employees
WHERE lastname LIKE '%a%a%';