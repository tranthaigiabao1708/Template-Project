-- ================================================================
-- VI DU, CU THE VOI CHU DE A - BAN HANG ONLINE
-- (Day la code mau huong dan, hoc vien can tuy chinh theo
--  thiet ke cua minh)
-- ================================================================
-- PROJECT I - STARTER CODE: CHỦ ĐỀ A - BÁN HÀNG ONLINE
-- Cole.vn - Data Engineering Course
-- ================================================================

-- =============================================
-- PHẦN 1: TẠO DATABASE
-- =============================================
-- TODO: Tạo database với collation phù hợp tiếng Việt
CREATE DATABASE OnlineShopDB
COLLATE Vietnamese_CI_AS;
GO

USE OnlineShopDB;
GO

-- =============================================
-- PHẦN 2: TẠO BẢNG
-- =============================================

-- Bảng Categories (Danh mục sản phẩm)
CREATE TABLE Categories (
    CategoryID INT IDENTITY(1,1) PRIMARY KEY,
    CategoryName NVARCHAR(100) NOT NULL,
    Description NVARCHAR(500),
    CreatedDate DATETIME DEFAULT GETDATE(),
    IsActive BIT DEFAULT 1
);
GO

-- Bảng Customers (Khách hàng)
CREATE TABLE Customers (
    CustomerID INT IDENTITY(1,1) PRIMARY KEY,
    FullName NVARCHAR(150) NOT NULL,
    Email NVARCHAR(100) UNIQUE NOT NULL,
    Phone NVARCHAR(15),
    Address NVARCHAR(500),
    City NVARCHAR(100),
    DateOfBirth DATE,
    Gender NVARCHAR(10),
    CreatedDate DATETIME DEFAULT GETDATE(),
    IsActive BIT DEFAULT 1
);
GO

-- Bảng Products (Sản phẩm)
CREATE TABLE Products (
    ProductID INT IDENTITY(1,1) PRIMARY KEY,
    CategoryID INT NOT NULL,
    ProductName NVARCHAR(200) NOT NULL,
    Description NVARCHAR(1000),
    Price DECIMAL(18,2) NOT NULL CHECK (Price >= 0),
    StockQuantity INT NOT NULL DEFAULT 0 CHECK (StockQuantity >= 0),
    ImageURL NVARCHAR(500),
    CreatedDate DATETIME DEFAULT GETDATE(),
    IsActive BIT DEFAULT 1,
    FOREIGN KEY (CategoryID) REFERENCES Categories(CategoryID)
);
GO

-- Bảng Orders (Đơn hàng)
CREATE TABLE Orders (
    OrderID INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID INT NOT NULL,
    OrderDate DATETIME DEFAULT GETDATE(),
    Status NVARCHAR(50) DEFAULT N'Pending' 
        CHECK (Status IN (N'Pending', N'Confirmed', N'Shipping', N'Delivered', N'Cancelled')),
    TotalAmount DECIMAL(18,2) DEFAULT 0,
    ShippingAddress NVARCHAR(500),
    Note NVARCHAR(500),
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
);
GO

-- Bảng OrderDetails (Chi tiết đơn hàng)
CREATE TABLE OrderDetails (
    OrderDetailID INT IDENTITY(1,1) PRIMARY KEY,
    OrderID INT NOT NULL,
    ProductID INT NOT NULL,
    Quantity INT NOT NULL CHECK (Quantity > 0),
    UnitPrice DECIMAL(18,2) NOT NULL,
    Discount DECIMAL(5,2) DEFAULT 0 CHECK (Discount >= 0 AND Discount <= 100),
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
);
GO

-- TODO: Tạo thêm các bảng còn lại
-- Bảng Payments (Thanh toán)
-- Bảng ProductReviews (Đánh giá sản phẩm)
-- Bảng InventoryLog (Lịch sử kho)
-- (Thêm bảng tùy chọn theo thiết kế của bạn)

-- =============================================
-- PHẦN 3: TẠO INDEXES
-- =============================================
CREATE INDEX IX_Products_CategoryID ON Products(CategoryID);
CREATE INDEX IX_Orders_CustomerID ON Orders(CustomerID);
CREATE INDEX IX_Orders_OrderDate ON Orders(OrderDate);
CREATE INDEX IX_OrderDetails_OrderID ON OrderDetails(OrderID);

-- TODO: Thêm indexes phù hợp cho các truy vấn báo cáo

-- =============================================
-- PHẦN 4: INSERT DỮ LIỆU MẪU
-- =============================================

-- Categories
INSERT INTO Categories (CategoryName, Description) VALUES
(N'Điện thoại', N'Smartphone và phụ kiện'),
(N'Laptop', N'Máy tính xách tay'),
(N'Thời trang', N'Quần áo, giày dép'),
(N'Đồ gia dụng', N'Thiết bị gia đình'),
(N'Sách', N'Sách và văn phòng phẩm');
GO

-- Customers (mẫu 10 khách hàng)
INSERT INTO Customers (FullName, Email, Phone, Address, City, DateOfBirth, Gender) VALUES
(N'Nguyễn Văn An', 'an.nguyen@email.com', '0901234567', N'123 Lê Lợi', N'TP.HCM', '1990-05-15', N'Nam'),
(N'Trần Thị Bình', 'binh.tran@email.com', '0912345678', N'456 Nguyễn Huệ', N'Hà Nội', '1992-08-20', N'Nữ'),
(N'Lê Hoàng Cường', 'cuong.le@email.com', '0923456789', N'789 Trần Phú', N'Đà Nẵng', '1988-03-10', N'Nam'),
(N'Phạm Thị Dung', 'dung.pham@email.com', '0934567890', N'321 Hai Bà Trưng', N'TP.HCM', '1995-12-01', N'Nữ'),
(N'Hoàng Minh Đức', 'duc.hoang@email.com', '0945678901', N'654 Lý Thường Kiệt', N'Hà Nội', '1991-07-25', N'Nam');
-- TODO: Thêm 95+ khách hàng nữa

-- Products (mẫu)
INSERT INTO Products (CategoryID, ProductName, Description, Price, StockQuantity) VALUES
(1, N'iPhone 15 Pro Max', N'Apple iPhone 15 Pro Max 256GB', 32990000, 50),
(1, N'Samsung Galaxy S24 Ultra', N'Samsung S24 Ultra 512GB', 28990000, 45),
(2, N'MacBook Air M3', N'Apple MacBook Air 13 inch M3', 27990000, 30),
(2, N'Dell XPS 15', N'Dell XPS 15 Core i7', 35990000, 20),
(3, N'Áo polo nam', N'Áo polo cotton cao cấp', 350000, 200);
-- TODO: Thêm sản phẩm cho đủ dữ liệu

-- TODO: Insert dữ liệu cho Orders, OrderDetails

-- =============================================
-- PHẦN 5: STORED PROCEDURES (MẪU)
-- =============================================

-- SP1: Tạo đơn hàng mới
CREATE OR ALTER PROCEDURE sp_CreateOrder
    @CustomerID INT,
    @ShippingAddress NVARCHAR(500),
    @Note NVARCHAR(500) = NULL,
    @OrderID INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        
        INSERT INTO Orders (CustomerID, ShippingAddress, Note)
        VALUES (@CustomerID, @ShippingAddress, @Note);
        
        SET @OrderID = SCOPE_IDENTITY();
        
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

-- TODO: Viết thêm 4+ Stored Procedures:
-- sp_AddOrderDetail
-- sp_UpdateOrderStatus
-- sp_GetCustomerOrders
-- sp_UpdateProductStock
-- (và các SP khác theo yêu cầu)

-- =============================================
-- PHẦN 6: VIEWS (MẪU)
-- =============================================

-- View 1: Tổng quan đơn hàng
CREATE OR ALTER VIEW vw_OrderSummary AS
SELECT 
    o.OrderID,
    c.FullName AS CustomerName,
    c.Email,
    o.OrderDate,
    o.Status,
    o.TotalAmount,
    COUNT(od.OrderDetailID) AS TotalItems
FROM Orders o
JOIN Customers c ON o.CustomerID = c.CustomerID
LEFT JOIN OrderDetails od ON o.OrderID = od.OrderID
GROUP BY o.OrderID, c.FullName, c.Email, o.OrderDate, o.Status, o.TotalAmount;
GO

-- TODO: Viết thêm 2+ Views

-- =============================================
-- PHẦN 7: BÁO CÁO SQL (MẪU)
-- =============================================

-- Báo cáo 1: Top 10 sản phẩm bán chạy nhất theo tháng
-- TODO: Hoàn thiện query
SELECT TOP 10
    p.ProductName,
    SUM(od.Quantity) AS TotalSold,
    SUM(od.Quantity * od.UnitPrice * (1 - od.Discount/100)) AS Revenue,
    MONTH(o.OrderDate) AS SaleMonth,
    YEAR(o.OrderDate) AS SaleYear
FROM OrderDetails od
JOIN Products p ON od.ProductID = p.ProductID
JOIN Orders o ON od.OrderID = o.OrderID
WHERE o.Status != N'Cancelled'
GROUP BY p.ProductName, MONTH(o.OrderDate), YEAR(o.OrderDate)
ORDER BY TotalSold DESC;

-- TODO: Viết thêm 9 báo cáo còn lại (xem danh sách trong README.md)
