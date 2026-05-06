# Submission Template - Mini Project 2: Big Data ETL Pipeline

## Thông tin học viên
| Thông tin | Chi tiết |
|-----------|----------|
| **Họ và tên** | [Điền tên] |
| **Mã học viên** | [Điền mã] |
| **Ngày nộp** | [DD/MM/YYYY] |

---

## 1. System Architecture
![Architecture](docs/architecture.png)

---

## 2. Extract (MySQL HDFS)
### Source Database:
| Table | Columns | Record Count |
|-------|---------|-------------|
| | | |

### Extract Method:
[PySpark JDBC / Sqoop - Giải thích]

---

## 3. Transform (PySpark)
### Transformations Applied:
| # | Transform | Input | Output | Description |
|---|-----------|-------|--------|-------------|
| 1 | Dedup | raw_df | cleaned_df | |
| 2 | | | | |

### Data Quality Report:
| Metric | Before | After |
|--------|--------|-------|
| Total Records | | |
| Null Count | | |
| Duplicate Count | | |

---

## 4. Load (HDFS HBase)
### HBase Table Design:
| Table | Row Key | Column Families | Description |
|-------|---------|-----------------|-------------|
| | | | |

---

## 5. Analytical Queries
| # | Query Description | Result Summary | Screenshot |
|---|-------------------|---------------|------------|
| 1 | Monthly Revenue | | ![](screenshots/q1.png) |
| 2 | Top Products | | |
| 3 | | | |
| 4 | | | |
| 5 | | | |

---

## Checklist
- [ ] MySQL source database + sample data
- [ ] PySpark Extract job
- [ ] PySpark Transform (cleansing + aggregation)
- [ ] Data quality checks
- [ ] HBase table design + load
- [ ] 5+ analytical queries
- [ ] System Architecture diagram
- [ ] Docker setup (optional)
- [ ] README + GitHub
