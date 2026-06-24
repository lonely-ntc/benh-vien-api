/**
 * Script to seed category data into Firebase Firestore
 * Run: node seed_categories.js
 */

import admin from 'firebase-admin';
import { readFileSync } from 'fs';

// Load service account
const serviceAccount = JSON.parse(
  readFileSync('./service-account.json', 'utf8')
);

// Initialize Firebase Admin
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

// Category data with actual API IDs
const categories = {
  GioiTinh: [
    { id: 262, name: 'Nữ' },
    { id: 263, name: 'Nam' }
  ],

  CoKhong: [
    { id: 264, name: 'Có' },
    { id: 265, name: 'Không' }
  ],

  TinhTrangTiemChung: [
    { id: 11134, name: 'Có' },
    { id: 11135, name: 'Không' },
    { id: 11137, name: 'Không rõ' }
  ],

  NgheNghiep: [
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
    { id: 11214, name: 'Ngoại kiều' },
    { id: 11215, name: 'Việt kiều' },
    { id: 11216, name: 'Hưu trí' },
    { id: 11562, name: 'Trẻ 15 tuổi không đi học' },
    { id: 11563, name: 'Trí thức' },
    { id: 11565, name: 'Bác sĩ' },
    { id: 11566, name: 'Còn nhỏ' },
    { id: 11567, name: 'Các tổ chức xã hội Đảng, đoàn thể' },
    { id: 11568, name: 'Thất nghiệp' },
    { id: 11569, name: 'Nhân dân' },
    { id: 11570, name: 'Công nhân quốc phòng' },
    { id: 11571, name: 'Thân nhân sĩ quan' },
    { id: 11572, name: 'Hộ nghèo' },
    { id: 11573, name: 'Nội trợ' },
    { id: 11574, name: 'Nhân viên văn phòng' },
    { id: 11575, name: 'Bưu điện' },
    { id: 11576, name: 'Giáo dục đào tạo' },
    { id: 11577, name: 'Quản lý nhà nước' },
    { id: 11578, name: 'An ninh quốc phòng' },
    { id: 11579, name: 'Dịch vụ công cộng' },
    { id: 11580, name: 'Dịch vụ gia đình' },
    { id: 11581, name: 'Dịch vụ (trừ dịch vụ gia đình và dịch vụ công cộng)' },
    { id: 11582, name: 'Thương mại' },
    { id: 11583, name: 'Giao thông vận tải' },
    { id: 11584, name: 'Xây dựng' },
    { id: 11585, name: 'Nông, lâm nghiệp, chăn nuôi, đánh cá' },
    { id: 11586, name: 'Bộ đội biên phòng' },
    { id: 11587, name: 'Công nhân xây dựng' },
    { id: 11588, name: 'Làm rẫy' },
    { id: 11589, name: 'Kiểm lâm' },
    { id: 11590, name: 'Làm thuê theo mùa' },
    { id: 11591, name: 'Người đi rừng' },
    { id: 11592, name: 'Công nghiệp, tiểu thủ công nghiệp' },
    { id: 11593, name: 'Khác' }
  ],

  DanToc: [
    { id: 15, name: 'Kinh' }, { id: 16, name: 'Tày' }, { id: 17, name: 'Thái' },
    { id: 18, name: 'Hoa' }, { id: 19, name: 'Khme' }, { id: 20, name: 'Mường' },
    { id: 21, name: 'Nùng' }, { id: 22, name: 'Hán' }, { id: 23, name: 'Dao' },
    { id: 24, name: 'Gia rai' }, { id: 25, name: 'Cao lan' }, { id: 26, name: 'Ê đê' },
    { id: 27, name: 'Ba na' }, { id: 28, name: 'Xơ đăng' }, { id: 29, name: 'Sán Chay' },
    { id: 30, name: 'Cơ ho' }, { id: 31, name: 'Chăm' }, { id: 32, name: 'Sán chỉ' },
    { id: 33, name: 'Hrê' }, { id: 34, name: 'M nông' }, { id: 35, name: 'Raglai' },
    { id: 36, name: 'Xtiêng' }, { id: 37, name: 'Bru (Khùa)' }, { id: 38, name: 'Thổ' },
    { id: 39, name: 'Giấy' }, { id: 40, name: 'Cơ Tu' }, { id: 41, name: 'Giẻ Triêng' },
    { id: 42, name: 'Mạ' }, { id: 43, name: 'Khơ mú' }, { id: 44, name: 'Co (Cùa)' },
    { id: 45, name: 'Tà ôi' }, { id: 46, name: 'Chơ-ro' }, { id: 47, name: 'Kháng' },
    { id: 48, name: 'Xinh mun' }, { id: 49, name: 'Hà nhì' }, { id: 50, name: 'Chu ru' },
    { id: 51, name: 'Lào' }, { id: 52, name: 'La chí' }, { id: 53, name: 'La ha' },
    { id: 54, name: 'Phù lá' }, { id: 55, name: 'La hụ' }, { id: 56, name: 'Lự' },
    { id: 57, name: 'Lô Lô' }, { id: 58, name: 'Cà Doòng' }, { id: 59, name: 'Mảng' },
    { id: 60, name: 'Pà thẻn' }, { id: 61, name: 'Cờ lao' }, { id: 62, name: 'Cống' },
    { id: 63, name: 'Bố Y' }, { id: 64, name: 'Si la' }, { id: 65, name: 'Pu piéo' },
    { id: 66, name: 'Brâu' }, { id: 67, name: 'Ơ đu' }, { id: 68, name: 'Rơ măm' },
    { id: 1017, name: 'Tày Poọng' }, { id: 1018, name: 'Thù lao' }, { id: 1019, name: 'Pa dí' },
    { id: 1020, name: 'Cao lan' }, { id: 1021, name: 'Quý châu(Pu nà)' }, { id: 1022, name: 'Thuỷ' },
    { id: 1023, name: 'Vân kiều' }, { id: 1024, name: 'Pa cô' }, { id: 1025, name: 'Ba hy' },
    { id: 1026, name: 'Tù riềng' }, { id: 1027, name: 'Hà lăng' }, { id: 1028, name: 'Treng' },
    { id: 1029, name: 'Xil (Chil)' }, { id: 1031, name: 'Hroi' }, { id: 1032, name: 'Tu dí' },
    { id: 1033, name: 'Nước ngoài' }, { id: 1034, name: 'Kor' }, { id: 1035, name: 'Chứt' },
    { id: 1036, name: 'Krê' }, { id: 1037, name: 'Mông' }, { id: 1038, name: 'Sán dìu' },
    { id: 1039, name: 'Ve' }, { id: 1040, name: 'Khác trong nước' }
  ],

  DieuTri: [
    { id: 11143, name: 'Thở oxy' },
    { id: 11144, name: 'Thở NCPAP' },
    { id: 11145, name: 'Thở máy' },
    { id: 11146, name: 'IVIG' },
    { id: 11203, name: 'Không hỗ trợ hô hấp' }
  ],

  HinhThucDieuTri: [
    { id: 11128, name: 'Điều trị nội trú' },
    { id: 11129, name: 'Điều trị ngoại trú' },
    { id: 11130, name: 'Ra viện' },
    { id: 11131, name: 'Tử vong' },
    { id: 11132, name: 'Chuyển viện' },
    { id: 11133, name: 'Tình trạng khác' },
    { id: 11544, name: 'Nặng xin về' }
  ],

  PhanLoaiChanDoan: [
    { id: 11545, name: 'Có thể' },
    { id: 11546, name: 'Nghi ngờ (lâm sàng)' },
    { id: 11547, name: 'Xác định phòng xét nghiệm' }
  ],

  LoaiBenhPham: [
    { id: 11548, name: 'Máu' },
    { id: 11549, name: 'Phân' },
    { id: 11550, name: 'Dịch ngoáy họng' },
    { id: 11551, name: 'Dịch tỵ hầu' },
    { id: 11552, name: 'Dịch sang thương da' },
    { id: 11553, name: 'Dịch não tủy' },
    { id: 11554, name: 'Nước tiểu' }
  ],

  LoaiXetNghiem: [
    { id: 11192, name: 'Test nhanh' },
    { id: 11193, name: 'Mac-elisa' },
    { id: 11194, name: 'PCR' },
    { id: 11195, name: 'Soi' },
    { id: 11555, name: 'Cấy' }
  ],

  KetQuaXetNghiem: [
    { id: 11140, name: 'Dương tính' },
    { id: 11141, name: 'Âm tính' },
    { id: 11142, name: 'Chưa có kết quả' }
  ],

  PhanDoBenh: [
    { id: 1, name: 'Sốt xuất huyết Dengue' },
    { id: 2, name: 'Sốt xuất huyết Dengue có dấu hiệu cảnh báo' },
    { id: 3, name: 'Sốt xuất huyết Dengue nặng' },
    { id: 4, name: 'Độ 1' },
    { id: 5, name: 'Độ 2a' },
    { id: 6, name: 'Độ 2b' },
    { id: 7, name: 'Độ 3' },
    { id: 8, name: 'Độ 4' }
  ],

  Tinh: [
    { id: 1, name: 'Thành phố Hà Nội' },
    { id: 3, name: 'Tỉnh Cao Bằng' },
    { id: 5, name: 'Tỉnh Tuyên Quang' },
    { id: 6, name: 'Tỉnh Lào Cai' },
    { id: 7, name: 'Tỉnh Điện Biên' },
    { id: 8, name: 'Tỉnh Lai Châu' },
    { id: 9, name: 'Tỉnh Sơn La' },
    { id: 12, name: 'Tỉnh Thái Nguyên' },
    { id: 13, name: 'Tỉnh Lạng Sơn' },
    { id: 14, name: 'Tỉnh Quảng Ninh' },
    { id: 16, name: 'Tỉnh Phú Thọ' },
    { id: 18, name: 'Tỉnh Bắc Ninh' },
    { id: 20, name: 'Thành phố Hải Phòng' },
    { id: 21, name: 'Tỉnh Hưng Yên' },
    { id: 25, name: 'Tỉnh Ninh Bình' },
    { id: 26, name: 'Tỉnh Thanh Hóa' },
    { id: 27, name: 'Tỉnh Nghệ An' },
    { id: 28, name: 'Tỉnh Hà Tĩnh' },
    { id: 30, name: 'Tỉnh Quảng Trị' },
    { id: 31, name: 'Thành phố Huế' },
    { id: 32, name: 'Thành phố Đà Nẵng' },
    { id: 34, name: 'Tỉnh Quảng Ngãi' },
    { id: 37, name: 'Tỉnh Khánh Hòa' },
    { id: 41, name: 'Tỉnh Gia Lai' },
    { id: 42, name: 'Tỉnh Đắk Lắk' },
    { id: 44, name: 'Tỉnh Lâm Đồng' },
    { id: 46, name: 'Tỉnh Tây Ninh' },
    { id: 48, name: 'Tỉnh Đồng Nai' },
    { id: 50, name: 'Thành Phố Hồ Chí Minh' },
    { id: 55, name: 'Tỉnh Vĩnh Long' },
    { id: 56, name: 'Tỉnh Đồng Tháp' },
    { id: 57, name: 'Tỉnh An Giang' },
    { id: 59, name: 'Thành phố Cần Thơ' },
    { id: 63, name: 'Tỉnh Cà Mau' }
  ],

  BenhTruyenNhiem: [
    { id: 1, name: 'Bại liệt' },
    { id: 2, name: 'Bạch hầu' },
    { id: 3, name: 'Bệnh do liên cầu lợn ở người' },
    { id: 4, name: 'Cúm A(H5N1)' },
    { id: 5, name: 'Cúm A(H7N9)' },
    { id: 6, name: 'Dịch hạch' },
    { id: 7, name: 'Ê-bô-la (Ebolla)' },
    { id: 8, name: 'Lát-sa (Lassa)' },
    { id: 9, name: 'Mác-bớt (Marburg)' },
    { id: 10, name: 'Rubella (Rubeon)' },
    { id: 11, name: 'Sốt Tây sông Nin' },
    { id: 12, name: 'Sốt vàng' },
    { id: 13, name: 'Sốt xuất huyết Dengue' },
    { id: 14, name: 'Sởi' },
    { id: 15, name: 'Tả' },
    { id: 16, name: 'Tay - chân - miệng' },
    { id: 17, name: 'Than' },
    { id: 18, name: 'Viêm đường hô hấp Trung đông do corona vi rút (MERS-CoV)' },
    { id: 19, name: 'Nhiễm trùng do não mô cầu' },
    { id: 20, name: 'Zika' },
    { id: 21, name: 'Covid-19' },
    { id: 23, name: 'Mpox' },
    { id: 24, name: 'Bệnh truyền nhiễm nguy hiểm mới nổi và bệnh mới phát sinh chưa rõ tác nhân gây bệnh' },
    { id: 25, name: 'Dại' },
    { id: 26, name: 'Ho gà' },
    { id: 27, name: 'Liệt mềm cấp nghi bại liệt' },
    { id: 28, name: 'Lao phổi' },
    { id: 29, name: 'Sốt rét' },
    { id: 34, name: 'Thương hàn' },
    { id: 35, name: 'Uốn ván sơ sinh' },
    { id: 36, name: 'Uốn ván khác' },
    { id: 38, name: 'Viêm gan vi rút A' },
    { id: 39, name: 'Viêm gan vi rút B' },
    { id: 40, name: 'Viêm gan vi rút C' },
    { id: 41, name: 'Viêm não Nhật Bản' },
    { id: 42, name: 'Viêm não vi rút khác' },
    { id: 45, name: 'Xoắn khuẩn vàng da (Leptospira)' },
    { id: 46, name: 'Bệnh do vi rút Adeno' },
    { id: 50, name: 'Cúm' },
    { id: 51, name: 'Lỵ amíp' },
    { id: 52, name: 'Lỵ trực trùng' },
    { id: 53, name: 'Quai bị' },
    { id: 54, name: 'Thủy đậu' },
    { id: 55, name: 'Tiêu chảy' },
    { id: 56, name: 'Viêm gan vi rút khác (hoặc không có định típ vi rút)' },
    { id: 57, name: 'Thay đổi chẩn đoán, bệnh không có trong danh mục' },
    { id: 58, name: 'Chikungunya' },
    { id: 59, name: 'Bệnh do vi rút Nipah' }
  ],

  BenhNen: [
    { id: 11217, name: 'Lao hô hấp, có khẳng định về vi khuẩn học và mô học' },
    { id: 11218, name: 'Lao đường hô hấp, không khẳng định về vi khuẩn học hoặc mô học' },
    { id: 11221, name: 'Bệnh Phong' },
    { id: 11222, name: 'Bệnh do virus suy giảm miễn dịch ở người (HIV) dẫn đến các bệnh nhiễm trùng và kí sinh trùng' },
    { id: 11223, name: 'HIV/AIDS' },
    { id: 11245, name: 'Bạch cầu cấp dòng lympho' },
    { id: 11246, name: 'Bạch cầu cấp dòng tủy' },
    { id: 11251, name: 'Bệnh tan máu bẩm sinh (Thalassemia)' },
    { id: 11255, name: 'Tan máu tự miễn' },
    { id: 11260, name: 'Suy tủy' },
    { id: 11261, name: 'Thiếu yếu tố VIII di truyền (Hemophilia A)' },
    { id: 11262, name: 'Thiếu yếu tố IX di truyền (Hemophilia B)' },
    { id: 11268, name: 'Xuất huyết giảm tiểu cầu miễn dịch' },
    { id: 11276, name: 'Suy tuyến giáp' },
    { id: 11278, name: 'Basedow' },
    { id: 11282, name: 'Bệnh đái tháo đường type 1' },
    { id: 11283, name: 'Cường insulin' },
    { id: 11291, name: 'Suy dinh dưỡng (thể Kwashiorkor)' },
    { id: 11292, name: 'Suy dinh dưỡng (thể Marasmus)' },
    { id: 11294, name: 'Suy dinh dưỡng nặng' },
    { id: 11298, name: 'Bệnh thừa cân béo phì' },
    { id: 11316, name: 'Động kinh' },
    { id: 11317, name: 'Trạng thái động kinh' },
    { id: 11318, name: 'Hội chứng Guillain Barre' },
    { id: 11319, name: 'Bệnh nhược cơ' },
    { id: 11321, name: 'Bại não trẻ em' },
    { id: 11323, name: 'Tăng huyết áp vô căn (nguyên phát)' },
    { id: 11326, name: 'Bệnh thiếu máu cục bộ cơ tim' },
    { id: 11327, name: 'Bệnh phổi tắc nghẽn mạn tính' },
    { id: 11329, name: 'Tăng áp động mạch phổi nguyên phát' },
    { id: 11337, name: 'Viêm cơ tim cấp' },
    { id: 11338, name: 'Bệnh cơ tim' },
    { id: 11345, name: 'Suy tim' },
    { id: 11347, name: 'Nhồi máu não' },
    { id: 11357, name: 'Hen phế quản' },
    { id: 11358, name: 'Hội chứng suy hô hấp tiến triển' },
    { id: 11362, name: 'Bệnh Crohn' },
    { id: 11371, name: 'Xơ gan' },
    { id: 11386, name: 'Lupus ban đỏ hệ thống' },
    { id: 11395, name: 'Hội chứng thận hư' },
    { id: 11401, name: 'Suy thận cấp' },
    { id: 11402, name: 'Bệnh thận mạn' },
    { id: 11405, name: 'Suy thận mạn' },
    { id: 11431, name: 'Thông liên thất' },
    { id: 11432, name: 'Thông liên nhĩ' },
    { id: 11433, name: 'Tứ chứng Fallot' },
    { id: 11448, name: 'Còn ống động mạch' },
    { id: 11467, name: 'Bệnh Hirschsprung' },
    { id: 11468, name: 'Teo đường mật' },
    { id: 11475, name: 'Hội chứng Down' },
    { id: 11476, name: 'Hội chứng Tuner' },
    { id: 11481, name: 'Bệnh Hemophillia' },
    { id: 11485, name: 'Đái tháo đường phụ thuộc insuline' },
    { id: 11486, name: 'Đái tháo đường không phụ thuộc insuline' },
    { id: 11488, name: 'Bại não' },
    { id: 11496, name: 'Lao (các loại)' },
    { id: 11497, name: 'Lupus ban đỏ' },
    { id: 11499, name: 'Suy giảm miễn dịch' },
    { id: 11500, name: 'Tăng huyết áp có biến chứng' },
    { id: 11518, name: 'Ung thư *' },
    { id: 11561, name: 'Không có bệnh nền' }
  ]
};

async function seedCategories() {
  console.log('🌱 Starting category seeding...\n');

  for (const [collectionName, items] of Object.entries(categories)) {
    console.log(`📦 Seeding collection: ${collectionName}`);
    
    const batch = db.batch();
    let count = 0;

    for (const item of items) {
      const docRef = db.collection(collectionName).doc(item.id.toString());
      batch.set(docRef, {
        id: item.id,
        name: item.name,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        updatedAt: admin.firestore.FieldValue.serverTimestamp()
      });
      count++;
    }

    await batch.commit();
    console.log(`   ✅ Added ${count} items to ${collectionName}`);
  }

  console.log('\n🎉 Category seeding completed successfully!');
}

// Run the seeding
seedCategories()
  .then(() => process.exit(0))
  .catch(error => {
    console.error('❌ Error seeding categories:', error);
    process.exit(1);
  });
