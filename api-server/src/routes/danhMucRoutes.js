import { Router } from 'express';
import { requireAuth } from '../auth.js';

const router = Router();

router.use(requireAuth);

// Danh mục tĩnh — CategoryCode chuẩn của hệ thống
const DANH_MUC = {
  GioiTinh: ['Nam', 'Nữ', 'Khác'],

  CoKhong: ['Có', 'Không'],

  NhomMau: ['A', 'B', 'AB', 'O', 'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'],

  TrangThai: ['Chờ', 'Đang khám', 'Đã khám'],

  DanToc: ['Kinh','Tày','Thái','Mường','Khmer','Mông','Nùng','Dao','Hoa','Chăm','Khác'],

  NgheNghiep: [
    'Học sinh / Sinh viên','Công nhân','Nông dân','Cán bộ / Viên chức',
    'Kinh doanh / Buôn bán','Nội trợ','Hưu trí','Thất nghiệp','Khác',
  ],

  DieuTri: ['Ngoại trú','Nội trú','Cấp cứu','Phẫu thuật','Theo dõi'],

  HinhThucDieuTri: ['Dùng thuốc','Phẫu thuật','Vật lý trị liệu','Hóa trị','Xạ trị','Kết hợp','Khác'],

  BenhTruyenNhiem: [
    'COVID-19','Sốt xuất huyết','Tay chân miệng','Cúm',
    'Viêm gan B','Viêm gan C','HIV/AIDS','Lao','Sởi','Không',
  ],

  BenhNen: [
    'Tiểu đường','Tăng huyết áp','Tim mạch','Ung thư',
    'Thận mãn','COPD','Hen suyễn','Xơ gan','Không','Khác',
  ],

  PhanLoaiChanDoan: ['Xác định','Nghi ngờ','Có thể','Loại trừ'],

  LoaiBenhPham: ['Máu','Nước tiểu','Dịch họng','Dịch mũi','Phân','Đàm','Khác'],

  LoaiXetNghiem: [
    'PCR','Test nhanh kháng nguyên','Huyết học','Sinh hóa',
    'Vi sinh','Giải phẫu bệnh','X-quang','Siêu âm','CT scan','MRI','Khác',
  ],

  KetQuaXetNghiem: ['Dương tính','Âm tính','Nghi ngờ','Chờ kết quả'],

  TinhTrangTiemChung: ['Chưa tiêm','Tiêm 1 mũi','Tiêm 2 mũi','Tiêm 3 mũi','Tiêm nhắc lại'],

  PhanDoBenh: ['Nhẹ','Trung bình','Nặng','Nguy kịch'],

  Tinh: [
    'An Giang','Bà Rịa - Vũng Tàu','Bắc Giang','Bắc Kạn','Bạc Liêu',
    'Bắc Ninh','Bến Tre','Bình Định','Bình Dương','Bình Phước',
    'Bình Thuận','Cà Mau','Cần Thơ','Cao Bằng','Đà Nẵng',
    'Đắk Lắk','Đắk Nông','Điện Biên','Đồng Nai','Đồng Tháp',
    'Gia Lai','Hà Giang','Hà Nam','Hà Nội','Hà Tĩnh',
    'Hải Dương','Hải Phòng','Hậu Giang','Hòa Bình','Hưng Yên',
    'Khánh Hòa','Kiên Giang','Kon Tum','Lai Châu','Lâm Đồng',
    'Lạng Sơn','Lào Cai','Long An','Nam Định','Nghệ An',
    'Ninh Bình','Ninh Thuận','Phú Thọ','Phú Yên','Quảng Bình',
    'Quảng Nam','Quảng Ngãi','Quảng Ninh','Quảng Trị','Sóc Trăng',
    'Sơn La','Tây Ninh','Thái Bình','Thái Nguyên','Thanh Hóa',
    'Thừa Thiên Huế','Tiền Giang','TP. Hồ Chí Minh','Trà Vinh',
    'Tuyên Quang','Vĩnh Long','Vĩnh Phúc','Yên Bái',
  ],

  ChanDoanBenh: [
    'COVID-19','Sốt xuất huyết','Tay chân miệng','Cúm','Viêm gan B',
    'Viêm phổi','Tăng huyết áp','Tiểu đường type 2','Nhồi máu cơ tim',
    'Đột quỵ','Ung thư phổi','Sỏi thận','Viêm ruột thừa','Gãy xương',
    'Hen suyễn','COPD','Suy tim','Xơ gan','Lao phổi',
  ],
};

/**
 * GET /api/danhMuc
 * Trả về tất cả danh mục
 */
router.get('/', (_req, res) => {
  res.json({ success: true, data: DANH_MUC });
});

/**
 * GET /api/danhMuc/:code
 * Ví dụ: GET /api/danhMuc/GioiTinh
 */
router.get('/:code', (req, res) => {
  const key = req.params.code;
  // Tìm không phân biệt hoa thường
  const found = Object.keys(DANH_MUC).find(k => k.toLowerCase() === key.toLowerCase());
  if (!found) {
    return res.status(404).json({
      success: false,
      message: `Không tìm thấy danh mục "${key}".`,
      availableCodes: Object.keys(DANH_MUC),
    });
  }
  res.json({ success: true, code: found, data: DANH_MUC[found] });
});

export default router;
