# Mini Project 1: Hadoop Framework, HBase và Sqoop

> **Module**: Apache Hadoop, HDFS
> **Mức độ**: Trung bình
> **Thời gian**: 2 tuần

---

## Mục tiêu

Sau khi hoàn thành project, học viên sẽ biết cách:
- Di chuyển dữ liệu từ cơ sở dữ liệu quan hệ (RDS) sang HBase và ngược lại bằng Sqoop.
- Nạp dữ liệu từ file CSV/TSV vào HBase bằng phương pháp bulk import.
- Viết chương trình MapReduce (mapper và reducer) để xử lý và tính toán trên tập dữ liệu lớn.
- Kết nối kết quả phân tích với công cụ trực quan hóa để tạo dashboard.

---

## Kiến trúc hệ thống

Xem sơ đồ kiến trúc chi tiết tại: [docs/architecture.md](docs/architecture.md)

---

## Hướng dẫn thực hiện chi tiết

Project này gồm 4 bước chính, học viên thực hiện tuần tự.

---

## Bước 1 - Sqoop Import: Chuyển dữ liệu từ RDS sang HBase (25 điểm)

**Mục đích**: Lấy dữ liệu đang có trong cơ sở dữ liệu quan hệ (MySQL hoặc PostgreSQL trên Amazon RDS) và chuyển sang HBase để lưu trữ dạng NoSQL, phục vụ xử lý Big Data.

**Đầu vào**:
- Một RDS instance đang chạy (MySQL hoặc PostgreSQL) đã có sẵn dữ liệu trong các bảng.
- Thông tin kết nối: endpoint, port, username, password, tên database, tên bảng.

**Đầu ra**:
- Một hoặc nhiều HBase table chứa dữ liệu tương ứng với bảng trong RDS.
- Kết quả xác nhận khi scan HBase table thấy dữ liệu đầy đủ.

**Cách làm**:

1. Đầu tiên, đảm bảo EMR cluster của bạn đã được khởi tạo và có cài đặt Sqoop, HBase.

2. Kiểm tra kết nối đến RDS từ EMR:
```bash
mysql -h <rds-endpoint> -u admin -p -e "SHOW DATABASES;"
```

3. Chạy Sqoop import để chuyển dữ liệu từ RDS sang HBase. Đây là lệnh mẫu, bạn cần thay đổi thông tin cho phù hợp:
```bash
sqoop import \
  --connect jdbc:mysql://<rds-endpoint>:3306/<database_name> \
  --username admin \
  --password <password> \
  --table <source_table> \
  --hbase-table <target_hbase_table> \
  --column-family cf \
  --hbase-row-key id \
  --hbase-create-table \
  -m 1
```
Giải thích các tham số:
- `--connect`: Đường dẫn JDBC kết nối đến RDS.
- `--table`: Tên bảng nguồn trong RDS cần import.
- `--hbase-table`: Tên HBase table sẽ tạo để chứa dữ liệu.
- `--column-family`: Tên column family trong HBase (thường đặt là `cf`).
- `--hbase-row-key`: Cột nào trong bảng nguồn sẽ làm row key cho HBase.
- `-m 1`: Số mapper (đặt 1 nếu dữ liệu nhỏ).

4. Xác nhận dữ liệu đã vào HBase thành công:
```bash
hbase shell
> scan 'target_hbase_table', {LIMIT => 10}
> count 'target_hbase_table'
```

5. Chụp screenshot kết quả scan và lưu vào thư mục `screenshots/`.

---

## Bước 2 - Bulk Import: Nạp dữ liệu từ file CSV vào HBase (20 điểm)

**Mục đích**: Thực hành nạp dữ liệu từ các file CSV/TSV (không phải từ database) trực tiếp vào HBase. Đây là kỹ thuật thường dùng khi dữ liệu đến từ file log, file export, hoặc dữ liệu từ bên thứ ba.

**Đầu vào**:
- 2 file dữ liệu (CSV hoặc TSV), mỗi file có cột rõ ràng.
- Các file này cần được upload lên HDFS trước.

**Đầu ra**:
- 2 HBase table mới, mỗi table chứa dữ liệu tương ứng với 1 file.
- Kết quả xác nhận (count records, scan mẫu).

**Cách làm**:

1. Upload file dữ liệu lên HDFS:
```bash
hdfs dfs -mkdir -p /data/input/
hdfs dfs -put dataset1.csv /data/input/
hdfs dfs -put dataset2.csv /data/input/
```

2. Tạo HBase table trước (nếu chưa có):
```bash
hbase shell
> create 'dataset1_table', 'cf'
> create 'dataset2_table', 'cf'
```

3. Sử dụng ImportTsv để nạp dữ liệu từ HDFS vào HBase:
```bash
hbase org.apache.hadoop.hbase.mapreduce.ImportTsv \
  -Dimporttsv.separator=',' \
  -Dimporttsv.columns='HBASE_ROW_KEY,cf:col1,cf:col2,cf:col3' \
  dataset1_table \
  /data/input/dataset1.csv
```
Giải thích:
- `-Dimporttsv.separator`: Ký tự phân cách trong file (dấu phẩy cho CSV, tab cho TSV).
- `-Dimporttsv.columns`: Danh sách cột, cột đầu tiên là `HBASE_ROW_KEY`, các cột còn lại là `column_family:column_name`.
- Dòng cuối là tên HBase table và đường dẫn HDFS chứa file.

4. Làm tương tự cho file thứ 2.

5. Xác nhận dữ liệu:
```bash
hbase shell
> count 'dataset1_table'
> scan 'dataset1_table', {LIMIT => 5}
```

---

## Bước 3 - MapReduce: Xử lý và phân tích dữ liệu (30 điểm)

**Mục đích**: Viết chương trình MapReduce để tính toán thống kê trên dữ liệu đã nạp. Ví dụ: tính tổng doanh thu theo nhóm, đếm số lượng theo danh mục, tìm giá trị lớn nhất/nhỏ nhất, v.v. Đây là kỹ thuật xử lý dữ liệu phân tán cốt lõi của Hadoop.

**Đầu vào**:
- Dữ liệu đã nạp vào HDFS (từ bước 1 hoặc bước 2), dưới dạng file text/CSV.

**Đầu ra**:
- Thư mục output trên HDFS chứa kết quả tính toán (file part-00000, part-00001, ...).
- Mỗi dòng kết quả có dạng: `key<TAB>value` (ví dụ: `DanhMuc_A  15000`).

**Cách làm**:

1. Viết file `mapper.py` - nhiệm vụ của mapper là đọc từng dòng dữ liệu, tách ra cặp (key, value) cần tính toán, rồi in ra stdout:
```python
#!/usr/bin/env python3
# mapper.py
import sys

for line in sys.stdin:
    line = line.strip()
    fields = line.split(',')
    # Ví dụ: tính tổng doanh thu theo danh mục sản phẩm
    # Giả sử cột 0 là danh mục, cột 3 là doanh thu
    category = fields[0]
    revenue = fields[3]
    print(f'{category}\t{revenue}')
```

2. Viết file `reducer.py` - nhiệm vụ của reducer là gộp các giá trị có cùng key và tính toán (sum, count, avg, ...):
```python
#!/usr/bin/env python3
# reducer.py
import sys

current_key = None
current_sum = 0

for line in sys.stdin:
    line = line.strip()
    key, value = line.split('\t')
    value = float(value)

    if key == current_key:
        current_sum += value
    else:
        if current_key is not None:
            print(f'{current_key}\t{current_sum}')
        current_key = key
        current_sum = value

# In dòng cuối cùng
if current_key is not None:
    print(f'{current_key}\t{current_sum}')
```

3. Test thử trên máy local trước khi chạy trên cluster:
```bash
cat sample-data/dataset1.csv | python3 mapper.py | sort | python3 reducer.py
```
Nếu kết quả in ra đúng, chuyển sang bước tiếp.

4. Chạy MapReduce job trên EMR cluster:
```bash
hadoop jar /usr/lib/hadoop/hadoop-streaming.jar \
  -files mapper.py,reducer.py \
  -mapper "python3 mapper.py" \
  -reducer "python3 reducer.py" \
  -input /data/input/dataset1.csv \
  -output /output/mapreduce/result
```

5. Kiểm tra kết quả:
```bash
hdfs dfs -ls /output/mapreduce/result/
hdfs dfs -cat /output/mapreduce/result/part-00000 | head -20
```

6. Chụp screenshot kết quả output và lưu vào thư mục `screenshots/`.

---

## Bước 4 - Sqoop Export và Dashboard (25 điểm)

**Mục đích**: Chuyển kết quả phân tích từ HDFS trở lại database quan hệ (RDS) để kết nối với công cụ trực quan hóa. Đây là bước cuối cùng - đưa insight từ Big Data về dạng để người dùng cuối (business users) đọc được.

**Đầu vào**:
- Kết quả MapReduce trên HDFS (thư mục /output/mapreduce/result/).
- Một bảng trong RDS đã được tạo sẵn để nhận kết quả.

**Đầu ra**:
- Bảng RDS chứa kết quả phân tích.
- Dashboard với tối thiểu 3 biểu đồ trực quan hóa dữ liệu.

**Cách làm**:

1. Tạo bảng kết quả trong RDS trước:
```sql
CREATE TABLE mapreduce_results (
    category VARCHAR(100),
    total_revenue DECIMAL(18,2)
);
```

2. Chạy Sqoop export để chuyển dữ liệu từ HDFS về RDS:
```bash
sqoop export \
  --connect jdbc:mysql://<rds-endpoint>:3306/<database_name> \
  --username admin \
  --password <password> \
  --table mapreduce_results \
  --export-dir /output/mapreduce/result \
  --input-fields-terminated-by '\t'
```
Giải thích:
- `--export-dir`: Thư mục HDFS chứa kết quả MapReduce.
- `--input-fields-terminated-by`: Ký tự phân cách giữa các cột trong file HDFS (ở đây là tab vì MapReduce output dùng tab).

3. Xác nhận dữ liệu đã vào RDS:
```sql
SELECT * FROM mapreduce_results ORDER BY total_revenue DESC LIMIT 10;
```

4. Kết nối công cụ trực quan hóa (Power BI, Tableau, hoặc Google Data Studio) với RDS và tạo dashboard:
   - Biểu đồ 1: Bar chart - Top danh mục theo doanh thu.
   - Biểu đồ 2: Pie chart - Tỷ lệ doanh thu theo nhóm.
   - Biểu đồ 3: Line chart hoặc biểu đồ khác tùy chọn.

5. Chụp screenshot dashboard và lưu vào `screenshots/dashboard.png`.

---

## Vẽ System Architecture Diagram

Mỗi học viên bắt buộc tự vẽ sơ đồ kiến trúc hệ thống cho project của mình.

**Yêu cầu**:
- Thể hiện đầy đủ luồng dữ liệu: RDS -> Sqoop Import -> HBase -> HDFS -> MapReduce -> HDFS -> Sqoop Export -> RDS -> Dashboard.
- Ghi rõ tên technology ở mỗi thành phần.
- Export thành file PNG và đặt trong thư mục `docs/architecture.png`.

**Công cụ gợi ý**: draw.io (miễn phí), Excalidraw, Lucidchart.

---

## Cấu trúc thư mục nộp bài

```
StudentName-MiniProject1/
  README.md
  docs/
    architecture.png
  scripts/
    sqoop-import.sh
    sqoop-export.sh
    bulk-import.sh
    create-hbase-tables.sh
  mapreduce/
    mapper.py
    reducer.py
    run-job.sh
  sample-data/
    dataset1.csv
    dataset2.csv
  sql/
    create-rds-tables.sql
    create-result-tables.sql
  screenshots/
    sqoop-import-result.png
    hbase-scan.png
    mapreduce-output.png
    dashboard.png
```

---

## Timeline gợi ý

| Tuần | Công việc |
|------|-----------|
| Tuần 1 | Setup EMR cluster, tạo RDS. Thực hiện Bước 1 (Sqoop import) và Bước 2 (Bulk import) |
| Tuần 2 | Thực hiện Bước 3 (MapReduce). Bước 4 (Sqoop export và Dashboard). Hoàn thiện bài nộp |
