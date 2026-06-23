/**
 * Format dữ liệu bệnh nhân từ Firestore sang chuẩn API
 * - Thông tin cá nhân: text (trả về "" nếu null)
 * - Danh mục: chỉ trả về id
 */
export function formatBenhNhanToAPI(data) {
  // Helper: lấy id, trả về "" nếu null
  const getId = (obj) => {
    if (obj === null || obj === undefined) return "";
    if (typeof obj === 'string' || typeof obj === 'number') return obj.toString();
    return obj?.id?.toString() || "";
  };
  
  return {
    Id: data.benhNhanId || null,
    UnitId: null,
    MaBenhNhan: data.benhNhanId || data.cccd || "",
    HoTen: data.hoTen || "",
    NgaySinh: data.ngaySinh || "",
    
    // Giới tính: chỉ id
    GioiTinhId: getId(data.gioiTinh),
    
    // Dân tộc: chỉ id
    DanTocId: getId(data.danToc),
    
    MaDinhDanhCaNhan: data.cccd || "",
    SDT: data.soDienThoai || "",
    BHYT: data.baoHiemYTe || "",
    
    // Nghề nghiệp: chỉ id
    NgheNghiepId: getId(data.ngheNghiep),
    
    DiaChi: data.diaChi || "",
    
    // Tỉnh: chỉ id
    CityId: getId(data.tinh),
    
    Ward: data.phuong || "",
    WardId: data.phuong || "",
    
    NhomMau: data.nhomMau || "",
    
    // Bệnh nền: chỉ id
    BenhNenId: getId(data.benhNen),
    
    // Bệnh truyền nhiễm: chỉ id
    BenhTruyenNhiemId: getId(data.benhTruyenNhiem),
    
    // Tình trạng tiêm chủng: chỉ id
    TinhTrangTiemChungId: getId(data.tinhTrangTiemChung),
    
    // Dị ứng: chỉ id
    CoKhongId: getId(data.coKhong),
    
    // Điều trị: chỉ id
    DieuTriId: getId(data.dieuTri),
    
    // Hình thức điều trị: chỉ id
    HinhThucDieuTriId: getId(data.hinhThucDieuTri),
    
    // Chẩn đoán bệnh: chỉ id
    ChanDoanBenhId: getId(data.chanDoanBenh),
    
    // Phân loại chẩn đoán: chỉ id
    PhanLoaiChanDoanId: getId(data.phanLoaiChanDoan),
    
    // Phân độ bệnh: chỉ id
    PhanDoBenhId: getId(data.phanDoBenh),
    
    // Loại bệnh phẩm: chỉ id
    LoaiBenhPhamId: getId(data.loaiBenhPham),
    
    // Loại xét nghiệm: chỉ id
    LoaiXetNghiemId: getId(data.loaiXetNghiem),
    
    // Kết quả xét nghiệm: chỉ id
    KetQuaXetNghiemId: getId(data.ketQuaXetNghiem),
    
    // Cơ sở báo cáo: chỉ id
    CoSoBaoCaoId: getId(data.coSoBaoCao),
    
    // Cơ sở điều trị: chỉ id
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
 * - Danh mục: chỉ trả về id
 */
export function formatBenhTNToAPI(data) {
  // Helper: lấy id, trả về "" nếu null
  const getId = (obj) => {
    if (obj === null || obj === undefined) return "";
    if (typeof obj === 'string' || typeof obj === 'number') return obj.toString();
    return obj?.id?.toString() || "";
  };
  
  return {
    Id: data.benhAnId || null,
    UnitId: null,
    MaBenhNhan: data.benhAnId || "",
    HoTen: data.hoTen || "",
    NgaySinh: data.ngaySinh || "",
    
    GioiTinhId: getId(data.gioiTinh),
    DanTocId: getId(data.danTocId),
    
    MaDinhDanhCaNhan: data.maDinhDanhCaNhan || "",
    TenNguoiBaoHo: data.tenNguoiBaoHo || "",
    SDT: data.sdt || "",
    
    CoThaiId: getId(data.coThai),
    TuanThai: data.tuanThai || null,
    NgheNghiepId: getId(data.ngheNghiep),
    
    DiaChiNoiLamViec_Hoc: data.diaChiNoiLamViec || "",
    NoiLamViec_Hoc: data.noiLamViec || "",
    
    CityId_Hoc: getId(data.cityIdHoc),
    WardId_Hoc: getId(data.wardIdHoc),
    NoiLamViec_CityId: getId(data.noiLamViecCityId),
    NoiLamViec_WardId: getId(data.noiLamViecWardId),
    
    NoiOHienNay: data.noiOHienNay || "",
    CityId: getId(data.cityId),
    WardId: getId(data.wardId),
    NoiOHienNay_CityId: getId(data.noiOHienNayCityId),
    NoiOHienNay_WardId: getId(data.noiOHienNayWardId),
    NoiOHienNay_KhuPho: data.noiOHienNayKhuPho || null,
    
    KhuPhoAp: data.khuPhoAp || "",
    SoHSBA: data.soHSBA || "",
    
    CoSoDieuTriId: getId(data.coSoDieuTri),
    CityId_CSDT: getId(data.cityIdCSDT),
    
    ChanDoanBenhId: getId(data.chanDoanBenh),
    PhanDoBenhId: getId(data.phanDoBenh),
    
    ThongTinDieuTri: data.thongTinDieuTri || "",
    ChanDoanBienChung: data.chanDoanBienChung || "",
    ChanDoanBenhKemTheo: data.chanDoanBenhKemTheo || "",
    
    BenhNenKemTheoId: getId(data.benhNenKemTheo),
    
    NgayKhoiPhat: data.ngayKhoiPhat || "",
    NgayNhapVien: data.ngayNhapVien || "",
    NgayXV_TV_CV: data.ngayXVTVCV || null,
    
    PhanLoaiChanDoanId: getId(data.phanLoaiChanDoan),
    LayMauXN: data.layMauXN || "",
    LoaiBenhPhamId: getId(data.loaiBenhPham),
    
    DonViThucHienXN: data.donViThucHienXN || "",
    NgayLayMau: data.ngayLayMau || "",
    
    LoaiXNId: getId(data.loaiXN),
    KetQuaXNId: getId(data.ketQuaXN),
    TinhTrangTiemId: getId(data.tinhTrangTiem),
    HinhThucDieuTriId: getId(data.hinhThucDieuTri),
    
    ChanDoanChinh: data.chanDoanChinh || null,
    SoMuiTiemUong: data.soMuiTiemUong || "",
    TienSuDichTe: data.tienSuDichTe || "",
    NguoiDieuTraDichTe: data.nguoiDieuTraDichTe || "",
    SDTNguoiDieuTraDTe: data.sdtNguoiDieuTraDTe || "",
    
    DonViDieuTraId: getId(data.donViDieuTra),
    
    EmailDonViDieuTra: data.emailDonViDieuTra || "",
    NgayBaoCao: data.ngayBaoCao || "",
    NguoiBaoCao: data.nguoiBaoCao || "",
    SDTNguoiBaoCao: data.sdtNguoiBaoCao || "",
    EmailNguoiBaoCao: data.emailNguoiBaoCao || "",
    PhanDoBenhText: null,
  };
}
