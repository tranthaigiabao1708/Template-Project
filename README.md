# Data Engineering – Project Templates

> Bộ template dành cho các đồ án môn **Kỹ thuật Dữ liệu (Data Engineering)**.  
> Học viên chọn **một template** phù hợp với loại đồ án được giao, clone về và bắt đầu làm việc.

---

## Danh sách Template

| # | Folder | Mô tả | Công nghệ chính |
|---|--------|--------|-----------------|
| 1 | [**Project-I-Database-Design**](./Project-I-Database-Design/) | Thiết kế CSDL quan hệ, chuẩn hóa, ERD | SQL Server / PostgreSQL |
| 2 | [**Project-II-DWH-ETL-PowerBI**](./Project-II-DWH-ETL-PowerBI/) | Xây dựng Data Warehouse, ETL pipeline & báo cáo BI | SSIS / Python, Power BI |
| 3 | [**Project-III-AWS-DWH-DataLake**](./Project-III-AWS-DWH-DataLake/) | Data Warehouse & Data Lake trên AWS | S3, Glue, Redshift, Athena |
| 4 | [**Mini-Project-1-Hadoop-HBase-Sqoop**](./Mini-Project-1-Hadoop-HBase-Sqoop/) | Hệ sinh thái Hadoop – lưu trữ & truy vấn Big Data | Hadoop, HBase, Sqoop |
| 5 | [**Mini-Project-2-BigData-ETL**](./Mini-Project-2-BigData-ETL/) | ETL pipeline xử lý dữ liệu lớn | Spark, Airflow |
| 6 | [**Mini-Project-3-Realtime-Retail**](./Mini-Project-3-Realtime-Retail/) | Streaming & xử lý dữ liệu thời gian thực | Kafka, Spark Streaming |
| 7 | [**Final-Project-LakeHouse**](./Final-Project-LakeHouse/) | Đồ án cuối kỳ – Kiến trúc Lakehouse end-to-end | Delta Lake, Spark, Airflow |

---

## Hướng dẫn sử dụng

### Bước 1 – Clone repo
```bash
git clone https://github.com/tranthaigiabao1708/Template-Project.git
```

### Bước 2 – Chọn template phù hợp
Mở folder tương ứng với đồ án được giao và đọc file `README.md` bên trong.

### Bước 3 – Bắt đầu làm việc
Mỗi template đã bao gồm:
- **README.md** – Hướng dẫn chi tiết từng bước
- **docs/** – Sơ đồ kiến trúc & thiết kế
- **rubric.md** – Tiêu chí chấm điểm
- **submission-template.md** – Mẫu báo cáo nộp bài
- **starter-code/** – Code khởi đầu *(nếu có)*

---

## Cấu trúc mỗi Template

```
Project-X/
├── README.md                 # Hướng dẫn thực hiện
├── docs/
│   ├── architecture.md       # Mô tả kiến trúc
│   └── diagram_*.png         # Sơ đồ minh họa
├── rubric.md                 # Tiêu chí chấm điểm
├── submission-template.md    # Mẫu nộp bài
└── starter-code/             # Code mẫu khởi đầu
```

---

## Lưu ý

- Mỗi nhóm chỉ chọn **một template** theo phân công của giảng viên.
- Đọc kỹ **rubric.md** trước khi bắt đầu để nắm tiêu chí đánh giá.
- Sử dụng **submission-template.md** làm khung báo cáo nộp bài.
