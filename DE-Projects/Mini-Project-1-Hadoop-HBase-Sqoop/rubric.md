# Rubric - Mini Project 1: Hadoop + HBase + Sqoop
## Tổng điểm: 100

### Task 1: Sqoop Import RDS HBase (25đ)
| Tiêu chí | Xuất sắc | Khá | TB | Chưa đạt |
|----------|----------|-----|-----|----------|
| Sqoop command đúng (10đ) | Chạy thành công, đầy đủ options | Chạy được, thiếu options | Có lỗi nhỏ | Không chạy |
| HBase table design (8đ) | Column families hợp lý, row key thiết kế tốt | CF cơ bản, row key OK | 1 CF, row key đơn giản | Sai design |
| Data verification (7đ) | HBase scan + count verify | Scan verify | Chưa verify | Không verify |

### Task 2: Bulk Import (20đ)
| Tiêu chí | Xuất sắc | Khá | TB | Chưa đạt |
|----------|----------|-----|-----|----------|
| Import script (12đ) | 2 files, validation, error handling | 2 files loaded | 1 file | Không load |
| Data quality (8đ) | Pre-import validation, counts match | Counts match | Partial | No validation |

### Task 3: MapReduce (30đ)
| Tiêu chí | Xuất sắc | Khá | TB | Chưa đạt |
|----------|----------|-----|-----|----------|
| Mapper logic (10đ) | Complex parsing, multiple outputs | Correct parsing | Basic | Sai |
| Reducer logic (10đ) | Multi-aggregation, combiners | Single aggregation | Basic sum | Sai |
| Job execution (10đ) | Chạy thành công, output đúng | Chạy được | Có lỗi | Không chạy |

### Task 4: Export & Dashboard (25đ)
| Tiêu chí | Xuất sắc | Khá | TB | Chưa đạt |
|----------|----------|-----|-----|----------|
| Sqoop export (10đ) | Export thành công, data intact | Export OK | Partial | Không export |
| Dashboard (10đ) | 3+ charts, interactive | 2 charts | 1 chart | Không có |
| Architecture diagram (5đ) | Professional, complete | Clear | Basic | Không có |
