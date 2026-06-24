// Model bệnh nhân — 51 trường đầy đủ như bệnh truyền nhiễm
// Các trường danh mục lưu dạng Map {"id": int, "name": String} lên Firestore

import 'package:cloud_firestore/cloud_firestore.dart';
import 'category_options.dart';

class BenhNhan {
  final String id;

  // ── 1-15: Thông tin cá nhân ──────────────────────────────────────────
  final String? benhNhanId;             // 1. Mã bệnh nhân
  final String hoTen;                   // 2. Họ tên
  final String? ngaySinh;               // 3. Ngày sinh
  final CategoryItem? gioiTinhItem;     // 4. Giới tính
  final CategoryItem? danTocItem;       // 5. Dân tộc
  final String? cccd;                   // 6. CCCD (MaDinhDanhCaNhan)
  final String? tenNguoiBaoHo;          // 7. Người bảo hộ
  final String? soDienThoai;            // 8. SĐT
  final CategoryItem? coThaiItem;       // 9. Có thai
  final int? tuanThai;                  // 10. Tuần thai
  final String? ngheNghiep;             // 11. Nghề nghiệp
  final String? noiLamViecHoc;          // 12. Nơi làm/học
  final String? diaChiNoiLamViecHoc;    // 13. Địa chỉ làm/học
  final CategoryItem? cityIdHocItem;    // 14. Tỉnh làm/học
  final String? wardIdHoc;              // 15. Phường làm/học

  // ── 16-20: Địa chỉ hiện tại ──────────────────────────────────────────
  final String? noiOHienNay;            // 16. Nơi ở hiện nay
  final CategoryItem? tinhItem;         // 17. Tỉnh nơi ở
  final String? phuong;                 // 18. Phường nơi ở
  final String? khuPhoAp;               // 19. Khu phố/ấp
  final String? soHSBA;                 // 20. Số HSBA

  // ── 21-33: Điều trị & Chẩn đoán ──────────────────────────────────────
  final CategoryItem? coSoDieuTriItem;  // 21. Cơ sở điều trị
  final CategoryItem? cityIdCSDTItem;   // 22. Tỉnh CSDT
  final CategoryItem? hinhThucDieuTriItem; // 23. Hình thức điều trị
  final CategoryItem? chanDoanBenhItem; // 24. Chẩn đoán bệnh
  final CategoryItem? phanDoBenhItem;   // 25. Phân độ bệnh
  final CategoryItem? thongTinDieuTriItem; // 26. Thông tin điều trị
  final String? chanDoanBienChung;      // 27. Chẩn đoán biến chứng
  final String? chanDoanBenhKemTheo;    // 28. Chẩn đoán bệnh kèm theo
  final CategoryItem? benhNenKemTheoItem; // 29. Bệnh nền kèm theo
  final String? ngayKhoiPhat;           // 30. Ngày khởi phát
  final String? ngayNhapVien;           // 31. Ngày nhập viện
  final String? ngayXVTVCV;             // 32. Ngày xuất/tử/chuyển viện
  final CategoryItem? phanLoaiChanDoanItem; // 33. Phân loại chẩn đoán

  // ── 34-39: Xét nghiệm ────────────────────────────────────────────────
  final CategoryItem? layMauXNItem;     // 34. Lấy mẫu XN
  final CategoryItem? loaiBenhPhamItem; // 35. Loại bệnh phẩm
  final String? donViThucHienXN;        // 36. Đơn vị XN
  final String? ngayLayMau;             // 37. Ngày lấy mẫu
  final CategoryItem? loaiXetNghiemItem; // 38. Loại XN
  final CategoryItem? ketQuaXetNghiemItem; // 39. Kết quả XN

  // ── 40-41: Tiêm chủng ────────────────────────────────────────────────
  final CategoryItem? tinhTrangTiemChungItem; // 40. Tình trạng tiêm
  final int? soMuiTiemUong;             // 41. Số mũi tiêm

  // ── 42-46: Dịch tễ ───────────────────────────────────────────────────
  final String? tienSuDichTe;           // 42. Tiền sử dịch tễ
  final String? nguoiDieuTraDichTe;     // 43. Người điều tra
  final String? sdtNguoiDieuTraDTe;     // 44. SĐT điều tra
  final String? donViDieuTra;           // 45. Đơn vị điều tra
  final String? emailDonViDieuTra;      // 46. Email điều tra

  // ── 47-51: Báo cáo ───────────────────────────────────────────────────
  final String? ngayBaoCao;             // 47. Ngày báo cáo
  final String? nguoiBaoCao;            // 48. Người báo cáo
  final String? sdtNguoiBaoCao;         // 49. SĐT báo cáo
  final String? emailNguoiBaoCao;       // 50. Email báo cáo
  final String? phanDoBenhText;         // 51. Phân độ bệnh (text)

  // ── Metadata ──────────────────────────────────────────────────────────
  final String? baoHiemYTe;
  final String? nhomMau;
  final CategoryItem? coSoBaoCaoItem;
  final String? phongKham;
  final int? soThuTu;
  final String? trangThai;
  final DateTime? ngayDangKy;
  final DateTime? ngayCapNhat;

  const BenhNhan({
    required this.id,
    required this.hoTen,
    this.benhNhanId,
    this.ngaySinh,
    this.gioiTinhItem,
    this.danTocItem,
    this.cccd,
    this.tenNguoiBaoHo,
    this.soDienThoai,
    this.coThaiItem,
    this.tuanThai,
    this.ngheNghiep,
    this.noiLamViecHoc,
    this.diaChiNoiLamViecHoc,
    this.cityIdHocItem,
    this.wardIdHoc,
    this.noiOHienNay,
    this.tinhItem,
    this.phuong,
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
    this.loaiXetNghiemItem,
    this.ketQuaXetNghiemItem,
    this.tinhTrangTiemChungItem,
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
    this.baoHiemYTe,
    this.nhomMau,
    this.coSoBaoCaoItem,
    this.phongKham,
    this.soThuTu,
    this.trangThai,
    this.ngayDangKy,
    this.ngayCapNhat,
  });


  // ── Getters tiện ích (tương thích ngược) ─────────────────────────────
  String? get gioiTinh           => gioiTinhItem?.name;
  String? get danToc             => danTocItem?.name;
  String? get tinh               => tinhItem?.name;
  String? get coThai             => coThaiItem?.name;
  String? get cityIdHoc          => cityIdHocItem?.name;
  String? get benhNenKemTheo     => benhNenKemTheoItem?.name;
  String? get tinhTrangTiemChung => tinhTrangTiemChungItem?.name;
  String? get thongTinDieuTri    => thongTinDieuTriItem?.name;
  String? get hinhThucDieuTri    => hinhThucDieuTriItem?.name;
  String? get chanDoanBenh       => chanDoanBenhItem?.name;
  String? get phanLoaiChanDoan   => phanLoaiChanDoanItem?.name;
  String? get phanDoBenh         => phanDoBenhItem?.name;
  String? get loaiBenhPham       => loaiBenhPhamItem?.name;
  String? get loaiXetNghiem      => loaiXetNghiemItem?.name;
  String? get ketQuaXetNghiem    => ketQuaXetNghiemItem?.name;
  String? get coSoBaoCao         => coSoBaoCaoItem?.name;
  String? get coSoDieuTri        => coSoDieuTriItem?.name;
  String? get cityIdCSDT         => cityIdCSDTItem?.name;
  String? get layMauXN           => layMauXNItem?.name;
  
  // Getters tương thích ngược với code cũ
  String? get diaChi             => noiOHienNay;  // Dùng noiOHienNay thay cho diaChi
  String? get phuongMoiHCM       => phuong;       // Alias cho phuong
  String? get benhNen            => benhNenKemTheo; // Dùng benhNenKemTheo thay cho benhNen
  String? get benhTruyenNhiem    => chanDoanBenh;   // Dùng chanDoanBenh thay cho benhTruyenNhiem
  String? get coKhong            => coThai;         // Dùng coThai thay cho coKhong
  String? get dieuTri            => thongTinDieuTri; // Dùng thongTinDieuTri thay cho dieuTri

  // ── Parse từ Firestore ─────────────────────────────────────────────────
  factory BenhNhan.fromFirestore(Map<String, dynamic> data, String docId) {
    DateTime? ts(dynamic v) => v is Timestamp ? v.toDate() : null;
    int? toInt(dynamic v) => v is int ? v : (v is String ? int.tryParse(v) : null);
    CategoryItem? cat(dynamic v, List<CategoryItem> list) =>
        CategoryItem.fromFirestore(v, list);

    return BenhNhan(
      id: docId,
      hoTen: data['hoTen'] ?? '',
      benhNhanId: data['benhNhanId'],
      ngaySinh: data['ngaySinh'],
      gioiTinhItem:           cat(data['gioiTinh'],           CategoryOptions.gioiTinh),
      danTocItem:             cat(data['danToc'],             CategoryOptions.danToc),
      cccd: data['cccd'],
      tenNguoiBaoHo: data['tenNguoiBaoHo'],
      soDienThoai: data['soDienThoai'],
      coThaiItem:             cat(data['coThai'],             CategoryOptions.coKhong),
      tuanThai: toInt(data['tuanThai']),
      ngheNghiep: data['ngheNghiep'],
      noiLamViecHoc: data['noiLamViecHoc'],
      diaChiNoiLamViecHoc: data['diaChiNoiLamViecHoc'],
      cityIdHocItem:          cat(data['cityIdHoc'],          CategoryOptions.tinh),
      wardIdHoc: data['wardIdHoc'],
      noiOHienNay: data['noiOHienNay'],
      tinhItem:               cat(data['tinh'],               CategoryOptions.tinh),
      phuong: data['phuong'],
      khuPhoAp: data['khuPhoAp'],
      soHSBA: data['soHSBA'],
      coSoDieuTriItem:        cat(data['coSoDieuTri'],        CategoryOptions.coSoDieuTri),
      cityIdCSDTItem:         cat(data['cityIdCSDT'],         CategoryOptions.tinh),
      hinhThucDieuTriItem:    cat(data['hinhThucDieuTri'],    CategoryOptions.hinhThucDieuTri),
      chanDoanBenhItem:       cat(data['chanDoanBenh'],       CategoryOptions.chanDoanBenh),
      phanDoBenhItem:         cat(data['phanDoBenh'],         CategoryOptions.phanDoBenh),
      thongTinDieuTriItem:    cat(data['thongTinDieuTri'],    CategoryOptions.dieuTri),
      chanDoanBienChung: data['chanDoanBienChung'],
      chanDoanBenhKemTheo: data['chanDoanBenhKemTheo'],
      benhNenKemTheoItem:     cat(data['benhNenKemTheo'],     CategoryOptions.benhNen),
      ngayKhoiPhat: data['ngayKhoiPhat'],
      ngayNhapVien: data['ngayNhapVien'],
      ngayXVTVCV: data['ngayXVTVCV'],
      phanLoaiChanDoanItem:   cat(data['phanLoaiChanDoan'],   CategoryOptions.phanLoaiChanDoan),
      layMauXNItem:           cat(data['layMauXN'],           CategoryOptions.coKhong),
      loaiBenhPhamItem:       cat(data['loaiBenhPham'],       CategoryOptions.loaiBenhPham),
      donViThucHienXN: data['donViThucHienXN'],
      ngayLayMau: data['ngayLayMau'],
      loaiXetNghiemItem:      cat(data['loaiXetNghiem'],      CategoryOptions.loaiXetNghiem),
      ketQuaXetNghiemItem:    cat(data['ketQuaXetNghiem'],    CategoryOptions.ketQuaXetNghiem),
      tinhTrangTiemChungItem: cat(data['tinhTrangTiemChung'], CategoryOptions.tinhTrangTiemChung),
      soMuiTiemUong: toInt(data['soMuiTiemUong']),
      tienSuDichTe: data['tienSuDichTe'],
      nguoiDieuTraDichTe: data['nguoiDieuTraDichTe'],
      sdtNguoiDieuTraDTe: data['sdtNguoiDieuTraDTe'],
      donViDieuTra: data['donViDieuTra'],
      emailDonViDieuTra: data['emailDonViDieuTra'],
      ngayBaoCao: data['ngayBaoCao'],
      nguoiBaoCao: data['nguoiBaoCao'],
      sdtNguoiBaoCao: data['sdtNguoiBaoCao'],
      emailNguoiBaoCao: data['emailNguoiBaoCao'],
      phanDoBenhText: data['phanDoBenhText'],
      baoHiemYTe: data['baoHiemYTe'],
      nhomMau: data['nhomMau'],
      coSoBaoCaoItem:         cat(data['coSoBaoCao'],         CategoryOptions.coSoBaoCao),
      phongKham: data['phongKham'],
      soThuTu: data['soThuTu'] is int ? data['soThuTu'] : null,
      trangThai: data['trangThai'] ?? 'Chờ',
      ngayDangKy:  ts(data['ngayDangKy']),
      ngayCapNhat: ts(data['ngayCapNhat']),
    );
  }


  // ── Ghi lên Firestore — lưu Map {id, name} cho từng trường danh mục ───
  Map<String, dynamic> toFirestore() {
    return {
      'hoTen': hoTen,
      if (benhNhanId != null)  'benhNhanId': benhNhanId,
      if (ngaySinh != null)    'ngaySinh': ngaySinh,
      if (gioiTinhItem != null)           'gioiTinh':           gioiTinhItem!.toMap(),
      if (danTocItem != null)             'danToc':             danTocItem!.toMap(),
      if (cccd != null)                   'cccd':               cccd,
      if (tenNguoiBaoHo != null)          'tenNguoiBaoHo':      tenNguoiBaoHo,
      if (soDienThoai != null)            'soDienThoai':        soDienThoai,
      if (coThaiItem != null)             'coThai':             coThaiItem!.toMap(),
      if (tuanThai != null)               'tuanThai':           tuanThai,
      if (ngheNghiep != null)             'ngheNghiep':         ngheNghiep,
      if (noiLamViecHoc != null)          'noiLamViecHoc':      noiLamViecHoc,
      if (diaChiNoiLamViecHoc != null)    'diaChiNoiLamViecHoc': diaChiNoiLamViecHoc,
      if (cityIdHocItem != null)          'cityIdHoc':          cityIdHocItem!.toMap(),
      if (wardIdHoc != null)              'wardIdHoc':          wardIdHoc,
      if (noiOHienNay != null)            'noiOHienNay':        noiOHienNay,
      if (tinhItem != null)               'tinh':               tinhItem!.toMap(),
      if (phuong != null)                 'phuong':             phuong,
      if (khuPhoAp != null)               'khuPhoAp':           khuPhoAp,
      if (soHSBA != null)                 'soHSBA':             soHSBA,
      if (coSoDieuTriItem != null)        'coSoDieuTri':        coSoDieuTriItem!.toMap(),
      if (cityIdCSDTItem != null)         'cityIdCSDT':         cityIdCSDTItem!.toMap(),
      if (hinhThucDieuTriItem != null)    'hinhThucDieuTri':    hinhThucDieuTriItem!.toMap(),
      if (chanDoanBenhItem != null)       'chanDoanBenh':       chanDoanBenhItem!.toMap(),
      if (phanDoBenhItem != null)         'phanDoBenh':         phanDoBenhItem!.toMap(),
      if (thongTinDieuTriItem != null)    'thongTinDieuTri':    thongTinDieuTriItem!.toMap(),
      if (chanDoanBienChung != null)      'chanDoanBienChung':  chanDoanBienChung,
      if (chanDoanBenhKemTheo != null)    'chanDoanBenhKemTheo': chanDoanBenhKemTheo,
      if (benhNenKemTheoItem != null)     'benhNenKemTheo':     benhNenKemTheoItem!.toMap(),
      if (ngayKhoiPhat != null)           'ngayKhoiPhat':       ngayKhoiPhat,
      if (ngayNhapVien != null)           'ngayNhapVien':       ngayNhapVien,
      if (ngayXVTVCV != null)             'ngayXVTVCV':         ngayXVTVCV,
      if (phanLoaiChanDoanItem != null)   'phanLoaiChanDoan':   phanLoaiChanDoanItem!.toMap(),
      if (layMauXNItem != null)           'layMauXN':           layMauXNItem!.toMap(),
      if (loaiBenhPhamItem != null)       'loaiBenhPham':       loaiBenhPhamItem!.toMap(),
      if (donViThucHienXN != null)        'donViThucHienXN':    donViThucHienXN,
      if (ngayLayMau != null)             'ngayLayMau':         ngayLayMau,
      if (loaiXetNghiemItem != null)      'loaiXetNghiem':      loaiXetNghiemItem!.toMap(),
      if (ketQuaXetNghiemItem != null)    'ketQuaXetNghiem':    ketQuaXetNghiemItem!.toMap(),
      if (tinhTrangTiemChungItem != null) 'tinhTrangTiemChung': tinhTrangTiemChungItem!.toMap(),
      if (soMuiTiemUong != null)          'soMuiTiemUong':      soMuiTiemUong,
      if (tienSuDichTe != null)           'tienSuDichTe':       tienSuDichTe,
      if (nguoiDieuTraDichTe != null)     'nguoiDieuTraDichTe': nguoiDieuTraDichTe,
      if (sdtNguoiDieuTraDTe != null)     'sdtNguoiDieuTraDTe': sdtNguoiDieuTraDTe,
      if (donViDieuTra != null)           'donViDieuTra':       donViDieuTra,
      if (emailDonViDieuTra != null)      'emailDonViDieuTra':  emailDonViDieuTra,
      if (ngayBaoCao != null)             'ngayBaoCao':         ngayBaoCao,
      if (nguoiBaoCao != null)            'nguoiBaoCao':        nguoiBaoCao,
      if (sdtNguoiBaoCao != null)         'sdtNguoiBaoCao':     sdtNguoiBaoCao,
      if (emailNguoiBaoCao != null)       'emailNguoiBaoCao':   emailNguoiBaoCao,
      if (phanDoBenhText != null)         'phanDoBenhText':     phanDoBenhText,
      if (baoHiemYTe != null)             'baoHiemYTe':         baoHiemYTe,
      if (nhomMau != null)                'nhomMau':            nhomMau,
      if (coSoBaoCaoItem != null)         'coSoBaoCao':         coSoBaoCaoItem!.toMap(),
      if (phongKham != null)              'phongKham':          phongKham,
      if (soThuTu != null)                'soThuTu':            soThuTu,
      'trangThai':   trangThai ?? 'Chờ',
      'ngayDangKy':  ngayDangKy ?? FieldValue.serverTimestamp(),
      'ngayCapNhat': FieldValue.serverTimestamp(),
    };
  }


  /// Payload chuẩn để đẩy lên API ngoài — các trường danh mục chỉ lấy id (String).
  /// Khớp 100% format bệnh truyền nhiễm với 51 trường đầy đủ
  Map<String, dynamic> toApiPayload() => {
    'Id':                   null,
    'UnitId':               null,
    'MaBenhNhan':           benhNhanId ?? cccd ?? '',
    'HoTen':                hoTen,
    'NgaySinh':             ngaySinh,
    'GioiTinh':             gioiTinhItem?.id.toString(),
    'DanTocId':             danTocItem?.id.toString(),
    'MaDinhDanhCaNhan':     cccd ?? '000',
    'TenNguoiBaoHo':        tenNguoiBaoHo,
    'SDT':                  soDienThoai,
    'CoThai':               coThaiItem?.id.toString(),
    'TuanThai':             tuanThai,
    'NgheNghiep':           ngheNghiep,
    'DiaChiNoiLamViec_Hoc': diaChiNoiLamViecHoc ?? '',
    'NoiLamViec_Hoc':       noiLamViecHoc ?? '',
    'CityId_Hoc':           cityIdHocItem?.id.toString(),
    'WardId_Hoc':           wardIdHoc,
    'NoiLamViec_CityId':    null,
    'NoiLamViec_WardId':    null,
    'NoiOHienNay':          noiOHienNay,
    'CityId':               tinhItem?.id.toString(),
    'WardId':               phuong,
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
    'LoaiXN':               loaiXetNghiemItem?.id.toString() ?? '',
    'KetQuaXN':             ketQuaXetNghiemItem?.id.toString() ?? '',
    'TinhTrangTiem':        tinhTrangTiemChungItem?.id.toString(),
    'ChanDoanChinh':        null,
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
    // Các trường metadata bổ sung
    'BHYT':                 baoHiemYTe,
    'NhomMau':              nhomMau,
    'CoSoBaoCao':           coSoBaoCaoItem?.id.toString(),
    'PhongKham':            phongKham,
    'TrangThai':            trangThai ?? 'Chờ',
    'SoThuTu':              soThuTu,
  };
}