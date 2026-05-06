# Rubric - Mini Project 3: Real-time Retail Analysis
## Tổng điểm: 100

### Task 1: Kafka Producer (20đ)
| Tiêu chí | Xuất sắc | Khá | TB | Chưa đạt |
|----------|----------|-----|-----|----------|
| Event schema (8đ) | Rich schema, multiple event types | Good schema | Basic | Minimal |
| Producer logic (8đ) | Configurable rate, partitioning | Working producer | Basic sends | Không chạy |
| Topic design (4đ) | Multiple partitions, proper config | Single partition OK | Default config | Sai |

### Task 2: Spark Streaming (40đ)
| Tiêu chí | Xuất sắc | Khá | TB | Chưa đạt |
|----------|----------|-----|-----|----------|
| Kafka consumer (8đ) | Structured streaming, schema parsing | Working consumer | Basic | Không connect |
| Windowed aggregations (12đ) | Tumbling + sliding windows, watermark | 1 window type | Basic groupBy | Không có |
| KPIs (12đ) | 5+ real-time KPIs, complex logic | 3-4 KPIs | 1-2 KPIs | Không có |
| Fault tolerance (8đ) | Checkpointing, exactly-once | Checkpointing | At-least-once | Không có |

### Task 3: Output & Visualization (25đ)
| Tiêu chí | Xuất sắc | Khá | TB | Chưa đạt |
|----------|----------|-----|-----|----------|
| Persistent output (10đ) | Parquet + DB, partitioned | Parquet files | Console only | Không output |
| Dashboard (10đ) | Real-time, 3+ views, interactive | 2+ views | 1 view | Không có |
| Demo (5đ) | Video/GIF demo running system | Screenshots | Partial | Không có |

### Task 4: Documentation (15đ)
| Tiêu chí | Xuất sắc | Khá | TB | Chưa đạt |
|----------|----------|-----|-----|----------|
| Architecture (7đ) | Professional, Kafka+Spark detail | Clear diagram | Basic | Không có |
| Windowing doc (4đ) | Strategy explained with rationale | Basic explanation | Mentioned | Không có |
| README (4đ) | Reproducible, detailed | Complete | Basic | Không có |
