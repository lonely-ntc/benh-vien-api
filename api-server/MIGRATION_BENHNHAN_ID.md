# Migration: Thêm mã bệnh nhân (benhNhanId) và mã bệnh án (benhAnId)

## 📋 Mục đích

Script migration này tự động tạo mã nghiệp vụ cho:
- **Bệnh nhân**: Thêm trường `benhNhanId` với format BN0001, BN0002, BN0003...
- **Bệnh truyền nhiễm**: Thêm trường `benhAnId` với format BA0001, BA0002, BA0003...

## 🚀 Cách chạy

### Bước 1: Cài đặt dependencies (nếu chưa)
```bash
cd api-server
npm install
```

### Bước 2: Kiểm tra Firebase credentials
Đảm bảo file `service-account.json` tồn tại trong thư mục `api-server/`

### Bước 3: Chạy migration
```bash
npm run migrate:benh-nhan-id
```

Hoặc:
```bash
node migrate_benh_nhan_id.js
```

## 📊 Migration sẽ làm gì?

### 1. Bệnh nhân (Collection: `benhNhan`)
- Quét tất cả documents không có `benhNhanId`
- Tạo mã theo thứ tự: BN0001, BN0002, BN0003...
- Cập nhật từng document với `benhNhanId` tương ứng

### 2. Bệnh truyền nhiễm (Collection: `benhTruyenNhiem`)
- Quét tất cả documents không có `benhAnId`
- Tạo mã theo thứ tự: BA0001, BA0002, BA0003...
- Cập nhật từng document với `benhAnId` tương ứng

## ⚠️ Lưu ý quan trọng

### 1. Backup dữ liệu
**Luôn luôn backup Firestore trước khi chạy migration!**

Backup từ Firebase Console:
1. Vào Firebase Console → Firestore Database
2. Chọn tab "Import/Export"
3. Export toàn bộ database

### 2. Chạy khi nào?
- Chạy **MỘT LẦN DUY NHẤT** khi mới setup hệ thống token API
- Không chạy lại nếu đã có `benhNhanId` / `benhAnId`
- Script tự động bỏ qua các documents đã có mã

### 3. Môi trường
- **Development**: Test trước trên Firestore dev/staging
- **Production**: Chỉ chạy khi đã test kỹ và backup đầy đủ

### 4. Thời gian chạy
- Phụ thuộc vào số lượng documents
- 1000 documents ~ 1-2 phút
- 10000 documents ~ 10-20 phút

## 📝 Output mẫu

```
🚀 Bắt đầu migration: Thêm benhNhanId và benhAnId...

📊 Collection: benhNhan
   ✅ Đã cập nhật 150 documents với benhNhanId
   ℹ️  75 documents đã có benhNhanId (bỏ qua)

📊 Collection: benhTruyenNhiem
   ✅ Đã cập nhật 200 documents với benhAnId
   ℹ️  50 documents đã có benhAnId (bỏ qua)

✅ Migration hoàn tất!
```

## 🔍 Kiểm tra sau migration

### Bệnh nhân
```bash
# Trong Firestore Console hoặc qua API
GET /api/benhNhan
```

Kiểm tra các documents có field `benhNhanId` với giá trị như:
- BN0001
- BN0002
- BN0003
- ...

### Bệnh truyền nhiễm
```bash
GET /api/benhTruyenNhiem
```

Kiểm tra các documents có field `benhAnId` với giá trị như:
- BA0001
- BA0002
- BA0003
- ...

## 🛠 Troubleshooting

### Error: "Firebase Admin SDK not initialized"
→ Kiểm tra file `service-account.json` có tồn tại không

### Error: "Permission denied"
→ Kiểm tra service account có quyền write vào Firestore không

### Một số documents không được cập nhật
→ Kiểm tra Firestore rules, có thể cần temporarily disable security rules

### Mã bị trùng
→ Script tự động tìm số lớn nhất hiện có và tạo mã tiếp theo, không bao giờ trùng

### Muốn chạy lại từ đầu
1. Xóa tất cả `benhNhanId` và `benhAnId` thủ công trong Firestore
2. Chạy lại script

## 📌 Sau migration

### 1. Cập nhật app mobile
Đảm bảo app Flutter có model `BenhNhan` và `BenhTruyenNhiem` đã bao gồm:
```dart
class BenhNhan {
  String? benhNhanId; // BN0001, BN0002...
  // ... other fields
}

class BenhTruyenNhiem {
  String? benhAnId; // BA0001, BA0002...
  // ... other fields
}
```

### 2. Sử dụng Token API
Giờ có thể tạo token dựa trên mã nghiệp vụ:
```bash
POST /api/benhNhan/byIds
{
  "benhNhanIds": ["BN0001", "BN0002"],
  "benhTNIds": ["BA0001"]
}
```

### 3. Tạo mã cho dữ liệu mới
Khi thêm bệnh nhân/bệnh án mới:
- App mobile tự động tạo mã mới (BNxxxx / BAxxxx)
- Hoặc API server tự động tạo khi push dữ liệu mới

## 🔗 Liên quan

- [POSTMAN_TEST_TOKEN.md](./POSTMAN_TEST_TOKEN.md) - Hướng dẫn test API với Postman
- [migrate_benh_nhan_id.js](./migrate_benh_nhan_id.js) - Source code migration script
