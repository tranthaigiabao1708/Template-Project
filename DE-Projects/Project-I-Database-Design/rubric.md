# Rubric chấm điểm - Project I

## Tổng điểm: 100

---

### Phần 1: Thiết kế Database (40 điểm)

| Tiêu chí | Xuất sắc (100%) | Khá (75%) | Trung bình (50%) | Chưa đạt (0-25%) |
|----------|-----------------|-----------|-------------------|-------------------|
| **ERD Design** (15đ) | ERD rõ ràng, đầy đủ 8+ bảng, quan hệ chính xác, có cardinality | 6-7 bảng, đa số quan hệ đúng | 5 bảng, thiếu một số quan hệ | <5 bảng, ERD không rõ ràng |
| **Normalization** (10đ) | Đạt 3NF hoàn toàn, giải thích được | Đạt 2NF-3NF, còn 1-2 vi phạm nhỏ | Đạt 1NF-2NF | Chưa chuẩn hóa |
| **Constraints** (8đ) | PK, FK, CHECK, UNIQUE, DEFAULT đầy đủ | PK, FK đầy đủ, thiếu vài constraints | Chỉ có PK, FK | Thiếu constraints |
| **Indexes** (7đ) | Indexes phù hợp cho queries, giải thích lý do | Indexes cơ bản đúng | Chỉ có clustered index | Không có index |

### Phần 2: Dữ liệu mẫu (10 điểm)

| Tiêu chí | Xuất sắc (100%) | Khá (75%) | Trung bình (50%) | Chưa đạt (0-25%) |
|----------|-----------------|-----------|-------------------|-------------------|
| **Số lượng** (5đ) | 100+ records bảng chính, đủ tất cả bảng | 50-99 records | 20-49 records | <20 records |
| **Chất lượng** (5đ) | Dữ liệu thực tế, nhất quán, đa dạng | Khá thực tế, nhất quán | Dữ liệu cơ bản | Dữ liệu rác, không nhất quán |

### Phần 3: Stored Procedures & Views (20 điểm)

| Tiêu chí | Xuất sắc (100%) | Khá (75%) | Trung bình (50%) | Chưa đạt (0-25%) |
|----------|-----------------|-----------|-------------------|-------------------|
| **Stored Procedures** (12đ) | 5+ SP với transactions, error handling, parameters | 5 SP cơ bản hoạt động | 3-4 SP đơn giản | <3 SP hoặc không chạy |
| **Views** (8đ) | 3+ views phức tạp, phục vụ báo cáo tốt | 3 views cơ bản | 1-2 views đơn giản | Không có views |

### Phần 4: Báo cáo SQL (30 điểm)

| Tiêu chí | Xuất sắc (100%) | Khá (75%) | Trung bình (50%) | Chưa đạt (0-25%) |
|----------|-----------------|-----------|-------------------|-------------------|
| **Số lượng** (10đ) | 10+ câu query | 8-9 câu | 5-7 câu | <5 câu |
| **Độ phức tạp** (10đ) | JOIN, subquery, window functions, CTE | JOIN, subquery | Chỉ JOIN đơn giản | Chỉ SELECT cơ bản |
| **Kết quả** (5đ) | Kết quả chính xác, có screenshot | Đa số đúng | 50% đúng | Không chạy được |
| **System Architecture** (5đ) | Diagram rõ ràng, chuyên nghiệp, đầy đủ | Diagram cơ bản đầy đủ | Diagram sơ sài | Không có |

---

## Điểm thưởng (tối đa +10 điểm)

| Tiêu chí | Điểm |
|----------|-------|
| Sử dụng Window Functions | +2 |
| Tạo Triggers cho audit log | +2 |
| Viết Unit Test cho SP | +2 |
| Database Diagram trong SSMS | +2 |
| Documentation chi tiết (README) | +2 |

---

## Bảng quy đổi điểm

| Điểm | Xếp loại |
|-------|----------|
| 90-100+ | Xuất sắc |
| 80-89 | Giỏi |
| 65-79 | Khá |
| 50-64 | Trung bình |
| <50 | Chưa đạt - Cần làm lại |
