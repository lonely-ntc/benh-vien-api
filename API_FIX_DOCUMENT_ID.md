# Sửa lỗi: API sử dụng Firestore Document ID

## Vấn đề
API backend ban đầu tìm kiếm theo field `benhNhanId` và `benhAnId`, nhưng:
- API `/tatca` trả về Firestore **document ID** (`ifHA1QKSttw9AelYVpoh`)
- Dữ liệu có field `benhNhanId` (`BNO158`) riêng biệt
- Khi tạo token với `benhNhanId`, API không tìm thấy dữ liệu → **404 Not Found**

## Giải pháp
Thay đổi backend API để sử dụng **Firestore document ID** thay vì field nghiệp vụ:

### 1. **POST /api/benhNhan/byIds**
**Trước:**
```javascript
// Tìm theo field benhNhanId
const snap = await db.collection('benhNhan')
  .where('benhNhanId', 'in', chunk)
  .get();
```

**Sau:**
```javascript
// Lấy trực tiếp theo document ID
for (const docId of benhNhanIds) {
  const doc = await db.collection('benhNhan').doc(docId).get();
  if (doc.exists) {
    benhNhanData.push({ id: doc.id, ...sanitize(doc.data()) });
  }
}
```

### 2. **GET /api/benhNhan/thongtinbenhnhan**
**Trước:**
```javascript
// Tìm theo field benhNhanId
const snap = await db.collection('benhNhan')
  .where('benhNhanId', 'in', chunk)
  .get();
```

**Sau:**
```javascript
// Lấy trực tiếp theo document ID
for (const docId of benhNhanIds) {
  const doc = await db.collection('benhNhan').doc(docId).get();
  if (doc.exists) {
    const data = doc.data();
    benhNhanData.push(formatBenhNhanToAPI(data));
  }
}
```

### 3. **Tương tự cho Bệnh Truyền Nhiễm**
- `POST /api/benhTruyenNhiem/byIds` - sử dụng document ID
- `GET /api/benhTruyenNhiem/thongtinbenhan` - sử dụng document ID

## Lợi ích

✅ **Nhất quán**: API `/tatca` và `/byIds` đều dùng document ID
✅ **Đơn giản**: Không cần query theo field, chỉ cần `.doc(id).get()`
✅ **Nhanh hơn**: Truy vấn trực tiếp theo ID thay vì query with index
✅ **Không lỗi**: Không bị 404 khi field `benhNhanId`/`benhAnId` chưa có

## Files đã sửa
- `api-server/src/routes/benhNhanRoutes.js`
- `api-server/src/routes/benhTruyenNhiemRoutes.js`

## Cách deploy
```bash
cd api-server
git add .
git commit -m "Fix: Use Firestore document ID instead of benhNhanId/benhAnId"
git push
```

Render sẽ tự động deploy lại sau vài phút.

## Test
Sau khi deploy:
1. Chọn bệnh nhân trong app
2. Nhấn "Xem Token"
3. Sử dụng data token để lấy dữ liệu
4. Kết quả: ✅ Success (không còn 404)

---
**Ngày sửa**: 20/06/2026
