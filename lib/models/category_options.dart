// Các lựa chọn dropdown cho từng CategoryCode

class CategoryOptions {
  // GioiTinh
  static const List<String> gioiTinh = ['Nam', 'Nữ', 'Khác'];

  // CoKhong (Có / Không — dùng cho dị ứng, v.v.)
  static const List<String> coKhong = ['Có', 'Không'];

  // Nhóm máu
  static const List<String> nhomMau = ['A', 'B', 'AB', 'O', 'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];

  // Trạng thái khám
  static const List<String> trangThai = ['Chờ', 'Đang khám', 'Đã khám'];

  // DanToc — dân tộc phổ biến Việt Nam
  static const List<String> danToc = [
    'Kinh', 'Tày', 'Thái', 'Mường', 'Khmer', 'Mông',
    'Nùng', 'Dao', 'Hoa', 'Chăm', 'Khác',
  ];

  // NgheNghiep
  static const List<String> ngheNghiep = [
    'Học sinh / Sinh viên', 'Công nhân', 'Nông dân', 'Cán bộ / Viên chức',
    'Kinh doanh / Buôn bán', 'Nội trợ', 'Hưu trí', 'Thất nghiệp', 'Khác',
  ];

  // DieuTri
  static const List<String> dieuTri = [
    'Ngoại trú', 'Nội trú', 'Cấp cứu', 'Phẫu thuật', 'Theo dõi',
  ];

  // HinhThucDieuTri
  static const List<String> hinhThucDieuTri = [
    'Dùng thuốc', 'Phẫu thuật', 'Vật lý trị liệu',
    'Hóa trị', 'Xạ trị', 'Kết hợp', 'Khác',
  ];

  // BenhTruyenNhiem
  static const List<String> benhTruyenNhiem = [
    'COVID-19', 'Sốt xuất huyết', 'Tay chân miệng', 'Cúm',
    'Viêm gan B', 'Viêm gan C', 'HIV/AIDS', 'Lao', 'Sởi', 'Không',
  ];

  // BenhNen
  static const List<String> benhNen = [
    'Tiểu đường', 'Tăng huyết áp', 'Tim mạch', 'Ung thư',
    'Thận mãn', 'COPD', 'Hen suyễn', 'Xơ gan', 'Không', 'Khác',
  ];

  // PhanLoaiChanDoan
  static const List<String> phanLoaiChanDoan = [
    'Xác định', 'Nghi ngờ', 'Có thể', 'Loại trừ',
  ];

  // LoaiBenhPham
  static const List<String> loaiBenhPham = [
    'Máu', 'Nước tiểu', 'Dịch họng', 'Dịch mũi', 'Phân', 'Đàm', 'Khác',
  ];

  // LoaiXetNghiem
  static const List<String> loaiXetNghiem = [
    'PCR', 'Test nhanh kháng nguyên', 'Huyết học', 'Sinh hóa',
    'Vi sinh', 'Giải phẫu bệnh', 'X-quang', 'Siêu âm', 'CT scan', 'MRI', 'Khác',
  ];

  // KetQuaXetNghiem
  static const List<String> ketQuaXetNghiem = [
    'Dương tính', 'Âm tính', 'Nghi ngờ', 'Chờ kết quả',
  ];

  // TinhTrangTiemChung
  static const List<String> tinhTrangTiemChung = [
    'Chưa tiêm', 'Tiêm 1 mũi', 'Tiêm 2 mũi', 'Tiêm 3 mũi', 'Tiêm nhắc lại',
  ];

  // Tinh — Tỉnh / Thành phố (63 tỉnh thành, rút gọn các tỉnh phổ biến)
  static const List<String> tinh = [
    'An Giang', 'Bà Rịa - Vũng Tàu', 'Bắc Giang', 'Bắc Kạn', 'Bạc Liêu',
    'Bắc Ninh', 'Bến Tre', 'Bình Định', 'Bình Dương', 'Bình Phước',
    'Bình Thuận', 'Cà Mau', 'Cần Thơ', 'Cao Bằng', 'Đà Nẵng',
    'Đắk Lắk', 'Đắk Nông', 'Điện Biên', 'Đồng Nai', 'Đồng Tháp',
    'Gia Lai', 'Hà Giang', 'Hà Nam', 'Hà Nội', 'Hà Tĩnh',
    'Hải Dương', 'Hải Phòng', 'Hậu Giang', 'Hòa Bình', 'Hưng Yên',
    'Khánh Hòa', 'Kiên Giang', 'Kon Tum', 'Lai Châu', 'Lâm Đồng',
    'Lạng Sơn', 'Lào Cai', 'Long An', 'Nam Định', 'Nghệ An',
    'Ninh Bình', 'Ninh Thuận', 'Phú Thọ', 'Phú Yên', 'Quảng Bình',
    'Quảng Nam', 'Quảng Ngãi', 'Quảng Ninh', 'Quảng Trị', 'Sóc Trăng',
    'Sơn La', 'Tây Ninh', 'Thái Bình', 'Thái Nguyên', 'Thanh Hóa',
    'Thừa Thiên Huế', 'Tiền Giang', 'TP. Hồ Chí Minh', 'Trà Vinh',
    'Tuyên Quang', 'Vĩnh Long', 'Vĩnh Phúc', 'Yên Bái',
  ];

  // PhanDoBenh
  static const List<String> phanDoBenh = [
    'Nhẹ', 'Trung bình', 'Nặng', 'Nguy kịch',
  ];
}
