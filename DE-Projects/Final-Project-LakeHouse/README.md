# Final Project: Xây dựng LakeHouse

> **Module**: Tổng hợp - Apache Kafka, Spark, Airflow, Data Modeling, Data Lake
> **Mức độ**: Chuyên sâu
> **Thời gian**: 4 tuần

---

## Mục tiêu

Trong project này, học viên sẽ xây dựng một hệ thống LakeHouse hoàn chỉnh - kết hợp cả dữ liệu real-time và batch, xử lý theo kiến trúc Medallion (Bronze -> Silver -> Gold), và truy vấn để tạo insights.

Cụ thể, học viên sẽ làm việc với 2 loại dữ liệu:

| Loại dữ liệu | Mô tả | Luồng xử lý |
|---------------|-------|-------------|
| Clickstream Data | Dữ liệu hành vi người dùng (xem trang, click, mua hàng) - đến liên tục theo thời gian thực | Kafka Producer -> Kafka -> Spark Streaming -> Iceberg Table (lưu trên MinIO) |
| Batch Data (Bookings) | Dữ liệu đặt phòng từ PostgreSQL - nạp định kỳ | PostgreSQL -> Spark Batch ETL -> Iceberg Table (lưu trên MinIO) |

Sau khi dữ liệu đã vào Iceberg tables, học viên viết queries để phân tích và tạo dashboard.

Chủ đề: Học viên có thể tự lựa chọn bài toán (e-commerce, hotel bookings, ride-sharing, ...). Dữ liệu mẫu cung cấp là hotel bookings. Cần được giảng viên phê duyệt nếu tự chọn chủ đề.

---

## Kiến trúc hệ thống

Xem sơ đồ kiến trúc mẫu tại: [docs/architecture.md](docs/architecture.md)

YÊU CẦU BẮT BUỘC: Học viên phải tự vẽ System Architecture diagram cho project của mình. Diagram phải thể hiện đầy đủ data flow từ source -> processing -> storage -> serving.

Mẫu tham khảo:
- huynn-lakehouse-project: https://github.com/huynndacoder/huynn-lakehouse-project (CDC pipeline với PostgreSQL, Debezium, Kafka, Spark, Iceberg)
- feature-store: https://github.com/dunghoang369/feature-store (Batch + Streaming pipeline với PySpark, Flink, Kafka, Airflow)

---

## Hướng dẫn thực hiện chi tiết

Project gồm 6 bước chính, thực hiện tuần tự trong 4 tuần.

---

## Bước 1 - Setup Infrastructure (Tuần 1, 3-4 ngày đầu) (15 điểm)

**Mục đích**: Dựng toàn bộ môi trường bằng Docker. Tất cả services (database, message broker, compute engine, storage) phải chạy được bằng 1 lệnh duy nhất `docker compose up -d`.

**Đầu vào**: File `docker-compose.yml` và các scripts khởi tạo.

**Đầu ra**:
- Tất cả services đang chạy:
  - PostgreSQL (source database) - port 5432
  - Kafka + Zookeeper (message broker) - port 9092
  - Spark Master + Worker (compute engine) - port 8090
  - MinIO (object storage, tương tự S3) - port 9000 (API), 9001 (console)
  - (Tùy chọn) Airflow, Trino/Doris, Streamlit
- Kafka topics đã được tạo.
- MinIO buckets đã được tạo.
- PostgreSQL đã có dữ liệu mẫu.

**Cách làm**:

1. Tạo file `docker-compose.yml`. Mẫu có sẵn ở phần cuối README - copy và tùy chỉnh.

2. Tạo file `.env` chứa các biến môi trường:
```
POSTGRES_USER=admin
POSTGRES_PASSWORD=admin
POSTGRES_DB=bookings_db
MINIO_ROOT_USER=admin
MINIO_ROOT_PASSWORD=admin12345
```

3. Khởi động tất cả services:
```bash
docker compose up -d
```

4. Đợi 30-60 giây cho services khởi động xong, kiểm tra:
```bash
docker compose ps
```
Tất cả services phải có trạng thái "running" hoặc "healthy".

5. Tạo Kafka topics:
```bash
docker exec -it kafka kafka-topics --create \
  --topic clickstream \
  --bootstrap-server localhost:9092 \
  --partitions 3 \
  --replication-factor 1
```

6. Tạo MinIO bucket (truy cập console tại http://localhost:9001):
   - Đăng nhập: admin / admin12345
   - Tạo bucket: `datalake`
   - Trong bucket `datalake`, tạo các folder: `warehouse/`, `checkpoint/`

7. PostgreSQL đã được khởi tạo với file `scripts/init_postgres.sql` (tự động chạy khi container bắt đầu). Kiểm tra:
```bash
docker exec -it postgres psql -U admin -d bookings_db -c "SELECT count(*) FROM bookings;"
```

8. Chụp screenshots các services đang chạy.

---

## Bước 2 - Real-time Ingestion: Clickstream Data (Tuần 1-2) (25 điểm)

**Mục đích**: Tạo chương trình mô phỏng dữ liệu hành vi người dùng (clickstream) và gửi vào Kafka. Sau đó, dùng Spark Structured Streaming đọc từ Kafka và ghi vào Iceberg table trên MinIO. Đây là luồng dữ liệu "real-time" của hệ thống.

**Đầu vào**: Kafka topic `clickstream` nhận dữ liệu liên tục từ Producer.

**Đầu ra**:
- Kafka Producer đang gửi events liên tục.
- Spark Streaming job đang đọc và ghi dữ liệu vào Iceberg Bronze table.
- Dữ liệu đã xuất hiện trên MinIO bucket.

**Cách làm**:

Phần A - Viết Clickstream Producer:

1. Tạo file `kafka/clickstream_producer.py`. Đây là chương trình Python gửi events mô phỏng hành vi người dùng:
```python
import json, random, time
from datetime import datetime
from kafka import KafkaProducer

producer = KafkaProducer(
    bootstrap_servers=['kafka:9092'],
    value_serializer=lambda v: json.dumps(v).encode('utf-8')
)

PAGES = ["/home", "/products", "/product/detail", "/cart", "/checkout", "/payment", "/confirmation"]
DEVICES = ["mobile", "desktop", "tablet"]
ACTIONS = ["page_view", "click", "add_to_cart", "remove_from_cart", "purchase", "search"]

def generate_clickstream():
    user_id = f"user_{random.randint(1, 500)}"
    session_id = f"sess_{random.randint(10000, 99999)}"
    return {
        "event_id": f"evt_{int(time.time()*1000)}_{random.randint(1,999)}",
        "user_id": user_id,
        "session_id": session_id,
        "action": random.choice(ACTIONS),
        "page": random.choice(PAGES),
        "device": random.choice(DEVICES),
        "timestamp": datetime.now().isoformat(),
        "duration_sec": random.randint(1, 300),
        "product_id": f"prod_{random.randint(1, 100)}" if random.random() > 0.3 else None,
        "referrer": random.choice(["google", "facebook", "direct", "email", None])
    }

if __name__ == "__main__":
    print("Bắt đầu gửi clickstream events...")
    while True:
        event = generate_clickstream()
        producer.send("clickstream", value=event)
        time.sleep(random.uniform(0.1, 1.0))
```
2. Chạy producer và xác nhận dữ liệu đang gửi.

Phần B - Viết Spark Streaming Job:

3. Tạo file `spark_jobs/streaming/clickstream_ingestion.py`. Chương trình này đọc từ Kafka, parse JSON, và ghi vào Iceberg table:
```python
from pyspark.sql import SparkSession
from pyspark.sql import functions as F
from pyspark.sql.types import *

spark = SparkSession.builder \
    .appName("ClickstreamIngestion") \
    .config("spark.sql.catalog.lakehouse", "org.apache.iceberg.spark.SparkCatalog") \
    .config("spark.sql.catalog.lakehouse.type", "hadoop") \
    .config("spark.sql.catalog.lakehouse.warehouse", "s3a://datalake/warehouse") \
    .config("spark.hadoop.fs.s3a.endpoint", "http://minio:9000") \
    .config("spark.hadoop.fs.s3a.access.key", "admin") \
    .config("spark.hadoop.fs.s3a.secret.key", "admin12345") \
    .config("spark.hadoop.fs.s3a.path.style.access", "true") \
    .getOrCreate()

# Định nghĩa schema của clickstream event
schema = StructType([
    StructField("event_id", StringType()),
    StructField("user_id", StringType()),
    StructField("session_id", StringType()),
    StructField("action", StringType()),
    StructField("page", StringType()),
    StructField("device", StringType()),
    StructField("timestamp", StringType()),
    StructField("duration_sec", IntegerType()),
    StructField("product_id", StringType()),
    StructField("referrer", StringType())
])

# Đọc từ Kafka
raw_stream = spark.readStream \
    .format("kafka") \
    .option("kafka.bootstrap.servers", "kafka:9092") \
    .option("subscribe", "clickstream") \
    .option("startingOffsets", "latest") \
    .load()

# Parse JSON và tính toán trường phát sinh
parsed = raw_stream \
    .select(F.from_json(F.col("value").cast("string"), schema).alias("data")) \
    .select("data.*") \
    .withColumn("event_time", F.to_timestamp("timestamp")) \
    .withColumn("event_date", F.to_date("event_time"))

# Ghi vào Iceberg Bronze table
query = parsed.writeStream \
    .format("iceberg") \
    .outputMode("append") \
    .option("path", "lakehouse.clickstream.bronze") \
    .option("checkpointLocation", "s3a://datalake/checkpoint/clickstream") \
    .start()

query.awaitTermination()
```
Giải thích:
- `spark.sql.catalog.lakehouse`: Cấu hình Iceberg catalog sử dụng MinIO làm storage.
- `s3a://`: Giao thức truy cập MinIO (tương tự S3).
- `checkpointLocation`: Lưu vị trí xử lý để phục hồi khi gặp lỗi.

4. Submit Spark job:
```bash
docker exec spark-master spark-submit \
  --packages org.apache.spark:spark-sql-kafka-0-10_2.12:3.4.0,org.apache.iceberg:iceberg-spark-runtime-3.4_2.12:1.4.0 \
  /opt/spark-jobs/streaming/clickstream_ingestion.py
```

5. Kiểm tra dữ liệu trên MinIO Console (http://localhost:9001) - dữ liệu phải xuất hiện trong bucket `datalake/warehouse/`.

---

## Bước 3 - Batch Ingestion: Bookings Data (Tuần 2) (20 điểm)

**Mục đích**: Đọc dữ liệu đặt phòng từ PostgreSQL và nạp vào Iceberg table. Đây là luồng dữ liệu "batch" - chạy định kỳ (hàng ngày hoặc hàng giờ) để cập nhật dữ liệu mới.

**Đầu vào**: PostgreSQL database `bookings_db` với các bảng: customers, rooms, bookings, payments.

**Đầu ra**: Iceberg tables chứa dữ liệu bookings trên MinIO.

**Cách làm**:

1. Tạo file `spark_jobs/batch/batch_ingestion.py`:
```python
from pyspark.sql import SparkSession
from pyspark.sql import functions as F

spark = SparkSession.builder \
    .appName("BatchIngestion-Bookings") \
    .config("spark.sql.catalog.lakehouse", "org.apache.iceberg.spark.SparkCatalog") \
    .config("spark.sql.catalog.lakehouse.type", "hadoop") \
    .config("spark.sql.catalog.lakehouse.warehouse", "s3a://datalake/warehouse") \
    .config("spark.hadoop.fs.s3a.endpoint", "http://minio:9000") \
    .config("spark.hadoop.fs.s3a.access.key", "admin") \
    .config("spark.hadoop.fs.s3a.secret.key", "admin12345") \
    .config("spark.hadoop.fs.s3a.path.style.access", "true") \
    .getOrCreate()

# Đọc dữ liệu từ PostgreSQL
bookings_df = spark.read \
    .format("jdbc") \
    .option("url", "jdbc:postgresql://postgres:5432/bookings_db") \
    .option("dbtable", "bookings") \
    .option("user", "admin") \
    .option("password", "admin") \
    .load()

# Thêm trường phát sinh
transformed_df = bookings_df \
    .withColumn("ingestion_date", F.current_date()) \
    .withColumn("booking_year", F.year("check_in_date")) \
    .withColumn("booking_month", F.month("check_in_date")) \
    .withColumn("stay_duration",
        F.datediff("check_out_date", "check_in_date"))

# Ghi vào Iceberg table
transformed_df.writeTo("lakehouse.bookings.bronze_bookings") \
    .using("iceberg") \
    .partitionedBy("booking_year", "booking_month") \
    .createOrReplace()

print("Batch ingestion hoàn thành!")
```

2. Submit job:
```bash
docker exec spark-master spark-submit \
  --packages org.apache.iceberg:iceberg-spark-runtime-3.4_2.12:1.4.0 \
  /opt/spark-jobs/batch/batch_ingestion.py
```

3. Nếu muốn tự động chạy định kỳ, tạo Airflow DAG hoặc dùng cron job.

4. Để nạp dữ liệu tăng dần (incremental load), thêm điều kiện lọc theo `updated_at`:
```python
# Chỉ lấy records mới hơn lần chạy trước
last_run = "2024-01-01"
bookings_df = spark.read \
    .format("jdbc") \
    .option("url", "jdbc:postgresql://postgres:5432/bookings_db") \
    .option("query", f"SELECT * FROM bookings WHERE updated_at > '{last_run}'") \
    .option("user", "admin") \
    .option("password", "admin") \
    .load()
```

---

## Bước 4 - Medallion Architecture: Bronze -> Silver -> Gold (Tuần 3) (15 điểm)

**Mục đích**: Xử lý dữ liệu qua 3 tầng chuẩn của Medallion Architecture:
- Bronze: Dữ liệu thô, vừa được nạp vào (từ Bước 2 và 3).
- Silver: Dữ liệu đã làm sạch, loại bỏ trùng lặp, chuẩn hóa kiểu dữ liệu.
- Gold: Dữ liệu đã tổng hợp, sẵn sàng cho phân tích và dashboard.

**Đầu vào**: Iceberg Bronze tables (clickstream và bookings).

**Đầu ra**:
- Iceberg Silver tables (dữ liệu sạch).
- Iceberg Gold tables (dữ liệu tổng hợp):
  - daily_booking_summary: Tổng hợp đặt phòng hàng ngày.
  - user_session_analytics: Phân tích phiên người dùng.
  - conversion_funnel: Tỷ lệ chuyển đổi theo từng bước.
  - revenue_by_category: Doanh thu theo danh mục/vùng miền/thời gian.

**Cách làm**:

1. Viết job Bronze -> Silver:
   - Đọc dữ liệu từ Bronze tables.
   - Xóa bản ghi trùng lặp (dựa trên event_id hoặc booking_id).
   - Loại bỏ dữ liệu không hợp lệ.
   - Chuẩn hóa kiểu dữ liệu.
   - Ghi vào Silver tables.

2. Viết job Silver -> Gold:
   - Đọc dữ liệu từ Silver tables.
   - Tính toán các aggregations:
     - Tổng hợp booking: số bookings, doanh thu, thời gian lưu trú trung bình... nhóm theo ngày.
     - Phân tích session: số trang xem, thời gian ở lại, hành vi... nhóm theo user và session.
     - Conversion funnel: Đếm số lượng user ở mỗi bước (xem trang -> xem sản phẩm -> thêm giỏ hàng -> thanh toán).
   - Ghi vào Gold tables.

3. Kiểm tra dữ liệu trong Gold tables.

---

## Bước 5 - Analytics và Serving (Tuần 3-4) (15 điểm)

**Mục đích**: Setup query engine để truy vấn Iceberg tables và tạo dashboard trực quan hóa.

**Đầu vào**: Iceberg Gold tables.

**Đầu ra**:
- Query engine (Trino/Doris) kết nối với Iceberg catalog.
- Tối thiểu 5 truy vấn phân tích với kết quả.
- Dashboard trực quan hóa.

**Cách làm**:

1. Setup query engine. Chọn 1 trong các options:
   - Trino: Thêm vào docker-compose, cấu hình Iceberg connector.
   - Doris/ClickHouse: Tương tự.
   - Hoặc sử dụng trực tiếp Spark SQL.

2. Viết và chạy tối thiểu 5 analytical queries:

   Query 1 - Daily Active Users (DAU) từ clickstream:
   Đếm số user duy nhất truy cập mỗi ngày.

   Query 2 - Conversion rate:
   Tính tỷ lệ người dùng đi từ xem trang đến mua hàng.

   Query 3 - Revenue trend:
   Doanh thu theo ngày/tuần/tháng, vẽ được xu hướng tăng/giảm.

   Query 4 - Top destinations/products:
   Sản phẩm hoặc địa điểm được đặt nhiều nhất.

   Query 5 - Average session duration by device:
   Thời gian trung bình mỗi phiên theo loại thiết bị (mobile/desktop/tablet).

3. Tạo dashboard (chọn 1):
   - Streamlit (Python, đơn giản): `pip install streamlit` -> viết file dashboard.py.
   - Apache Superset: Chuyên nghiệp hơn, cần setup thêm.
   - Power BI: Kết nối qua ODBC.

4. (Tùy chọn) Tạo FastAPI endpoints để serve dữ liệu cho dashboard.

---

## Bước 6 - Architecture Diagram và Documentation (Tuần 4) (10 điểm)

**Mục đích**: Vẽ sơ đồ kiến trúc hệ thống và hoàn thiện tài liệu nộp bài.

YÊU CẦU BẮT BUỘC: Học viên PHẢI tự vẽ System Architecture diagram.

**Đầu vào**: Toàn bộ project đã hoàn thành.

**Đầu ra**:
- File `docs/architecture.png`: Sơ đồ kiến trúc hệ thống.
- Tài liệu đầy đủ.

**Yêu cầu cho diagram**:
- Thể hiện TẤT CẢ components (PostgreSQL, Kafka, Spark, MinIO, Iceberg, Query Engine, Dashboard).
- Phân biệt rõ Real-time path (Clickstream -> Kafka -> Spark Streaming -> Iceberg) và Batch path (PostgreSQL -> Spark Batch -> Iceberg).
- Thể hiện Medallion Architecture (Bronze -> Silver -> Gold).
- Ghi rõ technology cho mỗi component.
- Sử dụng draw.io, Excalidraw, hoặc Lucidchart. KHÔNG dùng text-based diagram.
- Export thành PNG chất lượng cao.

---

## Cấu trúc thư mục nộp bài

```
StudentName-FinalProject-LakeHouse/
  README.md
  docs/
    architecture.png           (BẮT BUỘC)
    architecture.md
    data-dictionary.md
    medallion-architecture.md
  docker-compose.yml
  .env
  scripts/
    init_postgres.sql
    init_minio.sh
    create_topics.sh
    setup.sh
  kafka/
    clickstream_producer.py
    debezium.json              (tùy chọn - CDC connector)
  spark_jobs/
    streaming/
      clickstream_ingestion.py
      medallion_streaming.py
    batch/
      batch_ingestion.py
      gold_aggregations.py
  dags/                        (tùy chọn - Airflow DAGs)
    batch_pipeline.py
  serving/
    api.py                     (tùy chọn - FastAPI)
    dashboard.py
    queries.sql
  config/
    spark-defaults.conf
    iceberg-catalog.properties
  screenshots/
    system-running.png
    kafka-topics.png
    minio-buckets.png
    iceberg-tables.png
    dashboard.png
```

---

## Docker Compose - Mẫu

```yaml
version: '3.8'

services:
  postgres:
    image: postgres:15
    environment:
      POSTGRES_USER: admin
      POSTGRES_PASSWORD: admin
      POSTGRES_DB: bookings_db
    ports:
      - "5432:5432"
    volumes:
      - ./scripts/init_postgres.sql:/docker-entrypoint-initdb.d/init.sql
      - postgres_data:/var/lib/postgresql/data

  zookeeper:
    image: confluentinc/cp-zookeeper:7.5.0
    environment:
      ZOOKEEPER_CLIENT_PORT: 2181

  kafka:
    image: confluentinc/cp-kafka:7.5.0
    depends_on:
      - zookeeper
    environment:
      KAFKA_BROKER_ID: 1
      KAFKA_ZOOKEEPER_CONNECT: zookeeper:2181
      KAFKA_ADVERTISED_LISTENERS: PLAINTEXT://kafka:9092
      KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR: 1
    ports:
      - "9092:9092"

  minio:
    image: minio/minio:latest
    environment:
      MINIO_ROOT_USER: admin
      MINIO_ROOT_PASSWORD: admin12345
    command: server /data --console-address ":9001"
    ports:
      - "9000:9000"
      - "9001:9001"
    volumes:
      - minio_data:/data

  spark-master:
    image: bitnami/spark:3.4
    environment:
      - SPARK_MODE=master
    ports:
      - "8090:8080"
      - "7077:7077"
    volumes:
      - ./spark_jobs:/opt/spark-jobs

  spark-worker:
    image: bitnami/spark:3.4
    environment:
      - SPARK_MODE=worker
      - SPARK_MASTER_URL=spark://spark-master:7077
      - SPARK_WORKER_MEMORY=2g
      - SPARK_WORKER_CORES=2
    depends_on:
      - spark-master

volumes:
  postgres_data:
  minio_data:
```

---

## Quick Start (sau khi có đầy đủ files)

```bash
# 1. Khởi động tất cả services
docker compose up -d

# 2. Đợi services khởi động (30-60 giây)
docker compose ps

# 3. Tạo Kafka topics
./scripts/create_topics.sh

# 4. Tạo MinIO buckets
./scripts/init_minio.sh

# 5. Chạy clickstream producer
python kafka/clickstream_producer.py &

# 6. Submit Spark streaming job
docker exec spark-master spark-submit \
  --packages org.apache.spark:spark-sql-kafka-0-10_2.12:3.4.0,org.apache.iceberg:iceberg-spark-runtime-3.4_2.12:1.4.0 \
  /opt/spark-jobs/streaming/clickstream_ingestion.py

# 7. Chạy batch ingestion
docker exec spark-master spark-submit \
  --packages org.apache.iceberg:iceberg-spark-runtime-3.4_2.12:1.4.0 \
  /opt/spark-jobs/batch/batch_ingestion.py

# 8. Truy cập các giao diện:
# MinIO Console: http://localhost:9001
# Spark UI: http://localhost:8090
# Dashboard: http://localhost:8505 (nếu dùng Streamlit)
```

---

## Timeline gợi ý

| Tuần | Công việc |
|------|-----------|
| Tuần 1 | Bước 1: Docker setup (PostgreSQL, Kafka, Spark, MinIO). Bắt đầu Bước 2: Clickstream Producer |
| Tuần 2 | Hoàn thành Bước 2: Spark Streaming -> Iceberg. Bước 3: Batch ingestion từ PostgreSQL |
| Tuần 3 | Bước 4: Medallion Architecture (Bronze -> Silver -> Gold). Bắt đầu Bước 5: Query Engine |
| Tuần 4 | Hoàn thành Bước 5: Analytics và Dashboard. Bước 6: Architecture diagram và documentation |

---

## Điểm thưởng (tối đa +15 điểm)

| Tiêu chí | Điểm |
|----------|------|
| Tích hợp Debezium CDC (tự động bắt thay đổi từ PostgreSQL) | +3 |
| Xử lý schema evolution (khi schema thay đổi) | +2 |
| Data quality framework (Great Expectations) | +3 |
| CI/CD pipeline cho Spark jobs | +2 |
| Monitoring và alerting (Grafana) | +3 |
| Unit tests cho ETL jobs | +2 |

---

## Tài liệu tham khảo

- Apache Iceberg Documentation: https://iceberg.apache.org/docs/latest/
- Spark Structured Streaming: https://spark.apache.org/docs/latest/structured-streaming-programming-guide.html
- Medallion Architecture: https://www.databricks.com/glossary/medallion-architecture
- MinIO Documentation: https://min.io/docs/minio/linux/index.html
- Mẫu tham khảo:
  - huynn-lakehouse-project: https://github.com/huynndacoder/huynn-lakehouse-project
  - feature-store: https://github.com/dunghoang369/feature-store
