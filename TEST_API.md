# Test API Response Format

## Test với curl

### 1. Login để lấy JWT Token
```bash
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d "{\"username\":\"admin\",\"password\":\"admin\"}"
```

Lưu token vào biến:
```bash
# Windows PowerShell
$token = (curl -X POST http://localhost:3000/api/auth/login -H "Content-Type: application/json" -d '{"username":"admin","password":"admin"}' | ConvertFrom-Json).token

# Hoặc Linux/Mac
export TOKEN=$(curl -X POST http://localhost:3000/api/auth/login -H "Content-Type: application/json" -d '{"username":"admin","password":"admin"}' | jq -r '.token')
```

### 2. Tạo Data Token
```bash
# Windows PowerShell
$dataToken = (curl -X POST "http://localhost:3000/api/benhNhan/byIds" `
  -H "Content-Type: application/json" `
  -H "Authorization: Bearer $token" `
  -d '{"benhNhanIds":["BN0001"],"benhTNIds":[]}' | ConvertFrom-Json).token

# Linux/Mac
export DATA_TOKEN=$(curl -X POST http://localhost:3000/api/benhNhan/byIds \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{"benhNhanIds":["BN0001"],"benhTNIds":[]}' | jq -r '.token')
```

### 3. Lấy dữ liệu - Kiểm tra format
```bash
# Windows PowerShell  
curl -X GET "http://localhost:3000/api/benhNhan/thongtinbenhnhan?token=$dataToken" `
  -H "Authorization: Bearer $token"

# Linux/Mac
curl -X GET "http://localhost:3000/api/benhNhan/thongtinbenhnhan?token=$DATA_TOKEN" \
  -H "Authorization: Bearer $TOKEN" | jq
```

## Format mong đợi

Dữ liệu trả về SẼ có format:

```json
{
  "success": true,
  "data": {
    "benhNhan": [
      {
        "Id": "BN0001",
        "MaBenhNhan": "BN0001",
        "HoTen": "Nguyễn Văn A",
        "NgaySinh": "01/01/1990",
        "GioiTinh": "263",          // ← CHỈ CÓ ID (số dưới dạng string)
        "DanTocId": "15",            // ← CHỈ CÓ ID
        "NgheNghiep": "11593",       // ← CHỈ CÓ ID
        "CityId": "50",              // ← CHỈ CÓ ID
        "WardId": "166",             // ← ID hoặc text
        "ChanDoanBenh": "51",        // ← CHỈ CÓ ID
        "HinhThucDieuTri": "11128",  // ← CHỈ CÓ ID
        // ... các trường khác
      }
    ]
  }
}
```

## Lưu ý

- Tất cả các trường danh mục: CHỈ trả về ID (string)
- Thông tin cá nhân (HoTen, DiaChi...): Trả về text
- Nếu null → trả về ""
- ID luôn là string (ví dụ: "263" không phải 263)
