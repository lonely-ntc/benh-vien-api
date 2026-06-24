// CategoryItem — mỗi mục danh mục có Id (chuẩn API) và Name hiển thị
class CategoryItem {
  final int id;
  final String name;
  const CategoryItem(this.id, this.name);

  @override
  String toString() => name;

  /// Chuyển thành Map để lưu Firestore: {"id": 262, "name": "Nữ"}
  Map<String, dynamic> toMap() => {'id': id, 'name': name};

  /// Parse từ Firestore — hỗ trợ cả int id lẫn Map {"id":..,"name":..}
  static CategoryItem? fromFirestore(dynamic value, List<CategoryItem> list) {
    if (value == null) return null;
    if (value is int) return CategoryOptions.findById(list, value);
    if (value is Map) {
      final id = value['id'];
      if (id is int) return CategoryOptions.findById(list, id);
    }
    // Fallback: tìm theo tên nếu dữ liệu cũ lưu string
    if (value is String) return CategoryOptions.findByName(list, value);
    return null;
  }
}

class CategoryOptions {
  // ── GioiTinh ─────────────────────────────────────────────────────────────
  static const List<CategoryItem> gioiTinh = [
    CategoryItem(262, 'Nữ'),
    CategoryItem(263, 'Nam'),
  ];

  // ── CoKhong ──────────────────────────────────────────────────────────────
  static const List<CategoryItem> coKhong = [
    CategoryItem(264, 'Có'),
    CategoryItem(265, 'Không'),
  ];

  // ── TinhTrangTiemChung ────────────────────────────────────────────────────
  static const List<CategoryItem> tinhTrangTiemChung = [
    CategoryItem(11134, 'Có'),
    CategoryItem(11135, 'Không'),
    CategoryItem(11137, 'Không rõ'),
  ];

  // ── TrangThai (nội bộ app, không có API ID) ───────────────────────────────
  static const List<String> trangThai = ['Chờ', 'Đang khám', 'Đã khám'];

  // ── NhomMau (không có API ID) ─────────────────────────────────────────────
  static const List<String> nhomMau = [
    'A', 'B', 'AB', 'O', 'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-',
  ];

  // ── NgheNghiep ───────────────────────────────────────────────────────────
  static const List<CategoryItem> ngheNghiep = [
    CategoryItem(11204, 'Trẻ < 6 tuổi đi học, <15 tuổi không đi học'),
    CategoryItem(11205, 'Sinh viên, học sinh'),
    CategoryItem(11206, 'Hưu và > 60 tuổi'),
    CategoryItem(11207, 'Lực lượng vũ trang'),
    CategoryItem(11208, 'Tri thức'),
    CategoryItem(11209, 'Hành chính, sự nghiệp'),
    CategoryItem(11210, 'Công nhân'),
    CategoryItem(11211, 'Y tế'),
    CategoryItem(11212, 'Dịch vụ'),
    CategoryItem(11213, 'Nông dân'),
    CategoryItem(11214, 'Ngoại kiều'),
    CategoryItem(11215, 'Việt kiều'),
    CategoryItem(11216, 'Hưu trí'),
    CategoryItem(11562, 'Trẻ 15 tuổi không đi học'),
    CategoryItem(11563, 'Trí thức'),
    CategoryItem(11565, 'Bác sĩ'),
    CategoryItem(11566, 'Còn nhỏ'),
    CategoryItem(11567, 'Các tổ chức xã hội Đảng, đoàn thể'),
    CategoryItem(11568, 'Thất nghiệp'),
    CategoryItem(11569, 'Nhân dân'),
    CategoryItem(11570, 'Công nhân quốc phòng'),
    CategoryItem(11571, 'Thân nhân sĩ quan'),
    CategoryItem(11572, 'Hộ nghèo'),
    CategoryItem(11573, 'Nội trợ'),
    CategoryItem(11574, 'Nhân viên văn phòng'),
    CategoryItem(11575, 'Bưu điện'),
    CategoryItem(11576, 'Giáo dục đào tạo'),
    CategoryItem(11577, 'Quản lý nhà nước'),
    CategoryItem(11578, 'An ninh quốc phòng'),
    CategoryItem(11579, 'Dịch vụ công cộng'),
    CategoryItem(11580, 'Dịch vụ gia đình'),
    CategoryItem(11581, 'Dịch vụ (trừ dịch vụ gia đình và dịch vụ công cộng)'),
    CategoryItem(11582, 'Thương mại'),
    CategoryItem(11583, 'Giao thông vận tải'),
    CategoryItem(11584, 'Xây dựng'),
    CategoryItem(11585, 'Nông, lâm nghiệp, chăn nuôi, đánh cá'),
    CategoryItem(11586, 'Bộ đội biên phòng'),
    CategoryItem(11587, 'Công nhân xây dựng'),
    CategoryItem(11588, 'Làm rẫy'),
    CategoryItem(11589, 'Kiểm lâm'),
    CategoryItem(11590, 'Làm thuê theo mùa'),
    CategoryItem(11591, 'Người đi rừng'),
    CategoryItem(11592, 'Công nghiệp, tiểu thủ công nghiệp'),
    CategoryItem(11593, 'Khác'),
  ];

  // ── DanToc ───────────────────────────────────────────────────────────────
  static const List<CategoryItem> danToc = [
    CategoryItem(15, 'Kinh'),     CategoryItem(16, 'Tày'),          CategoryItem(17, 'Thái'),
    CategoryItem(18, 'Hoa'),      CategoryItem(19, 'Khme'),         CategoryItem(20, 'Mường'),
    CategoryItem(21, 'Nùng'),     CategoryItem(22, 'Hán'),          CategoryItem(23, 'Dao'),
    CategoryItem(24, 'Gia rai'),  CategoryItem(25, 'Cao lan'),      CategoryItem(26, 'Ê đê'),
    CategoryItem(27, 'Ba na'),    CategoryItem(28, 'Xơ đăng'),      CategoryItem(29, 'Sán Chay'),
    CategoryItem(30, 'Cơ ho'),    CategoryItem(31, 'Chăm'),         CategoryItem(32, 'Sán chỉ'),
    CategoryItem(33, 'Hrê'),      CategoryItem(34, 'M nông'),       CategoryItem(35, 'Raglai'),
    CategoryItem(36, 'Xtiêng'),   CategoryItem(37, 'Bru (Khùa)'),  CategoryItem(38, 'Thổ'),
    CategoryItem(39, 'Giấy'),     CategoryItem(40, 'Cơ Tu'),        CategoryItem(41, 'Giẻ Triêng'),
    CategoryItem(42, 'Mạ'),       CategoryItem(43, 'Khơ mú'),       CategoryItem(44, 'Co (Cùa)'),
    CategoryItem(45, 'Tà ôi'),    CategoryItem(46, 'Chơ-ro'),       CategoryItem(47, 'Kháng'),
    CategoryItem(48, 'Xinh mun'), CategoryItem(49, 'Hà nhì'),       CategoryItem(50, 'Chu ru'),
    CategoryItem(51, 'Lào'),      CategoryItem(52, 'La chí'),       CategoryItem(53, 'La ha'),
    CategoryItem(54, 'Phù lá'),   CategoryItem(55, 'La hụ'),        CategoryItem(56, 'Lự'),
    CategoryItem(57, 'Lô Lô'),    CategoryItem(58, 'Cà Doòng'),     CategoryItem(59, 'Mảng'),
    CategoryItem(60, 'Pà thẻn'),  CategoryItem(61, 'Cờ lao'),       CategoryItem(62, 'Cống'),
    CategoryItem(63, 'Bố Y'),     CategoryItem(64, 'Si la'),        CategoryItem(65, 'Pu piéo'),
    CategoryItem(66, 'Brâu'),     CategoryItem(67, 'Ơ đu'),         CategoryItem(68, 'Rơ măm'),
    CategoryItem(1017, 'Tày Poọng'),    CategoryItem(1018, 'Thù lao'),   CategoryItem(1019, 'Pa dí'),
    CategoryItem(1020, 'Cao lan'),      CategoryItem(1021, 'Quý châu(Pu nà)'), CategoryItem(1022, 'Thuỷ'),
    CategoryItem(1023, 'Vân kiều'),     CategoryItem(1024, 'Pa cô'),     CategoryItem(1025, 'Ba hy'),
    CategoryItem(1026, 'Tù riềng'),     CategoryItem(1027, 'Hà lăng'),   CategoryItem(1028, 'Treng'),
    CategoryItem(1029, 'Xil (Chil)'),   CategoryItem(1031, 'Hroi'),      CategoryItem(1032, 'Tu dí'),
    CategoryItem(1033, 'Nước ngoài'),   CategoryItem(1034, 'Kor'),       CategoryItem(1035, 'Chứt'),
    CategoryItem(1036, 'Krê'),          CategoryItem(1037, 'Mông'),      CategoryItem(1038, 'Sán dìu'),
    CategoryItem(1039, 'Ve'),           CategoryItem(1040, 'Khác trong nước'),
  ];

  // ── DieuTri ──────────────────────────────────────────────────────────────
  static const List<CategoryItem> dieuTri = [
    CategoryItem(11143, 'Thở oxy'),
    CategoryItem(11144, 'Thở NCPAP'),
    CategoryItem(11145, 'Thở máy'),
    CategoryItem(11146, 'IVIG'),
    CategoryItem(11203, 'Không hỗ trợ hô hấp'),
  ];

  // ── HinhThucDieuTri ──────────────────────────────────────────────────────
  static const List<CategoryItem> hinhThucDieuTri = [
    CategoryItem(11128, 'Điều trị nội trú'),
    CategoryItem(11129, 'Điều trị ngoại trú'),
    CategoryItem(11130, 'Ra viện'),
    CategoryItem(11131, 'Tử vong'),
    CategoryItem(11132, 'Chuyển viện'),
    CategoryItem(11133, 'Tình trạng khác'),
    CategoryItem(11544, 'Nặng xin về'),
  ];

  // ── PhanLoaiChanDoan ──────────────────────────────────────────────────────
  static const List<CategoryItem> phanLoaiChanDoan = [
    CategoryItem(11545, 'Có thể'),
    CategoryItem(11546, 'Nghi ngờ (lâm sàng)'),
    CategoryItem(11547, 'Xác định phòng xét nghiệm'),
  ];

  // ── LoaiBenhPham ─────────────────────────────────────────────────────────
  static const List<CategoryItem> loaiBenhPham = [
    CategoryItem(11548, 'Máu'),
    CategoryItem(11549, 'Phân'),
    CategoryItem(11550, 'Dịch ngoáy họng'),
    CategoryItem(11551, 'Dịch tỵ hầu'),
    CategoryItem(11552, 'Dịch sang thương da'),
    CategoryItem(11553, 'Dịch não tủy'),
    CategoryItem(11554, 'Nước tiểu'),
  ];

  // ── LoaiXetNghiem ─────────────────────────────────────────────────────────
  static const List<CategoryItem> loaiXetNghiem = [
    CategoryItem(11192, 'Test nhanh'),
    CategoryItem(11193, 'Mac-elisa'),
    CategoryItem(11194, 'PCR'),
    CategoryItem(11195, 'Soi'),
    CategoryItem(11555, 'Cấy'),
  ];

  // ── KetQuaXetNghiem ───────────────────────────────────────────────────────
  static const List<CategoryItem> ketQuaXetNghiem = [
    CategoryItem(11140, 'Dương tính'),
    CategoryItem(11141, 'Âm tính'),
    CategoryItem(11142, 'Chưa có kết quả'),
  ];

  // ── ChanDoanBenh ──────────────────────────────────────────────────────────
  static const List<CategoryItem> chanDoanBenh = [
    CategoryItem(1,  'Bại liệt'),
    CategoryItem(2,  'Bạch hầu'),
    CategoryItem(3,  'Bệnh do liên cầu lợn ở người'),
    CategoryItem(4,  'Cúm A(H5N1)'),
    CategoryItem(5,  'Cúm A(H7N9)'),
    CategoryItem(6,  'Dịch hạch'),
    CategoryItem(7,  'Ê-bô-la (Ebolla)'),
    CategoryItem(8,  'Lát-sa (Lassa)'),
    CategoryItem(9,  'Mác-bớt (Marburg)'),
    CategoryItem(10, 'Rubella (Rubeon)'),
    CategoryItem(11, 'Sốt Tây sông Nin'),
    CategoryItem(12, 'Sốt vàng'),
    CategoryItem(13, 'Sốt xuất huyết Dengue'),
    CategoryItem(14, 'Sởi'),
    CategoryItem(15, 'Tả'),
    CategoryItem(16, 'Tay - chân - miệng'),
    CategoryItem(17, 'Than'),
    CategoryItem(18, 'Viêm đường hô hấp Trung đông do corona vi rút (MERS-CoV)'),
    CategoryItem(19, 'Nhiễm trùng do não mô cầu'),
    CategoryItem(20, 'Zika'),
    CategoryItem(21, 'Covid-19'),
    CategoryItem(23, 'Mpox'),
    CategoryItem(24, 'Bệnh truyền nhiễm nguy hiểm mới nổi và bệnh mới phát sinh chưa rõ tác nhân gây bệnh'),
    CategoryItem(25, 'Dại'),
    CategoryItem(26, 'Ho gà'),
    CategoryItem(27, 'Liệt mềm cấp nghi bại liệt'),
    CategoryItem(28, 'Lao phổi'),
    CategoryItem(29, 'Sốt rét'),
    CategoryItem(34, 'Thương hàn'),
    CategoryItem(35, 'Uốn ván sơ sinh'),
    CategoryItem(36, 'Uốn ván khác'),
    CategoryItem(38, 'Viêm gan vi rút A'),
    CategoryItem(39, 'Viêm gan vi rút B'),
    CategoryItem(40, 'Viêm gan vi rút C'),
    CategoryItem(41, 'Viêm não Nhật Bản'),
    CategoryItem(42, 'Viêm não vi rút khác'),
    CategoryItem(45, 'Xoắn khuẩn vàng da (Leptospira)'),
    CategoryItem(46, 'Bệnh do vi rút Adeno'),
    CategoryItem(50, 'Cúm'),
    CategoryItem(51, 'Lỵ amíp'),
    CategoryItem(52, 'Lỵ trực trùng'),
    CategoryItem(53, 'Quai bị'),
    CategoryItem(54, 'Thủy đậu'),
    CategoryItem(55, 'Tiêu chảy'),
    CategoryItem(56, 'Viêm gan vi rút khác (hoặc không có định típ vi rút)'),
    CategoryItem(57, 'Thay đổi chẩn đoán, bệnh không có trong danh mục'),
    CategoryItem(58, 'Chikungunya'),
    CategoryItem(59, 'Bệnh do vi rút Nipah'),
  ];

  // ── BenhTruyenNhiem — alias ChanDoanBenh (dùng trong màn hình bệnh nhân) ──
  static List<CategoryItem> get benhTruyenNhiem => chanDoanBenh;

  // ── PhanDoBenh ────────────────────────────────────────────────────────────
  static const List<CategoryItem> phanDoBenh = [
    CategoryItem(1, 'Sốt xuất huyết Dengue'),
    CategoryItem(2, 'Sốt xuất huyết Dengue có dấu hiệu cảnh báo'),
    CategoryItem(3, 'Sốt xuất huyết Dengue nặng'),
    CategoryItem(4, 'Độ 1'),
    CategoryItem(5, 'Độ 2a'),
    CategoryItem(6, 'Độ 2b'),
    CategoryItem(7, 'Độ 3'),
    CategoryItem(8, 'Độ 4'),
  ];

  // ── Tinh ─────────────────────────────────────────────────────────────────
  static const List<CategoryItem> tinh = [
    CategoryItem(1,  'Thành phố Hà Nội'),
    CategoryItem(2,  'Tỉnh Hà Giang'),
    CategoryItem(3,  'Tỉnh Cao Bằng'),
    CategoryItem(4,  'Tỉnh Bắc Kạn'),
    CategoryItem(5,  'Tỉnh Tuyên Quang'),
    CategoryItem(6,  'Tỉnh Lào Cai'),
    CategoryItem(7,  'Tỉnh Điện Biên'),
    CategoryItem(8,  'Tỉnh Lai Châu'),
    CategoryItem(9,  'Tỉnh Sơn La'),
    CategoryItem(10, 'Tỉnh Yên Bái'),
    CategoryItem(11, 'Tỉnh Hòa Bình'),
    CategoryItem(12, 'Tỉnh Thái Nguyên'),
    CategoryItem(13, 'Tỉnh Lạng Sơn'),
    CategoryItem(14, 'Tỉnh Quảng Ninh'),
    CategoryItem(15, 'Tỉnh Bắc Giang'),
    CategoryItem(16, 'Tỉnh Phú Thọ'),
    CategoryItem(17, 'Tỉnh Vĩnh Phúc'),
    CategoryItem(18, 'Tỉnh Bắc Ninh'),
    CategoryItem(19, 'Tỉnh Hải Dương'),
    CategoryItem(20, 'Thành phố Hải Phòng'),
    CategoryItem(21, 'Tỉnh Hưng Yên'),
    CategoryItem(22, 'Tỉnh Thái Bình'),
    CategoryItem(23, 'Tỉnh Hà Nam'),
    CategoryItem(24, 'Tỉnh Nam Định'),
    CategoryItem(25, 'Tỉnh Ninh Bình'),
    CategoryItem(26, 'Tỉnh Thanh Hóa'),
    CategoryItem(27, 'Tỉnh Nghệ An'),
    CategoryItem(28, 'Tỉnh Hà Tĩnh'),
    CategoryItem(29, 'Tỉnh Quảng Bình'),
    CategoryItem(30, 'Tỉnh Quảng Trị'),
    CategoryItem(31, 'Tỉnh Thừa Thiên Huế'),
    CategoryItem(32, 'Thành phố Đà Nẵng'),
    CategoryItem(33, 'Tỉnh Quảng Nam'),
    CategoryItem(34, 'Tỉnh Quảng Ngãi'),
    CategoryItem(35, 'Tỉnh Bình Định'),
    CategoryItem(36, 'Tỉnh Phú Yên'),
    CategoryItem(37, 'Tỉnh Khánh Hòa'),
    CategoryItem(38, 'Tỉnh Ninh Thuận'),
    CategoryItem(39, 'Tỉnh Bình Thuận'),
    CategoryItem(40, 'Tỉnh Kon Tum'),
    CategoryItem(41, 'Tỉnh Gia Lai'),
    CategoryItem(42, 'Tỉnh Đắk Lắk'),
    CategoryItem(43, 'Tỉnh Đắk Nông'),
    CategoryItem(44, 'Tỉnh Lâm Đồng'),
    CategoryItem(45, 'Tỉnh Bình Phước'),
    CategoryItem(46, 'Tỉnh Tây Ninh'),
    CategoryItem(47, 'Tỉnh Bình Dương'),
    CategoryItem(48, 'Tỉnh Đồng Nai'),
    CategoryItem(49, 'Tỉnh Bà Rịa - Vũng Tàu'),
    CategoryItem(50, 'Thành phố Hồ Chí Minh'),
    CategoryItem(51, 'Tỉnh Long An'),
    CategoryItem(52, 'Tỉnh Tiền Giang'),
    CategoryItem(53, 'Tỉnh Bến Tre'),
    CategoryItem(54, 'Tỉnh Trà Vinh'),
    CategoryItem(55, 'Tỉnh Vĩnh Long'),
    CategoryItem(56, 'Tỉnh Đồng Tháp'),
    CategoryItem(57, 'Tỉnh An Giang'),
    CategoryItem(58, 'Tỉnh Kiên Giang'),
    CategoryItem(59, 'Thành phố Cần Thơ'),
    CategoryItem(60, 'Tỉnh Hậu Giang'),
    CategoryItem(61, 'Tỉnh Sóc Trăng'),
    CategoryItem(62, 'Tỉnh Bạc Liêu'),
    CategoryItem(63, 'Tỉnh Cà Mau'),
  ];

  // ── BenhNen (đầy đủ theo API) ─────────────────────────────────────────────
  static const List<CategoryItem> benhNen = [
    CategoryItem(11217, 'Lao hô hấp, có khẳng định về vi khuẩn học và mô học'),
    CategoryItem(11218, 'Lao đường hô hấp, không khẳng định về vi khuẩn học hoặc mô học'),
    CategoryItem(11221, 'Bệnh Phong'),
    CategoryItem(11222, 'Bệnh do virus suy giảm miễn dịch ở người (HIV) dẫn đến các bệnh nhiễm trùng và kí sinh trùng'),
    CategoryItem(11223, 'HIV/AIDS'),
    CategoryItem(11245, 'Bạch cầu cấp dòng lympho'),
    CategoryItem(11246, 'Bạch cầu cấp dòng tủy'),
    CategoryItem(11251, 'Bệnh tan máu bẩm sinh (Thalassemia)'),
    CategoryItem(11255, 'Tan máu tự miễn'),
    CategoryItem(11260, 'Suy tủy'),
    CategoryItem(11261, 'Thiếu yếu tố VIII di truyền (Hemophilia A)'),
    CategoryItem(11262, 'Thiếu yếu tố IX di truyền (Hemophilia B)'),
    CategoryItem(11268, 'Xuất huyết giảm tiểu cầu miễn dịch'),
    CategoryItem(11276, 'Suy tuyến giáp'),
    CategoryItem(11278, 'Basedow'),
    CategoryItem(11282, 'Bệnh đái tháo đường type 1'),
    CategoryItem(11283, 'Cường insulin'),
    CategoryItem(11291, 'Suy dinh dưỡng (thể Kwashiorkor)'),
    CategoryItem(11292, 'Suy dinh dưỡng (thể Marasmus)'),
    CategoryItem(11294, 'Suy dinh dưỡng nặng'),
    CategoryItem(11298, 'Bệnh thừa cân béo phì'),
    CategoryItem(11316, 'Động kinh'),
    CategoryItem(11317, 'Trạng thái động kinh'),
    CategoryItem(11318, 'Hội chứng Guillain Barre'),
    CategoryItem(11319, 'Bệnh nhược cơ'),
    CategoryItem(11321, 'Bại não trẻ em'),
    CategoryItem(11323, 'Tăng huyết áp vô căn (nguyên phát)'),
    CategoryItem(11326, 'Bệnh thiếu máu cục bộ cơ tim'),
    CategoryItem(11327, 'Bệnh phổi tắc nghẽn mạn tính'),
    CategoryItem(11329, 'Tăng áp động mạch phổi nguyên phát'),
    CategoryItem(11337, 'Viêm cơ tim cấp'),
    CategoryItem(11338, 'Bệnh cơ tim'),
    CategoryItem(11345, 'Suy tim'),
    CategoryItem(11347, 'Nhồi máu não'),
    CategoryItem(11357, 'Hen phế quản'),
    CategoryItem(11358, 'Hội chứng suy hô hấp tiến triển'),
    CategoryItem(11362, 'Bệnh Crohn'),
    CategoryItem(11371, 'Xơ gan'),
    CategoryItem(11386, 'Lupus ban đỏ hệ thống'),
    CategoryItem(11395, 'Hội chứng thận hư'),
    CategoryItem(11401, 'Suy thận cấp'),
    CategoryItem(11402, 'Bệnh thận mạn'),
    CategoryItem(11405, 'Suy thận mạn'),
    CategoryItem(11431, 'Thông liên thất'),
    CategoryItem(11432, 'Thông liên nhĩ'),
    CategoryItem(11433, 'Tứ chứng Fallot'),
    CategoryItem(11448, 'Còn ống động mạch'),
    CategoryItem(11467, 'Bệnh Hirschsprung'),
    CategoryItem(11468, 'Teo đường mật'),
    CategoryItem(11475, 'Hội chứng Down'),
    CategoryItem(11476, 'Hội chứng Tuner'),
    CategoryItem(11481, 'Bệnh Hemophillia'),
    CategoryItem(11485, 'Đái tháo đường phụ thuộc insuline'),
    CategoryItem(11486, 'Đái tháo đường không phụ thuộc insuline'),
    CategoryItem(11488, 'Bại não'),
    CategoryItem(11496, 'Lao (các loại)'),
    CategoryItem(11497, 'Lupus ban đỏ'),
    CategoryItem(11499, 'Suy giảm miễn dịch'),
    CategoryItem(11500, 'Tăng huyết áp có biến chứng'),
    CategoryItem(11518, 'Ung thư *'),
    CategoryItem(11561, 'Không có bệnh nền'),
  ];

  // ── CoSoBaoCao ────────────────────────────────────────────────────────────
  // Danh sách đầy đủ — chỉ lấy một số mục tiêu biểu để tránh file quá lớn;
  // toàn bộ dữ liệu nằm ở API /danhMuc/CoSoBaoCao
  static const List<CategoryItem> coSoBaoCao = [
    CategoryItem(10100, 'Bệnh viện Bệnh Nhiệt Đới'),
    CategoryItem(10101, 'Bệnh viện Nhi Đồng 1'),
    CategoryItem(10102, 'Bệnh viện Nhi Đồng 2'),
    CategoryItem(10103, 'Bệnh viện Nhi Đồng Thành phố'),
    CategoryItem(10092, 'Bệnh viện Nhân Dân Gia Định'),
    CategoryItem(10093, 'Bệnh viện An Bình'),
    CategoryItem(10098, 'Bệnh viện Nhân Dân 115'),
    CategoryItem(10091, 'Bệnh viện Trưng Vương'),
    CategoryItem(10094, 'Bệnh viện Nguyễn Tri Phương'),
    CategoryItem(10095, 'Bệnh viện Đa Khoa Khu vực Thủ Đức'),
    CategoryItem(10184, 'Bệnh viện Chợ Rẫy'),
    CategoryItem(10187, 'Bệnh viện ĐH Y Dược TP.HCM'),
    CategoryItem(10099, 'Bệnh viện Sài Gòn'),
    CategoryItem(10105, 'Bệnh viện Từ Dũ'),
    CategoryItem(10106, 'Bệnh viện Hùng Vương'),
    CategoryItem(10107, 'Bệnh viện Quận 1'),
    CategoryItem(10108, 'Bệnh viện Lê Văn Thịnh'),
    CategoryItem(10113, 'Bệnh viện Quận 7'),
    CategoryItem(10114, 'Bệnh viện Quận 8'),
    CategoryItem(10116, 'Bệnh viện Quận 10'),
    CategoryItem(10118, 'Bệnh viện Quận 12'),
    CategoryItem(10119, 'Bệnh viện Đa khoa Tân Phú'),
    CategoryItem(10120, 'Bệnh viện Quận Tân Bình'),
    CategoryItem(10121, 'Bệnh viện Đa khoa Phú Nhuận'),
    CategoryItem(10122, 'Bệnh viện Gò Vấp'),
    CategoryItem(10123, 'Bệnh viện Đa khoa Thủ Đức'),
    CategoryItem(10124, 'Bệnh viện Bình Thạnh'),
    CategoryItem(10125, 'Bệnh viện Bình Tân'),
    CategoryItem(10126, 'Bệnh viện huyện Bình Chánh'),
    CategoryItem(10127, 'Bệnh viện huyện Củ Chi'),
    CategoryItem(10128, 'Bệnh viện Huyện Nhà Bè'),
    CategoryItem(10130, 'Bệnh viện Vinmec Central Park'),
    CategoryItem(10131, 'Bệnh viện Triều An'),
    CategoryItem(10133, 'Bệnh viện FV'),
    CategoryItem(10160, 'Bệnh viện Đức Khang'),
    CategoryItem(10171, 'Bệnh viện Tâm Đức'),
    CategoryItem(10180, 'Bệnh viện Da Liễu'),
    CategoryItem(10181, 'Bệnh viện Hoàn Mỹ Thủ Đức'),
    CategoryItem(10182, 'Bệnh viện 30/4'),
    CategoryItem(10183, 'Bệnh viện 7A'),
    CategoryItem(10190, 'Bệnh viện Quân Y 175'),
    CategoryItem(10192, 'Bệnh viện Thống Nhất'),
    CategoryItem(10193, 'Bệnh viện Bình Dân'),
    CategoryItem(10200, 'Bệnh viện Tâm Thần'),
    CategoryItem(10201, 'Bệnh viện Truyền máu Huyết học'),
    CategoryItem(10203, 'Viện Tim'),
    CategoryItem(10210, 'Bệnh viện An Sinh'),
    CategoryItem(10214, 'Bệnh viện Đa khoa Quốc tế City'),
    CategoryItem(10216, 'Bệnh viện Đa khoa Tâm Trí Sài Gòn'),
    CategoryItem(10227, 'Bệnh viện Phụ Sản MêKông'),
    CategoryItem(10228, 'Bệnh viện Phụ sản Quốc Tế Sài Gòn'),
    CategoryItem(10285, 'Bệnh viện Đa khoa Tâm Anh'),
    CategoryItem(10341, 'Bệnh viện Nguyễn Trãi'),
    CategoryItem(11993, 'Trung tâm Kiểm soát bệnh tật Thành phố'),
    CategoryItem(25574, 'Bệnh viện Hoàn Mỹ'),
    CategoryItem(25579, 'Bệnh viện Đa khoa Tâm Anh Tân Bình'),
    CategoryItem(25683, 'Bệnh viện hoặc Phòng Khám khác'),
    CategoryItem(25882, 'Bệnh viện Y học cổ truyền tỉnh'),
    CategoryItem(25883, 'Bệnh viện đa khoa tỉnh Bình Dương'),
    CategoryItem(25889, 'Bệnh viện Quốc tế Becamex'),
    CategoryItem(25892, 'Bệnh viện Phụ Sản Nhi Bình Dương'),
    CategoryItem(25894, 'Bệnh viện đa khoa Quốc tế Hạnh Phúc'),
    CategoryItem(25901, 'Bệnh viện Đa Khoa Bà Rịa'),
    CategoryItem(25902, 'Bệnh viện Đa khoa Vũng Tàu'),
    CategoryItem(34757, 'Bệnh viện Từ Dũ CS2'),
    CategoryItem(34722, 'Phòng Khám đa khoa quốc tế Vinmec Grand Park'),
  ];

  // ── CoSoDieuTri — alias CoSoBaoCao (cùng danh sách) ─────────────────────
  static List<CategoryItem> get coSoDieuTri => coSoBaoCao;

  // ── Helper: tìm CategoryItem theo Id ─────────────────────────────────────
  static CategoryItem? findById(List<CategoryItem> list, int id) {
    try { return list.firstWhere((e) => e.id == id); } catch (_) { return null; }
  }

  /// Tìm CategoryItem theo Name (không phân biệt hoa thường)
  static CategoryItem? findByName(List<CategoryItem> list, String name) {
    try {
      return list.firstWhere((e) => e.name.toLowerCase() == name.toLowerCase());
    } catch (_) { return null; }
  }

  /// Lấy tên từ id — trả về null nếu không tìm thấy
  static String? nameById(List<CategoryItem> list, int? id) {
    if (id == null) return null;
    return findById(list, id)?.name;
  }
}
