/**
 * Format dữ liệu bệnh nhân từ Firestore sang chuẩn API
 * Đầy đủ 51 trường như bệnh truyền nhiễm
 */
export function formatBenhNhanToAPI(data) {
  // Helper: lấy id, trả về null nếu không có
  const getId = (obj) => {
    if (obj === null || obj === undefined) return null;
    if (typeof obj === 'string') return obj;
    if (typeof obj === 'number') return obj.toString();
    return obj?.id?.toString() || null;
  };
  
  return {
    // Thông tin cơ bản (1-3)
    Id: null,
    UnitId: null,
    MaBenhNhan: data.benhNhanId || data.cccd || "", // 1
    
    // Thông tin cá nhân (2-15)
    HoTen: data.hoTen || "", // 2
    NgaySinh: data.ngaySinh || "", // 3
    GioiTinh: getId(data.gioiTinh), // 4
    DanTocId: getId(data.danToc), // 5
    MaDinhDanhCaNhan: data.cccd || "", // 6
    TenNguoiBaoHo: data.tenNguoiBaoHo || "", // 7
    SDT: data.soDienThoai || "", // 8
    CoThai: getId(data.coThai), // 9
    TuanThai: data.tuanThai || null, // 10
    NgheNghiep: data.ngheNghiep || "", // 11
    DiaChiNoiLamViec_Hoc: data.diaChiNoiLamViecHoc || "", // 12
    NoiLamViec_Hoc: data.noiLamViecHoc || "", // 13
    CityId_Hoc: getId(data.cityIdHoc), // 14
    WardId_Hoc: data.wardIdHoc || "", // 15
    
    // Địa chỉ bổ sung
    NoiLamViec_CityId: null,
    NoiLamViec_WardId: null,
    
    // Địa chỉ hiện tại (16-20)
    NoiOHienNay: data.noiOHienNay || "", // 16
    CityId: getId(data.tinh), // 17
    WardId: data.phuong || "", // 18
    NoiOHienNay_CityId: null,
    NoiOHienNay_WardId: null,
    NoiOHienNay_KhuPho: null,
    KhuPhoAp: data.khuPhoAp || "", // 19
    SoHSBA: data.soHSBA || "", // 20
    
    // Điều trị & Chẩn đoán (21-33)
    CoSoDieuTri: getId(data.coSoDieuTri), // 21
    CityId_CSDT: getId(data.cityIdCSDT), // 22
    HinhThucDieuTri: getId(data.hinhThucDieuTri), // 23
    ChanDoanBenh: getId(data.chanDoanBenh), // 24
    PhanDoBenh: getId(data.phanDoBenh), // 25
    ThongTinDieuTri: data.thongTinDieuTri || "", // 26
    ChanDoanBienChung: data.chanDoanBienChung || "", // 27
    ChanDoanBenhKemTheo: data.chanDoanBenhKemTheo || "", // 28
    BenhNenKemTheoId: getId(data.benhNenKemTheo), // 29
    NgayKhoiPhat: data.ngayKhoiPhat || "", // 30
    NgayNhapVien: data.ngayNhapVien || "", // 31
    NgayXV_TV_CV: data.ngayXVTVCV || null, // 32
    PhanLoaiChanDoan: getId(data.phanLoaiChanDoan), // 33
    
    // Xét nghiệm (34-39)
    LayMauXN: data.layMauXN || "", // 34
    LoaiBenhPham: getId(data.loaiBenhPham), // 35
    DonViThucHienXN: data.donViThucHienXN || "", // 36
    NgayLayMau: data.ngayLayMau || "", // 37
    LoaiXN: getId(data.loaiXetNghiem), // 38
    KetQuaXN: getId(data.ketQuaXetNghiem), // 39
    
    // Tiêm chủng (40-41)
    TinhTrangTiem: getId(data.tinhTrangTiemChung), // 40
    SoMuiTiemUong: data.soMuiTiemUong?.toString() || "", // 41
    
    // Dịch tễ (42-46)
    TienSuDichTe: data.tienSuDichTe || "", // 42
    NguoiDieuTraDichTe: data.nguoiDieuTraDichTe || "", // 43
    SDTNguoiDieuTraDTe: data.sdtNguoiDieuTraDTe || "", // 44
    DonViDieuTra: data.donViDieuTra || "", // 45
    EmailDonViDieuTra: data.emailDonViDieuTra || "", // 46
    
    // Báo cáo (47-51)
    NgayBaoCao: data.ngayBaoCao || "", // 47
    NguoiBaoCao: data.nguoiBaoCao || "", // 48
    SDTNguoiBaoCao: data.sdtNguoiBaoCao || "", // 49
    EmailNguoiBaoCao: data.emailNguoiBaoCao || "", // 50
    PhanDoBenhText: data.phanDoBenhText || null, // 51
    
    // Trường bổ sung
    ChanDoanChinh: null,
    Ward: data.phuong || "",
    NhomMau: data.nhomMau || "",
    BHYT: data.baoHiemYTe || "",
    CoSoBaoCaoId: getId(data.coSoBaoCao),
    PhongKham: data.phongKham || "",
    TrangThai: data.trangThai || "Chờ",
    SoThuTu: data.soThuTu || null,
  };
}

/**
 * Format dữ liệu bệnh truyền nhiễm từ Firestore sang chuẩn API
 * Dựa theo JSON mẫu với đầy đủ 51 trường
 */
export function formatBenhTNToAPI(data) {
  // Helper: lấy id hoặc giá trị string, trả về null nếu không có
  const getId = (obj) => {
    if (obj === null || obj === undefined) return null;
    if (typeof obj === 'string') return obj;
    if (typeof obj === 'number') return obj.toString();
    return obj?.id?.toString() || null;
  };
  
  return {
    // Thông tin cơ bản (1-3)
    Id: null, // Được API tự sinh
    UnitId: null,
    MaBenhNhan: data.benhAnId || "", // Mã bệnh án (field 1)
    
    // Thông tin cá nhân (2-15)
    HoTen: data.hoTen || "", // 2
    NgaySinh: data.ngaySinh || "", // 3
    GioiTinh: getId(data.gioiTinh), // 4
    DanTocId: getId(data.danToc), // 5
    MaDinhDanhCaNhan: data.maDinhDanhCaNhan || "", // 6
    TenNguoiBaoHo: data.tenNguoiBaoHo || "", // 7
    SDT: data.sdt || "", // 8
    CoThai: getId(data.coThai), // 9
    TuanThai: data.tuanThai || null, // 10
    NgheNghiep: getId(data.ngheNghiep), // 11 - Lưu ý: có thể là string hoặc id
    DiaChiNoiLamViec_Hoc: data.diaChiNoiLamViec || "", // 12
    NoiLamViec_Hoc: data.noiLamViec || "", // 13
    CityId_Hoc: getId(data.cityIdHoc), // 14
    WardId_Hoc: getId(data.wardIdHoc), // 15
    
    // Địa chỉ bổ sung
    NoiLamViec_CityId: getId(data.noiLamViecCityId),
    NoiLamViec_WardId: getId(data.noiLamViecWardId),
    
    // Địa chỉ hiện tại (16-20)
    NoiOHienNay: data.noiOHienNay || "", // 16
    CityId: getId(data.cityId), // 17
    WardId: getId(data.wardId), // 18 - phường xã
    NoiOHienNay_CityId: getId(data.noiOHienNayCityId),
    NoiOHienNay_WardId: getId(data.noiOHienNayWardId),
    NoiOHienNay_KhuPho: null,
    KhuPhoAp: getId(data.khuPhoAp) || data.khuPhoAp || "", // 19
    SoHSBA: data.soHSBA || "", // 20
    
    // Điều trị & Chẩn đoán (21-33)
    CoSoDieuTri: getId(data.coSoDieuTri), // 21
    CityId_CSDT: getId(data.cityIdCSDT), // 22
    HinhThucDieuTri: getId(data.hinhThucDieuTri), // 23
    ChanDoanBenh: getId(data.chanDoanBenh), // 24
    PhanDoBenh: getId(data.phanDoBenh), // 25
    ThongTinDieuTri: data.thongTinDieuTri || "", // 26
    ChanDoanBienChung: data.chanDoanBienChung || "", // 27
    ChanDoanBenhKemTheo: data.chanDoanBenhKemTheo || "", // 28
    BenhNenKemTheoId: getId(data.benhNenKemTheo), // 29
    NgayKhoiPhat: data.ngayKhoiPhat || "", // 30
    NgayNhapVien: data.ngayNhapVien || "", // 31
    NgayXV_TV_CV: data.ngayXVTVCV || null, // 32
    PhanLoaiChanDoan: getId(data.phanLoaiChanDoan), // 33
    
    // Xét nghiệm (34-39)
    LayMauXN: data.layMauXN || "", // 34
    LoaiBenhPham: getId(data.loaiBenhPham), // 35
    DonViThucHienXN: data.donViThucHienXN || "", // 36
    NgayLayMau: data.ngayLayMau || "", // 37
    LoaiXN: getId(data.loaiXN), // 38
    KetQuaXN: getId(data.ketQuaXN), // 39
    
    // Tiêm chủng (40-41)
    TinhTrangTiem: getId(data.tinhTrangTiem), // 40
    SoMuiTiemUong: data.soMuiTiemUong?.toString() || "", // 41
    
    // Dịch tễ (42-46)
    TienSuDichTe: data.tienSuDichTe || "", // 42
    NguoiDieuTraDichTe: data.nguoiDieuTraDichTe || "", // 43
    SDTNguoiDieuTraDTe: data.sdtNguoiDieuTraDTe || "", // 44
    DonViDieuTra: getId(data.donViDieuTra), // 45
    EmailDonViDieuTra: data.emailDonViDieuTra || "", // 46
    
    // Báo cáo (47-51)
    NgayBaoCao: data.ngayBaoCao || "", // 47
    NguoiBaoCao: data.nguoiBaoCao || "", // 48
    SDTNguoiBaoCao: data.sdtNguoiBaoCao || "", // 49
    EmailNguoiBaoCao: data.emailNguoiBaoCao || "", // 50
    PhanDoBenhText: data.phanDoBenhText || null, // 51
    
    // Trường bổ sung
    ChanDoanChinh: data.chanDoanChinh || null,
  };
}
