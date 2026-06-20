# Tích hợp Token vào màn hình Đẩy Dữ Liệu

## Thay đổi

### ✅ Đã xóa
- **Màn hình "Lấy API Token"** riêng biệt (`lay_api_token_screen.dart`)
- Navigation icon từ AppBar màn hình "Đẩy dữ liệu"

### ✅ Đã tích hợp
Tất cả chức năng lấy token đã được tích hợp vào **màn hình "Đẩy dữ liệu"** với 2 loại token:

#### 1. **JWT Token (Token chung)**
- Dùng để xác thực tất cả các API calls
- Hiển thị trong phần xác thực tài khoản (bước 1)
- Có nút "Xem Token" để copy JWT token và Bearer token

#### 2. **Data Token (Token dữ liệu)**  
- Token đặc biệt cho dữ liệu đã chọn
- Tự động tạo khi nhấn nút "Xem Token" ở mỗi tab
- Chỉ chứa thông tin của các bệnh nhân/ca bệnh đã tick chọn

## Cách sử dụng

### ⚠️ Quan trọng
- API yêu cầu **mã nghiệp vụ** (benhNhanId, benhAnId), KHÔNG phải Firestore document ID
- Nếu bệnh nhân/ca bệnh chưa có mã nghiệp vụ, hệ thống sẽ tự động fallback sang document ID

### Bước 1: Xác thực
1. Nhập Username và Password
2. Nhấn "Lấy Token" → Nhận JWT Token

### Bước 2: Chọn dữ liệu
1. Chuyển sang tab "Bệnh nhân" hoặc "Bệnh TN"  
2. Tick chọn các mục cần lấy token

### Bước 3: Xem Token
1. Nhấn nút **"Xem Token"** (màu tím)
2. Dialog hiển thị:
   - **JWT Token** (token chung)
   - **Data Token** (token cho dữ liệu đã chọn)
   - Danh sách các mục đã chọn
   - Hướng dẫn sử dụng với ví dụ cURL

### Bước 4: Sử dụng Token
```bash
# Lấy dữ liệu bằng data token
curl -X GET "https://benh-vien-api.onrender.com/api/benhNhan/thongtinbenhnhan?token=<DATA_TOKEN>" \
  -H "Authorization: Bearer <JWT_TOKEN>"
```

## Tính năng Dialog Token

### Hiển thị
- ✅ JWT Token với các nút Copy Token và Copy Bearer
- ✅ Data Token với nút Copy  
- ✅ Danh sách 5 mục đầu tiên đã chọn (+ số lượng còn lại)
- ✅ Hướng dẫn sử dụng kèm ví dụ cURL command
- ✅ Nút copy cURL để test nhanh

### UI/UX
- 🎨 Design gradient tím đẹp mắt
- 🎨 Token hiển thị trong container màu đen với text màu xanh (terminal style)
- 📋 SelectableText cho phép select và copy dễ dàng
- ✅ Feedback khi copy thành công với SnackBar

## Lợi ích

1. **Đơn giản hơn**: Tất cả ở 1 màn hình, không cần chuyển qua lại
2. **Nhanh hơn**: Chọn dữ liệu và lấy token ngay lập tức
3. **Rõ ràng hơn**: Hiển thị cả 2 loại token và cách dùng trong cùng 1 dialog
4. **Trực quan hơn**: Thấy được danh sách dữ liệu đã chọn trước khi tạo token

## Files đã thay đổi

- ✏️ `lib/screens/day_du_lieu_screen.dart` - Thêm chức năng lấy token
- ❌ `lib/screens/lay_api_token_screen.dart` - Đã xóa
- ✏️ `lib/screens/quan_ly_tai_khoan_screen.dart` - Xóa import không dùng

---
**Ngày cập nhật**: 20/06/2026
