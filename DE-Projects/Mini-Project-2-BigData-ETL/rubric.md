# Rubric - Mini Project 2: Big Data ETL Pipeline
## Tổng điểm: 100

### Task 1: Extract MySQL HDFS (20đ)
| Tiêu chí | Xuất sắc | Khá | TB | Chưa đạt |
|----------|----------|-----|-----|----------|
| MySQL setup (5đ) | Schema + 100K+ records | Schema + data | Basic | Không có |
| Extract job (10đ) | PySpark JDBC, partitioned read | JDBC read OK | Sqoop basic | Không extract |
| HDFS storage (5đ) | Parquet, partitioned | Parquet | CSV | Không lưu |

### Task 2: Transform PySpark (35đ)
| Tiêu chí | Xuất sắc | Khá | TB | Chưa đạt |
|----------|----------|-----|-----|----------|
| Cleansing (10đ) | Null handling, dedup, validation | 2/3 techniques | Basic filter | Không có |
| Transformation (12đ) | Type cast, derived cols, date parsing | 2/3 techniques | 1 technique | Không có |
| Aggregation (8đ) | Multiple rollups, window functions | 2+ aggregations | 1 aggregation | Không có |
| Data quality (5đ) | Profile report, count validation | Count check | Basic check | Không có |

### Task 3: Load HDFS HBase (20đ)
| Tiêu chí | Xuất sắc | Khá | TB | Chưa đạt |
|----------|----------|-----|-----|----------|
| HBase design (8đ) | Optimized CF, row key design | Good design | Basic | Poor |
| Load job (8đ) | Connector hoặc bulk load | Manual load | Partial | Không load |
| Verification (4đ) | Count + sample verify | Count verify | Visual only | Không verify |

### Task 4: Analytical Queries (25đ)
| Tiêu chí | Xuất sắc | Khá | TB | Chưa đạt |
|----------|----------|-----|-----|----------|
| Query count (10đ) | 5+ queries | 4 queries | 2-3 queries | <2 |
| Complexity (10đ) | Window functions, complex joins | Aggregations | Basic | Too simple |
| Architecture (5đ) | Professional diagram | Clear diagram | Basic | Không có |
