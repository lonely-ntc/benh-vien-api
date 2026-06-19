/**
 * Format dữ liệu bệnh nhân từ Firestore sang chuẩn API
 * - Thông tin cá nhân: text
 * - Danh mục: chỉ lấy id
 * - Không có dữ liệu: null
 */
export function formatBenhNhanToAPI(data) {
  // Helper: lấy id từ object {id, name} hoặc trả về null
  const getId = (obj) => obj?.id?.toString() || null;
  
  return {
    Id: null,
    UnitId: null,
    MaBenhNhan: data.benhNhanId || data.cccd || null,
    HoTen: data.hoTen || null,
    NgaySinh: data.ngaySinh || null,
    GioiTinh: getId(data.gioiTinh),
    DanTocId: getId(data.danToc),
    MaDinhDanhCaNhan: data.cccd || null,
    SDT: data.soDienThoai || null,
    BHYT: data.baoHiemYTe || null,
    NgheNghiep: data.ngheNghiep || null,
    DiaChi: data.diaChi || null,
    CityId: getId(data.tinh),
    WardId: data.phuong || null,
    NhomMau: data.nhomMau || null,
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
    DonViDieuTra: data.donViDieuTra || null,
    PhongKham: data.phongKham || null,
    TrangThai: data.trangThai || null,
    SoThuTu: data.soThuTu || null,
  };
}

/**
 * Format dữ liệu bệnh truyền nhiễm từ Firestore sang chuẩn API
 */
export function formatBenhTNToAPI(data) {
  const getId = (obj) => obj?.id?.toString() || null;
  
  return {
    Id: null,
    UnitId: null,
    BenhAnId: data.benhAnId || null,
    HoTen: data.hoTen || null,
    NgaySinh: data.ngaySinh || null,
    GioiTinh: getId(data.gioiTinh),
    DanTocId: getId(data.danToc),
    MaDinhDanhCaNhan: data.maDinhDanhCaNhan || null,
    TenNguoiBaoHo: data.tenNguoiBaoHo || null,
    SDT: data.sdt || null,
    CoThai: getId(data.coThai),
    TuanThai: data.tuanThai || null,
    NgheNghiep: data.ngheNghiep || null,
    DiaChiNoiLamViec_Hoc: data.diaChiNoiLamViec || null,
    NoiLamViec_Hoc: data.noiLamViec || null,
    CityId_Hoc: getId(data.cityIdHoc),
    WardId_Hoc: data.wardIdHoc || null,
    NoiLamViec_CityId: getId(data.noiLamViecCityId),
    NoiLamViec_WardId: data.noiLamViecWardId || null,
    NoiOHienNay: data.noiOHienNay || null,
    CityId: getId(data.cityId),
    WardId: data.wardId || null,
    NoiOHienNay_CityId: getId(data.noiOHienNayCityId),
    NoiOHienNay_WardId: data.noiOHienNayWardId || null,
    NoiOHienNay_KhuPho: data.noiOHienNayKhuPho || null,
    KhuPhoAp: data.khuPhoAp || null,
    SoHSBA: data.soHSBA || null,
    CoSoDieuTri: getId(data.coSoDieuTri),
    CityId_CSDT: getId(data.cityIdCSDT),
    ChanDoanBenh: getId(data.chanDoanBenh),
    PhanDoBenh: getId(data.phanDoBenh),
    ThongTinDieuTri: data.thongTinDieuTri?.name || null,
    ChanDoanBienChung: data.chanDoanBienChung || null,
    ChanDoanBenhKemTheo: data.chanDoanBenhKemTheo || null,
    BenhNenKemTheoId: getId(data.benhNenKemTheo),
    NgayKhoiPhat: data.ngayKhoiPhat || null,
    NgayNhapVien: data.ngayNhapVien || null,
    NgayXV_TV_CV: data.ngayXVTVCV || null,
    PhanLoaiChanDoan: getId(data.phanLoaiChanDoan),
    LayMauXN: data.layMauXN?.name || null,
    LoaiBenhPham: getId(data.loaiBenhPham),
    DonViThucHienXN: data.donViThucHienXN || null,
    NgayLayMau: data.ngayLayMau || null,
    LoaiXN: getId(data.loaiXN),
    KetQuaXN: getId(data.ketQuaXN),
    TinhTrangTiem: getId(data.tinhTrangTiem),
    HinhThucDieuTri: getId(data.hinhThucDieuTri),
    ChanDoanChinh: data.chanDoanChinh || null,
    SoMuiTiemUong: data.soMuiTiemUong || null,
    TienSuDichTe: data.tienSuDichTe || null,
    NguoiDieuTraDichTe: data.nguoiDieuTraDichTe || null,
    SDTNguoiDieuTraDTe: data.sdtNguoiDieuTraDTe || null,
    DonViDieuTra: data.donViDieuTra || null,
    EmailDonViDieuTra: data.emailDonViDieuTra || null,
    NgayBaoCao: data.ngayBaoCao || null,
    NguoiBaoCao: data.nguoiBaoCao || null,
    SDTNguoiBaoCao: data.sdtNguoiBaoCao || null,
    EmailNguoiBaoCao: data.emailNguoiBaoCao || null,
    PhanDoBenhText: null,
  };
}
