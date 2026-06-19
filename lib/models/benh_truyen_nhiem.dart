// Model Bệnh Truyền Nhiễm — 51 trường theo chuẩn API
// Các trường danh mục lưu Map {"id": int, "name": String} lên Firestore.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'category_options.dart';

class BenhTruyenNhiem {
  final String id; // Firestore document ID

  // ── 1-6: Thông tin cá nhân ────────────────────────────────────────────
  final String? benhAnId;             // 1. Id — Bệnh án ID
  final String hoTen;                 // 2. HoTen
  final String? ngaySinh;             // 3. NgaySinh — DD/MM/YYYY
  final CategoryItem? gioiTinhItem;   // 4. GioiTinh
  final CategoryItem? danTocItem;     // 5. DanTocId
  final String? maDinhDanhCaNhan;     // 6. MaDinhDanhCaNhan
  final String? tenNguoiBaoHo;              // 7. TenNguoiBaoHo
  final String? sdt;                        // 8. SDT
  final CategoryItem? coThaiItem;           // 9. CoThai
  final int? tuanThai;                      // 10. TuanThai
  final String? ngheNghiep;                 // 11. NgheNghiep (string)
  final String? noiLamViecHoc;              // 12.
  final String? diaChinoiLamViecHoc;        // 13.
  final CategoryItem? cityIdHocItem;        // 14. Tinh nơi làm/học
  final String? wardIdHoc;                  // 15.

  // ── 16-20: Địa chỉ hiện tại ───────────────────────────────────────────
  final String? noiOHienNay;                // 16.
  final CategoryItem? cityIdItem;           // 17. Tinh nơi ở hiện tại
  final String? wardId;                     // 18.
  final String? khuPhoAp;                   // 19.
  final String? soHSBA;                     // 20.

  // ── 21-26: Điều trị & chẩn đoán ──────────────────────────────────────
  final CategoryItem? coSoDieuTriItem;      // 21. CoSoDieuTri
  final CategoryItem? cityIdCSDTItem;       // 22. Tinh CSDT
  final CategoryItem? hinhThucDieuTriItem;  // 23. HinhThucDieuTri
  final CategoryItem? chanDoanBenhItem;     // 24. ChanDoanBenh
  final CategoryItem? phanDoBenhItem;       // 25. PhanDoBenh
  final CategoryItem? thongTinDieuTriItem;  // 26. DieuTri

  // ── 27-32 ─────────────────────────────────────────────────────────────
  final String? chanDoanBienChung;          // 27.
  final String? chanDoanBenhKemTheo;        // 28.
  final CategoryItem? benhNenKemTheoItem;   // 29. BenhNen
  final String? ngayKhoiPhat;               // 30.
  final String? ngayNhapVien;               // 31.
  final String? ngayXVTVCV;                 // 32.

  // ── 33-39: Xét nghiệm ────────────────────────────────────────────────
  final CategoryItem? phanLoaiChanDoanItem; // 33.
  final CategoryItem? layMauXNItem;         // 34. CoKhong
  final CategoryItem? loaiBenhPhamItem;     // 35.
  final String? donViThucHienXN;            // 36.
  final String? ngayLayMau;                 // 37.
  final CategoryItem? loaiXNItem;           // 38.
  final CategoryItem? ketQuaXNItem;         // 39.

  // ── 40-41: Tiêm chủng ────────────────────────────────────────────────
  final CategoryItem? tinhTrangTiemItem;    // 40.
  final int? soMuiTiemUong;                 // 41.

  // ── 42-46: Dịch tễ ───────────────────────────────────────────────────
  final String? tienSuDichTe;               // 42.
  final String? nguoiDieuTraDichTe;         // 43.
  final String? sdtNguoiDieuTraDTe;         // 44.
  final String? donViDieuTra;               // 45.
  final String? emailDonViDieuTra;          // 46.

  // ── 47-50: Báo cáo ───────────────────────────────────────────────────
  final String? ngayBaoCao;                 // 47.
  final String? nguoiBaoCao;                // 48.
  final String? sdtNguoiBaoCao;             // 49.
  final String? emailNguoiBaoCao;           // 50.

  // ── 51 ───────────────────────────────────────────────────────────────
  final String? phanDoBenhText;             // 51.

  // ── Metadata ──────────────────────────────────────────────────────────
  final DateTime? ngayTao;
  final DateTime? ngayCapNhat;

  const BenhTruyenNhiem({
    required this.id,
    required this.hoTen,
    this.benhAnId,
    this.ngaySinh,
    this.gioiTinhItem,
    this.danTocItem,
    this.maDinhDanhCaNhan,
    this.tenNguoiBaoHo,
    this.sdt,
    this.coThaiItem,
    this.tuanThai,
    this.ngheNghiep,
    this.noiLamViecHoc,
    this.diaChinoiLamViecHoc,
    this.cityIdHocItem,
    this.wardIdHoc,
    this.noiOHienNay,
    this.cityIdItem,
    this.wardId,
    this.khuPhoAp,
    this.soHSBA,
    this.coSoDieuTriItem,
    this.cityIdCSDTItem,
    this.hinhThucDieuTriItem,
    this.chanDoanBenhItem,
    this.phanDoBenhItem,
    this.thongTinDieuTriItem,
    this.chanDoanBienChung,
    this.chanDoanBenhKemTheo,
    this.benhNenKemTheoItem,
    this.ngayKhoiPhat,
    this.ngayNhapVien,
    this.ngayXVTVCV,
    this.phanLoaiChanDoanItem,
    this.layMauXNItem,
    this.loaiBenhPhamItem,
    this.donViThucHienXN,
    this.ngayLayMau,
    this.loaiXNItem,
    this.ketQuaXNItem,
    this.tinhTrangTiemItem,
    this.soMuiTiemUong,
    this.tienSuDichTe,
    this.nguoiDieuTraDichTe,
    this.sdtNguoiDieuTraDTe,
    this.donViDieuTra,
    this.emailDonViDieuTra,
    this.ngayBaoCao,
    this.nguoiBaoCao,
    this.sdtNguoiBaoCao,
    this.emailNguoiBaoCao,
    this.phanDoBenhText,
    this.ngayTao,
    this.ngayCapNhat,
  });

  // ── Getters tương thích ngược ─────────────────────────────────────────
  String? get gioiTinh          => gioiTinhItem?.name;
  String? get danTocId          => danTocItem?.name;
  String? get coThai            => coThaiItem?.name;
  String? get cityIdHoc         => cityIdHocItem?.name;
  String? get cityId            => cityIdItem?.name;
  String? get coSoDieuTri       => coSoDieuTriItem?.name;
  String? get cityIdCSDT        => cityIdCSDTItem?.name;
  String? get hinhThucDieuTri   => hinhThucDieuTriItem?.name;
  String? get chanDoanBenh      => chanDoanBenhItem?.name;
  String? get phanDoBenh        => phanDoBenhItem?.name;
  String? get thongTinDieuTri   => thongTinDieuTriItem?.name;
  String? get benhNenKemTheoId  => benhNenKemTheoItem?.name;
  String? get phanLoaiChanDoan  => phanLoaiChanDoanItem?.name;
  String? get layMauXN          => layMauXNItem?.name;
  String? get loaiBenhPham      => loaiBenhPhamItem?.name;
  String? get loaiXN            => loaiXNItem?.name;
  String? get ketQuaXN          => ketQuaXNItem?.name;
  String? get tinhTrangTiem     => tinhTrangTiemItem?.name;

  factory BenhTruyenNhiem.fromFirestore(Map<String, dynamic> d, String docId) {
    DateTime? ts(dynamic v) => v is Timestamp ? v.toDate() : null;
    int? toInt(dynamic v) => v is int ? v : (v is String ? int.tryParse(v) : null);
    CategoryItem? cat(dynamic v, List<CategoryItem> list) =>
        CategoryItem.fromFirestore(v, list);

    return BenhTruyenNhiem(
      id: docId,
      hoTen: d['hoTen'] ?? '',
      benhAnId: d['benhAnId'],
      ngaySinh: d['ngaySinh'],
      gioiTinhItem:          cat(d['gioiTinh'],          CategoryOptions.gioiTinh),
      danTocItem:            cat(d['danTocId'],           CategoryOptions.danToc),
      maDinhDanhCaNhan: d['maDinhDanhCaNhan'],
      tenNguoiBaoHo: d['tenNguoiBaoHo'],
      sdt: d['sdt'],
      coThaiItem:            cat(d['coThai'],             CategoryOptions.coKhong),
      tuanThai: toInt(d['tuanThai']),
      ngheNghiep: d['ngheNghiep'],
      noiLamViecHoc: d['noiLamViecHoc'],
      diaChinoiLamViecHoc: d['diaChinoiLamViecHoc'],
      cityIdHocItem:         cat(d['cityIdHoc'],          CategoryOptions.tinh),
      wardIdHoc: d['wardIdHoc'],
      noiOHienNay: d['noiOHienNay'],
      cityIdItem:            cat(d['cityId'],             CategoryOptions.tinh),
      wardId: d['wardId'],
      khuPhoAp: d['khuPhoAp'],
      soHSBA: d['soHSBA'],
      coSoDieuTriItem:       cat(d['coSoDieuTri'],        CategoryOptions.coSoDieuTri),
      cityIdCSDTItem:        cat(d['cityIdCSDT'],         CategoryOptions.tinh),
      hinhThucDieuTriItem:   cat(d['hinhThucDieuTri'],    CategoryOptions.hinhThucDieuTri),
      chanDoanBenhItem:      cat(d['chanDoanBenh'],       CategoryOptions.chanDoanBenh),
      phanDoBenhItem:        cat(d['phanDoBenh'],         CategoryOptions.phanDoBenh),
      thongTinDieuTriItem:   cat(d['thongTinDieuTri'],    CategoryOptions.dieuTri),
      chanDoanBienChung: d['chanDoanBienChung'],
      chanDoanBenhKemTheo: d['chanDoanBenhKemTheo'],
      benhNenKemTheoItem:    cat(d['benhNenKemTheoId'],   CategoryOptions.benhNen),
      ngayKhoiPhat: d['ngayKhoiPhat'],
      ngayNhapVien: d['ngayNhapVien'],
      ngayXVTVCV: d['ngayXVTVCV'],
      phanLoaiChanDoanItem:  cat(d['phanLoaiChanDoan'],   CategoryOptions.phanLoaiChanDoan),
      layMauXNItem:          cat(d['layMauXN'],           CategoryOptions.coKhong),
      loaiBenhPhamItem:      cat(d['loaiBenhPham'],       CategoryOptions.loaiBenhPham),
      donViThucHienXN: d['donViThucHienXN'],
      ngayLayMau: d['ngayLayMau'],
      loaiXNItem:            cat(d['loaiXN'],             CategoryOptions.loaiXetNghiem),
      ketQuaXNItem:          cat(d['ketQuaXN'],           CategoryOptions.ketQuaXetNghiem),
      tinhTrangTiemItem:     cat(d['tinhTrangTiem'],      CategoryOptions.tinhTrangTiemChung),
      soMuiTiemUong: toInt(d['soMuiTiemUong']),
      tienSuDichTe: d['tienSuDichTe'],
      nguoiDieuTraDichTe: d['nguoiDieuTraDichTe'],
      sdtNguoiDieuTraDTe: d['sdtNguoiDieuTraDTe'],
      donViDieuTra: d['donViDieuTra'],
      emailDonViDieuTra: d['emailDonViDieuTra'],
      ngayBaoCao: d['ngayBaoCao'],
      nguoiBaoCao: d['nguoiBaoCao'],
      sdtNguoiBaoCao: d['sdtNguoiBaoCao'],
      emailNguoiBaoCao: d['emailNguoiBaoCao'],
      phanDoBenhText: d['phanDoBenhText'],
      ngayTao:     ts(d['ngayTao']),
      ngayCapNhat: ts(d['ngayCapNhat']),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'hoTen': hoTen,
    if (benhAnId != null)              'benhAnId':           benhAnId,
    if (ngaySinh != null)              'ngaySinh':           ngaySinh,
    if (gioiTinhItem != null)          'gioiTinh':           gioiTinhItem!.toMap(),
    if (danTocItem != null)            'danTocId':           danTocItem!.toMap(),
    if (maDinhDanhCaNhan != null)      'maDinhDanhCaNhan':   maDinhDanhCaNhan,
    if (tenNguoiBaoHo != null)         'tenNguoiBaoHo':      tenNguoiBaoHo,
    if (sdt != null)                   'sdt':                sdt,
    if (coThaiItem != null)            'coThai':             coThaiItem!.toMap(),
    if (tuanThai != null)              'tuanThai':           tuanThai,
    if (ngheNghiep != null)            'ngheNghiep':         ngheNghiep,
    if (noiLamViecHoc != null)         'noiLamViecHoc':      noiLamViecHoc,
    if (diaChinoiLamViecHoc != null)   'diaChinoiLamViecHoc': diaChinoiLamViecHoc,
    if (cityIdHocItem != null)         'cityIdHoc':          cityIdHocItem!.toMap(),
    if (wardIdHoc != null)             'wardIdHoc':          wardIdHoc,
    if (noiOHienNay != null)           'noiOHienNay':        noiOHienNay,
    if (cityIdItem != null)            'cityId':             cityIdItem!.toMap(),
    if (wardId != null)                'wardId':             wardId,
    if (khuPhoAp != null)              'khuPhoAp':           khuPhoAp,
    if (soHSBA != null)                'soHSBA':             soHSBA,
    if (coSoDieuTriItem != null)       'coSoDieuTri':        coSoDieuTriItem!.toMap(),
    if (cityIdCSDTItem != null)        'cityIdCSDT':         cityIdCSDTItem!.toMap(),
    if (hinhThucDieuTriItem != null)   'hinhThucDieuTri':    hinhThucDieuTriItem!.toMap(),
    if (chanDoanBenhItem != null)      'chanDoanBenh':       chanDoanBenhItem!.toMap(),
    if (phanDoBenhItem != null)        'phanDoBenh':         phanDoBenhItem!.toMap(),
    if (thongTinDieuTriItem != null)   'thongTinDieuTri':    thongTinDieuTriItem!.toMap(),
    if (chanDoanBienChung != null)     'chanDoanBienChung':  chanDoanBienChung,
    if (chanDoanBenhKemTheo != null)   'chanDoanBenhKemTheo': chanDoanBenhKemTheo,
    if (benhNenKemTheoItem != null)    'benhNenKemTheoId':   benhNenKemTheoItem!.toMap(),
    if (ngayKhoiPhat != null)          'ngayKhoiPhat':       ngayKhoiPhat,
    if (ngayNhapVien != null)          'ngayNhapVien':       ngayNhapVien,
    if (ngayXVTVCV != null)            'ngayXVTVCV':         ngayXVTVCV,
    if (phanLoaiChanDoanItem != null)  'phanLoaiChanDoan':   phanLoaiChanDoanItem!.toMap(),
    if (layMauXNItem != null)          'layMauXN':           layMauXNItem!.toMap(),
    if (loaiBenhPhamItem != null)      'loaiBenhPham':       loaiBenhPhamItem!.toMap(),
    if (donViThucHienXN != null)       'donViThucHienXN':    donViThucHienXN,
    if (ngayLayMau != null)            'ngayLayMau':         ngayLayMau,
    if (loaiXNItem != null)            'loaiXN':             loaiXNItem!.toMap(),
    if (ketQuaXNItem != null)          'ketQuaXN':           ketQuaXNItem!.toMap(),
    if (tinhTrangTiemItem != null)     'tinhTrangTiem':      tinhTrangTiemItem!.toMap(),
    if (soMuiTiemUong != null)         'soMuiTiemUong':      soMuiTiemUong,
    if (tienSuDichTe != null)          'tienSuDichTe':       tienSuDichTe,
    if (nguoiDieuTraDichTe != null)    'nguoiDieuTraDichTe': nguoiDieuTraDichTe,
    if (sdtNguoiDieuTraDTe != null)    'sdtNguoiDieuTraDTe': sdtNguoiDieuTraDTe,
    if (donViDieuTra != null)          'donViDieuTra':       donViDieuTra,
    if (emailDonViDieuTra != null)     'emailDonViDieuTra':  emailDonViDieuTra,
    if (ngayBaoCao != null)            'ngayBaoCao':         ngayBaoCao,
    if (nguoiBaoCao != null)           'nguoiBaoCao':        nguoiBaoCao,
    if (sdtNguoiBaoCao != null)        'sdtNguoiBaoCao':     sdtNguoiBaoCao,
    if (emailNguoiBaoCao != null)      'emailNguoiBaoCao':   emailNguoiBaoCao,
    if (phanDoBenhText != null)        'phanDoBenhText':      phanDoBenhText,
    'ngayTao':     ngayTao ?? FieldValue.serverTimestamp(),
    'ngayCapNhat': FieldValue.serverTimestamp(),
  };

  /// Payload chuẩn để đẩy lên API ngoài — các trường danh mục chỉ lấy id (String)
  /// Null nếu không có dữ liệu, khớp với format:
  /// {"GioiTinh":"263","DanTocId":"15","ChanDoanBenh":"16",...}
  Map<String, dynamic> toApiPayload() => {
    'Id':                   null,
    'UnitId':               null,
    'MaBenhNhan':           benhAnId ?? '',
    'HoTen':                hoTen,
    'NgaySinh':             ngaySinh,
    'GioiTinh':             gioiTinhItem?.id.toString(),
    'DanTocId':             danTocItem?.id.toString(),
    'MaDinhDanhCaNhan':     maDinhDanhCaNhan ?? '000',
    'TenNguoiBaoHo':        tenNguoiBaoHo,
    'SDT':                  sdt,
    'CoThai':               coThaiItem?.id.toString(),
    'TuanThai':             tuanThai,
    'NgheNghiep':           ngheNghiep,
    'DiaChiNoiLamViec_Hoc': diaChinoiLamViecHoc ?? '',
    'NoiLamViec_Hoc':       noiLamViecHoc ?? '',
    'CityId_Hoc':           cityIdHocItem?.id.toString(),
    'WardId_Hoc':           wardIdHoc,
    'NoiLamViec_CityId':    null,
    'NoiLamViec_WardId':    null,
    'NoiOHienNay':          noiOHienNay,
    'CityId':               cityIdItem?.id.toString(),
    'WardId':               wardId,
    'NoiOHienNay_CityId':   null,
    'NoiOHienNay_WardId':   null,
    'NoiOHienNay_KhuPho':   null,
    'KhuPhoAp':             khuPhoAp ?? '',
    'SoHSBA':               soHSBA ?? '',
    'CoSoDieuTri':          coSoDieuTriItem?.id.toString(),
    'CityId_CSDT':          cityIdCSDTItem?.id.toString(),
    'HinhThucDieuTri':      hinhThucDieuTriItem?.id.toString(),
    'ChanDoanBenh':         chanDoanBenhItem?.id.toString(),
    'PhanDoBenh':           phanDoBenhItem?.id.toString(),
    'ThongTinDieuTri':      thongTinDieuTriItem?.name,
    'ChanDoanBienChung':    chanDoanBienChung ?? '',
    'ChanDoanBenhKemTheo':  chanDoanBenhKemTheo ?? '',
    'BenhNenKemTheoId':     benhNenKemTheoItem?.id.toString(),
    'NgayKhoiPhat':         ngayKhoiPhat,
    'NgayNhapVien':         ngayNhapVien,
    'NgayXV_TV_CV':         ngayXVTVCV,
    'PhanLoaiChanDoan':     phanLoaiChanDoanItem?.id.toString(),
    'LayMauXN':             layMauXNItem?.id.toString() ?? '',
    'LoaiBenhPham':         loaiBenhPhamItem?.id.toString() ?? '',
    'DonViThucHienXN':      donViThucHienXN ?? '',
    'NgayLayMau':           ngayLayMau ?? '',
    'LoaiXN':               loaiXNItem?.id.toString() ?? '',
    'KetQuaXN':             ketQuaXNItem?.id.toString() ?? '',
    'TinhTrangTiem':        tinhTrangTiemItem?.id.toString(),
    'SoMuiTiemUong':        soMuiTiemUong?.toString() ?? '',
    'TienSuDichTe':         tienSuDichTe ?? '',
    'NguoiDieuTraDichTe':   nguoiDieuTraDichTe,
    'SDTNguoiDieuTraDTe':   sdtNguoiDieuTraDTe,
    'DonViDieuTra':         donViDieuTra,
    'EmailDonViDieuTra':    emailDonViDieuTra ?? '',
    'NgayBaoCao':           ngayBaoCao,
    'NguoiBaoCao':          nguoiBaoCao,
    'SDTNguoiBaoCao':       sdtNguoiBaoCao,
    'EmailNguoiBaoCao':     emailNguoiBaoCao,
    'PhanDoBenhText':       phanDoBenhText,
    'ChanDoanChinh':        null,
  };
}
