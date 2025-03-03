--*************************************************************************--
-- Title: Assignment06
-- Author: KateHolzhauer
-- Desc: This file demonstrates how to use Views
-- Change Log: When,Who,What
-- 2025-02-25,KateHolzhauer,Created File
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment06DB_KateHolzhauer')
	 Begin 
	  Alter Database [Assignment06DB_KateHolzhauer] set Single_user With Rollback Immediate;
	  Drop Database Assignment06DB_KateHolzhauer;
	 End
	Create Database Assignment06DB_KateHolzhauer;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment06DB_KateHolzhauer;

-- Create Tables (Module 01)-- 
Create Table Categories
([CategoryID] [int] IDENTITY(1,1) NOT NULL 
,[CategoryName] [nvarchar](100) NOT NULL
);
go

Create Table Products
([ProductID] [int] IDENTITY(1,1) NOT NULL 
,[ProductName] [nvarchar](100) NOT NULL 
,[CategoryID] [int] NULL  
,[UnitPrice] [mOney] NOT NULL
);
go

Create Table Employees -- New Table
([EmployeeID] [int] IDENTITY(1,1) NOT NULL 
,[EmployeeFirstName] [nvarchar](100) NOT NULL
,[EmployeeLastName] [nvarchar](100) NOT NULL 
,[ManagerID] [int] NULL  
);
go

Create Table Inventories
([InventoryID] [int] IDENTITY(1,1) NOT NULL
,[InventoryDate] [Date] NOT NULL
,[EmployeeID] [int] NOT NULL -- New Column
,[ProductID] [int] NOT NULL
,[Count] [int] NOT NULL
);
go

-- Add Constraints (Module 02) -- 
Begin  -- Categories
	Alter Table Categories 
	 Add Constraint pkCategories 
	  Primary Key (CategoryId);

	Alter Table Categories 
	 Add Constraint ukCategories 
	  Unique (CategoryName);
End
go 

Begin -- Products
	Alter Table Products 
	 Add Constraint pkProducts 
	  Primary Key (ProductId);

	Alter Table Products 
	 Add Constraint ukProducts 
	  Unique (ProductName);

	Alter Table Products 
	 Add Constraint fkProductsToCategories 
	  Foreign Key (CategoryId) References Categories(CategoryId);

	Alter Table Products 
	 Add Constraint ckProductUnitPriceZeroOrHigher 
	  Check (UnitPrice >= 0);
End
go

Begin -- Employees
	Alter Table Employees
	 Add Constraint pkEmployees 
	  Primary Key (EmployeeId);

	Alter Table Employees 
	 Add Constraint fkEmployeesToEmployeesManager 
	  Foreign Key (ManagerId) References Employees(EmployeeId);
End
go

Begin -- Inventories
	Alter Table Inventories 
	 Add Constraint pkInventories 
	  Primary Key (InventoryId);

	Alter Table Inventories
	 Add Constraint dfInventoryDate
	  Default GetDate() For InventoryDate;

	Alter Table Inventories
	 Add Constraint fkInventoriesToProducts
	  Foreign Key (ProductId) References Products(ProductId);

	Alter Table Inventories 
	 Add Constraint ckInventoryCountZeroOrHigher 
	  Check ([Count] >= 0);

	Alter Table Inventories
	 Add Constraint fkInventoriesToEmployees
	  Foreign Key (EmployeeId) References Employees(EmployeeId);
End 
go

-- Adding Data (Module 04) -- 
Insert Into Categories 
(CategoryName)
Select CategoryName 
 From Northwind.dbo.Categories
 Order By CategoryID;
go

Insert Into Products
(ProductName, CategoryID, UnitPrice)
Select ProductName,CategoryID, UnitPrice 
 From Northwind.dbo.Products
  Order By ProductID;
go

Insert Into Employees
(EmployeeFirstName, EmployeeLastName, ManagerID)
Select E.FirstName, E.LastName, IsNull(E.ReportsTo, E.EmployeeID) 
 From Northwind.dbo.Employees as E
  Order By E.EmployeeID;
go

Insert Into Inventories
(InventoryDate, EmployeeID, ProductID, [Count])
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, UnitsInStock
From Northwind.dbo.Products
UNIOn
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, UnitsInStock + 10 -- Using this is to create a made up value
From Northwind.dbo.Products
UNIOn
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, UnitsInStock + 20 -- Using this is to create a made up value
From Northwind.dbo.Products
Order By 1, 2
go

-- Show the Current data in the Categories, Products, and Inventories Tables
Select * From Categories;
go
Select * From Products;
go
Select * From Employees;
go
Select * From Inventories;
go

/********************************* Questions and Answers *********************************/
print 
'NOTES------------------------------------------------------------------------------------ 
 1) You can use any name you like for you views, but be descriptive and consistent
 2) You can use your working code from assignment 5 for much of this assignment
 3) You must use the BASIC views for each table after they are created in Question 1
------------------------------------------------------------------------------------------'
GO

-- Question 1 (5% pts): How can you create BACIC views to show data from each table in the database.
-- NOTES: 1) Do not use a *, list out each column!
--        2) Create one view per table!
--		  3) Use SchemaBinding to protect the views from being orphaned!

---- Basic select statements for the 4 tables:
--SELECT CategoryID, CategoryName
--	FROM Categories;
--GO

--SELECT ProductID, ProductName, CategoryID, UnitPrice
--	FROM Products;
--GO

--SELECT EmployeeID, EmployeeFirstName, EmployeeLastName, ManagerID
--	FROM Employees;
--GO

--SELECT InventoryID, InventoryDate, EmployeeID, ProductID, Count
--	FROM Inventories;
--GO

---- Create views for the 4 tables
-- Categories
CREATE VIEW [dbo].[vCategories]
	WITH SchemaBinding
	AS
		SELECT CategoryID, CategoryName
			FROM dbo.Categories;
GO

-- Products
CREATE VIEW [dbo].[vProducts]
	WITH SchemaBinding
	AS
		SELECT ProductID, ProductName, CategoryID, UnitPrice
			FROM dbo.Products;
GO

-- Employees
CREATE VIEW [dbo].[vEmployees]
	WITH SchemaBinding
	AS
		SELECT EmployeeID, EmployeeFirstName, EmployeeLastName, ManagerID
			FROM dbo.Employees;
GO

-- Inventories
CREATE VIEW [dbo].[vInventories]
	WITH SchemaBinding
	AS
		SELECT InventoryID, InventoryDate, EmployeeID, ProductID, Count
			FROM dbo.Inventories;
GO


-- Question 2 (5% pts): How can you set permissions, so that the public group CANNOT select data 
-- from each table, but can select data from each view?
USE Assignment06DB_KateHolzhauer;
DENY SELECT ON Categories TO Public;
DENY SELECT ON Products TO Public;
DENY SELECT ON Employees TO Public;
DENY SELECT ON Inventories TO Public;
GO

GRANT SELECT ON vCategories TO Public;
GRANT SELECT ON vProducts TO Public;
GRANT SELECT ON vEmployees TO Public;
GRANT SELECT ON vInventories TO Public;
GO

-- Question 3 (10% pts): How can you create a view to show a list of Category and Product names, 
-- and the price of each product?
-- Order the result by the Category and Product!

---- Select statement
--SELECT CategoryName, ProductName, UnitPrice
--	FROM Categories 
--		JOIN Products
--			ON Categories.CategoryID = Products.CategoryID
--	ORDER BY CategoryName, ProductName;
--GO

-- Add view
CREATE VIEW [dbo].[vProductsByCategories]
	AS
		SELECT TOP 100000 CategoryName, ProductName, UnitPrice
			FROM vCategories 
				JOIN vProducts
					ON vCategories.CategoryID = vProducts.CategoryID
			ORDER BY CategoryName, ProductName;
GO


-- Question 4 (10% pts): How can you create a view to show a list of Product names 
-- and Inventory Counts on each Inventory Date?
-- Order the results by the Product, Date, and Count!

---- Select statement
--SELECT ProductName, InventoryDate, Count
--	FROM Products
--		JOIN Inventories
--			ON Products.ProductID = Inventories.ProductID
--	ORDER BY ProductName, InventoryDate, Count;
--GO

-- Add view
CREATE VIEW [dbo].[vInventoriesByProductsByDates]
	AS
		SELECT TOP 100000 ProductName, InventoryDate, Count
			FROM vProducts
				JOIN vInventories
					ON vProducts.ProductID = vInventories.ProductID
			ORDER BY ProductName, InventoryDate, Count;
GO


-- Question 5 (10% pts): How can you create a view to show a list of Inventory Dates 
-- and the Employee that took the count?
-- Order the results by the Date and return only one row per date!

-- Here is are the rows selected from the view:

-- InventoryDate	EmployeeName
-- 2017-01-01	    Steven Buchanan
-- 2017-02-01	    Robert King
-- 2017-03-01	    Anne Dodsworth

----Select statement
--SELECT DISTINCT InventoryDate, EmployeeName = EmployeeFirstName + ' ' + EmployeeLastName
--	FROM Inventories
--		JOIN Employees
--			ON Inventories.EmployeeID = Employees.EmployeeID
--	ORDER BY InventoryDate;
-- GO

-- Add view
CREATE VIEW [dbo].[vInventoriesByEmployeesByDates]
	AS
		SELECT DISTINCT TOP 100000 InventoryDate, EmployeeName = EmployeeFirstName + ' ' + EmployeeLastName
			FROM vInventories
				JOIN vEmployees
					ON vInventories.EmployeeID = vEmployees.EmployeeID
			ORDER BY InventoryDate;
GO


-- Question 6 (10% pts): How can you create a view show a list of Categories, Products, 
-- and the Inventory Date and Count of each product?
-- Order the results by the Category, Product, Date, and Count!

----Select statement
--SELECT CategoryName, ProductName, InventoryDate, Count
--	FROM Inventories
--		JOIN Products
--			ON Products.ProductID=Inventories.ProductID 
--		JOIN Categories
--			ON Categories.CategoryID=Products.CategoryID
--	ORDER BY CategoryName, ProductName, InventoryDate, Count;
--GO

-- Add view
CREATE VIEW [dbo].[vInventoriesByProductsByCategories]
	AS
		SELECT TOP 100000 CategoryName, ProductName, InventoryDate, Count
			FROM vInventories
				JOIN vProducts
					ON vProducts.ProductID = vInventories.ProductID 
				JOIN vCategories
					ON vCategories.CategoryID = vProducts.CategoryID
			ORDER BY CategoryName, ProductName, InventoryDate, Count;
GO


-- Question 7 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the EMPLOYEE who took the count?
-- Order the results by the Inventory Date, Category, Product and Employee!

----Select statement
--SELECT CategoryName, ProductName, InventoryDate, Count, EmployeeName = EmployeeFirstName + ' ' + EmployeeLastName
--	FROM Inventories
--		JOIN Products
--			ON Products.ProductID=Inventories.ProductID 
--		JOIN Categories
--			ON Categories.CategoryID=Products.CategoryID
--		JOIN Employees
--			ON Employees.EmployeeID = Inventories.EmployeeID
--	ORDER BY InventoryDate, CategoryName, ProductName, EmployeeFirstName + ' ' + EmployeeLastName;
--GO

-- Add view
CREATE VIEW [dbo].[vInventoriesByProductsByEmployees]
	AS
		SELECT TOP 100000 CategoryName, ProductName, InventoryDate, Count, EmployeeName = EmployeeFirstName + ' ' + EmployeeLastName
			FROM vInventories
				JOIN vProducts
					ON vProducts.ProductID = vInventories.ProductID 
				JOIN vCategories
					ON vCategories.CategoryID = vProducts.CategoryID
				JOIN vEmployees
					ON vEmployees.EmployeeID = vInventories.EmployeeID
			ORDER BY InventoryDate, CategoryName, ProductName, EmployeeFirstName + ' ' + EmployeeLastName;
GO


-- Question 8 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the Employee who took the count
-- for the Products 'Chai' and 'Chang'? 

----Select statement
--SELECT CategoryName, ProductName, InventoryDate, Count, EmployeeName = EmployeeFirstName + ' ' + EmployeeLastName
--	FROM Inventories
--		JOIN Products
--			ON Products.ProductID=Inventories.ProductID 
--		JOIN Categories
--			ON Categories.CategoryID=Products.CategoryID
--		JOIN Employees
--			ON Employees.EmployeeID = Inventories.EmployeeID
--	WHERE Inventories.ProductID IN (SELECT ProductID FROM Products WHERE ProductName IN ('Chai', 'Chang'))
--	ORDER BY InventoryDate, CategoryName, ProductName;
--GO

-- Add view
CREATE VIEW [dbo].[vInventoriesForChaiAndChangByEmployees]
	AS
		SELECT TOP 100000 CategoryName, ProductName, InventoryDate, Count, EmployeeName = EmployeeFirstName + ' ' + EmployeeLastName
			FROM vInventories
				JOIN vProducts
					ON vProducts.ProductID = vInventories.ProductID 
				JOIN vCategories
					ON vCategories.CategoryID = vProducts.CategoryID
				JOIN vEmployees
					ON vEmployees.EmployeeID = vInventories.EmployeeID
			WHERE vInventories.ProductID IN (SELECT ProductID FROM vProducts WHERE ProductName IN ('Chai', 'Chang'))
			ORDER BY InventoryDate, CategoryName, ProductName;
GO


-- Question 9 (10% pts): How can you create a view to show a list of Employees and the Manager who manages them?
-- Order the results by the Manager's name!
CREATE VIEW [dbo].[vEmployeesByManager]
	AS
		SELECT TOP 100000 m.EmployeeFirstName + ' ' + m.EmployeeLastName AS Manager, 
					e.EmployeeFirstName + ' ' + e.EmployeeLastName AS Employee
			FROM vEmployees AS e
				JOIN vEmployees AS m
					ON e.ManagerID = m.EmployeeID
			ORDER BY 1,2;
GO


-- Question 10 (20% pts): How can you create one view to show all the data from all four 
-- BASIC Views? Also show the Employee's Manager Name and order the data by 
-- Category, Product, InventoryID, and Employee.

----Select statement
--SELECT Categories.CategoryID, CategoryName, Products.ProductID, ProductName, UnitPrice, InventoryID, InventoryDate, Count, E.EmployeeID, Employee = E.EmployeeFirstName + ' ' + E.EmployeeLastName, Manager = M.EmployeeFirstName + ' ' + M.EmployeeLastName
--	FROM Categories
--		JOIN Products
--			ON Categories.CategoryID = Products.CategoryID
--		JOIN Inventories
--			ON Products.ProductID = Inventories.ProductID 
--		JOIN Employees AS E
--			ON Inventories.EmployeeID = E.EmployeeID
--		JOIN Employees AS M
--			ON E.ManagerID = M.EmployeeID
--	ORDER BY CategoryName, ProductID, InventoryID, E.EmployeeFirstName + ' ' + E.EmployeeLastName
--GO

CREATE VIEW [dbo].[vInventoriesByProductsByCategoriesByEmployees]
	AS
		SELECT TOP 100000 vCategories.CategoryID, CategoryName, vProducts.ProductID, ProductName, UnitPrice, InventoryID, InventoryDate, Count, E.EmployeeID, Employee = E.EmployeeFirstName + ' ' + E.EmployeeLastName, Manager = M.EmployeeFirstName + ' ' + M.EmployeeLastName
			FROM vCategories
				JOIN vProducts
					ON vCategories.CategoryID = vProducts.CategoryID
				JOIN vInventories
					ON vProducts.ProductID = vInventories.ProductID 
				JOIN vEmployees AS E
					ON vInventories.EmployeeID = E.EmployeeID
				JOIN vEmployees AS M
					ON E.ManagerID = M.EmployeeID
			ORDER BY CategoryName, ProductID, InventoryID, E.EmployeeFirstName + ' ' + E.EmployeeLastName;
GO

-- Test your Views (NOTE: You must change the your view names to match what I have below!)
Print 'Note: You will get an error until the views are created!'
Select * From [dbo].[vCategories]
Select * From [dbo].[vProducts]
Select * From [dbo].[vInventories]
Select * From [dbo].[vEmployees]

Select * From [dbo].[vProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByDates]
Select * From [dbo].[vInventoriesByEmployeesByDates]
Select * From [dbo].[vInventoriesByProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByEmployees]
Select * From [dbo].[vInventoriesForChaiAndChangByEmployees]
Select * From [dbo].[vEmployeesByManager]
Select * From [dbo].[vInventoriesByProductsByCategoriesByEmployees]

/***************************************************************************************/