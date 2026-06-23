/**
 * Format dữ liệu bệnh nhân từ Firestore sang chuẩn API
 * - Thông tin cá nhân: text (trả về "" nếu null)
 * - Danh mục: name và nameId riêng biệt
 */
export function formatBenhNhanToAPI(data) {
  // Helper: lấy id, trả về "" nếu null
  const getId = (obj) => {
    if (obj === null || obj === undefined) return "";
    if (typeof obj === 'string' || typeof obj === 'number') return obj.toString();
    return obj?.id?.toString() || "";
  };

  // Helper: lấy name, trả về "" nếu null
  const getName = (obj) => {
    if (obj === null || obj === undefined) return "";
    if (typeof obj === 'string') return obj;
    return obj?.name?.toString() || "";
  };
  
  return {
    Id: data.benhNhanId || null,
    UnitId: null,
    MaBenhNhan: data.benhNhanId || data.cccd || "",
    HoTen: data.hoTen || "",
    NgaySinh: data.ngaySinh || "",
    
    // Giới tính: cả name và id
    GioiTinh: getName(data.gioiTinh),
    GioiTinhId: getId(data.gioiTinh),
    
    // Dân tộc: cả name và id
    DanToc: getName(data.danToc),
    DanTocId: getId(data.danToc),
    
    MaDinhDanhCaNhan: data.cccd || "",
    SDT: data.soDienThoai || "",
    BHYT: data.baoHiemYTe || "",
    
    // Nghề nghiệp: cả name và id
    NgheNghiep: getName(data.ngheNghiep),
    NgheNghiepId: getId(data.ngheNghiep),
    
    DiaChi: data.diaChi || "",
    
    // Tỉnh: cả name và id
    City: getName(data.tinh),
    CityId: getId(data.tinh),
    
    Ward: data.phuong || "",
    WardId: data.phuong || "",
    
    NhomMau: data.nhomMau || "",
    
    // Bệnh nền: cả name và id
    BenhNen: getName(data.benhNen),
    BenhNenId: getId(data.benhNen),
    
    // Bệnh truyền nhiễm: cả name và id
    BenhTruyenNhiem: getName(data.benhTruyenNhiem),
    BenhTruyenNhiemId: getId(data.benhTruyenNhiem),
    
    // Tình trạng tiêm chủng: cả name và id
    TinhTrangTiemChung: getName(data.tinhTrangTiemChung),
    TinhTrangTiemChungId: getId(data.tinhTrangTiemChung),
    
    // Dị ứng: cả name và id
    CoKhong: getName(data.coKhong),
    CoKhongId: getId(data.coKhong),
    
    // Điều trị: cả name và id
    DieuTri: getName(data.dieuTri),
    DieuTriId: getId(data.dieuTri),
    
    // Hình thức điều trị: cả name và id
    HinhThucDieuTri: getName(data.hinhThucDieuTri),
    HinhThucDieuTriId: getId(data.hinhThucDieuTri),
    
    // Chẩn đoán bệnh: cả name và id
    ChanDoanBenh: getName(data.chanDoanBenh),
    ChanDoanBenhId: getId(data.chanDoanBenh),
    
    // Phân loại chẩn đoán: cả name và id
    PhanLoaiChanDoan: getName(data.phanLoaiChanDoan),
    PhanLoaiChanDoanId: getId(data.phanLoaiChanDoan),
    
    // Phân độ bệnh: cả name và id
    PhanDoBenh: getName(data.phanDoBenh),
    PhanDoBenhId: getId(data.phanDoBenh),
    
    // Loại bệnh phẩm: cả name và id
    LoaiBenhPham: getName(data.loaiBenhPham),
    LoaiBenhPhamId: getId(data.loaiBenhPham),
    
    // Loại xét nghiệm: cả name và id
    LoaiXetNghiem: getName(data.loaiXetNghiem),
    LoaiXetNghiemId: getId(data.loaiXetNghiem),
    
    // Kết quả xét nghiệm: cả name và id
    KetQuaXetNghiem: getName(data.ketQuaXetNghiem),
    KetQuaXetNghiemId: getId(data.ketQuaXetNghiem),
    
    // Cơ sở báo cáo: cả name và id
    CoSoBaoCao: getName(data.coSoBaoCao),
    CoSoBaoCaoId: getId(data.coSoBaoCao),
    
    // Cơ sở điều trị: cả name và id
    CoSoDieuTri: getName(data.coSoDieuTri),
    CoSoDieuTriId: getId(data.coSoDieuTri),
    
    DonViDieuTra: data.donViDieuTra || "",
    PhongKham: data.phongKham || "",
    TrangThai: data.trangThai || "",
    SoThuTu: data.soThuTu || null,
  };
}

/**
 * Format dữ liệu bệnh truyền nhiễm từ Firestore sang chuẩn API
 * - Thông tin cá nhân: text
 * - Danh mục: name và nameId riêng biệt
 */
export function formatBenhTNToAPI(data) {
  // Helper: lấy id, trả về "" nếu null
  const getId = (obj) => {
    if (obj === null || obj === undefined) return "";
    if (typeof obj === 'string' || typeof obj === 'number') return obj.toString();
    return obj?.id?.toString() || "";
  };

  // Helper: lấy name, trả về "" nếu null
  const getName = (obj) => {
    if (obj === null || obj === undefined) return "";
    if (typeof obj === 'string') return obj;
    return obj?.name?.toString() || "";
  };
  
  return {
    Id: data.benhAnId || null,
    UnitId: null,
    MaBenhNhan: data.benhAnId || "",
    HoTen: data.hoTen || "",
    NgaySinh: data.ngaySinh || "",
    
    GioiTinh: getName(data.gioiTinh),
    GioiTinhId: getId(data.gioiTinh),
    
    DanToc: getName(data.danTocId),
    DanTocId: getId(data.danTocId),
    
    MaDinhDanhCaNhan: data.maDinhDanhCaNhan || "",
    TenNguoiBaoHo: data.tenNguoiBaoHo || "",
    SDT: data.sdt || "",
    
    CoThai: getName(data.coThai),
    CoThaiId: getId(data.coThai),
    
    TuanThai: data.tuanThai || null,
    
    NgheNghiep: getName(data.ngheNghiep),
    NgheNghiepId: getId(data.ngheNghiep),
    
    DiaChiNoiLamViec_Hoc: data.diaChiNoiLamViec || "",
    NoiLamViec_Hoc: data.noiLamViec || "",
    
    CityHoc: getName(data.cityIdHoc),
    CityId_Hoc: getId(data.cityIdHoc),
    
    Ward_Hoc: getName(data.wardIdHoc),
    WardId_Hoc: getId(data.wardIdHoc),
    
    NoiLamViecCity: getName(data.noiLamViecCityId),
    NoiLamViec_CityId: getId(data.noiLamViecCityId),
    
    NoiLamViecWard: getName(data.noiLamViecWardId),
    NoiLamViec_WardId: getId(data.noiLamViecWardId),
    
    NoiOHienNay: data.noiOHienNay || "",
    
    City: getName(data.cityId),
    CityId: getId(data.cityId),
    
    Ward: getName(data.wardId),
    WardId: getId(data.wardId),
    
    NoiOHienNayCity: getName(data.noiOHienNayCityId),
    NoiOHienNay_CityId: getId(data.noiOHienNayCityId),
    
    NoiOHienNayWard: getName(data.noiOHienNayWardId),
    NoiOHienNay_WardId: getId(data.noiOHienNayWardId),
    
    NoiOHienNay_KhuPho: data.noiOHienNayKhuPho || null,
    KhuPhoAp: data.khuPhoAp || "",
    SoHSBA: data.soHSBA || "",
    
    CoSoDieuTri: getName(data.coSoDieuTri),
    CoSoDieuTriId: getId(data.coSoDieuTri),
    
    CityCSĐT: getName(data.cityIdCSDT),
    CityId_CSDT: getId(data.cityIdCSDT),
    
    ChanDoanBenh: getName(data.chanDoanBenh),
    ChanDoanBenhId: getId(data.chanDoanBenh),
    
    PhanDoBenh: getName(data.phanDoBenh),
    PhanDoBenhId: getId(data.phanDoBenh),
    
    ThongTinDieuTri: getName(data.thongTinDieuTri),
    ChanDoanBienChung: data.chanDoanBienChung || "",
    ChanDoanBenhKemTheo: data.chanDoanBenhKemTheo || "",
    
    BenhNenKemTheo: getName(data.benhNenKemTheo),
    BenhNenKemTheoId: getId(data.benhNenKemTheo),
    
    NgayKhoiPhat: data.ngayKhoiPhat || "",
    NgayNhapVien: data.ngayNhapVien || "",
    NgayXV_TV_CV: data.ngayXVTVCV || null,
    
    PhanLoaiChanDoan: getName(data.phanLoaiChanDoan),
    PhanLoaiChanDoanId: getId(data.phanLoaiChanDoan),
    
    LayMauXN: getName(data.layMauXN),
    
    LoaiBenhPham: getName(data.loaiBenhPham),
    LoaiBenhPhamId: getId(data.loaiBenhPham),
    
    DonViThucHienXN: data.donViThucHienXN || "",
    NgayLayMau: data.ngayLayMau || "",
    
    LoaiXN: getName(data.loaiXN),
    LoaiXNId: getId(data.loaiXN),
    
    KetQuaXN: getName(data.ketQuaXN),
    KetQuaXNId: getId(data.ketQuaXN),
    
    TinhTrangTiem: getName(data.tinhTrangTiem),
    TinhTrangTiemId: getId(data.tinhTrangTiem),
    
    HinhThucDieuTri: getName(data.hinhThucDieuTri),
    HinhThucDieuTriId: getId(data.hinhThucDieuTri),
    
    ChanDoanChinh: data.chanDoanChinh || null,
    SoMuiTiemUong: data.soMuiTiemUong || "",
    TienSuDichTe: data.tienSuDichTe || "",
    NguoiDieuTraDichTe: data.nguoiDieuTraDichTe || "",
    SDTNguoiDieuTraDTe: data.sdtNguoiDieuTraDTe || "",
    
    DonViDieuTra: getName(data.donViDieuTra),
    DonViDieuTraId: getId(data.donViDieuTra),
    
    EmailDonViDieuTra: data.emailDonViDieuTra || "",
    NgayBaoCao: data.ngayBaoCao || "",
    NguoiBaoCao: data.nguoiBaoCao || "",
    SDTNguoiBaoCao: data.sdtNguoiBaoCao || "",
    EmailNguoiBaoCao: data.emailNguoiBaoCao || "",
    PhanDoBenhText: null,
  };
}
