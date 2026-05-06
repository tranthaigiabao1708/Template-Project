# Rubric - Project III: AWS DWH & Data Lake
## Tổng điểm: 100

### Phần 1: Data Lake trên S3 (20đ)
| Tiêu chí | Xuất sắc (100%) | Khá (75%) | TB (50%) | Chưa đạt |
|----------|-----------------|-----------|----------|-----------|
| **S3 Structure** (8đ) | 3 zones đúng Medallion, partition | 3 zones, chưa partition | 2 zones | Không có cấu trúc |
| **Glue Catalog** (6đ) | Crawler + catalog đầy đủ | Catalog cơ bản | Thiếu metadata | Không có |
| **IAM & Security** (6đ) | Least privilege, policies rõ ràng | IAM cơ bản | Dùng root | Không setup |

### Phần 2: ETL với AWS Glue (30đ)
| Tiêu chí | Xuất sắc (100%) | Khá (75%) | TB (50%) | Chưa đạt |
|----------|-----------------|-----------|----------|-----------|
| **Glue Job Bronze -> Silver** (12đ) | Full pipeline, error handling, partition | Pipeline chạy đúng | Chạy cơ bản | Không chạy |
| **Glue Job Silver -> Gold** (10đ) | Aggregations phức tạp, join | Aggregation cơ bản | Chỉ filter | Không có |
| **Job Configuration** (8đ) | Schedule, retry, bookmarks, monitoring | Schedule cơ bản | Manual trigger | Không config |

### Phần 3: Redshift DWH (20đ)
| Tiêu chí | Xuất sắc (100%) | Khá (75%) | TB (50%) | Chưa đạt |
|----------|-----------------|-----------|----------|-----------|
| **Schema Design** (8đ) | Star schema + distribution/sort keys | Star schema cơ bản | Tables đơn giản | Không có |
| **Data Loading** (6đ) | COPY command, VACUUM, ANALYZE | COPY command đúng | INSERT | Không load |
| **Queries** (6đ) | 5+ analytical queries, window functions | 3-4 queries | 1-2 queries | Không có |

### Phần 4: Query & Viz (15đ)
| Tiêu chí | Xuất sắc (100%) | Khá (75%) | TB (50%) | Chưa đạt |
|----------|-----------------|-----------|----------|-----------|
| **Athena** (5đ) | 5+ queries trên S3, partitioned | 3 queries | 1 query | Không có |
| **Dashboard** (10đ) | 3+ trang, interactive, chuyên nghiệp | 2-3 trang | 1 trang | Không có |

### Phần 5: Documentation (15đ)
| Tiêu chí | Xuất sắc (100%) | Khá (75%) | TB (50%) | Chưa đạt |
|----------|-----------------|-----------|----------|-----------|
| **Architecture** (7đ) | Diagram AWS chuyên nghiệp | Diagram rõ ràng | Sơ sài | Không có |
| **Cost & Security** (4đ) | Cost estimate + security review | 1 trong 2 | Sơ sài | Không có |
| **README** (4đ) | Có thể reproduce từ README | README đầy đủ | Thiếu info | Không có |
