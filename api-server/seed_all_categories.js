import admin from 'firebase-admin';
import { readFileSync } from 'fs';

// Initialize Firebase Admin
const serviceAccount = JSON.parse(readFileSync('./service-account.json', 'utf8'));
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

// ─────────────────────────────────────────────────────────────────────────────
// DỮ LIỆU DANH MỤC TỪ API
// ─────────────────────────────────────────────────────────────────────────────

const categories = {
  GioiTinh: [
    { Id: 262, Name: 'Nữ' },
    { Id: 263, Name: 'Nam' }
  ],

  CoKhong: [
    { Id: 264, Name: 'Có' },
    { Id: 265, Name: 'Không' }
  ],

  TinhTrangTiemChung: [
    { Id: 11134, Name: 'Có' },
    { Id: 11135, Name: 'Không' },
    { Id: 11137, Name: 'Không rõ' }
  ],

  DanToc: [
    { Id: 15, Name: 'Kinh' }, { Id: 16, Name: 'Tày' }, { Id: 17, Name: 'Thái' },
    { Id: 18, Name: 'Hoa' }, { Id: 19, Name: 'Khme' }, { Id: 20, Name: 'Mường' },
    { Id: 21, Name: 'Nùng' }, { Id: 22, Name: 'Hán' }, { Id: 23, Name: 'Dao' },
    { Id: 24, Name: 'Gia rai' }, { Id: 25, Name: 'Cao lan' }, { Id: 26, Name: 'Ê đê' },
    { Id: 27, Name: 'Ba na' }, { Id: 28, Name: 'Xơ đăng' }, { Id: 29, Name: 'Sán Chay' },
    { Id: 30, Name: 'Cơ ho' }, { Id: 31, Name: 'Chăm' }, { Id: 32, Name: 'Sán chỉ' },
    { Id: 33, Name: 'Hrê' }, { Id: 34, Name: 'M nông' }, { Id: 35, Name: 'Raglai' },
    { Id: 36, Name: 'Xtiêng' }, { Id: 37, Name: 'Bru (Khùa)' }, { Id: 38, Name: 'Thổ' },
    { Id: 39, Name: 'Giấy' }, { Id: 40, Name: 'Cơ Tu' }, { Id: 41, Name: 'Giẻ Triêng' },
    { Id: 42, Name: 'Mạ' }, { Id: 43, Name: 'Khơ mú' }, { Id: 44, Name: 'Co (Cùa)' },
    { Id: 45, Name: 'Tà ôi' }, { Id: 46, Name: 'Chơ-ro' }, { Id: 47, Name: 'Kháng' },
    { Id: 48, Name: 'Xinh mun' }, { Id: 49, Name: 'Hà nhì' }, { Id: 50, Name: 'Chu ru' },
    { Id: 51, Name: 'Lào' }, { Id: 52, Name: 'La chí' }, { Id: 53, Name: 'La ha' },
    { Id: 54, Name: 'Phù lá' }, { Id: 55, Name: 'La hụ' }, { Id: 56, Name: 'Lự' },
    { Id: 57, Name: 'Lô Lô' }, { Id: 58, Name: 'Cà Doòng' }, { Id: 59, Name: 'Mảng' },
    { Id: 60, Name: 'Pà thẻn' }, { Id: 61, Name: 'Cờ lao' }, { Id: 62, Name: 'Cống' },
    { Id: 63, Name: 'Bố Y' }, { Id: 64, Name: 'Si la' }, { Id: 65, Name: 'Pu piéo' },
    { Id: 66, Name: 'Brâu' }, { Id: 67, Name: 'Ơ đu' }, { Id: 68, Name: 'Rơ măm' },
    { Id: 1017, Name: 'Tày Poọng' }, { Id: 1018, Name: 'Thù lao' }, { Id: 1019, Name: 'Pa dí' },
    { Id: 1020, Name: 'Cao lan' }, { Id: 1021, Name: 'Quý châu(Pu nà)' }, { Id: 1022, Name: 'Thuỷ' },
    { Id: 1023, Name: 'Vân kiều' }, { Id: 1024, Name: 'Pa cô' }, { Id: 1025, Name: 'Ba hy' },
    { Id: 1026, Name: 'Tù riềng' }, { Id: 1027, Name: 'Hà lăng' }, { Id: 1028, Name: 'Treng' },
    { Id: 1029, Name: 'Xil (Chil)' }, { Id: 1031, Name: 'Hroi' }, { Id: 1032, Name: 'Tu dí' },
    { Id: 1033, Name: 'Nước ngoài' }, { Id: 1034, Name: 'Kor' }, { Id: 1035, Name: 'Chứt' },
    { Id: 1036, Name: 'Krê' }, { Id: 1037, Name: 'Mông' }, { Id: 1038, Name: 'Sán dìu' },
    { Id: 1039, Name: 'Ve' }, { Id: 1040, Name: 'Khác trong nước' }
  ],

  NgheNghiep: [
    { Id: 11204, Name: 'Trẻ < 6 tuổi đi học, <15 tuổi không đi học' },
    { Id: 11205, Name: 'Sinh viên, học sinh' },
    { Id: 11206, Name: 'Hưu và > 60 tuổi' },
    { Id: 11207, Name: 'Lực lượng vũ trang' },
    { Id: 11208, Name: 'Tri thức' },
    { Id: 11209, Name: 'Hành chính, sự nghiệp' },
    { Id: 11210, Name: 'Công nhân' },
    { Id: 11211, Name: 'Y tế' },
    { Id: 11212, Name: 'Dịch vụ' },
    { Id: 11213, Name: 'Nông dân' },
    { Id: 11214, Name: 'Ngoại kiều' },
    { Id: 11215, Name: 'Việt kiều' },
    { Id: 11216, Name: 'Hưu trí' },
    { Id: 11562, Name: 'Trẻ 15 tuổi không đi học\r\n' },
    { Id: 11563, Name: 'Trí thức' },
    { Id: 11565, Name: 'Bác sĩ' },
    { Id: 11566, Name: 'Còn nhỏ' },
    { Id: 11567, Name: 'Các tổ chức xã hội Đảng, đoàn thể' },
    { Id: 11568, Name: 'Thất nghiệp' },
    { Id: 11569, Name: 'Nhân dân' },
    { Id: 11570, Name: 'Công nhân quốc phòng' },
    { Id: 11571, Name: 'Thân nhân sĩ quan' },
    { Id: 11572, Name: 'Hộ nghèo' },
    { Id: 11573, Name: 'Nội trợ' },
    { Id: 11574, Name: 'Nhân viên văn phòng' },
    { Id: 11575, Name: 'Bưu điện' },
    { Id: 11576, Name: 'Giáo dục đào tạo' },
    { Id: 11577, Name: 'Quản lý nhà nước' },
    { Id: 11578, Name: 'An ninh quốc phòng' },
    { Id: 11579, Name: 'Dịch vụ công cộng' },
    { Id: 11580, Name: 'Dịch vụ gia đình' },
    { Id: 11581, Name: 'Dịch vụ (trừ dịch vụ gia đình và dịch vụ công cộng)' },
    { Id: 11582, Name: 'Thương mại' },
    { Id: 11583, Name: 'Giao thông vận tải' },
    { Id: 11584, Name: 'Xây dựng' },
    { Id: 11585, Name: 'Nông, lâm nghiệp, chăn nuôi, đánh cá' },
    { Id: 11586, Name: 'Bộ đội biên phòng' },
    { Id: 11587, Name: 'Công nhân xây dựng' },
    { Id: 11588, Name: 'Làm rẫy' },
    { Id: 11589, Name: 'Kiểm lâm' },
    { Id: 11590, Name: 'Làm thuê theo mùa' },
    { Id: 11591, Name: 'Người đi rừng' },
    { Id: 11592, Name: 'Công nghiệp, tiểu thủ công nghiệp' },
    { Id: 11593, Name: 'Khác' }
  ],

  DieuTri: [
    { Id: 11143, Name: 'Thở oxy' },
    { Id: 11144, Name: 'Thở NCPAP' },
    { Id: 11145, Name: 'Thở máy' },
    { Id: 11146, Name: 'IVIG' },
    { Id: 11203, Name: 'Không hỗ trợ hô hấp' }
  ],

  HinhThucDieuTri: [
    { Id: 11128, Name: 'Điều trị nội trú' },
    { Id: 11129, Name: 'Điều trị ngoại trú' },
    { Id: 11130, Name: 'Ra viện' },
    { Id: 11131, Name: 'Tử vong' },
    { Id: 11132, Name: 'Chuyển viện' },
    { Id: 11133, Name: 'Tình trạng khác' },
    { Id: 11544, Name: 'Nặng xin về' }
  ],

  PhanLoaiChanDoan: [
    { Id: 11545, Name: 'Có thể' },
    { Id: 11546, Name: 'Nghi ngờ (lâm sàng)' },
    { Id: 11547, Name: 'Xác định phòng xét nghiệm' }
  ],

  LoaiBenhPham: [
    { Id: 11548, Name: 'Máu' },
    { Id: 11549, Name: 'Phân' },
    { Id: 11550, Name: 'Dịch ngoáy họng' },
    { Id: 11551, Name: 'Dịch tỵ hầu' },
    { Id: 11552, Name: 'Dịch sang thương da' },
    { Id: 11553, Name: 'Dịch não tủy' },
    { Id: 11554, Name: 'Nước tiểu' }
  ],

  LoaiXetNghiem: [
    { Id: 11192, Name: 'Test nhanh' },
    { Id: 11193, Name: 'Mac-elisa' },
    { Id: 11194, Name: 'PCR' },
    { Id: 11195, Name: 'Soi' },
    { Id: 11555, Name: 'Cấy' }
  ],

  KetQuaXetNghiem: [
    { Id: 11140, Name: 'Dương tính' },
    { Id: 11141, Name: 'Âm tính' },
    { Id: 11142, Name: 'Chưa có kết quả' }
  ],

  ChanDoanBenh: [
    { Id: 1, Name: 'Bại liệt' },
    { Id: 2, Name: 'Bạch hầu' },
    { Id: 3, Name: 'Bệnh do liên cầu lợn ở người' },
    { Id: 4, Name: 'Cúm A(H5N1)' },
    { Id: 5, Name: 'Cúm A(H7N9)' },
    { Id: 6, Name: 'Dịch hạch' },
    { Id: 7, Name: 'Ê-bô-la (Ebolla)' },
    { Id: 8, Name: 'Lát-sa (Lassa)' },
    { Id: 9, Name: 'Mác-bớt (Marburg)' },
    { Id: 10, Name: 'Rubella (Rubeon)' },
    { Id: 11, Name: 'Sốt Tây sông Nin' },
    { Id: 12, Name: 'Sốt vàng' },
    { Id: 13, Name: 'Sốt xuất huyết Dengue' },
    { Id: 14, Name: 'Sởi' },
    { Id: 15, Name: 'Tả' },
    { Id: 16, Name: 'Tay - chân - miệng' },
    { Id: 17, Name: 'Than' },
    { Id: 18, Name: 'Viêm đường hô hấp Trung đông do corona vi rút (MERS-CoV)' },
    { Id: 19, Name: 'Nhiễm trùng do não mô cầu' },
    { Id: 20, Name: 'Zika' },
    { Id: 21, Name: 'Covid-19' },
    { Id: 23, Name: 'Mpox' },
    { Id: 24, Name: 'Bệnh truyền nhiễm nguy hiểm mới nổi và bệnh mới phát sinh chưa rõ tác nhân gây bệnh' },
    { Id: 25, Name: 'Dại' },
    { Id: 26, Name: 'Ho gà' },
    { Id: 27, Name: 'Liệt mềm cấp nghi bại liệt' },
    { Id: 28, Name: 'Lao phổi' },
    { Id: 29, Name: 'Sốt rét' },
    { Id: 34, Name: 'Thương hàn' },
    { Id: 35, Name: 'Uốn ván sơ sinh' },
    { Id: 36, Name: 'Uốn ván khác' },
    { Id: 38, Name: 'Viêm gan vi rút A' },
    { Id: 39, Name: 'Viêm gan vi rút B' },
    { Id: 40, Name: 'Viêm gan vi rút C' },
    { Id: 41, Name: 'Viêm não Nhật Bản' },
    { Id: 42, Name: 'Viêm não vi rút khác' },
    { Id: 45, Name: 'Xoắn khuẩn vàng da (Leptospira)' },
    { Id: 46, Name: 'Bệnh do vi rút Adeno' },
    { Id: 50, Name: 'Cúm' },
    { Id: 51, Name: 'Lỵ amíp' },
    { Id: 52, Name: 'Lỵ trực trùng' },
    { Id: 53, Name: 'Quai bị' },
    { Id: 54, Name: 'Thủy đậu' },
    { Id: 55, Name: 'Tiêu chảy' },
    { Id: 56, Name: 'Viêm gan vi rút khác (hoặc không có định típ vi rút)' },
    { Id: 57, Name: 'Thay đổi chẩn đoán, bệnh không có trong danh mục' },
    { Id: 58, Name: 'Chikungunya' },
    { Id: 59, Name: 'Bệnh do vi rút Nipah' }
  ],

  PhanDoBenh: [
    { Id: 1, Name: 'Sốt xuất huyết Dengue', ChanDoanId: 13 },
    { Id: 2, Name: 'Sốt xuất huyết Dengue có dấu hiệu cảnh báo', ChanDoanId: 13 },
    { Id: 3, Name: 'Sốt xuất huyết Dengue nặng', ChanDoanId: 13 },
    { Id: 4, Name: 'Độ 1', ChanDoanId: 16 },
    { Id: 5, Name: 'Độ 2a', ChanDoanId: 16 },
    { Id: 6, Name: 'Độ 2b', ChanDoanId: 16 },
    { Id: 7, Name: 'Độ 3', ChanDoanId: 16 },
    { Id: 8, Name: 'Độ 4', ChanDoanId: 16 }
  ],

  Tinh: [
    { Id: 1, Name: 'Thành phố Hà Nội' },
    { Id: 2, Name: 'Tỉnh Hà Giang' },
    { Id: 3, Name: 'Tỉnh Cao Bằng' },
    { Id: 4, Name: 'Tỉnh Bắc Kạn' },
    { Id: 5, Name: 'Tỉnh Tuyên Quang' },
    { Id: 6, Name: 'Tỉnh Lào Cai' },
    { Id: 7, Name: 'Tỉnh Điện Biên' },
    { Id: 8, Name: 'Tỉnh Lai Châu' },
    { Id: 9, Name: 'Tỉnh Sơn La' },
    { Id: 10, Name: 'Tỉnh Yên Bái' },
    { Id: 11, Name: 'Tỉnh Hòa Bình' },
    { Id: 12, Name: 'Tỉnh Thái Nguyên' },
    { Id: 13, Name: 'Tỉnh Lạng Sơn' },
    { Id: 14, Name: 'Tỉnh Quảng Ninh' },
    { Id: 15, Name: 'Tỉnh Bắc Giang' },
    { Id: 16, Name: 'Tỉnh Phú Thọ' },
    { Id: 17, Name: 'Tỉnh Vĩnh Phúc' },
    { Id: 18, Name: 'Tỉnh Bắc Ninh' },
    { Id: 19, Name: 'Tỉnh Hải Dương' },
    { Id: 20, Name: 'Thành phố Hải Phòng' },
    { Id: 21, Name: 'Tỉnh Hưng Yên' },
    { Id: 22, Name: 'Tỉnh Thái Bình' },
    { Id: 23, Name: 'Tỉnh Hà Nam' },
    { Id: 24, Name: 'Tỉnh Nam Định' },
    { Id: 25, Name: 'Tỉnh Ninh Bình' },
    { Id: 26, Name: 'Tỉnh Thanh Hóa' },
    { Id: 27, Name: 'Tỉnh Nghệ An' },
    { Id: 28, Name: 'Tỉnh Hà Tĩnh' },
    { Id: 29, Name: 'Tỉnh Quảng Bình' },
    { Id: 30, Name: 'Tỉnh Quảng Trị' },
    { Id: 31, Name: 'Tỉnh Thừa Thiên Huế' },
    { Id: 32, Name: 'Thành phố Đà Nẵng' },
    { Id: 33, Name: 'Tỉnh Quảng Nam' },
    { Id: 34, Name: 'Tỉnh Quảng Ngãi' },
    { Id: 35, Name: 'Tỉnh Bình Định' },
    { Id: 36, Name: 'Tỉnh Phú Yên' },
    { Id: 37, Name: 'Tỉnh Khánh Hòa' },
    { Id: 38, Name: 'Tỉnh Ninh Thuận' },
    { Id: 39, Name: 'Tỉnh Bình Thuận' },
    { Id: 40, Name: 'Tỉnh Kon Tum' },
    { Id: 41, Name: 'Tỉnh Gia Lai' },
    { Id: 42, Name: 'Tỉnh Đắk Lắk' },
    { Id: 43, Name: 'Tỉnh Đắk Nông' },
    { Id: 44, Name: 'Tỉnh Lâm Đồng' },
    { Id: 45, Name: 'Tỉnh Bình Phước' },
    { Id: 46, Name: 'Tỉnh Tây Ninh' },
    { Id: 47, Name: 'Tỉnh Bình Dương' },
    { Id: 48, Name: 'Tỉnh Đồng Nai' },
    { Id: 49, Name: 'Tỉnh Bà Rịa - Vũng Tàu' },
    { Id: 50, Name: 'Thành phố Hồ Chí Minh' },
    { Id: 51, Name: 'Tỉnh Long An' },
    { Id: 52, Name: 'Tỉnh Tiền Giang' },
    { Id: 53, Name: 'Tỉnh Bến Tre' },
    { Id: 54, Name: 'Tỉnh Trà Vinh' },
    { Id: 55, Name: 'Tỉnh Vĩnh Long' },
    { Id: 56, Name: 'Tỉnh Đồng Tháp' },
    { Id: 57, Name: 'Tỉnh An Giang' },
    { Id: 58, Name: 'Tỉnh Kiên Giang' },
    { Id: 59, Name: 'Thành phố Cần Thơ' },
    { Id: 60, Name: 'Tỉnh Hậu Giang' },
    { Id: 61, Name: 'Tỉnh Sóc Trăng' },
    { Id: 62, Name: 'Tỉnh Bạc Liêu' },
    { Id: 63, Name: 'Tỉnh Cà Mau' }
  ],

  BenhNen: [
    { Id: 11217, Name: 'Lao hô hấp, có khẳng định về vi khuẩn học và mô học' },
    { Id: 11218, Name: 'Lao đường hô hấp, không khẳng định về vi khuẩn học hoặc mô học' },
    { Id: 11221, Name: 'Bệnh Phong' },
    { Id: 11222, Name: 'Bệnh do virus suy giảm miễn dịch ở người (HIV) dẫn đến các bệnh nhiễm trùng và kí sinh trùng' },
    { Id: 11223, Name: 'HIV/AIDS' },
    { Id: 11245, Name: 'Bạch cầu cấp dòng lympho' },
    { Id: 11246, Name: 'Bạch cầu cấp dòng tủy' },
    { Id: 11251, Name: 'Bệnh tan máu bẩm sinh (Thalassemia)' },
    { Id: 11255, Name: 'Tan máu tự miễn' },
    { Id: 11260, Name: 'Suy tủy' },
    { Id: 11261, Name: 'Thiếu yếu tố VIII di truyền (Hemophilia A)' },
    { Id: 11262, Name: 'Thiếu yếu tố IX di truyền (Hemophilia B)' },
    { Id: 11268, Name: 'Xuất huyết giảm tiểu cầu miễn dịch' },
    { Id: 11276, Name: 'Suy tuyến giáp' },
    { Id: 11278, Name: 'Basedow' },
    { Id: 11282, Name: 'Bệnh đái tháo đường type 1' },
    { Id: 11283, Name: 'Cường insulin' },
    { Id: 11291, Name: 'Suy dinh dưỡng (thể Kwashiorkor)' },
    { Id: 11292, Name: 'Suy dinh dưỡng (thể Marasmus)' },
    { Id: 11294, Name: 'Suy dinh dưỡng nặng' },
    { Id: 11298, Name: 'Bệnh thừa cân béo phì' },
    { Id: 11316, Name: 'Động kinh' },
    { Id: 11317, Name: 'Trạng thái động kinh' },
    { Id: 11318, Name: 'Hội chứng Guillain Barre' },
    { Id: 11319, Name: 'Bệnh nhược cơ' },
    { Id: 11321, Name: 'Bại não trẻ em' },
    { Id: 11323, Name: 'Tăng huyết áp vô căn (nguyên phát)' },
    { Id: 11326, Name: 'Bệnh thiếu máu cục bộ cơ tim' },
    { Id: 11327, Name: 'Bệnh phổi tắc nghẽn mạn tính' },
    { Id: 11329, Name: 'Tăng áp động mạch phổi nguyên phát' },
    { Id: 11337, Name: 'Viêm cơ tim cấp' },
    { Id: 11338, Name: 'Bệnh cơ tim' },
    { Id: 11345, Name: 'Suy tim' },
    { Id: 11347, Name: 'Nhồi máu não' },
    { Id: 11357, Name: 'Hen phế quản' },
    { Id: 11358, Name: 'Hội chứng suy hô hấp tiến triển' },
    { Id: 11362, Name: 'Bệnh Crohn' },
    { Id: 11371, Name: 'Xơ gan' },
    { Id: 11386, Name: 'Lupus ban đỏ hệ thống' },
    { Id: 11395, Name: 'Hội chứng thận hư' },
    { Id: 11401, Name: 'Suy thận cấp' },
    { Id: 11402, Name: 'Bệnh thận mạn' },
    { Id: 11405, Name: 'Suy thận mạn' },
    { Id: 11431, Name: 'Thông liên thất' },
    { Id: 11432, Name: 'Thông liên nhĩ' },
    { Id: 11433, Name: 'Tứ chứng Fallot' },
    { Id: 11448, Name: 'Còn ống động mạch' },
    { Id: 11467, Name: 'Bệnh Hirschsprung' },
    { Id: 11468, Name: 'Teo đường mật' },
    { Id: 11475, Name: 'Hội chứng Down' },
    { Id: 11476, Name: 'Hội chứng Tuner' },
    { Id: 11481, Name: 'Bệnh Hemophillia' },
    { Id: 11485, Name: 'Đái tháo đường phụ thuộc insuline' },
    { Id: 11486, Name: 'Đái tháo đường không phụ thuộc insuline' },
    { Id: 11488, Name: 'Bại não' },
    { Id: 11496, Name: 'Lao (các loại)' },
    { Id: 11497, Name: 'Lupus ban đỏ' },
    { Id: 11499, Name: 'Suy giảm miễn dịch' },
    { Id: 11500, Name: 'Tăng huyết áp có biến chứng' },
    { Id: 11518, Name: 'Ung thư *' },
    { Id: 11561, Name: 'Không có bệnh nền' }
  ]
};

// ─────────────────────────────────────────────────────────────────────────────
// SEED FUNCTION
// ─────────────────────────────────────────────────────────────────────────────

async function seedCategory(collectionName, data) {
  console.log(`\n📦 Seeding ${collectionName}...`);
  const collection = db.collection(collectionName);
  
  let count = 0;
  const batch = db.batch();
  
  for (const item of data) {
    const docRef = collection.doc(item.Id.toString());
    batch.set(docRef, {
      id: item.Id,
      name: item.Name,
      ...(item.ChanDoanId && { chanDoanId: item.ChanDoanId })
    });
    count++;
    
    // Commit batch every 500 items
    if (count % 500 === 0) {
      await batch.commit();
      console.log(`  ✓ Committed ${count} items`);
    }
  }
  
  // Commit remaining items
  if (count % 500 !== 0) {
    await batch.commit();
  }
  
  console.log(`✅ ${collectionName}: ${count} documents seeded`);
}

async function seedAll() {
  try {
    console.log('🚀 Starting Firebase seeding...\n');
    
    for (const [collectionName, data] of Object.entries(categories)) {
      await seedCategory(collectionName, data);
    }
    
    console.log('\n✅ All categories seeded successfully!');
    process.exit(0);
  } catch (error) {
    console.error('❌ Error seeding:', error);
    process.exit(1);
  }
}

seedAll();
