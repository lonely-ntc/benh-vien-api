# Test API - Debug Guide

## 🔍 Kiểm tra server đang chạy

```bash
# Trong terminal api-server
cd api-server
npm start
```

Bạn sẽ thấy:
```
🚀  Bệnh Viện API đang chạy tại http://localhost:3000
    Docs: GET http://localhost:3000/
```

## 📝 Test từng bước

### 1. Test health check
```bash
GET http://localhost:3000/
```

**Expected**: JSON với danh sách endpoints

### 2. Lấy JWT Token
```bash
POST http://localhost:3000/api/auth/login
Content-Type: application/json

{
  "username": "admin",
  "password": "admin123"
}
```

**Expected**:
```json
{
  "success": true,
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "role": "admin",
  "hoTen": "Admin",
  "expiresIn": "24 giờ"
}
```

**❌ Nếu nhận HTML**: Server không chạy hoặc URL sai!

### 3. Tạo Data Token
```bash
POST http://localhost:3000/api/benhTruyenNhiem/byIds
Authorization: Bearer <JWT_TOKEN_TỪ_BƯỚC_2>
Content-Type: application/json

{
  "benhNhanIds": [],
  "benhTNIds": ["BA0001", "BA0002"]
}
```

**Expected**:
```json
{
  "success": true,
  "token": "abc123xyz",
  "message": "Token đã được tạo...",
  "summary": {
    "benhNhanCount": 0,
    "benhTNCount": 2,
    ...
  }
}
```

**Lưu ý**: Nếu `benhTNCount: 0`, có nghĩa là không tìm thấy dữ liệu với `benhAnId` = BA0001 hoặc BA0002. Kiểm tra Firestore!

### 4. Lấy dữ liệu theo Data Token
```bash
GET http://localhost:3000/api/benhTruyenNhiem/thongtinbenhan?token=abc123xyz
Authorization: Bearer <JWT_TOKEN_TỪ_BƯỚC_2>
```

**Expected**:
```json
{
  "success": true,
  "token": "abc123xyz",
  "timestamp": "2026-06-19T...",
  "data": {
    "benhNhan": [],
    "benhTruyenNhiem": [
      {
        "Id": null,
        "UnitId": null,
        "MaBenhNhan": "BA0001",
        "HoTen": "Nguyễn Văn A",
        "NgaySinh": "01/01/1990",
        "GioiTinh": "263",
        "DanTocId": "15",
        ...
      }
    ]
  },
  "summary": {
    "benhNhanCount": 0,
    "benhTNCount": 1,
    "total": 1
  }
}
```

## 🚨 Troubleshooting

### Nhận được HTML thay vì JSON?

**Nguyên nhân 1: URL sai**
```
❌ GET https://benh-vien-api.onrender.com/api/benhTruyenNhiem/thongtinbenhan/token=xxx
✅ GET https://benh-vien-api.onrender.com/api/benhTruyenNhiem/thongtinbenhan?token=xxx
                                                                             ^ Query param!
```

**Nguyên nhân 2: Server chưa deploy**
- Nếu test local: `http://localhost:3000`
- Nếu test Render: Đảm bảo đã push code lên GitHub và Render đã rebuild

**Nguyên nhân 3: Endpoint không tồn tại**
Kiểm tra console log:
```
⚠️  404 Not Found: GET /api/benhTruyenNhiem/thongtinbenhan
```

Nghĩa là endpoint chưa được register! Check `index.js`.

### Token không tồn tại?

**Kiểm tra logs**:
```
📥 GET /thongtinbenhan - Query: { token: 'abc123xyz' }
🔍 Token data: Not found
```

Nghĩa là:
1. Token đã hết hạn (24h)
2. Token chưa được tạo (POST /byIds chưa chạy)
3. Server đã restart (token lưu trong memory)

**Giải pháp**: Tạo lại token từ bước 3.

### Không có dữ liệu trả về?

**Kiểm tra logs**:
```
📊 Fetching: 0 BN, 2 BTN
✅ Returning: 0 BN, 0 BTN
```

Nghĩa là:
1. `benhAnId` không tồn tại trong Firestore
2. Tên field sai (phải là `benhAnId`, không phải `benhanId`)

**Giải pháp**: 
1. Chạy migration: `npm run migrate:benh-nhan-id`
2. Hoặc check Firestore Console xem có field `benhAnId` không

## 🎯 Test với Postman

### Setup Collection

1. **Create Collection**: "Bệnh Viện API"

2. **Add Environment Variables**:
   - `baseUrl`: `http://localhost:3000` (local) hoặc `https://benh-vien-api.onrender.com` (production)
   - `jwtToken`: (để trống, sẽ tự động set sau login)
   - `dataToken`: (để trống, sẽ tự động set sau byIds)

3. **Add Requests**:

#### Request 1: Login
```
POST {{baseUrl}}/api/auth/login
Body (JSON):
{
  "username": "admin",
  "password": "admin123"
}

Tests (tab Tests):
var jsonData = pm.response.json();
if (jsonData.success && jsonData.token) {
    pm.environment.set("jwtToken", jsonData.token);
}
```

#### Request 2: Create Token
```
POST {{baseUrl}}/api/benhTruyenNhiem/byIds
Authorization: Bearer {{jwtToken}}
Body (JSON):
{
  "benhNhanIds": [],
  "benhTNIds": ["BA0001"]
}

Tests:
var jsonData = pm.response.json();
if (jsonData.success && jsonData.token) {
    pm.environment.set("dataToken", jsonData.token);
}
```

#### Request 3: Get Data
```
GET {{baseUrl}}/api/benhTruyenNhiem/thongtinbenhan?token={{dataToken}}
Authorization: Bearer {{jwtToken}}
```

### Expected Result

Status: `200 OK`
Content-Type: `application/json`

```json
{
  "success": true,
  "data": {
    "benhTruyenNhiem": [...]
  }
}
```

**❌ Nếu nhận HTML**: 
1. Check URL có đúng không (có `?` trước token)
2. Check server đang chạy
3. Check Console để xem logs

## 🐛 Debug Mode

Để xem chi tiết logs:

```bash
# Trong api-server terminal
# Bạn sẽ thấy:

[2026-06-19T10:30:00.000Z] POST /api/auth/login
[2026-06-19T10:30:01.000Z] POST /api/benhTruyenNhiem/byIds
📥 POST /byIds - Body: { benhNhanIds: [], benhTNIds: ['BA0001'] }
📊 Found 1 BTN records
✅ Token created: abc123xyz

[2026-06-19T10:30:05.000Z] GET /api/benhTruyenNhiem/thongtinbenhan
📥 GET /thongtinbenhan - Query: { token: 'abc123xyz' }
🔍 Token data: Found
📊 Fetching: 0 BN, 1 BTN
✅ Returning: 0 BN, 1 BTN
```

Nếu không thấy logs này → Endpoint chưa được hit → Check URL!
