# Submission Template - Final Project: LakeHouse

## Thông tin học viên
| Thông tin | Chi tiết |
|-----------|----------|
| **Họ và tên** | [Điền tên] |
| **Mã học viên** | [Điền mã] |
| **GitHub Repo** | [Link GitHub] |
| **Ngày nộp** | [DD/MM/YYYY] |

---

## 1. System Architecture (BẮT BUỘC)

> Chèn ảnh Architecture diagram bạn tự vẽ

![System Architecture](docs/architecture.png)

### 1.1 Giải thích kiến trúc
[Mô tả tổng quan kiến trúc, giải thích tại sao chọn các công nghệ này]

### 1.2 Technology Stack

| Component | Technology | Version | Vai trò |
|-----------|-----------|---------|---------|
| Source DB | PostgreSQL | 15 | Bookings data |
| Message Broker | Apache Kafka | 7.5 | Clickstream ingestion |
| Processing | Apache Spark | 3.4 | Stream + Batch ETL |
| Storage | MinIO + Iceberg | | Data Lake |
| Query Engine | | | Analytics queries |
| Dashboard | | | Visualization |
| Orchestration | | | Scheduling |

---

## 2. Real-time Ingestion (Clickstream)

### 2.1 Kafka Producer
[Mô tả event schema và sending strategy]

### 2.2 Spark Streaming Job
[Mô tả streaming pipeline: Kafka Iceberg]

### 2.3 Windowing & Watermark Strategy
[Giải thích cách xử lý late data]

---

## 3. Batch Ingestion (Bookings)

### 3.1 Source Database Schema
[Mô tả PostgreSQL schema]

### 3.2 ETL Job
[Mô tả batch pipeline: PostgreSQL Iceberg]

### 3.3 Incremental Loading Strategy
[Giải thích cách xác định new/updated records]

---

## 4. Medallion Architecture

### 4.1 Bronze Layer
| Table | Source | Records | Partition |
|-------|--------|---------|-----------|
| | | | |

### 4.2 Silver Layer
| Table | Transform Applied | Records | Partition |
|-------|-------------------|---------|-----------|
| | | | |

### 4.3 Gold Layer
| Table | Business Logic | Records | Partition |
|-------|---------------|---------|-----------|
| | | | |

---

## 5. Analytics

### 5.1 Analytical Queries
| # | Query | Kết quả | Screenshot |
|---|-------|---------|------------|
| 1 | DAU | | ![](screenshots/query-1.png) |
| 2 | Conversion Rate | | |
| 3 | Revenue Trend | | |
| 4 | Top Products | | |
| 5 | Session Analytics | | |

### 5.2 Dashboard
![Dashboard](screenshots/dashboard.png)

---

## 6. Challenges & Learnings

### Khó khăn gặp phải
1. ...
2. ...

### Bài học rút ra
1. ...
2. ...

### Cải tiến trong tương lai
1. ...
2. ...

---

## Checklist nộp bài

### Infrastructure
- [ ] docker-compose.yml chạy được
- [ ] Setup scripts hoàn chỉnh
- [ ] .env file với environment variables

### Real-time Path
- [ ] Clickstream producer
- [ ] Spark Streaming job (Kafka Iceberg)
- [ ] Bronze Silver transformation

### Batch Path
- [ ] PostgreSQL source database
- [ ] Spark batch ETL job
- [ ] Incremental loading

### Medallion Architecture
- [ ] Bronze tables (raw data)
- [ ] Silver tables (cleaned data)
- [ ] Gold tables (4+ aggregation tables)

### Analytics & Serving
- [ ] Query Engine setup
- [ ] 5+ analytical queries
- [ ] Dashboard (3+ pages)

### Documentation
- [ ] **System Architecture diagram (PNG)** 
- [ ] README hoàn chỉnh
- [ ] Data dictionary
- [ ] Screenshots
- [ ] Đẩy lên GitHub
