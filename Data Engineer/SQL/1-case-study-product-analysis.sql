-- Product Analysis -- Western
use Northwind;

-- 1. PRODUCT ANALYSIS
-- overall picture of sales
SELECT

	YEAR(ord.OrderDate) AS 'year'
	, MONTH(ord.OrderDate) AS 'month'
	, SUM(od.UnitPrice * od.Quantity) AS 'sum_sales'
	, ROUND(100.0*(SUM(od.UnitPrice * od.Quantity) - LAG(SUM(od.UnitPrice * od.Quantity), 1) OVER(ORDER BY YEAR(ord.OrderDate), MONTH(ord.OrderDate))) / 
			LAG(SUM(od.UnitPrice * od.Quantity), 1) OVER(ORDER BY YEAR(ord.OrderDate), MONTH(ord.OrderDate)), 2) AS '%_chg_sum_sales'
	
	, AVG(od.UnitPrice * od.Quantity) AS 'avg_sales'
	, COUNT(od.UnitPrice * od.Quantity) AS 'vol_sales'

	, SUM(od.Quantity) AS 'sum_qty'
	, ROUND(100.0*(SUM(od.Quantity) - LAG(SUM(od.Quantity), 1) OVER(ORDER BY YEAR(ord.OrderDate), MONTH(ord.OrderDate))) / 
			LAG(SUM(od.Quantity), 1) OVER(ORDER BY YEAR(ord.OrderDate), MONTH(ord.OrderDate)), 2) AS '%_chg_sum_qty'

	, AVG(od.UnitPrice) AS 'avg_u_price'
	, ROUND(100.0*(AVG(od.UnitPrice) - LAG(AVG(od.UnitPrice), 1) OVER(ORDER BY YEAR(ord.OrderDate), MONTH(ord.OrderDate))) / 
			LAG(AVG(od.UnitPrice), 1) OVER(ORDER BY YEAR(ord.OrderDate), MONTH(ord.OrderDate)), 2) AS '%_chg_avg_u_price'

FROM Orders ord
JOIN [Order Details] od ON ord.OrderID = od.OrderID
GROUP BY YEAR(ord.OrderDate), MONTH(ord.OrderDate)
ORDER BY YEAR(ord.OrderDate), MONTH(ord.OrderDate)
;

-- because only in 1997 that capture the full date -> focusing analysis in 1997 only
-- pareto customer's company on sales in 1997
WITH company_sales AS
	(SELECT
		c.CompanyName
		, SUM(od.UnitPrice*od.Quantity) as 'sum_sales'
	FROM Orders ord
	JOIN Customers c ON ord.CustomerID = c.CustomerID
	JOIN [Order Details] od ON ord.OrderID = od.OrderID
	WHERE ord.OrderDate BETWEEN '1997-01-01' AND '1997-12-31'
	GROUP BY c.CompanyName)

SELECT 
	*
	, 100.0 * sum_sales / (SELECT SUM(sum_sales) FROM company_sales) AS '%_sales'
	, 100.0 * SUM(sum_sales) OVER(ORDER BY sum_sales DESC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) / (SELECT SUM(sum_sales) FROM company_sales) as '%_cumsum_sales'
FROM company_sales
;

-- pareto product name on sales
WITH product_sales AS
	(SELECT
		prod.ProductName
		, SUM(od.UnitPrice*od.Quantity) as 'sum_sales'
	FROM Orders ord	
	JOIN [Order Details] od ON ord.OrderID = od.OrderID
	JOIN Products prod ON od.ProductID = prod.ProductID
	WHERE ord.OrderDate BETWEEN '1997-01-01' AND '1997-12-31'
	GROUP BY prod.ProductName)

SELECT 
	*
	, 100.0 * sum_sales / (SELECT SUM(sum_sales) FROM product_sales) AS '%_sales'
	, 100.0 * SUM(sum_sales) OVER(ORDER BY sum_sales DESC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) / (SELECT SUM(sum_sales) FROM product_sales) as '%_cumsum_sales'
FROM product_sales
;

-- pareto category name on sales
WITH category_sales AS
	(SELECT
		cat.CategoryName
		, SUM(od.UnitPrice*od.Quantity) as 'sum_sales'
	FROM Orders ord	
	JOIN [Order Details] od ON ord.OrderID = od.OrderID
	JOIN Products prod ON od.ProductID = prod.ProductID
	JOIN Categories cat ON prod.CategoryID = cat.CategoryID
	WHERE ord.OrderDate BETWEEN '1997-01-01' AND '1997-12-31'
	GROUP BY cat.CategoryName)

SELECT 
	*
	, 100.0 * sum_sales / (SELECT SUM(sum_sales) FROM category_sales) AS '%_sales'
	, 100.0 * SUM(sum_sales) OVER(ORDER BY sum_sales DESC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) / (SELECT SUM(sum_sales) FROM category_sales) as '%_cumsum_sales'
FROM category_sales
;

-- pareto sales's teritory on sales
WITH teritory_sales AS
	(SELECT
		t.TerritoryDescription
		, SUM(od.UnitPrice*od.Quantity) as 'sum_sales'
	FROM Orders ord	
	JOIN [Order Details] od ON ord.OrderID = od.OrderID
	JOIN Employees e ON e.EmployeeID = ord.EmployeeID
	JOIN EmployeeTerritories et ON et.EmployeeID = ord.EmployeeID
	JOIN Territories t ON et.TerritoryID = t.TerritoryID
	WHERE ord.OrderDate BETWEEN '1997-01-01' AND '1997-12-31'
	GROUP BY t.TerritoryDescription)

SELECT 
	*
	, 100.0 * sum_sales / (SELECT SUM(sum_sales) FROM teritory_sales) AS '%_sales'
	, 100.0 * SUM(sum_sales) OVER(ORDER BY sum_sales DESC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) / (SELECT SUM(sum_sales) FROM teritory_sales) as '%_cumsum_sales'
FROM teritory_sales
;

-- pareto sales's region on sales
WITH region_sales AS
	(SELECT
		r.RegionDescription
		, SUM(od.UnitPrice*od.Quantity) as 'sum_sales'
	FROM Orders ord	
	JOIN [Order Details] od ON ord.OrderID = od.OrderID
	JOIN Employees e ON e.EmployeeID = ord.EmployeeID
	JOIN EmployeeTerritories et ON et.EmployeeID = ord.EmployeeID
	JOIN Territories t ON et.TerritoryID = t.TerritoryID
	JOIN Region r ON r.RegionID = t.RegionID
	WHERE ord.OrderDate BETWEEN '1997-01-01' AND '1997-12-31'
	GROUP BY r.RegionDescription)

SELECT 
	*
	, 100.0 * sum_sales / (SELECT SUM(sum_sales) FROM region_sales) AS '%_sales'
	, 100.0 * SUM(sum_sales) OVER(ORDER BY sum_sales DESC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) / (SELECT SUM(sum_sales) FROM region_sales) as '%_cumsum_sales'
FROM region_sales
;

-- pareto territory name on sales in Western region
-- territory in Western with the highest sales
WITH territory_sales AS
	(SELECT
		t.TerritoryDescription
		, SUM(od.UnitPrice*od.Quantity) as 'sum_sales'
	FROM Orders ord	
	JOIN [Order Details] od ON ord.OrderID = od.OrderID
	JOIN Employees e ON e.EmployeeID = ord.EmployeeID
	JOIN EmployeeTerritories et ON et.EmployeeID = ord.EmployeeID
	JOIN Territories t ON et.TerritoryID = t.TerritoryID
	JOIN Region r ON r.RegionID = t.RegionID
	WHERE (ord.OrderDate BETWEEN '1997-01-01' AND '1997-12-31') AND (RegionDescription = 'Western')
	GROUP BY t.TerritoryDescription)

SELECT 
	*
	, 100.0 * sum_sales / (SELECT SUM(sum_sales) FROM territory_sales) AS '%_sales'
	, 100.0 * SUM(sum_sales) OVER(ORDER BY sum_sales DESC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) / (SELECT SUM(sum_sales) FROM territory_sales) as '%_cumsum_sales'
FROM territory_sales
;


-- pareto category name on sales in Western region
-- category name in Western with the highest sales
WITH category_sales AS
	(SELECT
		cat.CategoryName
		, SUM(od.UnitPrice*od.Quantity) as 'sum_sales'
	FROM Orders ord	
	JOIN [Order Details] od ON ord.OrderID = od.OrderID
	JOIN Products prod ON od.ProductID = prod.ProductID
	JOIN Categories cat ON prod.CategoryID = cat.CategoryID
	JOIN Employees e ON e.EmployeeID = ord.EmployeeID
	JOIN EmployeeTerritories et ON et.EmployeeID = ord.EmployeeID
	JOIN Territories t ON et.TerritoryID = t.TerritoryID
	JOIN Region r ON r.RegionID = t.RegionID
	WHERE (ord.OrderDate BETWEEN '1997-01-01' AND '1997-12-31') AND (RegionDescription = 'Western')
	GROUP BY cat.CategoryName)

SELECT 
	*
	, 100.0 * sum_sales / (SELECT SUM(sum_sales) FROM category_sales) AS '%_sales'
	, 100.0 * SUM(sum_sales) OVER(ORDER BY sum_sales DESC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) / (SELECT SUM(sum_sales) FROM category_sales) as '%_cumsum_sales'
FROM category_sales
;

-- pareto product name on sales in Western region
-- product name in Western with the highest sales
WITH product_sales AS
	(SELECT
		prod.ProductName
		, SUM(od.UnitPrice*od.Quantity) as 'sum_sales'
	FROM Orders ord	
	JOIN [Order Details] od ON ord.OrderID = od.OrderID
	JOIN Products prod ON od.ProductID = prod.ProductID
	JOIN Categories cat ON prod.CategoryID = cat.CategoryID
	JOIN EmployeeTerritories et ON et.EmployeeID = ord.EmployeeID
	JOIN Territories t ON et.TerritoryID = t.TerritoryID
	JOIN Region r ON r.RegionID = t.RegionID
	WHERE (ord.OrderDate BETWEEN '1997-01-01' AND '1997-12-31') AND (RegionDescription = 'Western')
	GROUP BY prod.ProductName)

SELECT 
	*
	, 100.0 * sum_sales / (SELECT SUM(sum_sales) FROM product_sales) AS '%_sales'
	, 100.0 * SUM(sum_sales) OVER(ORDER BY sum_sales DESC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) / (SELECT SUM(sum_sales) FROM product_sales) as '%_cumsum_sales'
FROM product_sales
;


-----
-----
-- Analyze the spike phenomena on Nov 97 to Apr 98 period

-- pareto sales's region on sales on Nov 97 to Apr 98 period
WITH region_sales AS
	(SELECT
		r.RegionDescription
		, SUM(od.UnitPrice*od.Quantity) as 'sum_sales'
	FROM Orders ord	
	JOIN [Order Details] od ON ord.OrderID = od.OrderID
	JOIN EmployeeTerritories et ON et.EmployeeID = ord.EmployeeID
	JOIN Territories t ON et.TerritoryID = t.TerritoryID
	JOIN Region r ON r.RegionID = t.RegionID
	WHERE ord.OrderDate BETWEEN '1997-11-01' AND '1998-04-30'
	GROUP BY r.RegionDescription)

SELECT 
	*
	, 100.0 * sum_sales / (SELECT SUM(sum_sales) FROM region_sales) AS '%_sales'
	, 100.0 * SUM(sum_sales) OVER(ORDER BY sum_sales DESC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) / (SELECT SUM(sum_sales) FROM region_sales) as '%_cumsum_sales'
FROM region_sales
;


-- pareto territory name on sales in Western region
-- territory in Western with the highest sales on Nov 97 to Apr 98 period
WITH territory_sales AS
	(SELECT
		t.TerritoryDescription
		, SUM(od.UnitPrice*od.Quantity) as 'sum_sales'
	FROM Orders ord	
	JOIN [Order Details] od ON ord.OrderID = od.OrderID
	JOIN Employees e ON e.EmployeeID = ord.EmployeeID
	JOIN EmployeeTerritories et ON et.EmployeeID = ord.EmployeeID
	JOIN Territories t ON et.TerritoryID = t.TerritoryID
	JOIN Region r ON r.RegionID = t.RegionID
	WHERE (ord.OrderDate BETWEEN '1997-11-01' AND '1998-04-30') AND (RegionDescription = 'Western')
	GROUP BY t.TerritoryDescription)

SELECT 
	*
	, 100.0 * sum_sales / (SELECT SUM(sum_sales) FROM territory_sales) AS '%_sales'
	, 100.0 * SUM(sum_sales) OVER(ORDER BY sum_sales DESC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) / (SELECT SUM(sum_sales) FROM territory_sales) as '%_cumsum_sales'
FROM territory_sales
;

-- pareto category name on sales in Western region
-- category name in Western with the highest sales on Nov 97 to Apr 98 period
WITH category_sales AS
	(SELECT
		cat.CategoryName
		, SUM(od.UnitPrice*od.Quantity) as 'sum_sales'
	FROM Orders ord	
	JOIN [Order Details] od ON ord.OrderID = od.OrderID
	JOIN Products prod ON od.ProductID = prod.ProductID
	JOIN Categories cat ON prod.CategoryID = cat.CategoryID
	JOIN Employees e ON e.EmployeeID = ord.EmployeeID
	JOIN EmployeeTerritories et ON et.EmployeeID = ord.EmployeeID
	JOIN Territories t ON et.TerritoryID = t.TerritoryID
	JOIN Region r ON r.RegionID = t.RegionID
	WHERE (ord.OrderDate BETWEEN '1997-11-01' AND '1998-04-30') AND (RegionDescription = 'Western')
	GROUP BY cat.CategoryName)

SELECT 
	*
	, 100.0 * sum_sales / (SELECT SUM(sum_sales) FROM category_sales) AS '%_sales'
	, 100.0 * SUM(sum_sales) OVER(ORDER BY sum_sales DESC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) / (SELECT SUM(sum_sales) FROM category_sales) as '%_cumsum_sales'
FROM category_sales
;

-- pareto category name on sales in Western region
-- product name in Western with the highest sales on Nov 97 to Apr 98 period
WITH product_sales AS
	(SELECT
		prod.ProductName
		, SUM(od.UnitPrice*od.Quantity) as 'sum_sales'
	FROM Orders ord	
	JOIN [Order Details] od ON ord.OrderID = od.OrderID
	JOIN Products prod ON od.ProductID = prod.ProductID
	JOIN Categories cat ON prod.CategoryID = cat.CategoryID
	JOIN EmployeeTerritories et ON et.EmployeeID = ord.EmployeeID
	JOIN Territories t ON et.TerritoryID = t.TerritoryID
	JOIN Region r ON r.RegionID = t.RegionID
	WHERE (ord.OrderDate BETWEEN '1997-11-01' AND '1998-04-30') AND (RegionDescription = 'Western')
	GROUP BY prod.ProductName)

SELECT 
	*
	, 100.0 * sum_sales / (SELECT SUM(sum_sales) FROM product_sales) AS '%_sales'
	, 100.0 * SUM(sum_sales) OVER(ORDER BY sum_sales DESC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) / (SELECT SUM(sum_sales) FROM product_sales) as '%_cumsum_sales'
FROM product_sales
;