CREATE TABLE Customer (
    CustomerID INT PRIMARY KEY,      
    PersonID INT NULL,                             
    StoreID INT NULL,                              
    TerritoryID INT NULL,                          
    AccountNumber AS (isnull('AW'+[dbo].[ufnLeadingZeros]([CustomerID]),'')),         
    rowguid uniqueidentifier NOT NULL,
	ModifiedDate DATETIME NOT NULL
);
insert into Customer (CustomerID, PersonID, StoreID, TerritoryID, rowguid, ModifiedDate)
select CustomerID, PersonID, StoreID, TerritoryID, rowguid, ModifiedDate
from AdventureWorks2022.Sales.Customer;
ALTER TABLE Customer
ADD CONSTRAINT DF_Customer_ModifiedDate DEFAULT GETDATE() FOR ModifiedDate;

CREATE TABLE SalesTerritory (
	TerritoryID INT PRIMARY KEY,
	[Name] nvarchar(50) NOT NULL,
	CountryRegionCode nvarchar(3) NOT NULL,
	[Group] nvarchar(50) NOT NULL,
	SalesYTD money NOT NULL,
	SalesLastYear money NOT NULL,
	CostYTD money NOT NULL,
	CostLastYear money NOT NULL,
	rowguid uniqueidentifier NOT NULL,
	ModifiedDate DATETIME NOT NULL
);
insert into SalesTerritory (TerritoryID, [Name], CountryRegionCode, [Group], SalesYTD,SalesLastYear, CostYTD, CostLastYear,rowguid, ModifiedDate)
select TerritoryID, [Name], CountryRegionCode, [Group], SalesYTD,SalesLastYear, CostYTD, CostLastYear,rowguid, ModifiedDate
from AdventureWorks2022.Sales.SalesTerritory;
ALTER TABLE SalesTerritory
ADD CONSTRAINT UQ_SalesTerritory_Name UNIQUE ([Name]);

CREATE TABLE SalesPerson (
	BusinessEntityID INT PRIMARY KEY,
	TerritoryID INT NULL,
	SalesQuota money NULL,
	Bonus money NOT NULL,
	CommissionPct smallmoney NOT NULL,
	SalesYTD money NOT NULL,
	SalesLastYear money NOT NULL,
	rowguid uniqueidentifier NOT NULL,
	ModifiedDate DATETIME NOT NULL
);
insert into SalesPerson (BusinessEntityID, TerritoryID, SalesQuota, Bonus, CommissionPct, SalesYTD, SalesLastYear, rowguid, ModifiedDate)
select BusinessEntityID, TerritoryID, SalesQuota, Bonus, CommissionPct, SalesYTD, SalesLastYear, rowguid, ModifiedDate
from AdventureWorks2022.Sales.SalesPerson;
ALTER TABLE SalesPerson
ADD CONSTRAINT CK_SalesPerson_SalesYTD CHECK (SalesYTD >= 0);

CREATE TABLE CreditCard (
	CreditCardID INT PRIMARY KEY,
	CardType nvarchar(50) NOT NULL,
	CardNumber nvarchar(25) NOT NULL,
	ExpMonth tinyint NOT NULL,
	ExpYear smallint NOT NULL,
	ModifiedDate DATETIME NOT NULL
);
insert into CreditCard (CreditCardID, CardType, CardNumber, ExpMonth, ExpYear, ModifiedDate)
select CreditCardID, CardType, CardNumber, ExpMonth, ExpYear, ModifiedDate
from AdventureWorks2022.Sales.CreditCard;
ALTER TABLE CreditCard
ADD CONSTRAINT CK_CreditCard_ExpMonth CHECK (ExpMonth BETWEEN 1 AND 12);

CREATE TABLE SalesOrderHeader (
    SalesOrderID INT PRIMARY KEY,
    RevisionNumber TINYINT NOT NULL,
    OrderDate DATETIME NOT NULL,
    DueDate DATETIME NOT NULL,
    ShipDate DATETIME,
    Status TINYINT NOT NULL,
    OnlineOrderFlag BIT NOT NULL,
    SalesOrderNumber NVARCHAR(25) NOT NULL,
	PurchaseOrderNumber NVARCHAR(25),
    AccountNumber NVARCHAR(15),
    CustomerID INT NOT NULL,
    SalesPersonID INT,
    TerritoryID INT,
    BillToAddressID INT NOT NULL,
    ShipToAddressID INT NOT NULL,
    ShipMethodID INT NOT NULL,
    CreditCardID INT,
    CreditCardApprovalCode VARCHAR(15),
    CurrencyRateID INT,
    SubTotal MONEY NOT NULL,
    TaxAmt MONEY NOT NULL,
    Freight MONEY NOT NULL,
	[TotalDue]  AS (isnull(([SubTotal]+[TaxAmt])+[Freight],(0)))
);
insert into SalesOrderHeader (SalesOrderID,RevisionNumber, OrderDate, DueDate, ShipDate, [Status], OnlineOrderFlag, SalesOrderNumber, PurchaseOrderNumber, AccountNumber, CustomerID, SalesPersonID,
TerritoryID, BillToAddressID, ShipToAddressID, ShipMethodID, CreditCardID, CreditCardApprovalCode, CurrencyRateID, SubTotal, TaxAmt, Freight)
select SalesOrderID,RevisionNumber, OrderDate, DueDate, ShipDate, [Status], OnlineOrderFlag, SalesOrderNumber, PurchaseOrderNumber, AccountNumber, CustomerID, SalesPersonID,
TerritoryID, BillToAddressID, ShipToAddressID, ShipMethodID, CreditCardID, CreditCardApprovalCode, CurrencyRateID, SubTotal, TaxAmt, Freight
from AdventureWorks2022.Sales.SalesOrderHeader;
ALTER TABLE SalesOrderHeader
ADD CONSTRAINT DF_SalesOrderHeader_Status DEFAULT 1 FOR Status;

CREATE TABLE [Address](
	AddressID INT PRIMARY KEY,
	AddressLine1 nvarchar(60),
	AddressLine2 nvarchar(60) NULL,
	City nvarchar(30) NOT NULL,
	StateProvinceID int NOT NULL,
	PostalCode nvarchar(15) NOT NULL,
	SpatialLocation geography NULL,
	rowguid uniqueidentifier  NOT NULL,
	ModifiedDate DATETIME NOT NULL
);
insert into [Address] (AddressID, AddressLine1, AddressLine2, City, StateProvinceID, PostalCode, SpatialLocation, rowguid, ModifiedDate)
select AddressID, AddressLine1, AddressLine2, City, StateProvinceID, PostalCode, SpatialLocation, rowguid, ModifiedDate
from AdventureWorks2022.Person.[Address];
ALTER TABLE [Address]
ADD CONSTRAINT UQ_Address_PostalCode UNIQUE (PostalCode);

CREATE TABLE SalesOrderDetail(
	SalesOrderID INT NOT NULL,
    SalesOrderDetailID INT NOT NULL,
    CarrierTrackingNumber NVARCHAR(25),
    OrderQty SMALLINT NOT NULL,
    ProductID INT NOT NULL,
    SpecialOfferID INT NOT NULL,
    UnitPrice MONEY NOT NULL,
    UnitPriceDiscount MONEY NOT NULL,
    LineTotal NUMERIC(38,6) NOT NULL,
    Rowguid UNIQUEIDENTIFIER NOT NULL,
    ModifiedDate DATETIME NOT NULL,
	PRIMARY KEY (SalesOrderID, SalesOrderDetailID)
);
insert into SalesOrderDetail (SalesOrderID, SalesOrderDetailID, CarrierTrackingNumber, OrderQty, ProductID, SpecialOfferID, UnitPrice, UnitPriceDiscount, LineTotal, rowguid, ModifiedDate)
select SalesOrderID, SalesOrderDetailID, CarrierTrackingNumber, OrderQty, ProductID, SpecialOfferID, UnitPrice, UnitPriceDiscount, LineTotal, rowguid, ModifiedDate
from AdventureWorks2022.Sales.SalesOrderDetail;
ALTER TABLE SalesOrderDetail
ADD CONSTRAINT CK_SalesOrderDetail_OrderQty CHECK (OrderQty > 0);

CREATE TABLE SpecialOfferProduct(
	SpecialOfferID int NOT NULL,
	productID int NOT NULL,
	rowguid uniqueidentifier  NOT NULL,
	ModifiedDate DATETIME NOT NULL
	PRIMARY KEY (SpecialOfferID, ProductID)
);
insert into SpecialOfferProduct (SpecialOfferID, productID, rowguid, ModifiedDate)
select SpecialOfferID, productID, rowguid, ModifiedDate
from AdventureWorks2022.Sales.SpecialOfferProduct;
ALTER TABLE SpecialOfferProduct
ADD CONSTRAINT DF_SpecialOfferProduct_ModifiedDate DEFAULT GETDATE() FOR ModifiedDate;

CREATE TABLE ShipMethod(
	ShipMethodID int PRIMARY KEY,
	[Name] nvarchar(50) NOT NULL,
	ShipBase money NOT NULL,
	ShipRate money NOT NULL,
	rowguid uniqueidentifier  NOT NULL,
	ModifiedDate datetime NOT NULL,
);
insert into ShipMethod (ShipMethodID, [Name], ShipBase, ShipRate, rowguid, ModifiedDate)
select ShipMethodID, [Name], ShipBase, ShipRate, rowguid, ModifiedDate
from AdventureWorks2022.Purchasing.ShipMethod;
ALTER TABLE ShipMethod
ADD CONSTRAINT UQ_ShipMethod_Name UNIQUE ([Name]);

CREATE TABLE CurrencyRate(
	CurrencyRateID INT PRIMARY KEY,
    CurrencyRateDate DATETIME NOT NULL,
    FromCurrencyCode NCHAR(3) NOT NULL,
    ToCurrencyCode NCHAR(3) NOT NULL,
    AverageRate MONEY NOT NULL,
    EndOfDayRate MONEY NOT NULL,
	ModifiedDate DATETIME NOT NULL
);
insert into CurrencyRate (CurrencyRateID, CurrencyRateDate, FromCurrencyCode, ToCurrencyCode, AverageRate, EndOfDayRate, ModifiedDate)
select CurrencyRateID, CurrencyRateDate, FromCurrencyCode, ToCurrencyCode, AverageRate, EndOfDayRate, ModifiedDate
from AdventureWorks2022.Sales.CurrencyRate;
ALTER TABLE CurrencyRate
ADD CONSTRAINT CK_CurrencyRate_AverageRate CHECK (AverageRate > 0);

Alter table SalesOrderHeader
add foreign key (CustomerID) references Customer(CustomerID),
	foreign key (TerritoryID) references SalesTerritory(TerritoryID),
	foreign key (BusniessEntityID) references SalesPerson(BusniessEntityID),
	foreign key (CreditCardID) references CreditCard(CreditCardID),
	foreign key (AddressID) references [Address](AddressID),
	foreign key (ShipMethodID) references ShipMethod(ShipMethodID),
	foreign key (CurrencyRateID) references CurrencyRate(CurrencyRateID);

Alter table Customer
add foreign key (TerritoryID) references SalesTerritory(TerritoryID);

Alter table SalesPerson
add foreign key (TerritoryID) references SalesTerritory(TerritoryID);

Alter table SaleOrderDetail
add foreign key (SalesOrderID) references SalesOrderHeader(SalesOrderID);

CREATE TABLE Product (
	[ProductID] [int] NOT NULL,
	[Name] nvarchar(50) NOT NULL,
	[ProductNumber] [nvarchar](25) NOT NULL,
	[MakeFlag] [bit] NOT NULL,
	[FinishedGoodsFlag] [bit] NOT NULL,
	[Color] nvarchar(15) NULL,
	[SafetyStockLevel] [smallint] NOT NULL,
	[ReorderPoint] [smallint] NOT NULL,
	[StandardCost] [money] NOT NULL,
	[ListPrice] [money] NOT NULL,
	[Size] [nvarchar](5) NULL,
	[SizeUnitMeasureCode] [nchar](3) NULL,
	[WeightUnitMeasureCode] [nchar](3) NULL,
	[Weight] [decimal](8, 2) NULL,
	[DaysToManufacture] [int] NOT NULL,
	[ProductLine] [nchar](2) NULL,
	[Class] [nchar](2) NULL,
	[Style] [nchar](2) NULL,
	[ProductSubcategoryID] [int] NULL,
	[ProductModelID] [int] NULL,
	[SellStartDate] [datetime] NOT NULL,
	[SellEndDate] [datetime] NULL,
	[DiscontinuedDate] [datetime] NULL,
	[rowguid] [uniqueidentifier]  NOT NULL,
	[ModifiedDate] [datetime] NOT NULL,
);

insert into [dbo].[Product]
select * from [AdventureWorks2022].[Production].[Product]


CREATE TABLE ProductCategory (
    ProductCategoryID INT PRIMARY KEY,
    Name NVARCHAR(50) NOT NULL,
    Rowguid UNIQUEIDENTIFIER NOT NULL,
    ModifiedDate DATETIME NOT NULL
);

CREATE TABLE ProductSubcategory (
    ProductSubcategoryID INT PRIMARY KEY,
    ProductCategoryID INT NOT NULL,
    Name NVARCHAR(50) NOT NULL,
    Rowguid UNIQUEIDENTIFIER NOT NULL,
    ModifiedDate DATETIME NOT NULL
);

insert into [dbo].[ProductCategory]
select * from [AdventureWorks2022].[Production].[ProductCategory]

insert into [dbo].[ProductSubcategory]
select * from [AdventureWorks2022].[Production].[ProductSubcategory]

CREATE TABLE [Person](
	[BusinessEntityID] INT PRIMARY KEY,
	[PersonType] nchar(2) NOT NULL,
	[NameStyle] nvarchar(8) NOT NULL,
	[Title] nvarchar(8) NULL,
	[FirstName] nvarchar(50) NOT NULL,
	[MiddleName] nvarchar(50) NULL,
	[LastName] nvarchar(50) NOT NULL,
	[Suffix] nvarchar(10) NULL,
	[EmailPromotion] int NOT NULL,
	[rowguid] [uniqueidentifier] ROWGUIDCOL  NOT NULL,
	[ModifiedDate] [datetime] NOT NULL
 );
 insert into [dbo].[Person]
select BusinessEntityID, PersonType, NameStyle, Title, FirstName, MiddleName, LastName, Suffix, EmailPromotion, rowguid, ModifiedDate
from [AdventureWorks2022].[Person].[Person]

CREATE TABLE Department (
	DepartmentID smallint PRIMARY KEY,
	[Name] nvarchar(50) NOT NULL,
	GroupName nvarchar(50) NOT NULL,
	ModifiedDate datetime NOT NULL
);
insert into [dbo].[Department]
select * from [AdventureWorks2022].[HumanResources].[Department]

CREATE TABLE [Shift](
	ShiftID tinyint PRIMARY KEY,
	[Name] nvarchar(50) NOT NULL,
	StartTime time(7) NOT NULL,
	EndTime time(7) NOT NULL,
	ModifiedDate datetime NOT NULL
);
insert into [dbo].[Shift]
select * from [AdventureWorks2022].[HumanResources].[Shift]

CREATE TABLE Employee (
	[BusinessEntityID] [int] PRIMARY KEY,
	[NationalIDNumber] [nvarchar](15) NOT NULL,
	[LoginID] [nvarchar](256) NOT NULL,
	[OrganizationNode] [hierarchyid] NULL,
	[JobTitle] [nvarchar](50) NOT NULL,
	[BirthDate] [date] NOT NULL,
	[MaritalStatus] [nchar](1) NOT NULL,
	[Gender] [nchar](1) NOT NULL,
	[HireDate] [date] NOT NULL,
	[VacationHours] [smallint] NOT NULL,
	[SickLeaveHours] [smallint] NOT NULL,
	[rowguid] [uniqueidentifier] ROWGUIDCOL  NOT NULL,
	[ModifiedDate] [datetime] NOT NULL,
);
insert into [dbo].[Employee]
select BusinessEntityID, NationalIDNumber, LoginID, OrganizationNode, JobTitle, BirthDate, MaritalStatus, Gender, HireDate, VacationHours, SickLeaveHours, rowguid, ModifiedDate
from [AdventureWorks2022].[HumanResources].[Employee]

CREATE TABLE EmployeeDepartmentHistory(
	[BusinessEntityID] [int] NOT NULL,
	[DepartmentID] [smallint] NOT NULL,
	[ShiftID] [tinyint] NOT NULL,
	[StartDate] [date] NOT NULL,
	[EndDate] [date] NULL,
	[ModifiedDate] [datetime] NOT NULL,
 CONSTRAINT [PK_EmployeeDepartmentHistory_BusinessEntityID_StartDate_DepartmentID] PRIMARY KEY CLUSTERED 
([BusinessEntityID] ASC,
	[StartDate] ASC,
	[DepartmentID] ASC,
	[ShiftID] ASC)
);
insert into [dbo].[EmployeeDepartmentHistory]
select * from [AdventureWorks2022].[HumanResources].[EmployeeDepartmentHistory]
