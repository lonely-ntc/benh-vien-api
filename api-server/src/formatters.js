/**
 * Format dữ liệu bệnh nhân từ Firestore sang chuẩn API
 * - Thông tin cá nhân: text (trả về "" nếu null)
 * - Danh mục: chỉ lấy id (trả về "" nếu null)
 * - Id: sử dụng benhNhanId từ Firestore thay vì null
 */
export function formatBenhNhanToAPI(data) {
  // Helper: lấy id hoặc giá trị text, trả về "" nếu null
  const getId = (obj) => {
    if (obj === null || obj === undefined) return "";
    if (typeof obj === 'string' || typeof obj === 'number') return obj.toString();
    return obj?.id?.toString() || "";
  };
  
  const getText = (val) => {
    if (val === null || val === undefined) return "";
    if (typeof val === 'string') return val;
    return val.toString();
  };
  
  return {
    Id: data.benhNhanId || null,  // Sử dụng benhNhanId từ Firestore (VD: BNO158)
    UnitId: null,
    MaBenhNhan: data.benhNhanId || data.cccd || "",
    HoTen: data.hoTen || "",
    NgaySinh: data.ngaySinh || "",
    GioiTinh: getId(data.gioiTinh),
    DanTocId: getId(data.danToc),
    MaDinhDanhCaNhan: data.cccd || "",
    SDT: data.soDienThoai || "",
    BHYT: data.baoHiemYTe || "",
    NgheNghiep: getId(data.ngheNghiep) || "",
    DiaChi: data.diaChi || "",
    CityId: getId(data.tinh),
    WardId: getText(data.phuong) || "",
    NhomMau: data.nhomMau || "",
    BenhNen: getId(data.benhNen),
    BenhTruyenNhiem: getId(data.benhTruyenNhiem),
    TinhTrangTiemChung: getId(data.tinhTrangTiemChung),
    CoKhong: getId(data.coKhong),
    DieuTri: getId(data.dieuTri),
    HinhThucDieuTri: getId(data.hinhThucDieuTri),
    ChanDoanBenh: getId(data.chanDoanBenh),
    PhanLoaiChanDoan: getId(data.phanLoaiChanDoan),
    PhanDoBenh: getId(data.phanDoBenh),
    LoaiBenhPham: getId(data.loaiBenhPham),
    LoaiXetNghiem: getId(data.loaiXetNghiem),
    KetQuaXetNghiem: getId(data.ketQuaXetNghiem),
    CoSoBaoCao: getId(data.coSoBaoCao),
    CoSoDieuTri: getId(data.coSoDieuTri),
    DonViDieuTra: getText(data.donViDieuTra),
    PhongKham: data.phongKham || "",
    TrangThai: data.trangThai || "",
    SoThuTu: data.soThuTu || null,
  };
}

/**
 * Format dữ liệu bệnh truyền nhiễm từ Firestore sang chuẩn API
 * - Id: sử dụng benhAnId từ Firestore thay vì null
 */
export function formatBenhTNToAPI(data) {
  // Helper: lấy id hoặc giá trị text, trả về "" nếu null
  const getId = (obj) => {
    if (obj === null || obj === undefined) return "";
    if (typeof obj === 'string' || typeof obj === 'number') return obj.toString();
    return obj?.id?.toString() || "";
  };
  
  const getText = (val) => {
    if (val === null || val === undefined) return "";
    if (typeof val === 'string') return val;
    return val.toString();
  };
  
  return {
    Id: data.benhAnId || null,  // Sử dụng benhAnId từ Firestore
    UnitId: null,
    MaBenhNhan: data.benhAnId || "",
    HoTen: data.hoTen || "",
    NgaySinh: data.ngaySinh || "",
    GioiTinh: getId(data.gioiTinh),
    DanTocId: getId(data.danToc),
    MaDinhDanhCaNhan: data.maDinhDanhCaNhan || "",
    TenNguoiBaoHo: data.tenNguoiBaoHo || "",
    SDT: data.sdt || "",
    CoThai: getId(data.coThai) || null,
    TuanThai: data.tuanThai || null,
    NgheNghiep: getId(data.ngheNghiep) || "",
    DiaChiNoiLamViec_Hoc: data.diaChiNoiLamViec || "",
    NoiLamViec_Hoc: data.noiLamViec || "",
    CityId_Hoc: getId(data.cityIdHoc) || "",
    WardId_Hoc: getText(data.wardIdHoc) || "",
    NoiLamViec_CityId: getId(data.noiLamViecCityId) || null,
    NoiLamViec_WardId: getText(data.noiLamViecWardId) || null,
    NoiOHienNay: data.noiOHienNay || "",
    CityId: getId(data.cityId) || "",
    WardId: getText(data.wardId) || "",
    NoiOHienNay_CityId: getId(data.noiOHienNayCityId) || null,
    NoiOHienNay_WardId: getText(data.noiOHienNayWardId) || null,
    NoiOHienNay_KhuPho: data.noiOHienNayKhuPho || null,
    KhuPhoAp: getText(data.khuPhoAp) || "",
    SoHSBA: data.soHSBA || "",
    CoSoDieuTri: getId(data.coSoDieuTri) || "",
    CityId_CSDT: getId(data.cityIdCSDT) || "",
    ChanDoanBenh: getId(data.chanDoanBenh) || "",
    PhanDoBenh: getId(data.phanDoBenh) || "",
    ThongTinDieuTri: data.thongTinDieuTri?.name || data.thongTinDieuTri || "",
    ChanDoanBienChung: data.chanDoanBienChung || "",
    ChanDoanBenhKemTheo: data.chanDoanBenhKemTheo || "",
    BenhNenKemTheoId: getId(data.benhNenKemTheo) || "",
    NgayKhoiPhat: data.ngayKhoiPhat || "",
    NgayNhapVien: data.ngayNhapVien || "",
    NgayXV_TV_CV: data.ngayXVTVCV || null,
    PhanLoaiChanDoan: getId(data.phanLoaiChanDoan) || "",
    LayMauXN: data.layMauXN?.name || data.layMauXN || "",
    LoaiBenhPham: getId(data.loaiBenhPham) || "",
    DonViThucHienXN: data.donViThucHienXN || "",
    NgayLayMau: data.ngayLayMau || "",
    LoaiXN: getId(data.loaiXN) || "",
    KetQuaXN: getId(data.ketQuaXN) || "",
    TinhTrangTiem: getId(data.tinhTrangTiem) || "",
    HinhThucDieuTri: getId(data.hinhThucDieuTri) || "",
    ChanDoanChinh: data.chanDoanChinh || null,
    SoMuiTiemUong: data.soMuiTiemUong || "",
    TienSuDichTe: data.tienSuDichTe || "",
    NguoiDieuTraDichTe: data.nguoiDieuTraDichTe || "",
    SDTNguoiDieuTraDTe: data.sdtNguoiDieuTraDTe || "",
    DonViDieuTra: getId(data.donViDieuTra) || "",
    EmailDonViDieuTra: data.emailDonViDieuTra || "",
    NgayBaoCao: data.ngayBaoCao || "",
    NguoiBaoCao: data.nguoiBaoCao || "",
    SDTNguoiBaoCao: data.sdtNguoiBaoCao || "",
    EmailNguoiBaoCao: data.emailNguoiBaoCao || "",
    PhanDoBenhText: null,
  };
}
