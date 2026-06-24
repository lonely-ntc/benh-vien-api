/**
 * Script tạo đầy đủ danh mục cho database
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
// DANH MỤC
// ═══════════════════════════════════════════════════════════════════════════

const CATEGORIES = {
  gioiTinh: [
    { id: 263, name: 'Nam' },
    { id: 264, name: 'Nữ' },
    { id: 265, name: 'Khác' }
  ],
  
  danToc: [
    { id: 1, name: 'Kinh' },
    { id: 2, name: 'Tày' },
    { id: 3, name: 'Thái' },
    { id: 4, name: 'Mường' },
    { id: 5, name: 'Khmer' },
    { id: 6, name: 'Hoa' },
    { id: 7, name: 'Nùng' },
    { id: 8, name: 'H\'Mông' },
    { id: 9, name: 'Dao' },
    { id: 10, name: 'Gia Rai' }
  ],
  
  ngheNghiep: [
    { id: 11590, name: 'Học sinh / Sinh viên' },
    { id: 11591, name: 'Nông dân' },
    { id: 11592, name: 'Công nhân' },
    { id: 11593, name: 'Kinh doanh / Buôn bán' },
    { id: 11594, name: 'Nội trợ' },
    { id: 11595, name: 'Giáo viên' },
    { id: 11596, name: 'Nhân viên văn phòng' },
    { id: 11597, name: 'Y tế' },
    { id: 11598, name: 'Công an / Quân đội' },
    { id: 11599, name: 'Khác' }
  ],
  
  coKhong: [
    { id: 11134, name: 'Có' },
    { id: 11135, name: 'Không' }
  ],
  
  dieuTri: [
    { id: 11200, name: 'Nội trú' },
    { id: 11201, name: 'Ngoại trú' },
    { id: 11202, name: 'Cách ly' },
    { id: 11203, name: 'Theo dõi' }
  ],
  
  hinhThucDieuTri: [
    { id: 11128, name: 'Nội khoa' },
    { id: 11129, name: 'Ngoại khoa' },
    { id: 11130, name: 'Phục hồi chức năng' },
    { id: 11131, name: 'Hóa trị' },
    { id: 11132, name: 'Xạ trị' },
    { id: 11133, name: 'Điều trị tại nhà' }
  ],
  
  benhNen: [
    { id: 11560, name: 'Có' },
    { id: 11561, name: 'Không' },
    { id: 11562, name: 'Tiểu đường' },
    { id: 11563, name: 'Cao huyết áp' },
    { id: 11564, name: 'Tim mạch' },
    { id: 11565, name: 'Hen suyễn' }
  ],
  
  phanLoaiChanDoan: [
    { id: 11545, name: 'Có thể' },
    { id: 11546, name: 'Nghi ngờ' },
    { id: 11547, name: 'Xác định' }
  ],
  
  loaiBenhPham: [
    { id: 11550, name: 'Máu' },
    { id: 11551, name: 'Dịch mũi họng' },
    { id: 11552, name: 'Phân' },
    { id: 11553, name: 'Nước tiểu' },
    { id: 11554, name: 'Dịch não tủy' }
  ],
  
  loaiXetNghiem: [
    { id: 11548, name: 'PCR' },
    { id: 11549, name: 'Test nhanh' },
    { id: 11557, name: 'Xét nghiệm máu' },
    { id: 11558, name: 'X-quang' },
    { id: 11559, name: 'CT scan' }
  ],
  
  ketQuaXetNghiem: [
    { id: 11140, name: 'Dương tính' },
    { id: 11141, name: 'Âm tính' },
    { id: 11142, name: 'Nghi ngờ' },
    { id: 11143, name: 'Chưa có kết quả' }
  ],
  
  tinhTrangTiemChung: [
    { id: 11134, name: 'Chưa tiêm' },
    { id: 11135, name: 'Tiêm 1 mũi' },
    { id: 11136, name: 'Tiêm 2 mũi' },
    { id: 11137, name: 'Tiêm 3 mũi' },
    { id: 11138, name: 'Tiêm đủ liều' }
  ],
  
  chanDoanBenh: [
    { id: 20, name: 'Cúm A/H1N1' },
    { id: 21, name: 'Covid-19' },
    { id: 22, name: 'Sốt xuất huyết' },
    { id: 23, name: 'Tay chân miệng' },
    { id: 24, name: 'Viêm gan A' },
    { id: 25, name: 'Viêm gan B' },
    { id: 26, name: 'Lao phổi' },
    { id: 27, name: 'Sốt rét' },
    { id: 28, name: 'Tiêu chảy cấp' },
    { id: 29, name: 'Thủy đậu' }
  ],
  
  phanDoBenh: [
    { id: 1, name: 'Nhẹ' },
    { id: 2, name: 'Trung bình' },
    { id: 3, name: 'Nặng' },
    { id: 4, name: 'Nguy kịch' }
  ],
  
  tinh: [
    { id: 1, name: 'Hà Nội' },
    { id: 50, name: 'TP. Hồ Chí Minh' },
    { id: 48, name: 'Đà Nẵng' },
    { id: 4, name: 'Hải Phòng' },
    { id: 79, name: 'TP. Cần Thơ' },
    { id: 92, name: 'An Giang' },
    { id: 74, name: 'Bình Dương' },
    { id: 75, name: 'Đồng Nai' },
    { id: 83, name: 'Bến Tre' },
    { id: 89, name: 'Long An' }
  ],
  
  coSoBaoCao: [
    { id: 74001, name: 'Bệnh viện Chợ Rẫy' },
    { id: 74002, name: 'Bệnh viện Bình Dân' },
    { id: 74003, name: 'Bệnh viện Nhi Đồng 1' },
    { id: 74004, name: 'Bệnh viện Từ Dũ' },
    { id: 74005, name: 'Bệnh viện Hùng Vương' }
  ],
  
  coSoDieuTri: [
    { id: 74001, name: 'Bệnh viện Chợ Rẫy' },
    { id: 74002, name: 'Bệnh viện Bình Dân' },
    { id: 74003, name: 'Bệnh viện Nhi Đồng 1' },
    { id: 74004, name: 'Bệnh viện Từ Dũ' },
    { id: 74005, name: 'Bệnh viện Hùng Vương' }
  ],
  
  donViDieuTra: [
    { id: 74001, name: 'Bệnh viện Chợ Rẫy' },
    { id: 74002, name: 'Bệnh viện Bình Dân' },
    { id: 74003, name: 'Bệnh viện Nhi Đồng 1' },
    { id: 74004, name: 'Bệnh viện Từ Dũ' },
    { id: 74005, name: 'Bệnh viện Hùng Vương' },
    { id: 74006, name: 'Trung tâm Y tế Quận 1' },
    { id: 74007, name: 'Trung tâm Y tế Quận 3' },
    { id: 74008, name: 'Trung tâm Y tế Quận 5' },
    { id: 74009, name: 'Trung tâm Y tế Quận 10' },
    { id: 74010, name: 'Trung tâm Y tế Bình Thạnh' }
  ]
};

// ═══════════════════════════════════════════════════════════════════════════
// MAIN
// ═══════════════════════════════════════════════════════════════════════════

async function main() {
  console.log('\n╔════════════════════════════════════════════════════════════════╗');
  console.log('║              TẠO DANH MỤC CHO DATABASE                         ║');
  console.log('╚════════════════════════════════════════════════════════════════╝\n');
  
  try {
    for (const [collection, items] of Object.entries(CATEGORIES)) {
      console.log(`📝 Đang tạo ${collection}...`);
      
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
      
      console.log(`   ✅ Đã tạo ${items.length} items cho ${collection}\n`);
    }
    
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
