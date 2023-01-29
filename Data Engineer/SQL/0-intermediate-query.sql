-- soal 1

SELECT DATEPART(MONTH, OrderDate) as month, 
	COUNT(CustomerID) as num_customer
		FROM Orders
			WHERE OrderDate BETWEEN '1997-01-01' AND '1997-12-31'
				GROUP BY DATEPART(MONTH, OrderDate)

---------------------------------------------------------
-- soal 2
SELECT CONCAT(FirstName, ' ', LastName) AS Name FROM Employees
	WHERE Title = 'Sales Representative';

---------------------------------------------------------
-- soal 3
SELECT p.ProductName, SUM(d.Quantity) as tot_quantity
	FROM Orders o
		JOIN [Order Details] d ON o.OrderID = d.OrderID
		JOIN Products p ON d.ProductID = p.ProductID
	WHERE OrderDate BETWEEN '1997-01-01' AND '1997-01-31'
		GROUP BY p.ProductName
		ORDER BY SUM(d.Quantity) DESC
			OFFSET 0 ROWS 
				FETCH NEXT 5 ROWS ONLY;

---------------------------------------------------------
-- soal 4
SELECT DISTINCT com.CompanyName FROM Orders ord
	JOIN [Order Details] det ON ord.OrderID = det.OrderID
	JOIN Products prod ON det.ProductID = prod.ProductID
	JOIN Customers com ON ord.CustomerID = com.CustomerID
	WHERE (ProductName = 'Chai') AND (OrderDate BETWEEN '1997-06-01' AND '1997-06-30')
		ORDER BY 1

---------------------------------------------------------
-- soal 5
WITH sales_table(OrderID, sales) AS(SELECT OrderID, SUM(UnitPrice*Quantity)
	FROM [Order Details]
		GROUP BY OrderID)
SELECT
	COUNT(CASE WHEN sales<=100 THEN OrderID ELSE NULL END) AS 'sales<=100', 
	COUNT(CASE WHEN (sales>100) AND (sales<=250) THEN OrderID ELSE NULL END) AS '100< sales <=250',
	COUNT(CASE WHEN (sales>250) AND (sales<=500) THEN OrderID ELSE NULL END) AS '250< sales <=500',
	COUNT(CASE WHEN sales>500 THEN OrderID ELSE NULL END) AS 'sales>500'
FROM sales_table;

---------------------------------------------------------
-- soal 6
WITH sales_table(OrderID, sales) AS(SELECT OrderID, SUM(UnitPrice*Quantity)
	FROM [Order Details]
	GROUP BY OrderID)
SELECT
	DISTINCT CompanyName FROM sales_table s
		JOIN Orders ord ON s.OrderID = ord.OrderID
		JOIN Customers cus ON ord.CustomerID = cus.CustomerID
	WHERE (sales>500) AND (OrderDate BETWEEN '1997-01-01' AND '1997-12-31');

---------------------------------------------------------
-- soal 7
WITH sales_product(month, ProductName, sales, ranking) AS(SELECT MONTH(o.OrderDate), ProductName, 
					SUM(d.UnitPrice*d.Quantity), ROW_NUMBER() OVER(PARTITION BY MONTH(o.OrderDate) 
					ORDER BY SUM(d.UnitPrice*d.Quantity) DESC)
	FROM Orders o
		JOIN [Order Details] d ON o.OrderID = d.OrderID
		JOIN Products p ON d.ProductID = p.ProductID
	WHERE OrderDate BETWEEN '1997-01-01' AND '1997-12-31'
	GROUP BY MONTH(o.OrderDate), ProductName)
SELECT * FROM sales_product WHERE ranking <= 5 ORDER BY 'month', ranking;

---------------------------------------------------------
-- soal 8
-- using Northwind database
USE Northwind;
GO
-- creating the view
CREATE VIEW v_order_details (OrderID, ProductID, ProductName, UnitPrice, Quantity, Discount, discounted_price)
	AS
		SELECT
			ord.OrderID, ord.ProductID, ProductName, ord.UnitPrice, 
			ord.Quantity, ord.Discount, (1.0 - ord.Discount) * ord.UnitPrice
	FROM [Order Details] ord
	JOIN Products prod ON ord.ProductID = prod.ProductID;
GO
-- checking the view
SELECT * FROM v_order_details;

---------------------------------------------------------
-- soal 9
DROP PROCEDURE IF EXISTS pr_invoice;
GO
CREATE PROCEDURE pr_invoice (@cust_id AS nchar(5)) AS
 BEGIN
	SELECT
		ord.CustomerID, cus.ContactName, 
		ord.OrderID, ord.OrderDate, 
		ord.RequiredDate, ord.ShippedDate
	FROM Orders ord
	JOIN Customers cus ON ord.CustomerID = cus.CustomerID
	WHERE ord.CustomerID = @cust_id
END;

GO

EXECUTE pr_invoice @cust_id = 'TOMSP';
EXECUTE pr_invoice @cust_id = 'VICTE';
