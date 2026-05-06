# Mini Project 3: Online Retail Analysis - Xử lý dữ liệu thời gian thực

> **Module**: Apache Kafka, Apache Spark Streaming
> **Mức độ**: Nâng cao
> **Thời gian**: 2 tuần

---

## Mục tiêu

Sau khi hoàn thành project, học viên sẽ biết cách:
- Sử dụng Apache Kafka làm message broker để truyền dữ liệu theo thời gian thực.
- Viết Kafka Producer mô phỏng dữ liệu giao dịch bán lẻ liên tục.
- Sử dụng Spark Structured Streaming để xử lý dữ liệu real-time.
- Tính toán các chỉ số KPI theo cửa sổ thời gian (windowed aggregations).
- Lưu kết quả và trực quan hóa.

Chủ đề: Online Retail (bán lẻ trực tuyến). Học viên có thể tự lựa chọn loại dữ liệu khác (ride-sharing, IoT sensors, social media, ...) - cần được giảng viên phê duyệt.

---

## Kiến trúc hệ thống

Xem sơ đồ kiến trúc chi tiết tại: [docs/architecture.md](docs/architecture.md)

---

## Hướng dẫn thực hiện chi tiết

Project này gồm 4 bước chính: tạo nguồn dữ liệu (Producer), xử lý (Streaming), xuất kết quả (Output), và tài liệu (Documentation).

---

## Bước 1 - Kafka Producer: Mô phỏng dữ liệu real-time (20 điểm)

**Mục đích**: Tạo chương trình gửi dữ liệu liên tục vào Kafka topic, mô phỏng luồng giao dịch bán hàng thực tế. Trong thực tế, dữ liệu này đến từ website/app, nhưng trong project này ta sẽ mô phỏng bằng script Python.

**Đầu vào**:
- Kafka cluster đang chạy (có thể dùng Docker).
- Danh sách sản phẩm mẫu (định nghĩa sẵn trong code).

**Đầu ra**:
- 1 Kafka topic `retail-transactions` đang nhận dữ liệu liên tục.
- Mỗi message là 1 event JSON chứa: loại sự kiện (new/update/cancel), order_id, sản phẩm, số lượng, giá, thời gian, vùng miền.

**Cách làm**:

1. Setup môi trường bằng Docker. Tạo file `docker-compose.yml` (mẫu có sẵn ở cuối README):
```bash
docker-compose up -d
```

2. Tạo Kafka topic:
```bash
docker exec -it kafka kafka-topics --create \
  --topic retail-transactions \
  --bootstrap-server localhost:9092 \
  --partitions 3 \
  --replication-factor 1
```
Giải thích:
- `--partitions 3`: Chia topic thành 3 partition để xử lý song song.
- Mỗi partition có thể được đọc bởi 1 consumer riêng.

3. Viết file `producer.py`. Chương trình này chạy liên tục, mỗi 0.5-2 giây gửi 1 event:
```python
from kafka import KafkaProducer
import json, time, random
from datetime import datetime

producer = KafkaProducer(
    bootstrap_servers=['localhost:9092'],
    value_serializer=lambda v: json.dumps(v).encode('utf-8')
)

PRODUCTS = [
    {"id": "P001", "name": "Laptop", "category": "Electronics", "base_price": 999.99},
    {"id": "P002", "name": "Phone", "category": "Electronics", "base_price": 699.99},
    {"id": "P003", "name": "Headphones", "category": "Accessories", "base_price": 149.99},
    {"id": "P004", "name": "Keyboard", "category": "Accessories", "base_price": 79.99},
    {"id": "P005", "name": "Monitor", "category": "Electronics", "base_price": 399.99},
]

def generate_event():
    product = random.choice(PRODUCTS)
    event_type = random.choices(
        ["new_order", "update_order", "cancel_order"],
        weights=[0.7, 0.2, 0.1]
    )[0]
    return {
        "event_type": event_type,
        "order_id": f"ORD-{random.randint(10000, 99999)}",
        "product_id": product["id"],
        "product_name": product["name"],
        "category": product["category"],
        "quantity": random.randint(1, 5),
        "unit_price": product["base_price"],
        "customer_id": f"C{random.randint(1, 1000):04d}",
        "timestamp": datetime.now().isoformat(),
        "region": random.choice(["North", "South", "East", "West"])
    }

if __name__ == "__main__":
    print("Bắt đầu gửi dữ liệu retail...")
    while True:
        event = generate_event()
        producer.send("retail-transactions", value=event)
        print(f"Đã gửi: {event['event_type']} - {event['order_id']}")
        time.sleep(random.uniform(0.5, 2.0))
```

4. Chạy producer:
```bash
pip install kafka-python
python producer.py
```

5. Kiểm tra dữ liệu đang được gửi bằng Kafka Console Consumer:
```bash
docker exec -it kafka kafka-console-consumer \
  --topic retail-transactions \
  --bootstrap-server localhost:9092 \
  --from-beginning
```
Bạn sẽ thấy các message JSON hiện ra liên tục.

6. Chụp screenshot producer đang chạy và consumer đang nhận dữ liệu.

---

## Bước 2 - Spark Structured Streaming: Xử lý dữ liệu real-time (40 điểm)

**Mục đích**: Kết nối Spark với Kafka topic và xử lý dữ liệu theo thời gian thực. Spark đọc từng batch dữ liệu từ Kafka, parse JSON, tính toán các chỉ số (KPIs) theo cửa sổ thời gian (windowed aggregations), rồi xuất kết quả.

**Đầu vào**: Kafka topic `retail-transactions` đang nhận dữ liệu liên tục từ Producer.

**Đầu ra**:
- Các bảng thống kê real-time được in ra console (hoặc lưu file):
  - Doanh thu theo vùng miền mỗi 5 phút.
  - Top sản phẩm bán chạy trong 15 phút gần nhất.
  - Tỷ lệ hủy đơn.
  - Số đơn hàng mỗi phút.

**Cách làm**:

1. Viết file `stream_processor.py`. Đầu tiên, tạo SparkSession và kết nối Kafka:
```python
from pyspark.sql import SparkSession
from pyspark.sql import functions as F
from pyspark.sql.types import *

spark = SparkSession.builder \
    .appName("RetailStreamAnalysis") \
    .config("spark.jars.packages",
            "org.apache.spark:spark-sql-kafka-0-10_2.12:3.4.0") \
    .getOrCreate()
```

2. Định nghĩa schema của message JSON:
```python
schema = StructType([
    StructField("event_type", StringType()),
    StructField("order_id", StringType()),
    StructField("product_id", StringType()),
    StructField("product_name", StringType()),
    StructField("category", StringType()),
    StructField("quantity", IntegerType()),
    StructField("unit_price", DoubleType()),
    StructField("customer_id", StringType()),
    StructField("timestamp", StringType()),
    StructField("region", StringType())
])
```

3. Đọc dữ liệu từ Kafka:
```python
raw_stream = spark.readStream \
    .format("kafka") \
    .option("kafka.bootstrap.servers", "localhost:9092") \
    .option("subscribe", "retail-transactions") \
    .option("startingOffsets", "latest") \
    .load()
```
Giải thích:
- `readStream`: Đọc dữ liệu liên tục (khác với `read` đọc 1 lần).
- `startingOffsets: latest`: Chỉ đọc dữ liệu mới (không đọc dữ liệu cũ).

4. Parse JSON và tính toán các trường phát sinh:
```python
parsed_stream = raw_stream \
    .select(F.from_json(
        F.col("value").cast("string"), schema
    ).alias("data")) \
    .select("data.*") \
    .withColumn("event_time", F.to_timestamp("timestamp")) \
    .withColumn("total_amount", F.col("quantity") * F.col("unit_price"))
```

5. Tính doanh thu theo vùng miền, gộp theo cửa sổ 5 phút (Tumbling Window):
```python
revenue_by_window = parsed_stream \
    .filter(F.col("event_type") == "new_order") \
    .withWatermark("event_time", "10 minutes") \
    .groupBy(
        F.window("event_time", "5 minutes"),
        "region"
    ) \
    .agg(
        F.count("*").alias("order_count"),
        F.sum("total_amount").alias("total_revenue"),
        F.avg("total_amount").alias("avg_order_value")
    )
```
Giải thích:
- `withWatermark("event_time", "10 minutes")`: Cho phép dữ liệu đến trễ tối đa 10 phút.
- `window("event_time", "5 minutes")`: Nhóm dữ liệu theo cửa sổ 5 phút. Ví dụ: 10:00-10:05, 10:05-10:10, ...
- Chỉ tính đơn hàng mới (`new_order`), không tính cập nhật hay hủy.

6. Tính top sản phẩm theo cửa sổ trượt 15 phút (Sliding Window):
```python
top_products = parsed_stream \
    .filter(F.col("event_type") == "new_order") \
    .withWatermark("event_time", "10 minutes") \
    .groupBy(
        F.window("event_time", "15 minutes", "5 minutes"),
        "product_name", "category"
    ) \
    .agg(
        F.sum("quantity").alias("total_quantity"),
        F.sum("total_amount").alias("total_revenue")
    )
```
Giải thích:
- `window("event_time", "15 minutes", "5 minutes")`: Cửa sổ 15 phút, trượt mỗi 5 phút. Nghĩa là cứ 5 phút lại tính lại top sản phẩm trong 15 phút gần nhất.

7. Xuất kết quả ra console để kiểm tra:
```python
query = revenue_by_window.writeStream \
    .outputMode("update") \
    .format("console") \
    .option("truncate", False) \
    .start()

query.awaitTermination()
```

8. Đảm bảo Producer đang chạy (Bước 1), rồi chạy file stream_processor.py. Bạn sẽ thấy kết quả cập nhật liên tục trên console.

9. Chụp screenshot kết quả streaming.

---

## Bước 3 - Output và Visualization (25 điểm)

**Mục đích**: Lưu kết quả xử lý vào storage (file Parquet hoặc database) và tạo dashboard hiển thị KPIs.

**Đầu vào**: Kết quả streaming từ Bước 2.

**Đầu ra**:
- Dữ liệu kết quả được lưu dạng Parquet (hoặc database).
- Dashboard hiển thị các KPIs real-time.
- Screenshots hoặc video demo hệ thống đang chạy.

**Cách làm**:

1. Thay output từ console sang Parquet files:
```python
query = revenue_by_window.writeStream \
    .outputMode("append") \
    .format("parquet") \
    .option("path", "/output/revenue_by_window") \
    .option("checkpointLocation", "/checkpoint/revenue") \
    .start()
```
Giải thích:
- `checkpointLocation`: Lưu vị trí xử lý để phục hồi khi gặp lỗi (fault tolerance).

2. Tạo dashboard. Có thể sử dụng:
   - Power BI kết nối với file Parquet.
   - Streamlit (Python) để tạo dashboard đơn giản.
   - Grafana kết nối với database.

3. Dashboard cần hiển thị:
   - Số đơn hàng mỗi phút.
   - Tổng doanh thu theo vùng miền.
   - Top sản phẩm bán chạy.
   - Tỷ lệ đơn hàng bị hủy.

4. Chụp screenshots hoặc quay video demo hệ thống đang chạy.

---

## Bước 4 - Documentation (15 điểm)

**Mục đích**: Hoàn thiện tài liệu giải thích kiến trúc, chiến lược windowing, và cách xử lý lỗi.

**Đầu vào**: Toàn bộ project đã hoàn thành.

**Đầu ra**:
- System Architecture diagram (PNG).
- Tài liệu giải thích windowing strategy.
- Tài liệu mô tả fault tolerance.

**Cách làm**:
1. Vẽ System Architecture diagram thể hiện: Producer -> Kafka -> Spark Streaming -> Output.
2. Viết tài liệu giải thích:
   - Tumbling window là gì? Sliding window là gì? Tại sao chọn windowing đó?
   - Watermark là gì? Tại sao cần watermark?
   - Nếu hệ thống gặp lỗi, checkpoint giúp gì?
3. Sắp xếp file theo cấu trúc nộp bài.

---

## Cấu trúc thư mục nộp bài

```
StudentName-MiniProject3/
  README.md
  docs/
    architecture.png
    windowing-strategy.md
  docker/
    docker-compose.yml
  kafka/
    producer.py
    create-topics.sh
  spark-streaming/
    stream_processor.py
    real_time_kpis.py
    output_writer.py
  config/
    spark-defaults.conf
  screenshots/
    kafka-producer.png
    streaming-output.png
    dashboard.png
```

---

## Docker Setup

Tạo file `docker-compose.yml` để chạy Kafka và Spark:

```yaml
version: '3.8'
services:
  zookeeper:
    image: confluentinc/cp-zookeeper:7.5.0
    environment:
      ZOOKEEPER_CLIENT_PORT: 2181
    ports:
      - "2181:2181"

  kafka:
    image: confluentinc/cp-kafka:7.5.0
    depends_on:
      - zookeeper
    environment:
      KAFKA_BROKER_ID: 1
      KAFKA_ZOOKEEPER_CONNECT: zookeeper:2181
      KAFKA_ADVERTISED_LISTENERS: PLAINTEXT://kafka:9092,PLAINTEXT_HOST://localhost:29092
      KAFKA_LISTENER_SECURITY_PROTOCOL_MAP: PLAINTEXT:PLAINTEXT,PLAINTEXT_HOST:PLAINTEXT
      KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR: 1
    ports:
      - "29092:29092"

  spark-master:
    image: bitnami/spark:3.4
    environment:
      - SPARK_MODE=master
    ports:
      - "8080:8080"
      - "7077:7077"

  spark-worker:
    image: bitnami/spark:3.4
    environment:
      - SPARK_MODE=worker
      - SPARK_MASTER_URL=spark://spark-master:7077
    depends_on:
      - spark-master
```

Khởi động: `docker-compose up -d`

---

## Timeline gợi ý

| Tuần | Công việc |
|------|-----------|
| Tuần 1 | Setup Kafka + Spark (Docker). Viết Kafka Producer. Bắt đầu Spark Streaming cơ bản |
| Tuần 2 | Hoàn thiện windowed analytics. Tạo dashboard. Viết documentation |
