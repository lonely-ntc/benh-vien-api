import { Router } from 'express';
import { requireAuth } from '../auth.js';

const router = Router();
router.use(requireAuth);

// Helper — chuyển array tên (string) sang [{Id, Name}] với Id tự tăng từ 1
const toIdName = (arr) => arr.map((name, i) => ({ Id: i + 1, Name: name }));

// ── Danh mục chuẩn — Id khớp với API hệ thống ────────────────────────────
const DANH_MUC = {
  GioiTinh: [
    { Id: 262, Name: 'Nữ' },
    { Id: 263, Name: 'Nam' },
  ],

  CoKhong: [
    { Id: 11134, Name: 'Có' },
    { Id: 11135, Name: 'Không' },
    { Id: 11137, Name: 'Không rõ' },
  ],

  TinhTrangTiemChung: [
    { Id: 11134, Name: 'Có' },
    { Id: 11135, Name: 'Không' },
    { Id: 11137, Name: 'Không rõ' },
  ],

  NhomMau: toIdName(['A', 'B', 'AB', 'O', 'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-']),

  TrangThai: toIdName(['Chờ', 'Đang khám', 'Đã khám']),

  NgheNghiep: toIdName([
    'Học sinh / Sinh viên', 'Công nhân', 'Nông dân', 'Cán bộ / Viên chức',
    'Kinh doanh / Buôn bán', 'Nội trợ', 'Hưu trí', 'Thất nghiệp', 'Khác',
  ]),

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
    { Id: 1039, Name: 'Ve' }, { Id: 1040, Name: 'Khác trong nước' },
  ],

  DieuTri: [
    { Id: 11143, Name: 'Thở oxy' },
    { Id: 11144, Name: 'Thở NCPAP' },
    { Id: 11145, Name: 'Thở máy' },
    { Id: 11146, Name: 'IVIG' },
    { Id: 11203, Name: 'Không hỗ trợ hô hấp' },
  ],

  HinhThucDieuTri: [
    { Id: 11128, Name: 'Điều trị nội trú' },
    { Id: 11129, Name: 'Điều trị ngoại trú' },
    { Id: 11130, Name: 'Ra viện' },
    { Id: 11131, Name: 'Tử vong' },
    { Id: 11132, Name: 'Chuyển viện' },
    { Id: 11133, Name: 'Tình trạng khác' },
    { Id: 11544, Name: 'Nặng xin về' },
  ],

  PhanLoaiChanDoan: [
    { Id: 11545, Name: 'Có thể' },
    { Id: 11546, Name: 'Nghi ngờ (lâm sàng)' },
    { Id: 11547, Name: 'Xác định phòng xét nghiệm' },
  ],

  LoaiBenhPham: [
    { Id: 11548, Name: 'Máu' }, { Id: 11549, Name: 'Phân' },
    { Id: 11550, Name: 'Dịch ngoáy họng' }, { Id: 11551, Name: 'Dịch tỵ hầu' },
    { Id: 11552, Name: 'Dịch sang thương da' }, { Id: 11553, Name: 'Dịch não tủy' },
    { Id: 11554, Name: 'Nước tiểu' },
  ],

  LoaiXetNghiem: [
    { Id: 11548, Name: 'Máu' }, { Id: 11549, Name: 'Phân' },
    { Id: 11550, Name: 'Dịch ngoáy họng' }, { Id: 11551, Name: 'Dịch tỵ hầu' },
    { Id: 11552, Name: 'Dịch sang thương da' }, { Id: 11553, Name: 'Dịch não tủy' },
    { Id: 11554, Name: 'Nước tiểu' },
  ],

  KetQuaXetNghiem: [
    { Id: 11140, Name: 'Dương tính' },
    { Id: 11141, Name: 'Âm tính' },
    { Id: 11142, Name: 'Chưa có kết quả' },
  ],

  ChanDoanBenh: [
    { Id: 1,  Name: 'Bại liệt' }, { Id: 2,  Name: 'Bạch hầu' },
    { Id: 3,  Name: 'Bệnh do liên cầu lợn ở người' }, { Id: 4,  Name: 'Cúm A(H5N1)' },
    { Id: 5,  Name: 'Cúm A(H7N9)' }, { Id: 6,  Name: 'Dịch hạch' },
    { Id: 7,  Name: 'Ê-bô-la (Ebolla)' }, { Id: 8,  Name: 'Lát-sa (Lassa)' },
    { Id: 9,  Name: 'Mác-bớt (Marburg)' }, { Id: 10, Name: 'Rubella (Rubeon)' },
    { Id: 11, Name: 'Sốt Tây sông Nin' }, { Id: 12, Name: 'Sốt vàng' },
    { Id: 13, Name: 'Sốt xuất huyết Dengue' }, { Id: 14, Name: 'Sởi' },
    { Id: 15, Name: 'Tả' }, { Id: 16, Name: 'Tay - chân - miệng' },
    { Id: 17, Name: 'Than' }, { Id: 18, Name: 'Viêm đường hô hấp Trung đông do corona vi rút (MERS-CoV)' },
    { Id: 19, Name: 'Nhiễm trùng do não mô cầu' }, { Id: 20, Name: 'Zika' },
    { Id: 21, Name: 'Covid-19' }, { Id: 23, Name: 'Mpox' },
    { Id: 24, Name: 'Bệnh truyền nhiễm nguy hiểm mới nổi và bệnh mới phát sinh chưa rõ tác nhân gây bệnh' },
    { Id: 25, Name: 'Dại' }, { Id: 26, Name: 'Ho gà' },
    { Id: 27, Name: 'Liệt mềm cấp nghi bại liệt' }, { Id: 28, Name: 'Lao phổi' },
    { Id: 29, Name: 'Sốt rét' }, { Id: 34, Name: 'Thương hàn' },
    { Id: 35, Name: 'Uốn ván sơ sinh' }, { Id: 36, Name: 'Uốn ván khác' },
    { Id: 38, Name: 'Viêm gan vi rút A' }, { Id: 39, Name: 'Viêm gan vi rút B' },
    { Id: 40, Name: 'Viêm gan vi rút C' }, { Id: 41, Name: 'Viêm não Nhật Bản' },
    { Id: 42, Name: 'Viêm não vi rút khác' }, { Id: 45, Name: 'Xoắn khuẩn vàng da (Leptospira)' },
    { Id: 46, Name: 'Bệnh do vi rút Adeno' }, { Id: 50, Name: 'Cúm' },
    { Id: 51, Name: 'Lỵ amíp' }, { Id: 52, Name: 'Lỵ trực trùng' },
    { Id: 53, Name: 'Quai bị' }, { Id: 54, Name: 'Thủy đậu' },
    { Id: 55, Name: 'Tiêu chảy' }, { Id: 56, Name: 'Viêm gan vi rút khác (hoặc không có định típ vi rút)' },
    { Id: 57, Name: 'Thay đổi chẩn đoán, bệnh không có trong danh mục' },
    { Id: 58, Name: 'Chikungunya' }, { Id: 59, Name: 'Bệnh do vi rút Nipah' },
  ],

  PhanDoBenh: [
    { Id: 1, Name: 'Sốt xuất huyết Dengue', ChanDoanId: 13 },
    { Id: 2, Name: 'Sốt xuất huyết Dengue có dấu hiệu cảnh báo', ChanDoanId: 13 },
    { Id: 3, Name: 'Sốt xuất huyết Dengue nặng', ChanDoanId: 13 },
    { Id: 4, Name: 'Độ 1', ChanDoanId: 16 },
    { Id: 5, Name: 'Độ 2a', ChanDoanId: 16 },
    { Id: 6, Name: 'Độ 2b', ChanDoanId: 16 },
    { Id: 7, Name: 'Độ 3', ChanDoanId: 16 },
    { Id: 8, Name: 'Độ 4', ChanDoanId: 16 },
  ],

  Tinh: [
    { Id: 1,  Name: 'Thành phố Hà Nội' }, { Id: 3,  Name: 'Tỉnh Cao Bằng' },
    { Id: 5,  Name: 'Tỉnh Tuyên Quang' }, { Id: 6,  Name: 'Tỉnh Lào Cai' },
    { Id: 7,  Name: 'Tỉnh Điện Biên' },  { Id: 8,  Name: 'Tỉnh Lai Châu' },
    { Id: 9,  Name: 'Tỉnh Sơn La' },     { Id: 12, Name: 'Tỉnh Thái Nguyên' },
    { Id: 13, Name: 'Tỉnh Lạng Sơn' },   { Id: 14, Name: 'Tỉnh Quảng Ninh' },
    { Id: 16, Name: 'Tỉnh Phú Thọ' },    { Id: 18, Name: 'Tỉnh Bắc Ninh' },
    { Id: 20, Name: 'Thành phố Hải Phòng' }, { Id: 21, Name: 'Tỉnh Hưng Yên' },
    { Id: 25, Name: 'Tỉnh Ninh Bình' },  { Id: 26, Name: 'Tỉnh Thanh Hóa' },
    { Id: 27, Name: 'Tỉnh Nghệ An' },    { Id: 28, Name: 'Tỉnh Hà Tĩnh' },
    { Id: 30, Name: 'Tỉnh Quảng Trị' },  { Id: 31, Name: 'Thành phố Huế' },
    { Id: 32, Name: 'Thành phố Đà Nẵng' }, { Id: 34, Name: 'Tỉnh Quảng Ngãi' },
    { Id: 37, Name: 'Tỉnh Khánh Hòa' },  { Id: 41, Name: 'Tỉnh Gia Lai' },
    { Id: 42, Name: 'Tỉnh Đắk Lắk' },   { Id: 44, Name: 'Tỉnh Lâm Đồng' },
    { Id: 46, Name: 'Tỉnh Tây Ninh' },   { Id: 48, Name: 'Tỉnh Đồng Nai' },
    { Id: 50, Name: 'Thành Phố Hồ Chí Minh' }, { Id: 55, Name: 'Tỉnh Vĩnh Long' },
    { Id: 56, Name: 'Tỉnh Đồng Tháp' },  { Id: 57, Name: 'Tỉnh An Giang' },
    { Id: 59, Name: 'Thành phố Cần Thơ' }, { Id: 63, Name: 'Tỉnh Cà Mau' },
  ],
};

/**
 * GET /api/danhMuc
 * Trả về tất cả danh mục dạng {Code: [{Id, Name}]}
 */
router.get('/', (_req, res) => {
  res.json({ success: true, data: DANH_MUC });
});

/**
 * GET /api/danhMuc/:code
 * Ví dụ: GET /api/danhMuc/GioiTinh → [{Id:262,Name:"Nữ"},{Id:263,Name:"Nam"}]
 */
router.get('/:code', (req, res) => {
  const key = req.params.code;
  const found = Object.keys(DANH_MUC).find(k => k.toLowerCase() === key.toLowerCase());
  if (!found) {
    return res.status(404).json({
      success: false,
      message: `Không tìm thấy danh mục "${key}".`,
      availableCodes: Object.keys(DANH_MUC),
    });
  }
  res.json({
    success: true,
    code: found,
    data: DANH_MUC[found],
  });
});

export default router;
