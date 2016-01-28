select HR.Employees.empid, hr.Employees.firstname, hr.Employees.lastname, dbo.nums.n
FROM HR.Employees
CROSS JOIN dbo.Nums
where n < 6
ORDER BY n, empid;
