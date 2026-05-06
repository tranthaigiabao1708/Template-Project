# Rubric - Final Project: LakeHouse
## Tổng điểm: 100

### Phần 1: Infrastructure Setup (15đ)
| Tiêu chí | Xuất sắc (100%) | Khá (75%) | TB (50%) | Chưa đạt |
|----------|-----------------|-----------|----------|-----------|
| **Docker Compose** (8đ) | Tất cả services chạy 1 lệnh, health checks | Chạy được nhưng cần manual steps | Thiếu 1-2 services | Không chạy |
| **Setup Scripts** (4đ) | One-click setup, idempotent | Scripts cơ bản | Manual setup | Không có |
| **Documentation** (3đ) | README reproducible | README cơ bản | Sơ sài | Không có |

### Phần 2: Real-time Ingestion (25đ)
| Tiêu chí | Xuất sắc (100%) | Khá (75%) | TB (50%) | Chưa đạt |
|----------|-----------------|-----------|----------|-----------|
| **Clickstream Producer** (8đ) | Realistic events, configurable rate | Events hợp lệ | Events đơn giản | Không có |
| **Spark Streaming** (10đ) | Kafka -> Iceberg, watermark, exactly-once | Kafka -> Iceberg cơ bản | Kafka -> Console | Không stream |
| **Bronze -> Silver** (7đ) | Dedup, validation, schema evolution | Dedup cơ bản | Chỉ copy | Không có |

### Phần 3: Batch Ingestion (20đ)
| Tiêu chí | Xuất sắc (100%) | Khá (75%) | TB (50%) | Chưa đạt |
|----------|-----------------|-----------|----------|-----------|
| **PostgreSQL Setup** (5đ) | Schema + seed data đầy đủ | Schema cơ bản | Minimal | Không có |
| **Spark Batch ETL** (10đ) | Incremental load, merge, SCD | Full load đúng | Extract only | Không chạy |
| **Scheduling** (5đ) | Airflow DAG hoặc automated | Cron job | Manual trigger | Không có |

### Phần 4: Medallion Architecture (15đ)
| Tiêu chí | Xuất sắc (100%) | Khá (75%) | TB (50%) | Chưa đạt |
|----------|-----------------|-----------|----------|-----------|
| **Bronze** (3đ) | Cả stream + batch data | 1 loại data | Raw dump | Không có |
| **Silver** (5đ) | Cleansed, typed, partitioned | Cleansed cơ bản | Chỉ filter | Không có |
| **Gold** (7đ) | 4+ aggregation tables, complex logic | 2-3 tables | 1 table | Không có |

### Phần 5: Analytics & Serving (15đ)
| Tiêu chí | Xuất sắc (100%) | Khá (75%) | TB (50%) | Chưa đạt |
|----------|-----------------|-----------|----------|-----------|
| **Query Engine** (5đ) | Trino/Doris connected, queries Iceberg | Basic queries | SQL only | Không có |
| **Analytical Queries** (5đ) | 5+ queries, window functions, insights | 3-4 queries | 1-2 queries | Không có |
| **Dashboard** (5đ) | Interactive, real-time, professional | 3+ pages | 1 page | Không có |

### Phần 6: Architecture Diagram (10đ)
| Tiêu chí | Xuất sắc (100%) | Khá (75%) | TB (50%) | Chưa đạt |
|----------|-----------------|-----------|----------|-----------|
| **Completeness** (4đ) | All components + connections | Most components | Missing components | Không có |
| **Clarity** (3đ) | Professional, labeled, colored | Clear | Basic | Unclear |
| **Dual Path** (3đ) | RT + Batch clearly shown | Both shown | Only one | Missing |

---

## Điểm thưởng (+15 điểm tối đa)
| Tiêu chí | Điểm |
|----------|-------|
| Debezium CDC integration | +3 |
| Schema evolution handling | +2 |
| Data quality framework (Great Expectations) | +3 |
| CI/CD pipeline cho Spark jobs | +2 |
| Monitoring & alerting (Grafana) | +3 |
| Unit tests cho ETL jobs | +2 |
