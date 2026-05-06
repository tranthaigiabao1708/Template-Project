# Rubric - Project II: Data Warehouse + ETL + PowerBI

## Tổng điểm: 100

### Phần 1: Thiết kế Data Warehouse (25 điểm)

| Tiêu chí | Xuất sắc (100%) | Khá (75%) | TB (50%) | Chưa đạt |
|----------|-----------------|-----------|----------|-----------|
| **Star Schema** (10đ) | 1 Fact + 4+ Dims, đúng grain, surrogate keys | 1 Fact + 3 Dims | Schema cơ bản | Không đúng mô hình |
| **SCD Design** (5đ) | SCD Type 2 triển khai đúng | SCD Type 1 | Không có SCD | - |
| **DDL Scripts** (5đ) | Scripts chạy không lỗi, constraints đầy đủ | Scripts chạy được | Có lỗi nhỏ | Không chạy |
| **Schema Diagram** (5đ) | Diagram chuyên nghiệp, rõ ràng | Diagram cơ bản | Sơ sài | Không có |

### Phần 2: ETL Pipeline (30 điểm)

| Tiêu chí | Xuất sắc (100%) | Khá (75%) | TB (50%) | Chưa đạt |
|----------|-----------------|-----------|----------|-----------|
| **Extract** (8đ) | Nhiều nguồn, xử lý kết nối lỗi | 1-2 nguồn | 1 nguồn | Không có |
| **Transform** (10đ) | Cleansing + conversion + lookup + derived | 3/4 techniques | 2/4 techniques | <2 |
| **Load** (7đ) | Full + Incremental load, logging | Full load chạy đúng | Load cơ bản | Không load được |
| **Error Handling** (5đ) | Try-catch, logging, retry logic | Error handling cơ bản | Không đầy đủ | Không có |

### Phần 3: Power BI Dashboard (30 điểm)

| Tiêu chí | Xuất sắc (100%) | Khá (75%) | TB (50%) | Chưa đạt |
|----------|-----------------|-----------|----------|-----------|
| **Data Model** (5đ) | Star schema đúng trong PBI, relationships | Relationships đúng | Model cơ bản | Sai model |
| **DAX Measures** (8đ) | 5+ measures phức tạp (YoY, Running Total) | 3-4 measures | 1-2 measures | Không có |
| **Visualizations** (10đ) | 3+ trang, đa dạng chart types, interactive | 3 trang cơ bản | 1-2 trang | Không có |
| **Design & UX** (7đ) | Chuyên nghiệp, consistent, responsive | Khá đẹp | Cơ bản | Xấu |

### Phần 4: Documentation (15 điểm)

| Tiêu chí | Xuất sắc (100%) | Khá (75%) | TB (50%) | Chưa đạt |
|----------|-----------------|-----------|----------|-----------|
| **Architecture** (5đ) | Diagram chuyên nghiệp | Diagram rõ ràng | Sơ sài | Không có |
| **ETL Mapping** (5đ) | Mapping document chi tiết | Mapping cơ bản | Sơ sài | Không có |
| **Data Dictionary** (3đ) | Đầy đủ cho tất cả tables | Cơ bản | Thiếu nhiều | Không có |
| **README** (2đ) | Hướng dẫn rõ ràng, chạy được | Cơ bản | Sơ sài | Không có |

---

## Điểm thưởng (+10 điểm tối đa)

| Tiêu chí | Điểm |
|----------|-------|
| Incremental ETL với watermark | +3 |
| DAX Time Intelligence functions | +2 |
| Row-Level Security trong Power BI | +2 |
| Automated ETL scheduling (SQL Agent) | +2 |
| Power BI Paginated Reports | +1 |
