# API Server - Hệ thống quản lý bệnh nhân

API Server cho ứng dụng quản lý bệnh nhân bệnh viện, tích hợp với hệ thống API bên ngoài và Firebase Firestore.

## Cài đặt

```bash
npm install
```

## Cấu hình

1. Copy file `.env.example` thành `.env`:
```bash
copy .env.example .env
```

2. Cập nhật các biến môi trường trong file `.env`:
   - `PORT`: Cổng server (mặc định: 3000)
   - `EXTERNAL_API_BASE_URL`: URL API hệ thống bên ngoài
   - `EXTERNAL_API_USERNAME`: Tên đăng nhập API
   - `EXTERNAL_API_PASSWORD`: Mật khẩu API

3. Đặt file `service-account.json` (Firebase Admin SDK credentials) vào thư mục `api-server/`

## Chạy server

### Development
```bash
npm run dev
```

### Production
```bash
npm start
```

## Seed dữ liệu danh mục vào Firebase

Để đưa tất cả dữ liệu danh mục (Giới tính, Dân tộc, Nghề nghiệp, Bệnh truyền nhiễm, v.v.) vào Firestore:

```bash
node seed_categories.js
```

Script này sẽ tạo các collection sau trong Firestore:
- `GioiTinh` - Giới tính (Nam, Nữ)
- `CoKhong` - Có/Không
- `TinhTrangTiemChung` - Tình trạng tiêm chủng
- `NgheNghiep` - Nghề nghiệp (43 loại)
- `DanToc` - Dân tộc (54 dân tộc)
- `DieuTri` - Phương pháp điều trị
- `HinhThucDieuTri` - Hình thức điều trị
- `PhanLoaiChanDoan` - Phân loại chẩn đoán
- `LoaiBenhPham` - Loại bệnh phẩm
- `LoaiXetNghiem` - Loại xét nghiệm
- `KetQuaXetNghiem` - Kết quả xét nghiệm
- `PhanDoBenh` - Phân độ bệnh
- `Tinh` - Tỉnh thành
- `BenhTruyenNhiem` - Bệnh truyền nhiễm (50 loại)
- `BenhNen` - Bệnh nền (60+ loại)

## API Routes

### Authentication
- `POST /api/auth/login` - Đăng nhập và lấy token

### Bệnh nhân
- `GET /api/benh-nhan` - Lấy danh sách bệnh nhân
- `GET /api/benh-nhan/:id` - Lấy thông tin chi tiết bệnh nhân
- `POST /api/benh-nhan` - Thêm bệnh nhân mới
- `PUT /api/benh-nhan/:id` - Cập nhật thông tin bệnh nhân
- `DELETE /api/benh-nhan/:id` - Xóa bệnh nhân

### Bệnh truyền nhiễm
- `GET /api/benh-truyen-nhiem` - Lấy danh sách bệnh truyền nhiễm
- `GET /api/benh-truyen-nhiem/:id` - Lấy chi tiết bệnh truyền nhiễm
- `POST /api/benh-truyen-nhiem` - Thêm mới
- `PUT /api/benh-truyen-nhiem/:id` - Cập nhật
- `DELETE /api/benh-truyen-nhiem/:id` - Xóa

### Danh mục
- `GET /api/danh-muc/:categoryName` - Lấy danh mục theo tên
  - Các category: GioiTinh, DanToc, NgheNghiep, DieuTri, BenhTruyenNhiem, v.v.

## Deploy lên Render

Project đã được cấu hình sẵn file `render.yaml`. Để deploy:

1. Push code lên GitHub
2. Kết nối repository với Render
3. Render sẽ tự động deploy theo cấu hình trong `render.yaml`

## Scripts

- `npm start` - Chạy server production
- `npm run dev` - Chạy server development với nodemon
- `node seed_categories.js` - Seed dữ liệu danh mục vào Firestore
- `node migrate_ids.js` - Migration script cho cập nhật ID

## Cấu trúc thư mục

```
api-server/
├── src/
│   ├── routes/
│   │   ├── authRoutes.js
│   │   ├── benhNhanRoutes.js
│   │   ├── benhTruyenNhiemRoutes.js
│   │   └── danhMucRoutes.js
│   ├── formatters.js
│   └── index.js
├── seed_categories.js
├── migrate_ids.js
├── service-account.json (không commit)
├── .env (không commit)
├── .env.example
├── package.json
└── render.yaml
```

## Lưu ý

- File `service-account.json` và `.env` không được commit lên Git
- Tất cả ID trong danh mục đều đồng bộ với hệ thống API bên ngoài
- Server sử dụng Firebase Admin SDK để tương tác với Firestore
