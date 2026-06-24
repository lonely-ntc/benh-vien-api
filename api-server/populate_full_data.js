/**
 * Script để populate đầy đủ dữ liệu với ID chuẩn từ API
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
// DANH MỤC VỚI ID CHUẨN TỪ API
// ═══════════════════════════════════════════════════════════════════════════

const CATEGORIES = {
  gioiTinh: [
    { id: 262, name: 'Nữ' },
    { id: 263, name: 'Nam' }
  ],
  
  coKhong: [
    { id: 264, name: 'Có' },
    { id: 265, name: 'Không' }
  ],
  
  danToc: [
    { id: 15, name: 'Kinh' },
    { id: 16, name: 'Tày' },
    { id: 17, name: 'Thái' },
    { id: 18, name: 'Hoa' },
    { id: 19, name: 'Khme' },
    { id: 20, name: 'Mường' },
    { id: 21, name: 'Nùng' },
    { id: 22, name: 'Hán' },
    { id: 23, name: 'Dao' },
    { id: 24, name: 'Gia rai' }
  ],
  
  ngheNghiep: [
    { id: 11204, name: 'Trẻ < 6 tuổi đi học, <15 tuổi không đi học' },
    { id: 11205, name: 'Sinh viên, học sinh' },
    { id: 11206, name: 'Hưu và > 60 tuổi' },
    { id: 11207, name: 'Lực lượng vũ trang' },
    { id: 11208, name: 'Tri thức' },
    { id: 11209, name: 'Hành chính, sự nghiệp' },
    { id: 11210, name: 'Công nhân' },
    { id: 11211, name: 'Y tế' },
    { id: 11212, name: 'Dịch vụ' },
    { id: 11213, name: 'Nông dân' },
    { id: 11593, name: 'Khác' }
  ],
  
  dieuTri: [
    { id: 11143, name: 'Thở oxy' },
    { id: 11144, name: 'Thở NCPAP' },
    { id: 11145, name: 'Thở máy' },
    { id: 11146, name: 'IVIG' },
    { id: 11203, name: 'Không hỗ trợ hô hấp' }
  ],
  
  hinhThucDieuTri: [
    { id: 11128, name: 'Điều trị nội trú' },
    { id: 11129, name: 'Điều trị ngoại trú' },
    { id: 11130, name: 'Ra viện' },
    { id: 11131, name: 'Tử vong' },
    { id: 11132, name: 'Chuyển viện' },
    { id: 11133, name: 'Tình trạng khác' }
  ],
  
  benhNen: [
    { id: 11217, name: 'Lao hô hấp, có khẳng định về vi khuẩn học và mô học' },
    { id: 11282, name: 'Bệnh đái tháo đường type 1' },
    { id: 11561, name: 'Không có bệnh nền' }
  ],
  
  phanLoaiChanDoan: [
    { id: 11545, name: 'Có thể' },
    { id: 11546, name: 'Nghi ngờ (lâm sàng)' },
    { id: 11547, name: 'Xác định phòng xét nghiệm' }
  ],
  
  loaiBenhPham: [
    { id: 11548, name: 'Máu' },
    { id: 11549, name: 'Phân' },
    { id: 11550, name: 'Dịch ngoáy họng' },
    { id: 11551, name: 'Dịch tỵ hầu' },
    { id: 11554, name: 'Nước tiểu' }
  ],
  
  loaiXetNghiem: [
    { id: 11192, name: 'Test nhanh' },
    { id: 11193, name: 'Mac-elisa' },
    { id: 11194, name: 'PCR' },
    { id: 11195, name: 'Soi' },
    { id: 11555, name: 'Cấy' }
  ],
  
  ketQuaXetNghiem: [
    { id: 11140, name: 'Dương tính' },
    { id: 11141, name: 'Âm tính' },
    { id: 11142, name: 'Chưa có kết quả' }
  ],
  
  tinhTrangTiemChung: [
    { id: 11134, name: 'Có' },
    { id: 11135, name: 'Không' },
    { id: 11137, name: 'Không rõ' }
  ],
  
  chanDoanBenh: [
    { id: 1, name: 'Bại liệt' },
    { id: 13, name: 'Sốt xuất huyết Dengue' },
    { id: 16, name: 'Tay - chân - miệng' },
    { id: 21, name: 'Covid-19' },
    { id: 28, name: 'Lao phổi' },
    { id: 38, name: 'Viêm gan vi rút A' },
    { id: 39, name: 'Viêm gan vi rút B' },
    { id: 50, name: 'Cúm' },
    { id: 51, name: 'Lỵ amíp' },
    { id: 54, name: 'Thủy đậu' }
  ],
  
  phanDoBenh: [
    { id: 1, name: 'Sốt xuất huyết Dengue' },
    { id: 2, name: 'Sốt xuất huyết Dengue có dấu hiệu cảnh báo' },
    { id: 3, name: 'Sốt xuất huyết Dengue nặng' },
    { id: 4, name: 'Độ 1' },
    { id: 8, name: 'Độ 4' }
  ],
  
  tinh: [
    { id: 1, name: 'Thành phố Hà Nội' },
    { id: 20, name: 'Thành phố Hải Phòng' },
    { id: 32, name: 'Thành phố Đà Nẵng' },
    { id: 50, name: 'Thành Phố Hồ Chí Minh' },
    { id: 59, name: 'Thành phố Cần Thơ' },
    { id: 48, name: 'Tỉnh Đồng Nai' },
    { id: 46, name: 'Tỉnh Tây Ninh' },
    { id: 79, name: 'Tỉnh Bà Rịa - Vũng Tàu' }
  ],
  
  coSoBaoCao: [
    { id: 10014, name: 'Trung tâm Y tế khu vực Tân Hưng' },
    { id: 10118, name: 'Bệnh viện Quận 12' },
    { id: 10184, name: 'Bệnh viện Chợ Rẫy' },
    { id: 10106, name: 'Bệnh viện Hùng Vương' },
    { id: 74001, name: 'Bệnh viện Chợ Rẫy' }
  ],
  
  coSoDieuTri: [
    { id: 10014, name: 'Trung tâm Y tế khu vực Tân Hưng' },
    { id: 10118, name: 'Bệnh viện Quận 12' },
    { id: 10184, name: 'Bệnh viện Chợ Rẫy' },
    { id: 10106, name: 'Bệnh viện Hùng Vương' },
    { id: 74001, name: 'Bệnh viện Chợ Rẫy' }
  ],
  
  donViDieuTra: [
    { id: 10014, name: 'Trung tâm Y tế khu vực Tân Hưng' },
    { id: 10118, name: 'Bệnh viện Quận 12' },
    { id: 10184, name: 'Bệnh viện Chợ Rẫy' },
    { id: 10106, name: 'Bệnh viện Hùng Vương' },
    { id: 74001, name: 'Bệnh viện Chợ Rẫy' }
  ]
};

// ═══════════════════════════════════════════════════════════════════════════
// TẠO DANH MỤC
// ═══════════════════════════════════════════════════════════════════════════

async function createCategories() {
  console.log('📝 Bước 1: Tạo danh mục...\n');
  
  for (const [collection, items] of Object.entries(CATEGORIES)) {
    // Xóa collection cũ
    const snap = await db.collection(collection).get();
    if (snap.size > 0) {
      const batch = db.batch();
      snap.docs.forEach(doc => batch.delete(doc.ref));
      await batch.commit();
    }
    
    // Thêm items mới
    const batch = db.batch();
    for (const item of items) {
      const docRef = db.collection(collection).doc();
      batch.set(docRef, item);
    }
    await batch.commit();
    
    console.log(`   ✅ ${collection}: ${items.length} items`);
  }
  
  console.log('\n✅ Đã tạo xong danh mục!\n');
}

// ═══════════════════════════════════════════════════════════════════════════
// TẠO 50 BỆNH NHÂN MẪU
// ═══════════════════════════════════════════════════════════════════════════

const randomFrom = (arr) => arr[Math.floor(Math.random() * arr.length)];

const HO = ['Nguyễn', 'Trần', 'Lê', 'Phạm', 'Hoàng', 'Huỳnh', 'Phan', 'Vũ', 'Võ', 'Đặng'];
const TEN_DEM = ['Văn', 'Thị', 'Hữu', 'Đức', 'Minh', 'Tuấn', 'Thành', 'Hoàng', 'Quang', 'Anh'];
const TEN = ['Nam', 'Hùng', 'Dũng', 'Long', 'Khoa', 'Linh', 'Mai', 'Hương', 'Lan', 'Phương'];

function randomDate(start, end) {
  const date = new Date(start.getTime() + Math.random() * (end.getTime() - start.getTime()));
  return date.toLocaleDateString('vi-VN');
}

function randomPhone() {
  return '0' + Math.floor(Math.random() * 900000000 + 100000000);
}

function randomCCCD() {
  return '0' + Math.floor(Math.random() * 90000000000 + 10000000000).toString();
}

async function createPatients() {
  console.log('📝 Bước 2: Xóa dữ liệu bệnh nhân cũ...\n');
  
  // Xóa bệnh nhân cũ
  const bnSnap = await db.collection('benhNhan').get();
  if (bnSnap.size > 0) {
    console.log(`   Đang xóa ${bnSnap.size} bệnh nhân...`);
    const bnBatch = db.batch();
    bnSnap.docs.forEach(doc => bnBatch.delete(doc.ref));
    await bnBatch.commit();
  }
  
  // Xóa bệnh truyền nhiễm cũ
  const btnSnap = await db.collection('benhTruyenNhiem').get();
  if (btnSnap.size > 0) {
    console.log(`   Đang xóa ${btnSnap.size} bệnh truyền nhiễm...`);
    const btnBatch = db.batch();
    btnSnap.docs.forEach(doc => btnBatch.delete(doc.ref));
    await btnBatch.commit();
  }
  
  console.log('\n📝 Bước 3: Tạo 50 bệnh nhân mới...\n');
  
  for (let i = 1; i <= 50; i++) {
    const hoTen = `${randomFrom(HO)} ${randomFrom(TEN_DEM)} ${randomFrom(TEN)}`;
    const ngaySinh = randomDate(new Date(1960, 0, 1), new Date(2010, 11, 31));
    const gioiTinh = randomFrom(CATEGORIES.gioiTinh);
    
    // Tạo bệnh nhân
    const benhNhan = {
      benhNhanId: `BN${String(i).padStart(5, '0')}`,
      hoTen,
      ngaySinh,
      gioiTinh,
      danToc: randomFrom(CATEGORIES.danToc),
      ngheNghiep: randomFrom(CATEGORIES.ngheNghiep),
      soDienThoai: randomPhone(),
      cccd: randomCCCD(),
      diaChi: `Số ${Math.floor(Math.random() * 500 + 1)} Đường ${randomFrom(['Nguyễn Huệ', 'Lê Lợi', 'Trần Hưng Đạo', 'Hai Bà Trưng'])}`,
      tinh: randomFrom(CATEGORIES.tinh),
      soThuTu: i,
      ngayDangKy: new Date().toISOString(),
      ngayCapNhat: new Date().toISOString()
    };
    
    await db.collection('benhNhan').add(benhNhan);
    
    // Tạo bệnh truyền nhiễm (50% có bệnh truyền nhiễm)
    if (Math.random() > 0.5) {
      const benhTN = {
        benhAnId: `BA${String(i).padStart(5, '0')}`,
        hoTen,
        ngaySinh,
        gioiTinh,
        danTocId: randomFrom(CATEGORIES.danToc),
        maDinhDanhCaNhan: randomCCCD(),
        sdt: randomPhone(),
        ngheNghiep: randomFrom(CATEGORIES.ngheNghiep),
        cityId: randomFrom(CATEGORIES.tinh),
        coSoDieuTri: randomFrom(CATEGORIES.coSoDieuTri),
        cityIdCSDT: randomFrom(CATEGORIES.tinh),
        chanDoanBenh: randomFrom(CATEGORIES.chanDoanBenh),
        phanDoBenh: randomFrom(CATEGORIES.phanDoBenh),
        thongTinDieuTri: randomFrom(['Không hỗ trợ hô hấp', 'Thở oxy', 'Thở máy', 'Điều trị nội trú']),
        phanLoaiChanDoan: randomFrom(CATEGORIES.phanLoaiChanDoan),
        tinhTrangTiem: randomFrom(CATEGORIES.tinhTrangTiemChung),
        hinhThucDieuTri: randomFrom(CATEGORIES.hinhThucDieuTri),
        donViDieuTra: randomFrom(CATEGORIES.donViDieuTra),
        ngayKhoiPhat: randomDate(new Date(2024, 0, 1), new Date(2026, 5, 1)),
        ngayNhapVien: randomDate(new Date(2024, 0, 1), new Date(2026, 5, 1)),
        ngayBaoCao: randomDate(new Date(2024, 0, 1), new Date(2026, 5, 1)),
        nguoiBaoCao: `${randomFrom(HO)} ${randomFrom(TEN_DEM)} ${randomFrom(TEN)}`,
        sdtNguoiBaoCao: randomPhone(),
        ngayTao: new Date().toISOString()
      };
      
      await db.collection('benhTruyenNhiem').add(benhTN);
    }
    
    if (i % 10 === 0) {
      console.log(`   ✅ Đã tạo ${i}/50 bệnh nhân`);
    }
  }
  
  console.log('\n✅ Đã tạo xong 50 bệnh nhân!\n');
}

// ═══════════════════════════════════════════════════════════════════════════
// MAIN
// ═══════════════════════════════════════════════════════════════════════════

async function main() {
  console.log('\n╔════════════════════════════════════════════════════════════════╗');
  console.log('║         POPULATE DATABASE - TẠO DỮ LIỆU ĐẦY ĐỦ                ║');
  console.log('╚════════════════════════════════════════════════════════════════╝\n');
  
  try {
    await createCategories();
    await createPatients();
    
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
