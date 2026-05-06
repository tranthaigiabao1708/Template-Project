# Project I: Thiết kế Cơ sở dữ liệu và Xây dựng Báo cáo

> **Module**: Cơ sở dữ liệu quan hệ (SQL - SQL Server)
> **Mức độ**: Cơ bản
> **Thời gian**: 2 tuần

---

## Mục tiêu

Sau khi hoàn thành project, học viên sẽ biết cách:
- Phân tích yêu cầu nghiệp vụ của một hệ thống và xác định các thực thể, mối quan hệ.
- Thiết kế sơ đồ ERD (Entity-Relationship Diagram) chuẩn hóa đến 3NF.
- Tạo database trên SQL Server với đầy đủ constraints và indexes.
- Viết stored procedures và views để xử lý dữ liệu và phục vụ báo cáo.
- Viết các câu truy vấn SQL để tạo báo cáo từ dữ liệu.

---

## Chủ đề

Học viên chọn 1 trong 4 chủ đề dưới đây, hoặc có thể tự lựa chọn chủ đề khác (cần được giảng viên phê duyệt):

| STT | Chủ đề | Mô tả |
|-----|--------|-------|
| A | Bán hàng Online | Hệ thống quản lý đơn hàng, sản phẩm, khách hàng, thanh toán |
| B | Book phòng Khách sạn | Hệ thống đặt phòng, quản lý khách, dịch vụ, thanh toán |
| C | Đặt vé Sự kiện | Hệ thống bán vé, quản lý sự kiện, địa điểm, khách tham dự |
| D | Quản lý Nhân sự | Hệ thống HR: nhân viên, phòng ban, lương, chấm công |

---

## Kiến trúc hệ thống

Xem sơ đồ kiến trúc tham khảo tại: [docs/architecture.md](docs/architecture.md)

---

## Hướng dẫn thực hiện chi tiết

Project này gồm 7 bước, thực hiện tuần tự. File starter code mẫu nằm trong thư mục `starter-code/sql/`.

---

## Bước 1 - Chọn chủ đề và phân tích yêu cầu

**Mục đích**: Hiểu rõ bài toán nghiệp vụ trước khi bắt tay vào thiết kế. Bạn cần trả lời được các câu hỏi: Hệ thống này phục vụ ai? Quản lý những đối tượng gì? Các đối tượng liên quan với nhau như thế nào?

**Đầu vào**: Mô tả chủ đề bạn chọn (ví dụ: hệ thống bán hàng online).

**Đầu ra**: Danh sách các thực thể (entities) và mối quan hệ giữa chúng. Ví dụ:
- Khách hàng -> đặt -> Đơn hàng
- Đơn hàng -> chứa -> Chi tiết đơn hàng
- Sản phẩm -> thuộc -> Danh mục

**Cách làm**:
1. Đọc kỹ mô tả chủ đề bạn chọn.
2. Liệt kê tất cả các "đối tượng" chính trong hệ thống (ví dụ: Khách hàng, Sản phẩm, Đơn hàng, ...).
3. Với mỗi đối tượng, liệt kê các thuộc tính (ví dụ: Khách hàng có Tên, Email, SĐT, ...).
4. Xác định mối quan hệ giữa các đối tượng: 1-1, 1-nhiều, nhiều-nhiều.
5. Ghi chép lại thành tài liệu (có thể viết tay hoặc dùng Word).

---

## Bước 2 - Thiết kế ERD (40 điểm)

**Mục đích**: Chuyển danh sách thực thể và mối quan hệ từ Bước 1 thành sơ đồ ERD chính thức, chuẩn hóa đến 3NF (Third Normal Form) - đảm bảo không có dữ liệu trùng lặp, mỗi bảng có khóa chính rõ ràng.

**Đầu vào**: Danh sách thực thể, thuộc tính và mối quan hệ từ Bước 1.

**Đầu ra**:
- File ERD.png (sơ đồ quan hệ thực thể).
- Tối thiểu 8 bảng có quan hệ rõ ràng.
- Mỗi bảng có Primary Key, các bảng liên quan có Foreign Key.

**Cách làm**:
1. Mở công cụ vẽ ERD: [dbdiagram.io](https://dbdiagram.io) (miễn phí, dễ sử dụng), [draw.io](https://draw.io), hoặc SQL Server Management Studio.
2. Tạo từng bảng, định nghĩa các cột và kiểu dữ liệu.
3. Xác định Primary Key cho mỗi bảng (thường là cột ID tự tăng).
4. Vẽ các mối quan hệ (Foreign Key) giữa các bảng.
5. Kiểm tra chuẩn hóa 3NF:
   - 1NF: Mỗi cột chỉ chứa 1 giá trị, không có nhóm lặp.
   - 2NF: Mỗi cột phụ thuộc vào toàn bộ khóa chính.
   - 3NF: Không có cột nào phụ thuộc vào cột không phải khóa.
6. Export ERD thành file PNG và lưu vào `docs/ERD.png`.

Tham khảo ERD mẫu cho các chủ đề tại `docs/architecture.md`.

---

## Bước 3 - Tạo Database trên SQL Server

**Mục đích**: Biến ERD thành database thật trên SQL Server, viết script tạo từng bảng với đầy đủ ràng buộc.

**Đầu vào**: ERD đã thiết kế ở Bước 2.

**Đầu ra**:
- File `01-create-database.sql`: Script tạo database.
- File `02-create-tables.sql`: Script tạo tất cả các bảng với constraints.
- Database thực tế trên SQL Server có thể truy cập được.

**Cách làm**:
1. Mở SQL Server Management Studio (SSMS).
2. Tham khảo file mẫu `starter-code/sql/topic-A-online-sales-starter.sql` để hiểu cấu trúc.
3. Viết script tạo database:
```sql
CREATE DATABASE TenDatabase COLLATE Vietnamese_CI_AS;
GO
USE TenDatabase;
GO
```
4. Viết script tạo từng bảng theo thứ tự: bảng cha trước, bảng con sau (ví dụ: tạo bảng Categories trước, rồi mới tạo bảng Products vì Products tham chiếu đến Categories).
5. Thêm constraints: NOT NULL, UNIQUE, CHECK, DEFAULT.
6. Thêm Indexes cho các cột thường được truy vấn (ví dụ: ngày đặt hàng, mã khách hàng).
7. Chạy script trong SSMS và xác nhận không có lỗi.

---

## Bước 4 - Tạo dữ liệu mẫu (10 điểm)

**Mục đích**: Nạp dữ liệu mẫu vào database để có dữ liệu phục vụ viết báo cáo và test stored procedures. Dữ liệu phải thực tế và nhất quán giữa các bảng.

**Đầu vào**: Database đã tạo ở Bước 3 (các bảng còn trống).

**Đầu ra**:
- File `03-insert-data.sql`: Script INSERT dữ liệu.
- Tối thiểu 100 records cho bảng chính (ví dụ: bảng Orders, bảng Bookings, ...).
- Tất cả các bảng đều có dữ liệu.

**Cách làm**:
1. Bắt đầu từ các bảng cha (không có Foreign Key trỏ đến bảng khác). Ví dụ: Categories, Customers.
2. Sau đó insert dữ liệu cho các bảng con. Ví dụ: Products (tham chiếu Categories), Orders (tham chiếu Customers).
3. Đảm bảo dữ liệu nhất quán: mọi Foreign Key đều trỏ đến record tồn tại.
4. Dữ liệu nên đa dạng: có nhiều ngày khác nhau, nhiều trạng thái (Pending, Confirmed, Cancelled...), nhiều giá trị để báo cáo có ý nghĩa.

---

## Bước 5 - Viết Stored Procedures và Views (20 điểm)

**Mục đích**: Tạo các stored procedures (SP) để xử lý nghiệp vụ và views để đơn giản hóa truy vấn báo cáo. SP giúp đóng gói logic, bảo mật và tái sử dụng. Views giúp rút gọn các truy vấn phức tạp.

**Đầu vào**: Database đã có dữ liệu từ Bước 4.

**Đầu ra**:
- File `04-stored-procedures.sql`: Tối thiểu 5 Stored Procedures.
- File `05-views.sql`: Tối thiểu 3 Views.

**Yêu cầu cụ thể**:

Stored Procedures (tối thiểu 5):
- SP tạo mới (ví dụ: tạo đơn hàng mới, tạo khách hàng mới).
- SP cập nhật trạng thái (ví dụ: cập nhật trạng thái đơn hàng).
- SP xóa hoặc vô hiệu hóa (ví dụ: hủy đơn hàng).
- SP truy vấn (ví dụ: lấy danh sách đơn hàng của khách hàng).
- SP tính toán (ví dụ: tính tổng doanh thu theo tháng).
- Mỗi SP phải sử dụng BEGIN TRY...BEGIN CATCH và TRANSACTION.

Views (tối thiểu 3):
- View tổng hợp đơn hàng (join nhiều bảng).
- View thống kê doanh thu.
- View danh sách khác (tùy chọn).

---

## Bước 6 - Viết báo cáo SQL (30 điểm)

**Mục đích**: Viết các câu truy vấn SQL để trả lời các câu hỏi nghiệp vụ. Đây là phần quan trọng nhất - chứng minh bạn có thể khai thác dữ liệu để tạo insight.

**Đầu vào**: Database đã có dữ liệu và views từ các bước trước.

**Đầu ra**:
- File `06-reports.sql`: Tối thiểu 10 câu truy vấn báo cáo.
- Thư mục `screenshots/`: Ảnh chụp kết quả mỗi báo cáo.

**Danh sách báo cáo gợi ý** (tùy chủ đề):

Chủ đề A - Bán hàng Online:
1. Top 10 sản phẩm bán chạy nhất theo tháng
2. Doanh thu theo ngày/tuần/tháng
3. Khách hàng có tổng chi tiêu cao nhất
4. Tỷ lệ đơn hàng thành công vs hủy
5. Sản phẩm tồn kho thấp cần nhập thêm
6. Phân tích doanh thu theo danh mục sản phẩm
7. Khách hàng mới vs khách hàng quay lại
8. Trung bình giá trị đơn hàng theo thời gian
9. Sản phẩm được đánh giá cao nhất
10. Phân tích xu hướng bán hàng theo mùa

Chủ đề B - Book phòng Khách sạn:
1. Tỷ lệ lấp đầy phòng theo tháng
2. Doanh thu theo loại phòng
3. Khách hàng thường xuyên (top loyalty)
4. Thời gian lưu trú trung bình
5. Doanh thu dịch vụ phụ (spa, restaurant, laundry)
6. Phân tích peak season vs low season
7. Tỷ lệ hủy đặt phòng theo kênh booking
8. So sánh doanh thu các chi nhánh
9. Phân tích feedback/review của khách
10. Dự báo phòng trống theo tuần

Chủ đề C - Đặt vé Sự kiện:
1. Sự kiện có doanh thu cao nhất
2. Tỷ lệ bán vé theo loại vé (VIP, Standard, Economy)
3. Phân tích khách tham dự theo demographics
4. Doanh thu theo địa điểm tổ chức
5. Xu hướng mua vé (early bird vs last minute)
6. Top nghệ sĩ/diễn giả được yêu thích
7. Tỷ lệ refund/cancel theo sự kiện
8. Phân tích kênh bán vé hiệu quả nhất
9. So sánh doanh thu sự kiện online vs offline
10. Thống kê lượt check-in thực tế vs vé đã bán

Chủ đề D - Quản lý Nhân sự:
1. Tổng chi phí lương theo phòng ban
2. Phân tích cơ cấu nhân sự theo vị trí, giới tính, tuổi
3. Tỷ lệ nghỉ việc (turnover rate) theo quý
4. Top nhân viên có thành tích tốt nhất
5. Phân tích overtime theo phòng ban
6. Chi phí tuyển dụng vs số nhân viên mới
7. Thống kê ngày nghỉ phép đã sử dụng
8. So sánh lương trung bình theo vị trí và kinh nghiệm
9. Báo cáo chấm công: đi trễ, về sớm
10. Dự báo ngân sách nhân sự quý tiếp theo

---

## Bước 7 - Vẽ System Architecture và hoàn thiện

**Mục đích**: Tự vẽ sơ đồ kiến trúc hệ thống tổng thể và hoàn thiện bài nộp.

**Đầu vào**: Toàn bộ project đã hoàn thành.

**Đầu ra**:
- File `docs/architecture.png`: Sơ đồ kiến trúc hệ thống.
- Thư mục nộp bài đầy đủ theo cấu trúc bên dưới.

**Cách làm**:
1. Mở công cụ vẽ sơ đồ (draw.io, Excalidraw, hoặc Lucidchart).
2. Vẽ sơ đồ thể hiện: nguồn dữ liệu -> Database -> Business Logic -> Báo cáo.
3. Ghi rõ tên technology (SQL Server, SSMS, SSRS, ...).
4. Export thành PNG và lưu vào `docs/architecture.png`.
5. Sắp xếp tất cả file theo cấu trúc thư mục bên dưới.

---

## Cấu trúc thư mục nộp bài

```
StudentName-ProjectI/
  README.md
  docs/
    ERD.png
    architecture.png
  sql/
    01-create-database.sql
    02-create-tables.sql
    03-insert-data.sql
    04-stored-procedures.sql
    05-views.sql
    06-reports.sql
  screenshots/
    report-01.png
    report-02.png
    ...
```

---

## Tài liệu tham khảo

- Microsoft SQL Server Documentation: https://docs.microsoft.com/en-us/sql/sql-server/
- Database Normalization (1NF, 2NF, 3NF): https://www.guru99.com/database-normalization.html
- ERD Tutorial: https://www.lucidchart.com/pages/er-diagrams
- SQL Server Stored Procedures: https://docs.microsoft.com/en-us/sql/relational-databases/stored-procedures/
