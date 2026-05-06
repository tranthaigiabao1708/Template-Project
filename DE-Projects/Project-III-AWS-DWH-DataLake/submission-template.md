# Submission Template - Project III: AWS DWH & Data Lake

## Thông tin học viên
| Thông tin | Chi tiết |
|-----------|----------|
| **Họ và tên** | [Điền tên] |
| **Mã học viên** | [Điền mã] |
| **Ngày nộp** | [DD/MM/YYYY] |

---

## 1. System Architecture
![System Architecture](docs/architecture.png)

### Giải thích kiến trúc:
[Mô tả luồng dữ liệu và vai trò từng AWS service]

### AWS Services sử dụng:
| Service | Vai trò | Configuration |
|---------|---------|---------------|
| S3 | | |
| Glue | | |
| Redshift | | |
| Athena | | |
| IAM | | |

---

## 2. Data Lake Design
### S3 Structure:
```
s3://your-bucket/
 raw/
 cleaned/
 curated/
```

### Partition Strategy:
[Mô tả cách partition dữ liệu]

---

## 3. ETL Pipeline
### Glue Jobs:
| Job | Source | Target | Transform | Schedule |
|-----|--------|--------|-----------|----------|
| | | | | |

---

## 4. Redshift DWH
### Schema Design:
[Chèn ảnh schema]

### Distribution & Sort Keys:
| Table | Dist Key | Sort Key | Reasoning |
|-------|----------|----------|-----------|
| | | | |

---

## 5. Dashboard Screenshots
| Page | Screenshot |
|------|------------|
| | ![](screenshots/page1.png) |

---

## 6. Cost Estimation
| Service | Monthly Cost | Notes |
|---------|-------------|-------|
| | | |
| **Total** | | |

---

## Checklist
- [ ] System Architecture diagram
- [ ] S3 Data Lake với 3 zones
- [ ] Glue Crawler + Catalog
- [ ] 2+ Glue ETL jobs
- [ ] Redshift Star Schema + queries
- [ ] Athena queries
- [ ] Dashboard (3+ trang)
- [ ] Cost estimation
- [ ] Security review
- [ ] README + đẩy GitHub
