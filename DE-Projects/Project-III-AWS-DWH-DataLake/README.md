# Project III: Data Warehouse và Data Lake trên AWS

> **Module**: Cloud - AWS
> **Mức độ**: Trung bình - Nâng cao
> **Thời gian**: 3 tuần

---

## Mục tiêu

Sau khi hoàn thành project, học viên sẽ biết cách:
- Thiết kế kiến trúc Data Lake trên Amazon S3 theo Medallion Architecture (Raw/Cleaned/Curated).
- Sử dụng AWS Glue để tạo ETL pipeline xử lý dữ liệu từ dạng thô sang dạng sẵn sàng phân tích.
- Thiết kế và truy vấn Data Warehouse trên Amazon Redshift.
- Truy vấn dữ liệu trực tiếp trên S3 bằng Amazon Athena (không cần server).
- Tạo dashboard trực quan hóa dữ liệu bằng QuickSight hoặc Power BI.

Chủ đề: Học viên có thể tự lựa chọn chủ đề bài toán (bán hàng, kho vận, nhân sự, ...) hoặc sử dụng dữ liệu mẫu trong thư mục `sample-data/`. Cần được giảng viên phê duyệt nếu tự chọn chủ đề.

---

## Kiến trúc hệ thống

Xem sơ đồ kiến trúc chi tiết tại: [docs/architecture.md](docs/architecture.md)

---

## Hướng dẫn thực hiện chi tiết

Project này gồm 5 bước chính, thực hiện tuần tự.

---

## Bước 1 - Thiết kế Data Lake trên S3 (20 điểm)

**Mục đích**: Tạo "kho chứa dữ liệu" trên AWS S3, tổ chức theo 3 tầng (Medallion Architecture). Tầng Raw chứa dữ liệu gốc, tầng Cleaned chứa dữ liệu đã làm sạch, tầng Curated chứa dữ liệu đã xử lý sẵn sàng cho phân tích.

**Đầu vào**:
- Tài khoản AWS (có thể sử dụng Free Tier).
- Các file dữ liệu mẫu (CSV) trong thư mục `sample-data/`.

**Đầu ra**:
- 1 S3 bucket có cấu trúc thư mục rõ ràng.
- Dữ liệu mẫu đã được upload lên tầng Raw.
- IAM roles và policies đã được cấu hình.
- Glue Catalog database đã được tạo.

**Cách làm**:

1. Đăng nhập AWS Console. Tạo S3 bucket:
```bash
aws s3 mb s3://cole-de-project-<ten-cua-ban>
```

2. Tạo cấu trúc thư mục trong S3 bucket:
```
s3://cole-de-project-<ten-cua-ban>/
  raw/            (Bronze - dữ liệu gốc, dạng CSV)
  cleaned/        (Silver - dữ liệu đã làm sạch, dạng Parquet)
  curated/        (Gold - dữ liệu đã tổng hợp, dạng Parquet)
  scripts/        (Glue ETL scripts)
```

3. Upload dữ liệu mẫu lên tầng Raw:
```bash
aws s3 cp sample-data/ s3://cole-de-project-<ten-cua-ban>/raw/ --recursive
```

4. Tạo IAM Role cho Glue:
   - Vào IAM Console -> Create Role -> Chọn "Glue" làm service.
   - Attach policies: AmazonS3FullAccess, AWSGlueServiceRole.
   - Đặt tên: GlueETLRole.
   - Lưu ARN của role để dùng ở bước sau.

5. Tạo Glue Catalog Database (nơi đăng ký metadata của dữ liệu):
```bash
aws glue create-database --database-input '{"Name": "cole_de_project"}'
```

6. Tạo Glue Crawler để tự động phát hiện schema của dữ liệu trong S3:
   - Vào Glue Console -> Crawlers -> Add Crawler.
   - Trỏ đến S3 path: s3://cole-de-project-<ten-cua-ban>/raw/
   - Chọn IAM Role đã tạo.
   - Output: database `cole_de_project`.
   - Chạy crawler và kiểm tra tables đã được tạo trong Glue Catalog.

7. Chụp screenshot cấu trúc S3 và Glue Catalog.

---

## Bước 2 - ETL với AWS Glue (30 điểm)

**Mục đích**: Xây dựng luồng ETL tự động để chuyển dữ liệu từ Raw (CSV, chưa làm sạch) sang Cleaned (Parquet, đã làm sạch) và từ Cleaned sang Curated (đã tổng hợp, sẵn sàng phân tích).

**Đầu vào**:
- Dữ liệu trong S3 tầng Raw (CSV files).
- Glue Catalog database từ Bước 1.

**Đầu ra**:
- Dữ liệu đã làm sạch ở tầng Cleaned (Parquet format, có partition).
- Dữ liệu đã tổng hợp ở tầng Curated (Parquet, các bảng aggregate).
- 2 Glue ETL jobs chạy thành công.

**Cách làm**:

Job 1 - Raw to Cleaned (Bronze -> Silver):

1. Mở file starter code `starter-code/glue-scripts/raw-to-cleaned.py` để tham khảo.
2. Viết Glue ETL job (PySpark) thực hiện:
   - Đọc dữ liệu CSV từ S3 Raw.
   - Loại bỏ duplicates.
   - Xử lý NULL values.
   - Chuyển đổi kiểu dữ liệu (string -> date, string -> decimal, ...).
   - Thêm các cột phát sinh (năm, tháng, ngày trong tuần, ...).
   - Ghi ra S3 Cleaned dưới dạng Parquet, có partition theo năm/tháng.

3. Upload script lên S3:
```bash
aws s3 cp raw-to-cleaned.py s3://cole-de-project-<ten-cua-ban>/scripts/
```

4. Tạo Glue Job qua Console:
   - Type: Spark.
   - Script location: S3 path đến script.
   - IAM Role: GlueETLRole.
   - Parameters: S3_INPUT_PATH và S3_OUTPUT_PATH.

5. Chạy job và theo dõi trên CloudWatch Logs.

Job 2 - Cleaned to Curated (Silver -> Gold):

6. Viết Glue ETL job thứ 2 để tổng hợp dữ liệu:
   - Đọc dữ liệu Parquet từ S3 Cleaned.
   - Tính toán aggregations (tổng doanh thu theo tháng, top sản phẩm, ...).
   - Ghi ra S3 Curated.

7. Chạy Glue Crawler lại trên Cleaned và Curated để cập nhật Catalog.

8. Chụp screenshot Glue job runs và logs.

---

## Bước 3 - Data Warehouse trên Amazon Redshift (20 điểm)

**Mục đích**: Tạo Data Warehouse trên Redshift để thực hiện truy vấn phân tích nhanh trên dữ liệu lớn. Redshift là DWH chuyên dụng, tối ưu cho truy vấn phức tạp trên hàng triệu/hàng tỷ dòng.

**Đầu vào**: Dữ liệu đã xử lý trong S3 tầng Cleaned hoặc Curated.

**Đầu ra**:
- Redshift cluster (hoặc Serverless) đang chạy.
- Star Schema đã tạo (Fact + Dimensions).
- Dữ liệu đã load từ S3 vào Redshift.
- Tối thiểu 5 analytical queries.

**Cách làm**:

1. Tạo Redshift cluster (hoặc Redshift Serverless để tiết kiệm chi phí):
   - Vào Redshift Console -> Create cluster.
   - Chọn dc2.large (1 node) cho Free Trial.
   - Lưu ý: TẮT CLUSTER KHI KHÔNG SỬ DỤNG để tránh phát sinh chi phí.

2. Kết nối vào Redshift bằng SQL client (DBeaver, pgAdmin, hoặc Query Editor trong Console).

3. Tạo Star Schema (tương tự Project II nhưng trên Redshift):
```sql
CREATE TABLE dim_date (
    date_key INT PRIMARY KEY,
    full_date DATE,
    day_name VARCHAR(15),
    month_name VARCHAR(15),
    quarter INT,
    year INT
);

CREATE TABLE fact_sales (
    sales_key BIGINT IDENTITY(1,1),
    date_key INT REFERENCES dim_date(date_key),
    product_key INT,
    customer_key INT,
    quantity INT,
    total_amount DECIMAL(18,2)
);
```

4. Load dữ liệu từ S3 vào Redshift bằng COPY command:
```sql
COPY fact_sales
FROM 's3://cole-de-project-<ten-cua-ban>/curated/sales/'
IAM_ROLE 'arn:aws:iam::<account-id>:role/RedshiftS3Role'
FORMAT AS PARQUET;
```

5. Viết và chạy các analytical queries. Chụp screenshot kết quả.

---

## Bước 4 - Query và Visualization (15 điểm)

**Mục đích**: Truy vấn dữ liệu bằng Athena (trực tiếp trên S3, không cần server) và tạo dashboard trực quan hóa.

**Đầu vào**: Dữ liệu trong S3 (Glue Catalog) và/hoặc Redshift.

**Đầu ra**:
- Các câu truy vấn Athena chạy thành công.
- Dashboard với tối thiểu 3 trang.

**Cách làm**:

1. Mở Amazon Athena Console.
2. Chọn database `cole_de_project` từ Glue Catalog.
3. Chạy các truy vấn SQL trực tiếp trên dữ liệu S3:
```sql
-- Ví dụ: Doanh thu theo tháng
SELECT year, month, SUM(total_amount) as revenue
FROM curated_sales
GROUP BY year, month
ORDER BY year, month;
```
4. Lưu ý: Athena tính phí theo lượng dữ liệu scan. Dùng Parquet + partition để giảm chi phí.

5. Tạo dashboard:
   - Option A: Amazon QuickSight (kết nối với Athena hoặc Redshift).
   - Option B: Power BI Desktop (kết nối với Redshift qua ODBC driver).
6. Thiết kế tối thiểu 3 trang dashboard.
7. Chụp screenshots.

---

## Bước 5 - Documentation và nộp bài (15 điểm)

**Mục đích**: Hoàn thiện tài liệu và đóng gói bài nộp.

**Đầu vào**: Toàn bộ project đã hoàn thành.

**Đầu ra**: Thư mục nộp bài đầy đủ theo cấu trúc.

**Cách làm**:
1. Vẽ System Architecture diagram thể hiện toàn bộ AWS services đã sử dụng.
2. Viết Cost Estimation: ước tính chi phí hàng tháng cho solution.
3. Viết Security Notes: IAM roles, policies, encryption.
4. Sắp xếp file theo cấu trúc bên dưới.

---

## Cấu trúc thư mục nộp bài

```
StudentName-ProjectIII/
  README.md
  docs/
    architecture.png
    cost-estimation.md
    security-notes.md
  infrastructure/
    cloudformation/
      main-stack.yaml
    iam/
      policies.json
  glue-scripts/
    raw-to-cleaned.py
    cleaned-to-curated.py
    crawler-config.json
  redshift/
    create-tables.sql
    copy-commands.sql
    analytical-queries.sql
  athena/
    queries.sql
  sample-data/
    sales_data.csv
    products.csv
    customers.csv
  screenshots/
    s3-structure.png
    glue-job-run.png
    redshift-query.png
    dashboard.png
```

---

## Lưu ý chi phí AWS

Sử dụng AWS Free Tier khi có thể. TẮT Redshift cluster khi không sử dụng.

| Service | Free Tier | Ước tính chi phí |
|---------|-----------|------------------|
| S3 | 5GB free | ~$0.023/GB/tháng |
| Glue | 1M objects free | ~$0.44/DPU-hour |
| Redshift | 2 tháng free trial | ~$0.25/hour (dc2.large) |
| Athena | 1TB free/tháng | ~$5/TB scanned |
| QuickSight | Free trial | ~$9/user/tháng |

---

## Timeline gợi ý

| Tuần | Công việc |
|------|-----------|
| Tuần 1 | Setup AWS, tạo S3 Data Lake, upload dữ liệu, tạo Glue Crawler |
| Tuần 2 | Viết và chạy Glue ETL jobs. Setup Redshift và load dữ liệu |
| Tuần 3 | Athena queries, tạo Dashboard, hoàn thiện documentation |

---

## Tài liệu tham khảo

- AWS Data Lake Architecture: https://docs.aws.amazon.com/whitepapers/latest/building-data-lakes/building-data-lake-aws.html
- AWS Glue Developer Guide: https://docs.aws.amazon.com/glue/latest/dg/
- Amazon Redshift Getting Started: https://docs.aws.amazon.com/redshift/latest/gsg/
- Amazon Athena User Guide: https://docs.aws.amazon.com/athena/latest/ug/
