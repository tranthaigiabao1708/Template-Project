# Submission Template - Project II: DWH + ETL + PowerBI

## Thông tin học viên

| Thông tin | Chi tiết |
|-----------|----------|
| **Họ và tên** | [Điền tên] |
| **Mã học viên** | [Điền mã] |
| **Chủ đề** | [ ] Sales / [ ] Procurement / [ ] Logistics / [ ] Tự chọn: ___ |
| **Ngày nộp** | [DD/MM/YYYY] |

---

## 1. System Architecture

![System Architecture](docs/architecture.png)

### Giải thích kiến trúc:
[Mô tả luồng dữ liệu từ source staging DWH BI]

---

## 2. Data Warehouse Design

### 2.1 Star Schema
![Star Schema](docs/star-schema.png)

### 2.2 Fact Table

| Column | Type | Description |
|--------|------|-------------|
| | | |

### 2.3 Dimension Tables

| Table | Columns | SCD Type |
|-------|---------|----------|
| | | |

---

## 3. ETL Pipeline

### 3.1 ETL Mapping

| Source Table | Source Column | Transform | Target Table | Target Column |
|-------------|--------------|-----------|--------------|---------------|
| | | | | |

### 3.2 ETL Approach
- **Full Load**: [Bảng nào?]
- **Incremental Load**: [Bảng nào? Watermark column?]

### 3.3 Error Handling
[Mô tả cách xử lý lỗi]

---

## 4. Power BI Dashboard

### Screenshots
| Page | Screenshot | Mô tả |
|------|------------|-------|
| Overview | ![](screenshots/page1.png) | KPIs tổng quan |
| Analysis | ![](screenshots/page2.png) | Phân tích chi tiết |
| Trends | ![](screenshots/page3.png) | Xu hướng |

### DAX Measures

| Measure | Formula | Mô tả |
|---------|---------|-------|
| | | |

---

## Checklist nộp bài

- [ ] System Architecture diagram
- [ ] Star Schema diagram
- [ ] DDL scripts (Source + Staging + DWH)
- [ ] ETL packages / scripts
- [ ] ETL mapping document
- [ ] Power BI file (.pbix)
- [ ] Dashboard screenshots
- [ ] Data dictionary
- [ ] README hoàn chỉnh
- [ ] Đẩy lên GitHub
