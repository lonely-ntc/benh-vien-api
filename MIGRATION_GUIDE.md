# Migration Guide: Thay đổi cấu trúc Database

## 📋 Tóm tắt thay đổi

### Cấu trúc CŨ (hiện tại)
```json
{
  "gioiTinh": {
    "id": 263,
    "name": "Nam"
  },
  "danToc": {
    "id": 15,
    "name": "Kinh"
  }
}
```

### Cấu trúc MỚI (mục tiêu)
```json
{
  "gioiTinh": "Nam",
  "gioiTinhId": "263",
  "danToc": "Kinh",
  "danTocId": "15"
}
```

## ⚠️ Lưu ý quan trọng

Đây là thay đổi **BREAKING CHANGE** - sẽ ảnh hưởng đến:
1. ✅ Model Dart (BenhNhan, BenhTruyenNhiem)
2. ✅ Tất cả screens (thêm, sửa, hiển thị)
3. ✅ Firestore Service
4. ✅ API Formatter
5. ✅ Dữ liệu hiện có trong Firestore (cần migrate)

## 🎯 Các bước thực hiện

### Bước 1: Backup dữ liệu
```bash
# Export dữ liệu hiện tại
firebase firestore:export gs://your-bucket/backup-$(date +%Y%m%d)
```

### Bước 2: Chạy migration script
Tôi sẽ tạo script để:
- Đọc tất cả documents từ Firestore
- Chuyển đổi format: `{id,name}` → `name` + `nameId`
- Cập nhật lại Firestore

### Bước 3: Cập nhật code

#### 3.1. Model
- Xóa `CategoryItem`
- Thay bằng `String` cho name và `String?` cho id

#### 3.2. Formatter (API)
- Đơn giản hóa - không cần `getId()` phức tạp
- Trả về trực tiếp field có suffix `Id`

## 💡 Quyết định

**CÂU HỎI**: Bạn muốn tôi:

**Option A**: Tạo migration script để tự động chuyển đổi tất cả dữ liệu hiện có?
- ✅ Giữ nguyên dữ liệu cũ
- ✅ Tự động migrate
- ⚠️ Mất thời gian nếu nhiều data

**Option B**: Bắt đầu từ đầu với cấu trúc mới?
- ✅ Đơn giản, nhanh
- ⚠️ Mất dữ liệu cũ

Bạn chọn option nào? Hoặc bạn muốn tôi làm cả 2 (migration + code mới)?
