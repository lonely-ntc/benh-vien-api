/**
 * Script để reset database:
 * 1. Quét và giữ lại tất cả danh mục (gioiTinh, danToc, city, etc.) với id và name
 * 2. Xóa dữ liệu bệnh nhân cũ
 * 3. Tạo 10 bệnh nhân mẫu mới với dữ liệu ngẫu nhiên
 */

import admin from 'firebase-admin';
import { readFileSync } from 'fs';

// Khởi tạo Firebase Admin
const serviceAccount = JSON.parse(readFileSync('./service-account.json', 'utf8'));
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

// ═══════════════════════════════════════════════════════════════════════════
// BƯỚC 1: Quét và lưu tất cả danh mục
// ═══════════════════════════════════════════════════════════════════════════

const CATEGORY_COLLECTIONS = [
  'gioiTinh',
  'danToc',
  'ngheNghiep',
  'dieuTri',
  'hinhThucDieuTri',
  'benhTruyenNhiem',
  'benhNen',
  'phanLoaiChanDoan',
  'loaiBenhPham',
  'loaiXetNghiem',
  'ketQuaXetNghiem',
  'tinhTrangTiemChung',
  'coSoBaoCao',
  'donViDieuTra',
  'coSoDieuTri',
  'tinh',
  'phuong',
  'phuongMoiHCM',
  'chanDoanBenh',
  'phanDoBenh',
  'coKhong'
];

async function scanCategories() {
  console.log('🔍 Bước 1: Quét danh mục từ database cũ...\n');
  const categories = {};
  
  for (const collection of CATEGORY_COLLECTIONS) {
    try {
      const snap = await db.collection(collection).get();
      categories[collection] = [];
      
      snap.docs.forEach(doc => {
        const data = doc.data();
        categories[collection].push({
          id: data.id || doc.id,
          name: data.name || data.ten || ''
        });
      });
      
      console.log(`   ✅ ${collection}: ${categories[collection].length} items`);
    } catch (e) {
      console.log(`   ⚠️  ${collection}: Không tìm thấy hoặc lỗi`);
      categories[collection] = [];
    }
  }
  
  console.log('\n✅ Đã quét xong tất cả danh mục!\n');
  return categories;
}

// ═══════════════════════════════════════════════════════════════════════════
// BƯỚC 2: Xóa dữ liệu bệnh nhân cũ
// ═══════════════════════════════════════════════════════════════════════════

async function clearPatientData() {
  console.log('🗑️  Bước 2: Xóa dữ liệu bệnh nhân cũ...\n');
  
  // Xóa bệnh nhân
  const bnSnap = await db.collection('benhNhan').get();
  console.log(`   Đang xóa ${bnSnap.size} bệnh nhân...`);
  const bnBatch = db.batch();
  bnSnap.docs.forEach(doc => bnBatch.delete(doc.ref));
  await bnBatch.commit();
  
  // Xóa bệnh truyền nhiễm
  const btnSnap = await db.collection('benhTruyenNhiem').get();
  console.log(`   Đang xóa ${btnSnap.size} bệnh truyền nhiễm...`);
  const btnBatch = db.batch();
  btnSnap.docs.forEach(doc => btnBatch.delete(doc.ref));
  await btnBatch.commit();
  
  console.log('\n✅ Đã xóa dữ liệu bệnh nhân cũ!\n');
}

// ═══════════════════════════════════════════════════════════════════════════
// BƯỚC 3: Tạo dữ liệu bệnh nhân mẫu
// ═══════════════════════════════════════════════════════════════════════════

// Hàm random từ array
const randomFrom = (arr) => arr.length > 0 ? arr[Math.floor(Math.random() * arr.length)] : null;

// Danh sách tên mẫu
const HO = ['Nguyễn', 'Trần', 'Lê', 'Phạm', 'Hoàng', 'Huỳnh', 'Phan', 'Vũ', 'Võ', 'Đặng'];
const TEN_DEM = ['Văn', 'Thị', 'Hữu', 'Đức', 'Minh', 'Tuấn', 'Thành', 'Hoàng', 'Quang', 'Anh'];
const TEN = ['Nam', 'Hùng', 'Dũng', 'Long', 'Khoa', 'Linh', 'Mai', 'Hương', 'Lan', 'Phương'];

const DIA_CHI = [
  'Số 123 Nguyễn Huệ',
  'Số 456 Lê Lợi',
  'Số 789 Trần Hưng Đạo',
  'Số 321 Hai Bà Trưng',
  'Số 654 Lý Thường Kiệt',
  'Số 987 Võ Văn Tần',
  'Số 147 Điện Biên Phủ',
  'Số 258 Phan Đình Phùng',
  'Số 369 Nguyễn Trãi',
  'Số 741 Phạm Ngọc Thạch'
];

const NHOM_MAU = ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'];
const TRANG_THAI = ['Chờ', 'Đang khám', 'Hoàn thành', 'Hủy'];

function randomDate(start, end) {
  const date = new Date(start.getTime() + Math.random() * (end.getTime() - start.getTime()));
  return date.toLocaleDateString('vi-VN');
}

function randomPhone() {
  return '0' + Math.floor(Math.random() * 900000000 + 100000000);
}

function randomCCCD() {
  return Math.floor(Math.random() * 900000000000 + 100000000000).toString();
}

function randomBHYT() {
  const letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  return letters[Math.floor(Math.random() * letters.length)] + 
         letters[Math.floor(Math.random() * letters.length)] +
         Math.floor(Math.random() * 900000000000 + 100000000000);
}

async function createSamplePatients(categories) {
  console.log('📝 Bước 3: Tạo 10 bệnh nhân mẫu...\n');
  
  const batch = db.batch();
  
  for (let i = 1; i <= 10; i++) {
    const hoTen = `${randomFrom(HO)} ${randomFrom(TEN_DEM)} ${randomFrom(TEN)}`;
    const ngaySinh = randomDate(new Date(1960, 0, 1), new Date(2005, 11, 31));
    
    const benhNhan = {
      benhNhanId: `BN${String(i).padStart(4, '0')}`,
      hoTen,
      ngaySinh,
      gioiTinh: randomFrom(categories.gioiTinh),
      danToc: randomFrom(categories.danToc),
      ngheNghiep: randomFrom(categories.ngheNghiep),
      soDienThoai: randomPhone(),
      cccd: randomCCCD(),
      baoHiemYTe: randomBHYT(),
      diaChi: `${randomFrom(DIA_CHI)}, ${randomFrom(categories.phuong || [])?.name || 'Phường 1'}`,
      phuong: randomFrom(categories.phuong || [])?.name || '',
      phuongMoiHCM: randomFrom(categories.phuongMoiHCM || [])?.name || '',
      tinh: randomFrom(categories.tinh),
      nhomMau: randomFrom(NHOM_MAU),
      benhNen: randomFrom(categories.benhNen),
      benhTruyenNhiem: randomFrom(categories.benhTruyenNhiem),
      coKhong: randomFrom(categories.coKhong),
      tinhTrangTiemChung: randomFrom(categories.tinhTrangTiemChung),
      dieuTri: randomFrom(categories.dieuTri),
      hinhThucDieuTri: randomFrom(categories.hinhThucDieuTri),
      chanDoanBenh: randomFrom(categories.chanDoanBenh),
      phanLoaiChanDoan: randomFrom(categories.phanLoaiChanDoan),
      phanDoBenh: randomFrom(categories.phanDoBenh),
      loaiBenhPham: randomFrom(categories.loaiBenhPham),
      loaiXetNghiem: randomFrom(categories.loaiXetNghiem),
      ketQuaXetNghiem: randomFrom(categories.ketQuaXetNghiem),
      coSoBaoCao: randomFrom(categories.coSoBaoCao),
      coSoDieuTri: randomFrom(categories.coSoDieuTri),
      donViDieuTra: randomFrom(categories.donViDieuTra)?.name || '',
      phongKham: `Phòng khám ${['Nội', 'Ngoại', 'Sản', 'Nhi', 'Tai Mũi Họng'][Math.floor(Math.random() * 5)]}`,
      trangThai: randomFrom(TRANG_THAI),
      soThuTu: i,
      ngayDangKy: new Date().toISOString(),
      ngayCapNhat: new Date().toISOString()
    };
    
    const docRef = db.collection('benhNhan').doc();
    batch.set(docRef, benhNhan);
    
    console.log(`   ✅ BN${String(i).padStart(4, '0')}: ${hoTen}`);
  }
  
  await batch.commit();
  console.log('\n✅ Đã tạo 10 bệnh nhân mẫu!\n');
}

// ═══════════════════════════════════════════════════════════════════════════
// MAIN
// ═══════════════════════════════════════════════════════════════════════════

async function main() {
  console.log('\n╔════════════════════════════════════════════════════════════════╗');
  console.log('║         RESET DATABASE - TẠO DỮ LIỆU MẪU                      ║');
  console.log('╚════════════════════════════════════════════════════════════════╝\n');
  
  try {
    // Bước 1: Quét danh mục
    const categories = await scanCategories();
    
    // Bước 2: Xóa dữ liệu cũ
    await clearPatientData();
    
    // Bước 3: Tạo dữ liệu mẫu
    await createSamplePatients(categories);
    
    console.log('╔════════════════════════════════════════════════════════════════╗');
    console.log('║                    HOÀN THÀNH!                                 ║');
    console.log('╚════════════════════════════════════════════════════════════════╝\n');
    
    process.exit(0);
  } catch (error) {
    console.error('❌ Lỗi:', error);
    process.exit(1);
  }
}

main();
