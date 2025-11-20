--*************************************************************************--
-- Title: Assignment06
-- Author: VBetin
-- Desc: This file demonstrates how to use Views
-- Change Log: When,Who,What
-- 2017-01-01,November 19, 2025, VBetin,Created File
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment06DB_VBetin')
	 Begin 
	  Alter Database [Assignment06DB_VBetin] set Single_user With Rollback Immediate;
	  Drop Database Assignment06DB_VBetin;
	 End
	Create Database Assignment06DB_VBetin;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment06DB_VBetin;

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

-- Question 1 (5% pts): How can you create BACIC views to show data from each table in the database.
-- NOTES: 1) Do not use a *, list out each column!
--        2) Create one view per table!
--		  3) Use SchemaBinding to protect the views from being orphaned!
go
Create View vCategories
With SchemaBinding
  AS 
    Select 
	  CategoryID
	  ,CategoryName
	    From dbo.Categories as C
go
Create View vProducts
With SchemaBinding
  AS 
    Select 
	  ProductID
	  ,ProductName
	  ,CategoryID
	  ,UnitPrice
	    From dbo.Products as P
go
Create View vEmployees
With SchemaBinding
  AS 
    Select 
	  EmployeeID
	  ,EmployeeFirstName
	  ,EmployeeLastName
	  ,ManagerID
	    From dbo.Employees as E
go
Create View vInventories
With SchemaBinding
  AS 
    Select 
	  InventoryID
	  ,InventoryDate
	  ,EmployeeID
	  ,ProductID
	  ,[Count]
	    From dbo.Inventories as I
go
-- Question 2 (5% pts): How can you set permissions, so that the public group CANNOT select data 
-- from each table, but can select data from each view?
Deny Select On Categories To Public;
Deny Select On Products To Public;
Deny Select On Employees To Public;
Deny Select On Inventories To Public;
go

Grant Select On vCategories To Public;
Grant Select On vProducts To Public;
Grant Select On vEmployees To Public;
Grant Select On vInventories To Public;
go

-- Question 3 (10% pts): How can you create a view to show a list of Category and Product names, 
-- and the price of each product?
-- Order the result by the Category and Product!

/*
			--1 LOOK AT ALL DATA--
			Select * From Categories;
			Select * From Products;

			--2 LOOK AT JUST THE DATA WE WANT--
			Select CategoryName From Categories;
			Select ProductName, UnitPrice From Products;

			--3 COMBINE RESULTS--
			Select CategoryName, ProductName, UnitPrice 
			From Categories Join Products 
					On Categories.CategoryID = Products.CategoryID;

			--4 ORDER BY RESULTS--
			Select CategoryName, ProductName, UnitPrice 
			From Categories Join Products 
					On Categories.CategoryID = Products.CategoryID
			Order By CategoryName, ProductName;

			--4 ADDING ALIAS TO FINAL CODE--
			Select CategoryName, ProductName, UnitPrice 
			From Categories as c Join Products as p
					On c.CategoryID = p.CategoryID
			Order By CategoryName, ProductName
*/
Create View vProductsByCategories
As
  Select Top 1000000
      C.CategoryName
    , P.ProductName
    , P.UnitPrice 
  From vCategories as C 
   Inner Join vProducts as P
	On c.CategoryID = P.CategoryID
  Order By c.CategoryName, P.ProductName, P.UnitPrice;
go

-- Question 4 (10% pts): How can you create a view to show a list of Product names 
-- and Inventory Counts on each Inventory Date?
-- Order the results by the Product, Date, and Count!
/*
			--1 LOOK AT ALL DATA--
			Select * From Products;
			Select * From Inventories;

			--2 LOOK AT JUST THE DATA WE WANT--
			Select ProductName From Products;
			Select InventoryDate, [Count] From Inventories;

			--3 COMBINE RESULTS--
			Select ProductName, InventoryDate, [Count] 
			From Products Join Inventories 
					On Products.ProductID = Inventories.ProductID;

			--4 ORDER BY RESULTS--
			Select ProductName, InventoryDate, [Count] 
			From Products Join Inventories 
					On Products.ProductID = Inventories.ProductID
			Order By ProductName, InventoryDate, [Count];

			--4 ADDING ALIAS TO FINAL CODE--
			Select ProductName, InventoryDate, [Count] 
			From Products as p Join Inventories as i
					On p.ProductID = i.ProductID
			Order By ProductName, InventoryDate, [Count];
*/
Create View vInventoriesByProductsByDates
As
  Select Top 1000000
      P.ProductName
    , I.InventoryDate
    , I.[Count]
  From vProducts as P 
   Inner Join vInventories as I
	On P.ProductID = I.ProductID
  Order By P.ProductName, I.InventoryDate, I.[Count];
go

-- Question 5 (10% pts): How can you create a view to show a list of Inventory Dates 
-- and the Employee that took the count?
-- Order the results by the Date and return only one row per date!

-- Here is are the rows selected from the view:

-- InventoryDate	EmployeeName
-- 2017-01-01	    Steven Buchanan
-- 2017-02-01	    Robert King
-- 2017-03-01	    Anne Dodsworth

/*
			--1 LOOK AT ALL DATA--
			Select * From Inventories;
			Select * From Employees;

			--2 LOOK AT JUST THE DATA WE WANT--
			Select InventoryDate From Inventories;
			Select EmployeeFirstName + ' ' + EmployeeLastName as EmployeeName From Employees;

			--3 COMBINE RESULTS--
			Select Distinct InventoryDate, EmployeeFirstName + ' ' + EmployeeLastName as EmployeeName
			From Iventories Join Employees 
					On Inventories.EmployeeID = Employees.EmployeeID;

			--4 ORDER BY RESULTS--
			Select Distinct InventoryDate, EmployeeFirstName + ' ' + EmployeeLastName as EmployeeName
			From Iventories Join Employees 
					On Inventories.EmployeeID = Employees.EmployeeID
			Order By InventoryDate;

			--4 ADDING ALIAS TO FINAL CODE--
			Select Distinct InventoryDate, EmployeeFirstName + ' ' + EmployeeLastName as EmployeeName
			From Iventories as i Join Employees as e
					On i.EmployeeID = e.EmployeeID
			Order By InventoryDate;
*/

Create View vInventoriesByEmployeesByDates
As
  Select Distinct Top 1000000
      I.InventoryDate
    , E.EmployeeFirstName + ' ' + e.EmployeeLastName as EmployeeName
  From vInventories as I 
   Inner Join vEmployees as E
    On I.EmployeeID = E.EmployeeID
  Order By I.InventoryDate;
go

-- Question 6 (10% pts): How can you create a view show a list of Categories, Products, 
-- and the Inventory Date and Count of each product?
-- Order the results by the Category, Product, Date, and Count!
/*
			--1 LOOK AT ALL DATA--
			Select * From Categories;
			Select * From Products;
			Select * From Inventories;

			--2 LOOK AT JUST THE DATA WE WANT--
			Select CategoryName From Categories;
			Select ProductName From Products;
			Select InventoryDate, [Count] From Inventories;

			--3 COMBINE RESULTS--
			Select CategoryName, ProductName, InventoryDate, [Count]
			From Inventories 
				Join Products
					On Inventories.ProductID = Products.ProductID
				Join Categories
					On Products.CategoryID = Categories.CategoryID;

			--4 ORDER BY RESULTS--
			Select CategoryName, ProductName, InventoryDate, [Count]
			From Inventories 
				Join Products
					On Inventories.ProductID = Products.ProductID
				Join Categories
					On Products.CategoryID = Categories.CategoryID
			Order By CategoryName, ProductName, InventoryDate, [Count];

			--4 ADDING ALIAS TO FINAL CODE--
			Select CategoryName, ProductName, InventoryDate, [Count]
			From Inventories as i
				Join Products as p
					On i.ProductID = p.ProductID
				Join Categories as c
					On p.CategoryID = c.CategoryID
			Order By CategoryName, ProductName, InventoryDate, [Count];

*/
Create View vInventoriesByProductsByCategories
As
 Select Top 1000000
    C.CategoryName
  , P.ProductName
  , I.InventoryDate
  , I.[Count]
 From vInventories as I
  Inner Join vProducts as P
   On I.ProductID = P.ProductID
  Inner Join Categories as C
   On P.CategoryID = C.CategoryID
 Order By C.CategoryName, P.ProductName, I.InventoryDate, I.[Count];
go

-- Question 7 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the EMPLOYEE who took the count?
-- Order the results by the Inventory Date, Category, Product and Employee!

/*
			--1 LOOK AT ALL DATA--
			Select * From Categories;
			Select * From Products;
			Select * From Inventories;
			Select * From Employees;

			--2 LOOK AT JUST THE DATA WE WANT--
			Select CategoryName From Categories;
			Select ProductName From Products;
			Select InventoryDate, [Count] From Inventories;
			Select EmployeeFirstName + ' ' + EmployeeLastName as EmployeeName From Employees;

			--3 COMBINE RESULTS--
			Select CategoryName, ProductName, InventoryDate, [Count], EmployeeFirstName + ' ' + EmployeeLastName as EmployeeName
			From Inventories 
				Join Products
					On Inventories.ProductID = Products.ProductID
				Join Categories
					On Products.CategoryID = Categories.CategoryID
				Join Employees
					On Employees.EmployeesID = Inventories.EmployeeID;
			--4 ORDER BY RESULTS--
			Select CategoryName, ProductName, InventoryDate, [Count], EmployeeFirstName + ' ' + EmployeeLastName as EmployeeName
			From Inventories 
				Join Products
					On Inventories.ProductID = Products.ProductID
				Join Categories
					On Products.CategoryID = Categories.CategoryID
				Join Employees
					On Employees.EmployeesID = Inventories.EmployeeID
			Order By InventoryDate, CategoryName, ProductName, EmployeeName;

			--4 ADDING ALIAS TO FINAL CODE--
			Select CategoryName, ProductName, InventoryDate, [Count], EmployeeFirstName + ' ' + EmployeeLastName as EmployeeName
			From Inventories  as i
				Join Products as p 
					On i.ProductID = p.ProductID
				Join Categories as c
					On p.CategoryID = c.CategoryID
				Join Employees as e
					On e.EmployeesID = i.EmployeeID
			Order By InventoryDate, CategoryName, ProductName, EmployeeName;
			*/
Create View vInventoriesByProductsByEmployees
As
 Select Top 1000000
    C.CategoryName
  , P.ProductName
  , I.InventoryDate
  , I.[Count]
  , E.EmployeeFirstName + ' ' + e.EmployeeLastName as EmployeeName
 From vInventories  as I
  Inner Join vEmployees as E
   On I.EmployeeID = E.EmployeeID
  Inner Join vProducts as P
   On I.ProductID = P.ProductID
  Inner Join vCategories as C
   On P.CategoryID = C.CategoryID
 Order By I.InventoryDate, C.CategoryName, P.ProductName, EmployeeName;
go

-- Question 8 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the Employee who took the count
-- for the Products 'Chai' and 'Chang'? 

/*

			--4 ADD SUBQUERY to get ProductID based on ProductName--
			Select CategoryName, ProductName, InventoryDate, [Count], EmployeeFirstName + ' ' + EmployeeLastName as EmployeeName
			From Inventories 
				Join Products
					On Inventories.ProductID = Products.ProductID
				Join Categories
					On Products.CategoryID = Categories.CategoryID
				Join Employees
					On Employees.EmployeesID = Inventories.EmployeeID
			Where ProductID in (Select ProductID
									From Products
									Where ProductName In ('Chai', 'Chang'));
			
			--5 ORDER BY RESULTS--
			Select CategoryName, ProductName, InventoryDate, [Count], EmployeeFirstName + ' ' + EmployeeLastName as EmployeeName
			From Inventories 
				Join Products
					On Inventories.ProductID = Products.ProductID
				Join Categories
					On Products.CategoryID = Categories.CategoryID
				Join Employees
					On Employees.EmployeesID = Inventories.EmployeeID
			Where Inventories.ProductID in (Select ProductID
									From Products
									Where ProductName In ('Chai', 'Chang'));
			Order By InventoryDate, CategoryName, ProductName, EmployeeName;

			--6 ADDING ALIAS TO FINAL CODE--
						Select 
						CategoryName
						, ProductName
						, InventoryDate
						, [Count]
						, EmployeeFirstName + ' ' + EmployeeLastName as EmployeeName
						From Inventories  as i
							Join Products as p 
								On i.ProductID = p.ProductID
							Join Categories as c
								On p.CategoryID = c.CategoryID
							Join Employees as e
								On e.EmployeeID = i.EmployeeID
						Where i.ProductID in (Select ProductID
										From Products
											Where ProductName In ('Chai', 'Chang'))
						Order By InventoryDate, CategoryName, ProductName, EmployeeName;

			*/
Create View vInventoriesForChaiAndChangByEmployees
As
 Select Top 1000000
    C.CategoryName
  , P.ProductName
  , I.InventoryDate
  , I.[Count]
  , E.EmployeeFirstName + ' ' + e.EmployeeLastName as EmployeeName
 From vInventories  as I
  Inner Join vEmployees as E
   On I.EmployeeID = E.EmployeeID
  Inner Join vProducts as P
   On I.ProductID = P.ProductID
  Inner Join vCategories as C
   On P.CategoryID = C.CategoryID
    Where I.ProductID in (Select ProductID
                           From Products
                            Where ProductName In ('Chai','Chang'))
 Order By I.InventoryDate, C.CategoryName, P.ProductName, EmployeeName;
go

-- Question 9 (10% pts): How can you create a view to show a list of Employees and the Manager who manages them?
-- Order the results by the Manager's name!
/*
				
		Select * From Employees

		Select ManagerID, EmployeeID, EmployeeFirstName + ' ' + EmployeeLastName As Employee
		From Employees

		Select ManagerID, EmployeeID, EmployeeFirstName + ' ' + EmployeeLastName As Employee
		From Employees as E

		Select M.EmployeeID, E.ManagerID, E.EmployeeID,
		M.EmployeeFirstName + ' ' + M.EmployeeLastName as Manager
		, E.EmployeeFirstName + ' ' + E.EmployeeLastName as Employee
		From Employees as E
			Inner Join Employees as M
				on E.ManagerID = M.EmployeeID
		Order By Manager, Employee;

*/

Create View vEmployeesByManager
As
 Select Top 1000000
  M.EmployeeFirstName + ' ' + M.EmployeeLastName as Manager
  , E.EmployeeFirstName + ' ' + E.EmployeeLastName as Employee
 From vEmployees as E
  Inner Join vEmployees as M
   on E.ManagerID = M.EmployeeID
 Order By Manager, Employee;
go

-- Question 10 (20% pts): How can you create one view to show all the data from all four 
-- BASIC Views? Also show the Employee's Manager Name and order the data by 
-- Category, Product, InventoryID, and Employee.
Create --Drop
View vInventoriesByProductsByCategoriesByEmployees
As
 Select Top 1000000
   C.CategoryID
  ,C.CategoryName
  ,P.ProductID
  ,P.ProductName
  ,P.UnitPrice
  ,I.InventoryID
  ,I.InventoryDate
  ,I.[Count]
  ,E.EmployeeID
  ,E.EmployeeFirstName + ' ' + E.EmployeeLastName as Employee
  ,M.EmployeeFirstName + ' ' + M.EmployeeLastName as Manager
 From vCategories as C
  Inner Join vProducts as P
   On P.CategoryID = C.CategoryID
  Inner Join vInventories as I
   On P.ProductID = I.ProductID
  Inner Join vEmployees as E
   On I.EmployeeID = E.EmployeeID
  Inner Join vEmployees as M
   On E.ManagerID = M.EmployeeID
  Order By C.CategoryID, P.ProductID, I.InventoryID, E.EmployeeID;
go

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