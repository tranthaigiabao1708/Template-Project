# Submission Template - Mini Project 3: Real-time Retail Analysis

## Thông tin học viên
| Thông tin | Chi tiết |
|-----------|----------|
| **Họ và tên** | [Điền tên] |
| **Mã học viên** | [Điền mã] |
| **Ngày nộp** | [DD/MM/YYYY] |

---

## 1. System Architecture
![Architecture](docs/architecture.png)

---

## 2. Kafka Setup
### Topic Configuration:
| Topic | Partitions | Replication | Retention |
|-------|-----------|-------------|-----------|
| retail-transactions | | | |

### Event Schema:
```json
{
 "event_type": "new_order",
 "order_id": "ORD-12345",
 ...
}
```

---

## 3. Spark Streaming
### Windowing Strategy:
| Window Type | Duration | Slide | Purpose |
|------------|----------|-------|---------|
| Tumbling | 5 min | - | Revenue per window |
| Sliding | 15 min | 5 min | Top products |

### Real-time KPIs:
| KPI | Formula | Screenshot |
|-----|---------|------------|
| Orders/min | | |
| Revenue/window | | |
| Cancel rate | | |
| Top products | | |

---

## 4. Output & Dashboard
![Dashboard](screenshots/dashboard.png)

### Output Sinks:
| Sink | Format | Purpose |
|------|--------|---------|
| Console | Text | Monitoring |
| Parquet | Files | Historical |
| Database | SQL | Dashboard |

---

## 5. Fault Tolerance
[Mô tả cách xử lý failures, checkpointing strategy]

---

## Checklist
- [ ] Kafka topic created
- [ ] Producer generating events
- [ ] Spark Streaming consuming from Kafka
- [ ] Windowed aggregations (tumbling + sliding)
- [ ] 5+ real-time KPIs
- [ ] Persistent storage output
- [ ] Dashboard visualization
- [ ] Architecture diagram
- [ ] Docker setup
- [ ] README + GitHub
