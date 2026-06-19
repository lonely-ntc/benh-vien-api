// Model bệnh nhân — ánh xạ với collection Firestore
// Các trường danh mục lưu dạng Map {"id": int, "name": String} lên Firestore
// để khớp chuẩn API.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'category_options.dart';

class BenhNhan {
  final String id;

  // ── Thông tin cá nhân ──────────────────────────────────────────────────
  final String hoTen;
  final String? ngaySinh;               // "dd/MM/yyyy"
  final CategoryItem? gioiTinhItem;     // GioiTinh — lưu {id,name}
  final CategoryItem? danTocItem;       // DanToc   — lưu {id,name}
  final String? ngheNghiep;             // string (không có API id)
  final String? soDienThoai;
  final String? cccd;
  final String? baoHiemYTe;

  // ── Địa chỉ ───────────────────────────────────────────────────────────
  final String? diaChi;
  final CategoryItem? tinhItem;         // Tinh — lưu {id,name}
  final String? phuong;
  final String? phuongMoiHCM;

  // ── Thông tin y tế ────────────────────────────────────────────────────
  final String? nhomMau;                // string (không có API id)
  final CategoryItem? benhNenItem;      // BenhNen
  final CategoryItem? benhTruyenNhiemItem; // ChanDoanBenh
  final CategoryItem? tinhTrangTiemChungItem; // TinhTrangTiemChung
  final CategoryItem? coKhongItem;      // CoKhong

  // ── Chẩn đoán & Điều trị ─────────────────────────────────────────────
  final CategoryItem? dieuTriItem;          // DieuTri
  final CategoryItem? hinhThucDieuTriItem;  // HinhThucDieuTri
  final CategoryItem? chanDoanBenhItem;     // ChanDoanBenh
  final CategoryItem? phanLoaiChanDoanItem; // PhanLoaiChanDoan
  final CategoryItem? phanDoBenhItem;       // PhanDoBenh
  final CategoryItem? loaiBenhPhamItem;     // LoaiBenhPham
  final CategoryItem? loaiXetNghiemItem;    // LoaiXetNghiem
  final CategoryItem? ketQuaXetNghiemItem;  // KetQuaXetNghiem

  // ── Cơ sở / đơn vị ───────────────────────────────────────────────────
  final CategoryItem? coSoBaoCaoItem;   // CoSoBaoCao
  final String? donViDieuTra;           // text
  final CategoryItem? coSoDieuTriItem;  // CoSoDieuTri
  final String? phongKham;

  // ── Token / trạng thái ────────────────────────────────────────────────
  final int? soThuTu;
  final String? trangThai;
  final DateTime? ngayDangKy;
  final DateTime? ngayCapNhat;

  const BenhNhan({
    required this.id,
    required this.hoTen,
    this.ngaySinh,
    this.gioiTinhItem,
    this.danTocItem,
    this.ngheNghiep,
    this.soDienThoai,
    this.cccd,
    this.baoHiemYTe,
    this.diaChi,
    this.tinhItem,
    this.phuong,
    this.phuongMoiHCM,
    this.nhomMau,
    this.benhNenItem,
    this.benhTruyenNhiemItem,
    this.tinhTrangTiemChungItem,
    this.coKhongItem,
    this.dieuTriItem,
    this.hinhThucDieuTriItem,
    this.chanDoanBenhItem,
    this.phanLoaiChanDoanItem,
    this.phanDoBenhItem,
    this.loaiBenhPhamItem,
    this.loaiXetNghiemItem,
    this.ketQuaXetNghiemItem,
    this.coSoBaoCaoItem,
    this.donViDieuTra,
    this.coSoDieuTriItem,
    this.phongKham,
    this.soThuTu,
    this.trangThai,
    this.ngayDangKy,
    this.ngayCapNhat,
  });

  // ── Getters tiện ích (tương thích ngược với code cũ dùng String) ───────
  String? get gioiTinh           => gioiTinhItem?.name;
  String? get danToc             => danTocItem?.name;
  String? get tinh               => tinhItem?.name;
  String? get benhNen            => benhNenItem?.name;
  String? get benhTruyenNhiem    => benhTruyenNhiemItem?.name;
  String? get tinhTrangTiemChung => tinhTrangTiemChungItem?.name;
  String? get coKhong            => coKhongItem?.name;
  String? get dieuTri            => dieuTriItem?.name;
  String? get hinhThucDieuTri    => hinhThucDieuTriItem?.name;
  String? get chanDoanBenh       => chanDoanBenhItem?.name;
  String? get phanLoaiChanDoan   => phanLoaiChanDoanItem?.name;
  String? get phanDoBenh         => phanDoBenhItem?.name;
  String? get loaiBenhPham       => loaiBenhPhamItem?.name;
  String? get loaiXetNghiem      => loaiXetNghiemItem?.name;
  String? get ketQuaXetNghiem    => ketQuaXetNghiemItem?.name;
  String? get coSoBaoCao         => coSoBaoCaoItem?.name;
  String? get coSoDieuTri        => coSoDieuTriItem?.name;

  // ── Parse từ Firestore ─────────────────────────────────────────────────
  factory BenhNhan.fromFirestore(Map<String, dynamic> data, String docId) {
    DateTime? ts(dynamic v) => v is Timestamp ? v.toDate() : null;

    CategoryItem? cat(dynamic v, List<CategoryItem> list) =>
        CategoryItem.fromFirestore(v, list);

    return BenhNhan(
      id: docId,
      hoTen: data['hoTen'] ?? '',
      ngaySinh: data['ngaySinh'],
      gioiTinhItem:           cat(data['gioiTinh'],           CategoryOptions.gioiTinh),
      danTocItem:             cat(data['danToc'],             CategoryOptions.danToc),
      ngheNghiep: data['ngheNghiep'],
      soDienThoai: data['soDienThoai'],
      cccd: data['cccd'],
      baoHiemYTe: data['baoHiemYTe'],
      diaChi: data['diaChi'],
      tinhItem:               cat(data['tinh'],               CategoryOptions.tinh),
      phuong: data['phuong'],
      phuongMoiHCM: data['phuongMoiHCM'],
      nhomMau: data['nhomMau'],
      benhNenItem:            cat(data['benhNen'],            CategoryOptions.benhNen),
      benhTruyenNhiemItem:    cat(data['benhTruyenNhiem'],    CategoryOptions.chanDoanBenh),
      tinhTrangTiemChungItem: cat(data['tinhTrangTiemChung'], CategoryOptions.tinhTrangTiemChung),
      coKhongItem:            cat(data['coKhong'],            CategoryOptions.coKhong),
      dieuTriItem:            cat(data['dieuTri'],            CategoryOptions.dieuTri),
      hinhThucDieuTriItem:    cat(data['hinhThucDieuTri'],    CategoryOptions.hinhThucDieuTri),
      chanDoanBenhItem:       cat(data['chanDoanBenh'],       CategoryOptions.chanDoanBenh),
      phanLoaiChanDoanItem:   cat(data['phanLoaiChanDoan'],   CategoryOptions.phanLoaiChanDoan),
      phanDoBenhItem:         cat(data['phanDoBenh'],         CategoryOptions.phanDoBenh),
      loaiBenhPhamItem:       cat(data['loaiBenhPham'],       CategoryOptions.loaiBenhPham),
      loaiXetNghiemItem:      cat(data['loaiXetNghiem'],      CategoryOptions.loaiXetNghiem),
      ketQuaXetNghiemItem:    cat(data['ketQuaXetNghiem'],    CategoryOptions.ketQuaXetNghiem),
      coSoBaoCaoItem:         cat(data['coSoBaoCao'],         CategoryOptions.coSoBaoCao),
      donViDieuTra: data['donViDieuTra'],
      coSoDieuTriItem:        cat(data['coSoDieuTri'],        CategoryOptions.coSoDieuTri),
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
      if (ngaySinh != null)    'ngaySinh': ngaySinh,
      if (gioiTinhItem != null)           'gioiTinh':           gioiTinhItem!.toMap(),
      if (danTocItem != null)             'danToc':             danTocItem!.toMap(),
      if (ngheNghiep != null)             'ngheNghiep':         ngheNghiep,
      if (soDienThoai != null)            'soDienThoai':        soDienThoai,
      if (cccd != null)                   'cccd':               cccd,
      if (baoHiemYTe != null)             'baoHiemYTe':         baoHiemYTe,
      if (diaChi != null)                 'diaChi':             diaChi,
      if (tinhItem != null)               'tinh':               tinhItem!.toMap(),
      if (phuong != null)                 'phuong':             phuong,
      if (phuongMoiHCM != null)           'phuongMoiHCM':       phuongMoiHCM,
      if (nhomMau != null)                'nhomMau':            nhomMau,
      if (benhNenItem != null)            'benhNen':            benhNenItem!.toMap(),
      if (benhTruyenNhiemItem != null)    'benhTruyenNhiem':    benhTruyenNhiemItem!.toMap(),
      if (tinhTrangTiemChungItem != null) 'tinhTrangTiemChung': tinhTrangTiemChungItem!.toMap(),
      if (coKhongItem != null)            'coKhong':            coKhongItem!.toMap(),
      if (dieuTriItem != null)            'dieuTri':            dieuTriItem!.toMap(),
      if (hinhThucDieuTriItem != null)    'hinhThucDieuTri':    hinhThucDieuTriItem!.toMap(),
      if (chanDoanBenhItem != null)       'chanDoanBenh':       chanDoanBenhItem!.toMap(),
      if (phanLoaiChanDoanItem != null)   'phanLoaiChanDoan':   phanLoaiChanDoanItem!.toMap(),
      if (phanDoBenhItem != null)         'phanDoBenh':         phanDoBenhItem!.toMap(),
      if (loaiBenhPhamItem != null)       'loaiBenhPham':       loaiBenhPhamItem!.toMap(),
      if (loaiXetNghiemItem != null)      'loaiXetNghiem':      loaiXetNghiemItem!.toMap(),
      if (ketQuaXetNghiemItem != null)    'ketQuaXetNghiem':    ketQuaXetNghiemItem!.toMap(),
      if (coSoBaoCaoItem != null)         'coSoBaoCao':         coSoBaoCaoItem!.toMap(),
      if (donViDieuTra != null)           'donViDieuTra':       donViDieuTra,
      if (coSoDieuTriItem != null)        'coSoDieuTri':        coSoDieuTriItem!.toMap(),
      if (phongKham != null)              'phongKham':          phongKham,
      if (soThuTu != null)                'soThuTu':            soThuTu,
      'trangThai':   trangThai ?? 'Chờ',
      'ngayDangKy':  ngayDangKy ?? FieldValue.serverTimestamp(),
      'ngayCapNhat': FieldValue.serverTimestamp(),
    };
  }

  /// Payload chuẩn để đẩy lên API ngoài — các trường danh mục chỉ lấy id (String).
  /// Null nếu không có dữ liệu. Format khớp chuẩn JSON API:
  /// {"GioiTinh":"263","DanTocId":"15","ChanDoanBenh":"16",...}
  Map<String, dynamic> toApiPayload() => {
    'Id':                   null,
    'UnitId':               null,
    'MaBenhNhan':           cccd ?? '',
    'HoTen':                hoTen,
    'NgaySinh':             ngaySinh,
    'GioiTinh':             gioiTinhItem?.id.toString(),
    'DanTocId':             danTocItem?.id.toString(),
    'MaDinhDanhCaNhan':     cccd ?? '000',
    'SDT':                  soDienThoai,
    'BHYT':                 baoHiemYTe,
    'NgheNghiep':           ngheNghiep,
    'DiaChi':               diaChi ?? '',
    'CityId':               tinhItem?.id.toString(),
    'WardId':               phuong,
    'NhomMau':              nhomMau,
    'BenhNen':              benhNenItem?.id.toString(),
    'BenhTruyenNhiem':      benhTruyenNhiemItem?.id.toString(),
    'TinhTrangTiemChung':   tinhTrangTiemChungItem?.id.toString(),
    'CoKhong':              coKhongItem?.id.toString(),
    'DieuTri':              dieuTriItem?.id.toString(),
    'HinhThucDieuTri':      hinhThucDieuTriItem?.id.toString(),
    'ChanDoanBenh':         chanDoanBenhItem?.id.toString(),
    'PhanLoaiChanDoan':     phanLoaiChanDoanItem?.id.toString(),
    'PhanDoBenh':           phanDoBenhItem?.id.toString(),
    'LoaiBenhPham':         loaiBenhPhamItem?.id.toString(),
    'LoaiXetNghiem':        loaiXetNghiemItem?.id.toString(),
    'KetQuaXetNghiem':      ketQuaXetNghiemItem?.id.toString(),
    'CoSoBaoCao':           coSoBaoCaoItem?.id.toString(),
    'CoSoDieuTri':          coSoDieuTriItem?.id.toString(),
    'DonViDieuTra':         donViDieuTra,
    'PhongKham':            phongKham,
    'TrangThai':            trangThai ?? 'Chờ',
    'SoThuTu':              soThuTu,
  };
}

