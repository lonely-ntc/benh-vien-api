# Hướng dẫn Test API với Postman

## 📋 Tổng quan

API hỗ trợ 2 loại token:
- **JWT Token (Authentication)**: Token chung để xác thực, lấy từ `POST /api/auth/login`
- **Data Token**: Token dữ liệu tạm thời (24h) để lấy dữ liệu đã chọn

## 🔐 Bước 1: Lấy JWT Token (Authentication)

### Request
```
POST https://benh-vien-api.onrender.com/api/auth/login
Content-Type: application/json

{
  "username": "demo",
  "password": "demo123"
}
```

### Response
```json
{
  "success": true,
  "message": "Đăng nhập thành công",
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "role": "admin",
  "hoTen": "Demo User",
  "expiresIn": "24 giờ"
}
```

**⚠️ Lưu JWT Token này để dùng cho tất cả các requests sau!**

---

## 👥 Bước 2A: Test với Bệnh Nhân

### 2A.1. Xem tất cả bệnh nhân

```
GET https://benh-vien-api.onrender.com/api/benhNhan
Authorization: Bearer <JWT_TOKEN>
```

Lưu ý các mã `benhNhanId` trong response (VD: "BN0001", "BN0002"...)

### 2A.2. Tạo Data Token từ mã bệnh nhân

**Sử dụng `benhNhanId` (mã nghiệp vụ), KHÔNG phải Firestore document ID!**

```
POST https://benh-vien-api.onrender.com/api/benhNhan/byIds
Authorization: Bearer <JWT_TOKEN>
Content-Type: application/json

{
  "benhNhanIds": ["BN0001", "BN0002", "BN0003"],
  "benhTNIds": []
}
```

### Response
```json
{
  "success": true,
  "token": "abc123xyz456",
  "message": "Token đã được tạo. Sử dụng GET /api/benhNhan/thongtinbenhnhan?token=xxx để lấy dữ liệu.",
  "summary": {
    "benhNhanCount": 3,
    "benhTNCount": 0,
    "requestedBenhNhan": 3,
    "requestedBenhTN": 0,
    "notFoundBenhNhan": 0,
    "notFoundBenhTN": 0
  },
  "expiresIn": "24 giờ"
}
```

**⚠️ Lưu Data Token này (`abc123xyz456`) để dùng ở bước tiếp theo!**

### 2A.3. Lấy dữ liệu đã chọn bằng Data Token

```
GET https://benh-vien-api.onrender.com/api/benhNhan/thongtinbenhnhan?token=abc123xyz456
Authorization: Bearer <JWT_TOKEN>
```

### Response
```json
{
  "success": true,
  "token": "abc123xyz456",
  "timestamp": "2026-06-19T10:30:00.000Z",
  "data": {
    "benhNhan": [
      {
        "Id": null,
        "UnitId": null,
        "MaBenhNhan": "BN0001",
        "HoTen": "Nguyễn Văn A",
        "NgaySinh": "01/01/1990",
        "GioiTinh": "263",
        "DanTocId": "15",
        "MaDinhDanhCaNhan": "001234567890",
        "SDT": "0987654321",
        "BHYT": "DN123456789",
        "NgheNghiep": "11593",
        "DiaChi": "123 Đường ABC, Quận 1",
        "CityId": "50",
        "WardId": "166",
        "NhomMau": "A",
        "BenhNen": "36",
        "BenhTruyenNhiem": null,
        "TinhTrangTiemChung": "11135",
        "CoKhong": null,
        "DieuTri": null,
        "HinhThucDieuTri": "11128",
        "ChanDoanBenh": "51",
        "PhanLoaiChanDoan": "11546",
        "PhanDoBenh": "1",
        "LoaiBenhPham": null,
        "LoaiXetNghiem": null,
        "KetQuaXetNghiem": null,
        "CoSoBaoCao": null,
        "CoSoDieuTri": "74001",
        "DonViDieuTra": "74001",
        "PhongKham": null,
        "TrangThai": "active",
        "SoThuTu": 1
      }
    ],
    "benhTruyenNhiem": []
  },
  "summary": {
    "benhNhanCount": 1,
    "benhTNCount": 0,
    "total": 1,
    "requestedBenhNhan": 3,
    "requestedBenhTN": 0,
    "notFoundBenhNhan": 2,
    "notFoundBenhTN": 0
  }
}
```

---

## 🦠 Bước 2B: Test với Bệnh Truyền Nhiễm

### 2B.1. Xem tất cả bệnh truyền nhiễm

```
GET https://benh-vien-api.onrender.com/api/benhTruyenNhiem
Authorization: Bearer <JWT_TOKEN>
```

Lưu ý các mã `benhAnId` trong response (VD: "BA0001", "BA0002"...)

### 2B.2. Tạo Data Token từ mã bệnh án

**Sử dụng `benhAnId` (mã bệnh án), KHÔNG phải Firestore document ID!**

```
POST https://benh-vien-api.onrender.com/api/benhTruyenNhiem/byIds
Authorization: Bearer <JWT_TOKEN>
Content-Type: application/json

{
  "benhNhanIds": [],
  "benhTNIds": ["BA0001", "BA0002"]
}
```

### Response
```json
{
  "success": true,
  "token": "xyz789abc123",
  "message": "Token đã được tạo. Sử dụng GET /api/benhTruyenNhiem/thongtinbenhan?token=xxx để lấy dữ liệu.",
  "summary": {
    "benhNhanCount": 0,
    "benhTNCount": 2,
    "requestedBenhNhan": 0,
    "requestedBenhTN": 2,
    "notFoundBenhNhan": 0,
    "notFoundBenhTN": 0
  },
  "expiresIn": "24 giờ"
}
```

### 2B.3. Lấy dữ liệu đã chọn bằng Data Token

```
GET https://benh-vien-api.onrender.com/api/benhTruyenNhiem/thongtinbenhan?token=xyz789abc123
Authorization: Bearer <JWT_TOKEN>
```

### Response
```json
{
  "success": true,
  "token": "xyz789abc123",
  "timestamp": "2026-06-19T10:45:00.000Z",
  "data": {
    "benhNhan": [],
    "benhTruyenNhiem": [
      {
        "Id": null,
        "UnitId": null,
        "BenhAnId": "BA0001",
        "HoTen": "Trần Thị B",
        "NgaySinh": "15/05/1985",
        "GioiTinh": "264",
        "DanTocId": "15",
        "MaDinhDanhCaNhan": "098765432101",
        "TenNguoiBaoHo": "Trần Văn C",
        "SDT": "0912345678",
        "CoThai": "11141",
        "TuanThai": "12",
        "NgheNghiep": "11595",
        "NoiOHienNay": "Xã ABC, Huyện XYZ",
        "CityId": "79",
        "WardId": "123",
        "SoHSBA": "HS2024001",
        "CoSoDieuTri": "74001",
        "CityId_CSDT": "79",
        "ChanDoanBenh": "13",
        "PhanDoBenh": "2",
        "ThongTinDieuTri": "Điều trị nội trú",
        "ChanDoanBienChung": null,
        "ChanDoanBenhKemTheo": "Thiếu máu",
        "BenhNenKemTheoId": "36",
        "NgayKhoiPhat": "10/06/2026",
        "NgayNhapVien": "11/06/2026 08:00",
        "NgayXV_TV_CV": null,
        "PhanLoaiChanDoan": "11546",
        "LoaiBenhPham": "11551",
        "LoaiXN": "11557",
        "KetQuaXN": "11558",
        "TinhTrangTiem": "11135",
        "HinhThucDieuTri": "11128",
        "NgayBaoCao": "12/06/2026",
        "NguoiBaoCao": "Bs. Nguyễn D",
        "SDTNguoiBaoCao": "0909123456",
        "EmailNguoiBaoCao": "bsnguyend@hospital.vn",
        "PhanDoBenhText": null
      }
    ]
  },
  "summary": {
    "benhNhanCount": 0,
    "benhTNCount": 1,
    "total": 1,
    "requestedBenhNhan": 0,
    "requestedBenhTN": 2,
    "notFoundBenhNhan": 0,
    "notFoundBenhTN": 1
  }
}
```

---

## 🔄 Bước 3: Test kết hợp cả 2 loại

Bạn có thể tạo data token cho cả bệnh nhân VÀ bệnh truyền nhiễm cùng lúc:

```
POST https://benh-vien-api.onrender.com/api/benhNhan/byIds
Authorization: Bearer <JWT_TOKEN>
Content-Type: application/json

{
  "benhNhanIds": ["BN0001", "BN0002"],
  "benhTNIds": ["BA0001", "BA0003"]
}
```

Sau đó lấy dữ liệu:

```
GET https://benh-vien-api.onrender.com/api/benhNhan/thongtinbenhnhan?token=<DATA_TOKEN>
Authorization: Bearer <JWT_TOKEN>
```

Response sẽ chứa cả 2 loại dữ liệu trong `data.benhNhan` và `data.benhTruyenNhiem`.

---

## 📝 Lưu ý quan trọng

### ✅ Format dữ liệu API
- **Thông tin cá nhân** (Họ tên, Ngày sinh, SDT...): Hiển thị dạng **text**
- **Danh mục** (Giới tính, Dân tộc, Bệnh nền...): Chỉ hiển thị **ID** (số hoặc chuỗi)
- **Không có dữ liệu**: Trả về `null`

### ⚠️ Điểm khác biệt
1. **Mã nghiệp vụ vs Firestore ID**
   - `benhNhanId` (VD: "BN0001") ≠ Firestore document ID
   - `benhAnId` (VD: "BA0001") ≠ Firestore document ID
   - Token API sử dụng **mã nghiệp vụ**, không phải Firestore ID

2. **Hai loại token khác nhau**
   - **JWT Token**: Dùng cho authentication, có trong header `Authorization: Bearer xxx`
   - **Data Token**: Token tạm thời để lấy dữ liệu đã chọn, có trong query param `?token=xxx`

3. **Thời gian sống**
   - JWT Token: 24 giờ
   - Data Token: 24 giờ

### 🔄 Endpoint mapping
- `POST /api/benhNhan/byIds` → Tạo data token
- `GET /api/benhNhan/thongtinbenhnhan?token=xxx` → Lấy dữ liệu bệnh nhân
- `POST /api/benhTruyenNhiem/byIds` → Tạo data token
- `GET /api/benhTruyenNhiem/thongtinbenhan?token=xxx` → Lấy dữ liệu bệnh truyền nhiễm

---

## 🚨 Troubleshooting

### Error: "Token không tồn tại hoặc đã hết hạn"
→ Data token đã hết hạn (24h), tạo token mới từ `POST /byIds`

### Error: "Unauthorized"
→ JWT token sai hoặc hết hạn, lấy lại từ `POST /api/auth/login`

### Error: "Cần truyền mảng benhNhanIds với ít nhất 1 mã bệnh nhân"
→ Kiểm tra body request, phải có `benhNhanIds` hoặc `benhTNIds` (array không rỗng)

### Dữ liệu trả về ít hơn yêu cầu
→ Kiểm tra `summary.notFoundBenhNhan` và `summary.notFoundBenhTN` - một số mã không tồn tại trong database

---

## 📚 Tham khảo

- Base URL: `https://benh-vien-api.onrender.com`
- Tất cả endpoints đều cần JWT token trong header `Authorization: Bearer <token>`
- Format ngày tháng: `dd/MM/yyyy` hoặc `dd/MM/yyyy HH:mm`
- Timezone: UTC+7 (Vietnam)
