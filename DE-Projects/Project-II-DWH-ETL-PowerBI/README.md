# Project II: Data Warehouse + ETL + Power BI

> **Module**: ETL - Data Warehouse + Data Visualization - Power BI
> **Mức độ**: Trung bình
> **Thời gian**: 3 tuần

---

## Mục tiêu

Sau khi hoàn thành project, học viên sẽ biết cách:
- Thiết kế Data Warehouse theo mô hình Star Schema (bảng Fact và các bảng Dimension).
- Xây dựng luồng ETL (Extract - Transform - Load) để di chuyển và xử lý dữ liệu từ nguồn đến kho dữ liệu.
- Sử dụng SSIS (hoặc Python) để tự động hóa quá trình ETL.
- Tạo dashboard Power BI để trực quan hóa dữ liệu kinh doanh.
- Hiểu vòng đời dữ liệu từ Source -> Staging -> Data Warehouse -> BI Dashboard.

---

## Chủ đề

Học viên chọn 1 trong các bài toán dưới đây, hoặc có thể tự lựa chọn chủ đề khác (cần được giảng viên phê duyệt):

| STT | Chủ đề | Mô tả |
|-----|--------|-------|
| A | Bán hàng (Sales) | Phân tích doanh thu, sản phẩm, khách hàng, kênh bán |
| B | Mua hàng (Procurement) | Phân tích chi phí mua, nhà cung cấp, lead time |
| C | Kho vận (Logistics) | Phân tích tồn kho, giao hàng, hiệu suất kho |
| D | Tự chọn | Chủ đề khác (cần được giảng viên phê duyệt) |

---

## Kiến trúc hệ thống

Xem sơ đồ kiến trúc chi tiết tại: [docs/architecture.md](docs/architecture.md)

---

## Hướng dẫn thực hiện chi tiết

Project này gồm 5 bước chính. File starter code mẫu nằm trong thư mục `starter-code/sql/`.

---

## Bước 1 - Chuẩn bị Source Database (Ngày 1-3)

**Mục đích**: Tạo (hoặc sử dụng lại) cơ sở dữ liệu nguồn (OLTP) chứa dữ liệu giao dịch. Đây là "nguồn" mà bạn sẽ extract dữ liệu từ đó để đưa vào Data Warehouse.

**Đầu vào**: Database từ Project I (nếu đã làm), hoặc tạo mới từ starter code.

**Đầu ra**:
- Một SQL Server database chứa dữ liệu giao dịch (đơn hàng, sản phẩm, khách hàng, ...).
- Tối thiểu 200+ records để có đủ dữ liệu cho phân tích.

**Cách làm**:
1. Nếu bạn đã làm Project I, có thể tái sử dụng database đó.
2. Nếu chưa có, tham khảo file `starter-code/sql/data-warehouse.sql` để hiểu cấu trúc.
3. Tạo source database và insert dữ liệu mẫu đủ lớn.

---

## Bước 2 - Thiết kế Data Warehouse (Ngày 3-5) (25 điểm)

**Mục đích**: Thiết kế kho dữ liệu (Data Warehouse) theo mô hình Star Schema. Star Schema gồm 1 bảng Fact (chứa các số đo - metrics) và nhiều bảng Dimension (chứa thông tin mô tả - như sản phẩm, khách hàng, ngày tháng).

**Đầu vào**: Cấu trúc và dữ liệu của source database.

**Đầu ra**:
- Sơ đồ Star Schema (file PNG).
- Script DDL tạo tất cả các bảng trong DWH.
- Các bảng bao gồm:
  - 1 Fact Table (ví dụ: FactSales).
  - Tối thiểu 4 Dimension Tables (ví dụ: DimProduct, DimCustomer, DimDate, DimStore).

**Cách làm**:

1. Xác định "business process" cần phân tích. Ví dụ: bán hàng, mua hàng, xuất nhập kho.

2. Xác định "grain" - mức chi tiết của mỗi dòng trong Fact table. Ví dụ: mỗi dòng là 1 dòng trong hóa đơn (1 sản phẩm trong 1 đơn hàng).

3. Xác định các Dimension cần thiết. Hỏi các câu hỏi: Ai mua? Mua cái gì? Khi nào? Ở đâu? Mỗi câu hỏi là 1 Dimension.

4. Thiết kế các bảng:

   Bảng Fact (ví dụ FactSales):
   - Chứa các khóa ngoại trỏ đến Dimensions (DateKey, ProductKey, CustomerKey, ...).
   - Chứa các số đo (Quantity, UnitPrice, TotalAmount, Profit, ...).

   Bảng DimDate (bắt buộc, lúc nào cũng cần):
   - Chứa ngày, tháng, năm, quý, tên thứ, cuối tuần hay không, ...
   - Tham khảo starter code - bảng DimDate đã được tạo sẵn với 5 năm dữ liệu.

   Bảng DimProduct, DimCustomer, DimStore: tùy chủ đề.

5. Xác định Surrogate Key (khóa thay thế, dạng INT IDENTITY) cho mỗi Dimension. Đây là khóa chính của Dimension, khác với Natural Key (khóa tự nhiên từ source).

6. Nếu cần, thiết kế SCD (Slowly Changing Dimension):
   - SCD Type 1: Ghi đè dữ liệu cũ bằng dữ liệu mới (đơn giản).
   - SCD Type 2: Giữ lại lịch sử thay đổi bằng các cột EffectiveDate, ExpirationDate, IsCurrent.

7. Viết script DDL tạo các bảng, lưu vào `sql/03-data-warehouse.sql`.

8. Vẽ sơ đồ Star Schema và export thành PNG.

---

## Bước 3 - Xây dựng ETL Pipeline (Ngày 6-12) (30 điểm)

**Mục đích**: Tạo luồng xử lý dữ liệu từ Source -> Staging -> Data Warehouse. ETL là quá trình cốt lõi: Extract (lấy dữ liệu), Transform (làm sạch và chuyển đổi), Load (nạp vào DWH).

**Đầu vào**:
- Source database (từ Bước 1).
- Data Warehouse database (từ Bước 2, các bảng còn trống).

**Đầu ra**:
- Staging database chứa dữ liệu tạm.
- Data Warehouse đã có dữ liệu.
- SSIS packages hoặc Python scripts thực hiện ETL.
- Log ghi nhận quá trình ETL (số records, lỗi, ...).

**Cách làm**:

Giai đoạn E - Extract:
1. Tạo Staging database (cơ sở dữ liệu tạm, chứa dữ liệu "như nguồn").
2. Đọc dữ liệu từ Source và copy vào Staging. Lưu ý ghi thêm cột LoadDate và SourceSystem để theo dõi.
3. Sử dụng SSIS (Data Flow Task) hoặc Python (pyodbc / pandas) để thực hiện.

Giai đoạn T - Transform:
1. Làm sạch dữ liệu trong Staging:
   - Xử lý giá trị NULL (thay thế hoặc loại bỏ).
   - Loại bỏ bản ghi trùng lặp (duplicates).
   - Loại bỏ dữ liệu không hợp lệ (ví dụ: giá âm, ngày tương lai).
2. Chuyển đổi kiểu dữ liệu cho phù hợp với DWH.
3. Tạo các cột phát sinh (derived columns). Ví dụ: tính Profit = Revenue - Cost.
4. Thực hiện Lookup: map Natural Key từ Source sang Surrogate Key của Dimension.

Giai đoạn L - Load:
1. Nạp Dimension tables trước (Full Load - xóa sạch rồi nạp lại, hoặc Merge).
2. Nạp Fact table sau (Incremental Load - chỉ nạp dữ liệu mới).
3. Xử lý lỗi: ghi log mỗi bước, đếm số records thành công/thất bại.

---

## Bước 4 - Tạo Power BI Dashboard (Ngày 13-18) (30 điểm)

**Mục đích**: Kết nối Power BI với Data Warehouse và tạo dashboard trực quan hóa. Đây là bước "kết quả" - biến dữ liệu thành insight mà người dùng kinh doanh đọc được.

**Đầu vào**: Data Warehouse đã có dữ liệu từ Bước 3.

**Đầu ra**:
- File .pbix (Power BI Desktop).
- Tối thiểu 3 trang dashboard.
- Screenshots các trang dashboard.

**Cách làm**:

1. Mở Power BI Desktop, chọn "Get Data" -> "SQL Server".
2. Nhập server name và database name của DWH.
3. Import tất cả các bảng (Fact và Dimensions).

4. Kiểm tra Data Model trong Power BI:
   - Đảm bảo các relationship giữa Fact và Dimensions đúng (1-to-many).
   - Mỗi Dimension kết nối với Fact qua Surrogate Key.

5. Tạo DAX Measures (các phép tính):
   - Total Revenue = SUM(FactSales[TotalAmount])
   - Profit Margin = DIVIDE([Total Profit], [Total Revenue])
   - YoY Growth = so sánh doanh thu năm nay với năm trước
   - (Tham khảo các DAX mẫu trong file starter code)

6. Thiết kế 3 trang dashboard:

   Trang 1 - Overview: Hiển thị các KPIs tổng quan.
   - Card: Tổng doanh thu, tổng lợi nhuận, số đơn hàng.
   - Bar chart: Doanh thu theo tháng.
   - Slicer: Lọc theo năm, quý.

   Trang 2 - Analysis: Phân tích chi tiết theo Dimensions.
   - Bar chart: Top 10 sản phẩm / Top khách hàng.
   - Treemap: Doanh thu theo danh mục.
   - Table: Chi tiết dữ liệu.

   Trang 3 - Trends: Xu hướng theo thời gian.
   - Line chart: Doanh thu theo thời gian.
   - Xu hướng tăng/giảm.

7. Thêm Slicers, Drill-through, Bookmarks để tăng tính tương tác.
8. Lưu file .pbix và chụp screenshots từng trang.

---

## Bước 5 - Documentation và nộp bài (Ngày 19-21) (15 điểm)

**Mục đích**: Hoàn thiện tài liệu và đóng gói bài nộp.

**Đầu vào**: Toàn bộ project đã hoàn thành.

**Đầu ra**: Thư mục nộp bài đầy đủ.

**Cách làm**:
1. Vẽ System Architecture diagram (draw.io hoặc tương tự), export PNG.
2. Viết Data Dictionary (mô tả từng bảng, từng cột trong DWH).
3. Viết ETL Mapping Document (mỗi cột trong DWH lấy từ đâu, chuyển đổi như thế nào).
4. Sắp xếp file theo cấu trúc bên dưới.

---

## Cấu trúc thư mục nộp bài

```
StudentName-ProjectII/
  README.md
  docs/
    architecture.png
    star-schema.png
    etl-mapping.xlsx
    data-dictionary.md
  sql/
    01-source-database.sql
    02-staging-database.sql
    03-data-warehouse.sql
    04-sample-data.sql
  etl/
    SSIS-Project/       (nếu dùng SSIS)
    python-etl/         (nếu dùng Python)
      extract.py
      transform.py
      load.py
  powerbi/
    Dashboard.pbix
  screenshots/
    dashboard-page1.png
    dashboard-page2.png
    dashboard-page3.png
```

---

## Timeline gợi ý

| Tuần | Công việc |
|------|-----------|
| Tuần 1 | Chuẩn bị Source DB. Thiết kế Star Schema. Tạo Staging và DWH databases |
| Tuần 2 | Xây dựng ETL pipeline (SSIS hoặc Python). Test và fix lỗi |
| Tuần 3 | Tạo Power BI Dashboard. Hoàn thiện documentation và nộp bài |

---

## Tài liệu tham khảo

- Kimball Dimensional Modeling: https://www.kimballgroup.com/data-warehouse-business-intelligence-resources/kimball-techniques/dimensional-modeling-techniques/
- SSIS Tutorial: https://docs.microsoft.com/en-us/sql/integration-services/
- Power BI Documentation: https://docs.microsoft.com/en-us/power-bi/
- Star Schema Design: https://www.guru99.com/star-snowflake-data-warehousing.html
