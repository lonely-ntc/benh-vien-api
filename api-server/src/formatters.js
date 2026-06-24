/**
 * ═══════════════════════════════════════════════════════════════════════════
 * HELPERS dùng chung
 * ═══════════════════════════════════════════════════════════════════════════
 *
 * Flutter lưu CategoryItem vào Firestore dưới dạng Map: {"id": 263, "name": "Nam"}
 * Các helper bên dưới xử lý đúng cả 3 dạng:
 *   - Map  {"id": ..., "name": ...}  → lấy id hoặc name
 *   - Number (int)                   → toString()
 *   - String                         → giữ nguyên (hoặc null nếu rỗng)
 */

/**
 * Lấy id từ một Firestore field (có thể là Map, number, hoặc string).
 * Trả về string hoặc null.
 */
function getId(obj) {
  if (obj === null || obj === undefined) return null;
  if (typeof obj === 'number') return obj.toString();
  if (typeof obj === 'string') return obj === '' ? null : obj;
  // Map {"id": ..., "name": ...}
  if (typeof obj === 'object' && 'id' in obj) {
    const id = obj.id;
    if (id === null || id === undefined) return null;
    return id.toString();
  }
  return null;
}

/**
 * Lấy name từ một Firestore field (có thể là Map hoặc string thuần).
 * Trả về string hoặc "".
 */
function getName(obj) {
  if (obj === null || obj === undefined) return '';
  if (typeof obj === 'string') return obj;
  if (typeof obj === 'object' && 'name' in obj) return obj.name || '';
  return '';
}

// ═══════════════════════════════════════════════════════════════════════════

/**
 * Format dữ liệu bệnh nhân từ Firestore sang chuẩn API
 *
 * LƯU Ý: Flutter lưu mọi trường CategoryItem dưới dạng Map {"id": int, "name": String}
 * → Dùng getId() để lấy id, getName() để lấy tên hiển thị
 */
export function formatBenhNhanToAPI(data) {
  return {
    // ── Thông tin cơ bản ─────────────────────────────────────────────────
    Id: null,
    UnitId: null,
    MaBenhNhan: data.benhNhanId || data.cccd || '',

    // ── Thông tin cá nhân (2-15) ─────────────────────────────────────────
    HoTen:              data.hoTen || '',
    NgaySinh:           data.ngaySinh || '',
    GioiTinh:           getId(data.gioiTinh),           // Map {id,name}
    DanTocId:           getId(data.danToc),             // Map {id,name}
    MaDinhDanhCaNhan:   data.cccd || '',
    TenNguoiBaoHo:      data.tenNguoiBaoHo || '',
    SDT:                data.soDienThoai || '',
    CoThai:             getId(data.coThai),             // Map {id,name}
    TuanThai:           data.tuanThai || null,
    NgheNghiep:         getId(data.ngheNghiep),         // Map {id,name} — phải dùng getId
    DiaChiNoiLamViec_Hoc: data.diaChiNoiLamViecHoc || '',
    NoiLamViec_Hoc:     data.noiLamViecHoc || '',
    CityId_Hoc:         getId(data.cityIdHoc),          // Map {id,name}
    WardId_Hoc:         data.wardIdHoc || '',

    // Địa chỉ bổ sung
    NoiLamViec_CityId: null,
    NoiLamViec_WardId: null,

    // ── Địa chỉ hiện tại (16-20) ─────────────────────────────────────────
    NoiOHienNay:        data.noiOHienNay || '',
    CityId:             getId(data.tinh),               // Map {id,name}
    WardId:             data.phuong || '',
    NoiOHienNay_CityId: null,
    NoiOHienNay_WardId: null,
    NoiOHienNay_KhuPho: null,
    KhuPhoAp:           data.khuPhoAp || '',
    SoHSBA:             data.soHSBA || '',

    // ── Điều trị & Chẩn đoán (21-33) ─────────────────────────────────────
    CoSoDieuTri:        getId(data.coSoDieuTri),        // Map {id,name}
    CityId_CSDT:        getId(data.cityIdCSDT),         // Map {id,name}
    HinhThucDieuTri:    getId(data.hinhThucDieuTri),    // Map {id,name}
    ChanDoanBenh:       getId(data.chanDoanBenh),       // Map {id,name}
    PhanDoBenh:         getId(data.phanDoBenh),         // Map {id,name}
    ThongTinDieuTri:    getName(data.thongTinDieuTri),  // Map {id,name} → lấy tên text
    ChanDoanBienChung:  data.chanDoanBienChung || '',
    ChanDoanBenhKemTheo: data.chanDoanBenhKemTheo || '',
    BenhNenKemTheoId:   getId(data.benhNenKemTheo),     // Map {id,name}
    NgayKhoiPhat:       data.ngayKhoiPhat || '',
    NgayNhapVien:       data.ngayNhapVien || '',
    NgayXV_TV_CV:       data.ngayXVTVCV || null,
    PhanLoaiChanDoan:   getId(data.phanLoaiChanDoan),   // Map {id,name}

    // ── Xét nghiệm (34-39) — "" khi không có, không trả null ────────────
    LayMauXN:           getId(data.layMauXN) ?? '',     // Map {id,name}
    LoaiBenhPham:       getId(data.loaiBenhPham) ?? '', // Map {id,name}
    DonViThucHienXN:    data.donViThucHienXN || '',
    NgayLayMau:         data.ngayLayMau || '',
    LoaiXN:             getId(data.loaiXetNghiem) ?? '',// Map {id,name}
    KetQuaXN:           getId(data.ketQuaXetNghiem) ?? '', // Map {id,name}

    // ── Tiêm chủng (40-41) ───────────────────────────────────────────────
    TinhTrangTiem:      getId(data.tinhTrangTiemChung), // Map {id,name}
    SoMuiTiemUong:      data.soMuiTiemUong?.toString() || '',

    // ── Dịch tễ (42-46) ──────────────────────────────────────────────────
    TienSuDichTe:       data.tienSuDichTe || '',
    NguoiDieuTraDichTe: data.nguoiDieuTraDichTe || '',
    SDTNguoiDieuTraDTe: data.sdtNguoiDieuTraDTe || '',
    DonViDieuTra:       getId(data.donViDieuTra) ?? data.donViDieuTra ?? '', // có thể Map hoặc string
    EmailDonViDieuTra:  data.emailDonViDieuTra || '',

    // ── Báo cáo (47-51) ──────────────────────────────────────────────────
    NgayBaoCao:         data.ngayBaoCao || '',
    NguoiBaoCao:        data.nguoiBaoCao || '',
    SDTNguoiBaoCao:     data.sdtNguoiBaoCao || '',
    EmailNguoiBaoCao:   data.emailNguoiBaoCao || '',
    PhanDoBenhText:     data.phanDoBenhText || null,

    // ── Trường bổ sung ───────────────────────────────────────────────────
    ChanDoanChinh:  null,
    Ward:           data.phuong || '',
    NhomMau:        data.nhomMau || '',
    BHYT:           data.baoHiemYTe || '',
    CoSoBaoCaoId:   getId(data.coSoBaoCao),
    PhongKham:      data.phongKham || '',
    TrangThai:      data.trangThai || 'Chờ',
    SoThuTu:        data.soThuTu || null,
  };
}

// ═══════════════════════════════════════════════════════════════════════════

/**
 * Format dữ liệu bệnh truyền nhiễm từ Firestore sang chuẩn API
 */
export function formatBenhTNToAPI(data) {
  return {
    // ── Thông tin cơ bản ─────────────────────────────────────────────────
    Id: null,
    UnitId: null,
    MaBenhNhan: data.benhAnId || '',

    // ── Thông tin cá nhân (2-15) ─────────────────────────────────────────
    HoTen:              data.hoTen || '',
    NgaySinh:           data.ngaySinh || '',
    GioiTinh:           getId(data.gioiTinh),
    DanTocId:           getId(data.danToc),
    MaDinhDanhCaNhan:   data.maDinhDanhCaNhan || '',
    TenNguoiBaoHo:      data.tenNguoiBaoHo || '',
    SDT:                data.sdt || '',
    CoThai:             getId(data.coThai),
    TuanThai:           data.tuanThai || null,
    NgheNghiep:         getId(data.ngheNghiep),         // Map {id,name}
    DiaChiNoiLamViec_Hoc: data.diaChiNoiLamViec || '',
    NoiLamViec_Hoc:     data.noiLamViec || '',
    CityId_Hoc:         getId(data.cityIdHoc),
    WardId_Hoc:         getId(data.wardIdHoc),

    // Địa chỉ bổ sung
    NoiLamViec_CityId: getId(data.noiLamViecCityId),
    NoiLamViec_WardId: getId(data.noiLamViecWardId),

    // ── Địa chỉ hiện tại (16-20) ─────────────────────────────────────────
    NoiOHienNay:        data.noiOHienNay || '',
    CityId:             getId(data.cityId),
    WardId:             getId(data.wardId),
    NoiOHienNay_CityId: getId(data.noiOHienNayCityId),
    NoiOHienNay_WardId: getId(data.noiOHienNayWardId),
    NoiOHienNay_KhuPho: null,
    KhuPhoAp:           getId(data.khuPhoAp) ?? data.khuPhoAp ?? '',
    SoHSBA:             data.soHSBA || '',

    // ── Điều trị & Chẩn đoán (21-33) ─────────────────────────────────────
    CoSoDieuTri:        getId(data.coSoDieuTri),
    CityId_CSDT:        getId(data.cityIdCSDT),
    HinhThucDieuTri:    getId(data.hinhThucDieuTri),
    ChanDoanBenh:       getId(data.chanDoanBenh),
    PhanDoBenh:         getId(data.phanDoBenh),
    ThongTinDieuTri:    getName(data.thongTinDieuTri),  // Map {id,name} → lấy tên text
    ChanDoanBienChung:  data.chanDoanBienChung || '',
    ChanDoanBenhKemTheo: data.chanDoanBenhKemTheo || '',
    BenhNenKemTheoId:   getId(data.benhNenKemTheo),
    NgayKhoiPhat:       data.ngayKhoiPhat || '',
    NgayNhapVien:       data.ngayNhapVien || '',
    NgayXV_TV_CV:       data.ngayXVTVCV || null,
    PhanLoaiChanDoan:   getId(data.phanLoaiChanDoan),

    // ── Xét nghiệm (34-39) — "" khi không có ─────────────────────────────
    LayMauXN:           getId(data.layMauXN) ?? '',
    LoaiBenhPham:       getId(data.loaiBenhPham) ?? '',
    DonViThucHienXN:    data.donViThucHienXN || '',
    NgayLayMau:         data.ngayLayMau || '',
    LoaiXN:             getId(data.loaiXN) ?? '',
    KetQuaXN:           getId(data.ketQuaXN) ?? '',

    // ── Tiêm chủng (40-41) ───────────────────────────────────────────────
    TinhTrangTiem:      getId(data.tinhTrangTiem),
    SoMuiTiemUong:      data.soMuiTiemUong?.toString() || '',

    // ── Dịch tễ (42-46) ──────────────────────────────────────────────────
    TienSuDichTe:       data.tienSuDichTe || '',
    NguoiDieuTraDichTe: data.nguoiDieuTraDichTe || '',
    SDTNguoiDieuTraDTe: data.sdtNguoiDieuTraDTe || '',
    DonViDieuTra:       getId(data.donViDieuTra) ?? data.donViDieuTra ?? '',
    EmailDonViDieuTra:  data.emailDonViDieuTra || '',

    // ── Báo cáo (47-51) ──────────────────────────────────────────────────
    NgayBaoCao:         data.ngayBaoCao || '',
    NguoiBaoCao:        data.nguoiBaoCao || '',
    SDTNguoiBaoCao:     data.sdtNguoiBaoCao || '',
    EmailNguoiBaoCao:   data.emailNguoiBaoCao || '',
    PhanDoBenhText:     data.phanDoBenhText || null,

    // ── Trường bổ sung ───────────────────────────────────────────────────
    ChanDoanChinh: data.chanDoanChinh || null,
  };
}
