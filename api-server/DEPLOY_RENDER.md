# Hướng dẫn Deploy lên Render.com

## Bước 1 — Lấy Firebase Service Account Key

1. Mở [Firebase Console](https://console.firebase.google.com) → project **thongtinbenhnhan-8ab9b**
2. ⚙️ **Project Settings** → tab **Service accounts**
3. Nhấn **"Generate new private key"** → tải file JSON về
4. **Giữ file này bí mật**, đừng commit lên Git

---

## Bước 2 — Đẩy code lên GitHub

Thư mục cần push là `api-server/` (hoặc toàn bộ repo):

```bash
cd api-server
git init
git add .
git commit -m "Initial API server"
git remote add origin https://github.com/<your-username>/benh-vien-api.git
git push -u origin main
```

> File `.gitignore` đã loại trừ `service-account.json` và `.env`

---

## Bước 3 — Tạo Web Service trên Render

1. Đăng nhập [render.com](https://render.com)
2. **New** → **Web Service**
3. Kết nối GitHub repo vừa push
4. Cấu hình:

| Trường | Giá trị |
|--------|---------|
| **Name** | benh-vien-api |
| **Region** | Singapore (gần nhất) |
| **Branch** | main |
| **Root Directory** | api-server |
| **Runtime** | Node |
| **Build Command** | `npm install` |
| **Start Command** | `npm start` |
| **Plan** | Free |

---

## Bước 4 — Cấu hình Environment Variables

Trong Render Dashboard → tab **Environment**, thêm các biến:

| Key | Value |
|-----|-------|
| `JWT_SECRET` | Chuỗi ngẫu nhiên dài (ví dụ: `bv_2025_abcXYZ123!@#`) |
| `JWT_EXPIRES_IN` | `8h` |
| `FIREBASE_CREDENTIALS` | *(Dán toàn bộ nội dung file service-account.json vào đây)* |

### Cách lấy nội dung FIREBASE_CREDENTIALS:

```bash
# Windows PowerShell
Get-Content "service-account.json" -Raw
```

Copy toàn bộ JSON (bao gồm cả `{` và `}`) dán vào giá trị của biến `FIREBASE_CREDENTIALS`.

---

## Bước 5 — Deploy

Nhấn **"Create Web Service"** → Render sẽ tự build và deploy.

URL API sẽ có dạng: `https://benh-vien-api.onrender.com`

---

## Test API sau khi deploy

### 1. Health check
```
GET https://benh-vien-api.onrender.com/
```

### 2. Đăng nhập lấy token
```bash
curl -X POST https://benh-vien-api.onrender.com/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username": "admin", "password": "admin123"}'
```

Response:
```json
{
  "success": true,
  "message": "Đăng nhập thành công.",
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "expiresIn": "8h",
  "role": "admin",
  "username": "admin"
}
```

### 3. Lấy danh sách bệnh nhân
```bash
curl https://benh-vien-api.onrender.com/api/benhNhan \
  -H "Authorization: Bearer <token>"
```

### 4. Lấy danh sách bệnh truyền nhiễm
```bash
curl https://benh-vien-api.onrender.com/api/benhTruyenNhiem \
  -H "Authorization: Bearer <token>"
```

### 5. Lấy tất cả danh mục
```bash
curl https://benh-vien-api.onrender.com/api/danhMuc \
  -H "Authorization: Bearer <token>"
```

### 6. Lấy danh mục cụ thể
```bash
curl https://benh-vien-api.onrender.com/api/danhMuc/GioiTinh \
  -H "Authorization: Bearer <token>"
```

---

## Danh sách Endpoints

| Method | Endpoint | Auth | Mô tả |
|--------|----------|------|-------|
| GET | `/` | ❌ | Health check + docs |
| POST | `/api/auth/login` | ❌ | Đăng nhập → JWT |
| GET | `/api/benhNhan` | ✅ JWT | Danh sách bệnh nhân |
| GET | `/api/benhNhan/:id` | ✅ JWT | Chi tiết bệnh nhân |
| GET | `/api/benhTruyenNhiem` | ✅ JWT | Danh sách bệnh TN |
| GET | `/api/benhTruyenNhiem/:id` | ✅ JWT | Chi tiết bệnh TN |
| GET | `/api/danhMuc` | ✅ JWT | Tất cả danh mục |
| GET | `/api/danhMuc/:code` | ✅ JWT | Danh mục theo code |

## Query Parameters

| Param | Mô tả | Ví dụ |
|-------|-------|-------|
| `pageSize` | Số bản ghi/trang (max 200) | `?pageSize=20` |
| `startAfter` | Phân trang (docId cuối trang trước) | `?startAfter=abc123` |
| `chanDoanBenh` | Lọc theo chẩn đoán (benhTruyenNhiem) | `?chanDoanBenh=COVID-19` |
| `ketQuaXN` | Lọc theo kết quả XN | `?ketQuaXN=Dương tính` |

## Danh mục codes (dùng với /api/danhMuc/:code)

`GioiTinh`, `CoKhong`, `NhomMau`, `TrangThai`, `DanToc`, `NgheNghiep`,
`DieuTri`, `HinhThucDieuTri`, `BenhTruyenNhiem`, `BenhNen`,
`PhanLoaiChanDoan`, `LoaiBenhPham`, `LoaiXetNghiem`, `KetQuaXetNghiem`,
`TinhTrangTiemChung`, `PhanDoBenh`, `Tinh`, `ChanDoanBenh`

---

## Lưu ý quan trọng

- ⚠️ Free tier của Render sẽ **sleep sau 15 phút không có request** — lần đầu gọi sau khi sleep sẽ chờ ~30 giây
- 🔒 `JWT_SECRET` phải là chuỗi ngẫu nhiên mạnh trong production
- 🔒 Không bao giờ commit `service-account.json` lên GitHub
