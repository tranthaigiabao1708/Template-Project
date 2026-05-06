# Mini Project 2: Big Data ETL Pipeline

> **Module**: Apache Spark, HDFS, HBase
> **Mức độ**: Nâng cao
> **Thời gian**: 2 tuần

---

## Mục tiêu

Sau khi hoàn thành project, học viên sẽ biết cách xây dựng một ETL pipeline hoàn chỉnh:
- Extract: Đọc dữ liệu giao dịch từ MySQL database.
- Transform: Làm sạch và xử lý dữ liệu bằng PySpark trên HDFS.
- Load: Nạp dữ liệu đã xử lý vào HBase.
- Analyze: Chạy các truy vấn phân tích trên dữ liệu đã nạp.

---

## Kiến trúc hệ thống

Xem sơ đồ kiến trúc chi tiết tại: [docs/architecture.md](docs/architecture.md)

---

## Hướng dẫn thực hiện chi tiết

Project này gồm 4 bước chính theo luồng ETL. Học viên có thể tự chọn chủ đề dữ liệu (bán hàng, ngân hàng, logistics, ...) hoặc sử dụng dữ liệu mẫu cung cấp.

---

## Bước 1 - Extract: Đọc dữ liệu từ MySQL và lưu lên HDFS (20 điểm)

**Mục đích**: Lấy dữ liệu từ cơ sở dữ liệu giao dịch (MySQL) và sao chép lên HDFS - hệ thống file phân tán của Hadoop. Đây là bước "lấy dữ liệu ra khỏi nguồn" để chuyển sang hệ thống Big Data xử lý.

**Đầu vào**:
- MySQL database chứa dữ liệu giao dịch (tối thiểu 10,000 records).
- Các bảng nguồn: transactions, products, customers, ...

**Đầu ra**:
- Dữ liệu được lưu trên HDFS tại đường dẫn `/data/raw/` dưới dạng Parquet (hoặc CSV).

**Cách làm**:

1. Setup môi trường (chọn 1 trong 2 cách):
   - Cách A: Sử dụng Docker (khuyến khích) - chạy file `docker-compose.yml` cung cấp sẵn ở phần cuối README.
   - Cách B: Setup thủ công MySQL + Hadoop + HBase + Spark trên máy.

2. Tạo source database và nạp dữ liệu mẫu:
```sql
-- Chạy file sql/create-source-db.sql
-- File này tạo database, các bảng, và insert dữ liệu mẫu
```

3. Viết script PySpark để đọc dữ liệu từ MySQL qua JDBC và ghi lên HDFS:
```python
from pyspark.sql import SparkSession

spark = SparkSession.builder \
    .appName("ETL-Extract") \
    .config("spark.jars", "/path/to/mysql-connector-java.jar") \
    .getOrCreate()

# Đọc dữ liệu từ MySQL
df = spark.read \
    .format("jdbc") \
    .option("url", "jdbc:mysql://localhost:3306/source_db") \
    .option("dbtable", "transactions") \
    .option("user", "root") \
    .option("password", "password") \
    .load()

# Xem thử dữ liệu
df.show(5)
df.printSchema()
print(f"Tổng số records: {df.count()}")

# Ghi lên HDFS dưới dạng Parquet
df.write.mode("overwrite").parquet("hdfs:///data/raw/transactions")
```
Giải thích:
- `format("jdbc")`: Đọc dữ liệu qua giao thức JDBC.
- `.option("url", ...)`: Địa chỉ kết nối đến MySQL.
- `.parquet(...)`: Ghi dữ liệu dưới dạng Parquet (hiệu quả hơn CSV về kích thước và tốc độ truy vấn).

4. Làm tương tự cho các bảng khác (products, customers, ...).
5. Xác nhận dữ liệu đã lên HDFS:
```bash
hdfs dfs -ls /data/raw/
hdfs dfs -du -h /data/raw/
```

---

## Bước 2 - Transform: Làm sạch và xử lý dữ liệu bằng PySpark (35 điểm)

**Mục đích**: Đọc dữ liệu "thô" từ HDFS, làm sạch (xóa trùng lặp, xử lý NULL, kiểm tra hợp lệ), chuyển đổi (thêm cột mới, đổi kiểu dữ liệu, tổng hợp), rồi ghi lại dữ liệu "sạch" lên HDFS. Đây là bước quan trọng nhất - đảm bảo dữ liệu chính xác trước khi nạp vào HBase.

**Đầu vào**: Dữ liệu dạng Parquet trên HDFS tại `/data/raw/`.

**Đầu ra**:
- Dữ liệu đã làm sạch tại `/data/transformed/transactions/` (có partition theo năm/tháng).
- Bảng tổng hợp hàng ngày tại `/data/transformed/daily_summary/`.
- Báo cáo chất lượng dữ liệu (số records trước/sau, tỷ lệ lỗi, ...).

**Cách làm**:

1. Đọc dữ liệu từ HDFS:
```python
raw_df = spark.read.parquet("hdfs:///data/raw/transactions")
print(f"Tổng số records thô: {raw_df.count()}")
```

2. Làm sạch dữ liệu (Data Cleansing):
```python
from pyspark.sql import functions as F

# Xóa bản ghi trùng lặp theo transaction_id
deduped_df = raw_df.dropDuplicates(["transaction_id"])
print(f"Sau khi xóa trùng: {deduped_df.count()}")

# Loại bỏ dòng có amount = NULL hoặc amount <= 0
cleaned_df = deduped_df \
    .filter(F.col("amount").isNotNull()) \
    .filter(F.col("amount") > 0)
print(f"Sau khi lọc: {cleaned_df.count()}")
```

3. Chuyển đổi dữ liệu (Transformation):
```python
transformed_df = cleaned_df \
    .withColumn("transaction_date", F.to_date("timestamp")) \
    .withColumn("year", F.year("transaction_date")) \
    .withColumn("month", F.month("transaction_date")) \
    .withColumn("amount_category",
        F.when(F.col("amount") < 100, "small")
        .when(F.col("amount") < 1000, "medium")
        .otherwise("large"))
```
Giải thích:
- `to_date`: Chuyển cột timestamp thành kiểu date.
- `year`, `month`: Trích xuất năm, tháng từ date (dùng cho partition và báo cáo).
- `amount_category`: Tạo cột mới phân loại giá trị giao dịch.

4. Tổng hợp dữ liệu (Aggregation):
```python
daily_summary = transformed_df.groupBy("transaction_date") \
    .agg(
        F.count("*").alias("total_transactions"),
        F.sum("amount").alias("total_amount"),
        F.avg("amount").alias("avg_amount"),
        F.max("amount").alias("max_amount")
    )
```

5. Kiểm tra chất lượng dữ liệu (Data Quality):
```python
total = transformed_df.count()
null_count = transformed_df.filter(F.col("amount").isNull()).count()
print(f"Tổng records: {total}")
print(f"Records NULL amount: {null_count}")
print(f"Tỷ lệ dữ liệu sạch: {(total - null_count) / total * 100:.1f}%")
```

6. Ghi dữ liệu đã xử lý lên HDFS:
```python
# Dữ liệu chi tiết - partition theo năm/tháng
transformed_df.write.mode("overwrite") \
    .partitionBy("year", "month") \
    .parquet("hdfs:///data/transformed/transactions")

# Dữ liệu tổng hợp
daily_summary.write.mode("overwrite") \
    .parquet("hdfs:///data/transformed/daily_summary")
```

---

## Bước 3 - Load: Nạp dữ liệu vào HBase (20 điểm)

**Mục đích**: Chuyển dữ liệu đã xử lý từ HDFS vào HBase - cơ sở dữ liệu NoSQL tối ưu cho truy vấn theo key. HBase cho phép đọc ghi nhanh theo row key, phù hợp cho việc truy vấn theo ID hoặc time range.

**Đầu vào**: Dữ liệu đã xử lý trên HDFS tại `/data/transformed/`.

**Đầu ra**:
- HBase tables chứa dữ liệu đã xử lý.
- Kết quả xác nhận (scan, count).

**Cách làm**:

1. Thiết kế HBase table schema. Mỗi HBase table có 1 Row Key và nhiều Column Families:
```bash
hbase shell
> create 'analytics:transactions', 'info', 'metrics'
```
Giải thích:
- `analytics:transactions`: Tên namespace và table.
- `info`: Column family chứa thông tin mô tả (ngày, loại, ...).
- `metrics`: Column family chứa số liệu (số tiền, số lượng, ...).

2. Nạp dữ liệu từ PySpark vào HBase:
```python
transformed_df.write \
    .format("org.apache.hadoop.hbase.spark") \
    .option("hbase.table", "analytics:transactions") \
    .option("hbase.columns.mapping",
        "transaction_id STRING :key, "
        "info:date STRING, "
        "info:category STRING, "
        "metrics:amount DOUBLE, "
        "metrics:quantity INT") \
    .save()
```
Giải thích:
- `:key`: Cột nào sẽ làm Row Key (thông thường là ID hoặc composite key).
- `info:date`: Cột "date" trong column family "info".
- `metrics:amount`: Cột "amount" trong column family "metrics".

3. Xác nhận dữ liệu trong HBase:
```bash
hbase shell
> count 'analytics:transactions'
> scan 'analytics:transactions', {LIMIT => 10}
```

---

## Bước 4 - Analytical Queries (25 điểm)

**Mục đích**: Chạy các truy vấn phân tích trên dữ liệu đã nạp để tạo ra các insights có ý nghĩa kinh doanh. Đây là "sản phẩm cuối cùng" của pipeline - chứng minh dữ liệu đã xử lý đúng và có thể khai thác được.

**Đầu vào**: Dữ liệu trong HBase và/hoặc HDFS.

**Đầu ra**:
- Tối thiểu 5 truy vấn phân tích với kết quả.
- Screenshots kết quả mỗi truy vấn.

**Danh sách truy vấn (viết bằng PySpark hoặc HBase Shell)**:

1. Tổng doanh thu theo tháng - Monthly revenue trend.
2. Top 10 sản phẩm/categories theo doanh thu.
3. Phân phối giá trị giao dịch - Transaction value distribution (bao nhiêu giao dịch nhỏ/trung bình/lớn).
4. So sánh Year-over-Year growth - Tăng trưởng so với cùng kỳ năm trước.
5. Anomaly detection - Tìm các giao dịch bất thường (giá trị lớn hơn 3 độ lệch chuẩn).

---

## Cấu trúc thư mục nộp bài

```
StudentName-MiniProject2/
  README.md
  docs/
    architecture.png
  docker/
    docker-compose.yml
  pyspark/
    extract.py
    transform.py
    load.py
    analytics.py
    data_quality.py
  sql/
    create-source-db.sql
    insert-sample-data.sql
  sample-data/
    transactions.csv
  config/
    hbase-site.xml
    spark-defaults.conf
  screenshots/
    extract-result.png
    transform-result.png
    hbase-scan.png
    analytics-output.png
```

---

## Docker Setup (không bắt buộc nhưng khuyến khích)

Nếu muốn setup nhanh toàn bộ môi trường, tạo file `docker-compose.yml`:

```yaml
version: '3.8'
services:
  mysql:
    image: mysql:8.0
    environment:
      MYSQL_ROOT_PASSWORD: password
      MYSQL_DATABASE: source_db
    ports:
      - "3306:3306"
    volumes:
      - ./sql/create-source-db.sql:/docker-entrypoint-initdb.d/init.sql

  namenode:
    image: bde2020/hadoop-namenode:2.0.0-hadoop3.2.1-java8
    environment:
      - CLUSTER_NAME=test
    ports:
      - "9870:9870"

  datanode:
    image: bde2020/hadoop-datanode:2.0.0-hadoop3.2.1-java8

  hbase:
    image: harisekhon/hbase:latest
    ports:
      - "16010:16010"
      - "16020:16020"

  spark-master:
    image: bitnami/spark:latest
    environment:
      - SPARK_MODE=master
    ports:
      - "8080:8080"
      - "7077:7077"

  spark-worker:
    image: bitnami/spark:latest
    environment:
      - SPARK_MODE=worker
      - SPARK_MASTER_URL=spark://spark-master:7077
```

Khởi động: `docker-compose up -d`

---

## Timeline gợi ý

| Tuần | Công việc |
|------|-----------|
| Tuần 1 | Setup môi trường. Bước 1 (Extract từ MySQL sang HDFS). Bước 2 (Transform bằng PySpark) |
| Tuần 2 | Bước 3 (Load vào HBase). Bước 4 (Analytical queries). Hoàn thiện bài nộp |
