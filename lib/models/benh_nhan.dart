// Model bệnh nhân — ánh xạ với collection Firestore
// Cấu trúc theo CategoryCode chuẩn

import 'package:cloud_firestore/cloud_firestore.dart';

class BenhNhan {
  final String id;

  // ── Thông tin cá nhân ──────────────────────────────────────────────────
  final String hoTen;
  final String? ngaySinh;           // "dd/MM/yyyy"
  final String? gioiTinh;           // CategoryCode: GioiTinh
  final String? danToc;             // CategoryCode: DanToc
  final String? ngheNghiep;         // CategoryCode: NgheNghiep
  final String? soDienThoai;
  final String? cccd;               // Căn cước công dân
  final String? baoHiemYTe;         // Số BHYT

  // ── Địa chỉ ───────────────────────────────────────────────────────────
  final String? diaChi;             // Địa chỉ đầy đủ
  final String? tinh;               // CategoryCode: Tinh
  final String? phuong;             // CategoryCode: Phuong
  final String? phuongMoiHCM;       // CategoryCode: PhuongMoiHCM

  // ── Thông tin y tế ────────────────────────────────────────────────────
  final String? nhomMau;
  final String? benhNen;            // CategoryCode: BenhNen
  final String? benhTruyenNhiem;    // CategoryCode: BenhTruyenNhiem
  final String? tinhTrangTiemChung; // CategoryCode: TinhTrangTiemChung
  final String? coKhong;            // CategoryCode: CoKhong (Có/Không — dị ứng)

  // ── Thông tin khám / điều trị ─────────────────────────────────────────
  final String? dieuTri;            // CategoryCode: DieuTri
  final String? hinhThucDieuTri;    // CategoryCode: HinhThucDieuTri
  final String? chanDoanBenh;       // CategoryCode: ChanDoanBenh
  final String? phanLoaiChanDoan;   // CategoryCode: PhanLoaiChanDoan
  final String? phanDoBenh;         // CategoryCode: PhanDoBenh
  final String? loaiBenhPham;       // CategoryCode: LoaiBenhPham
  final String? loaiXetNghiem;      // CategoryCode: LoaiXetNghiem
  final String? ketQuaXetNghiem;    // CategoryCode: KetQuaXetNghiem

  // ── Cơ sở / đơn vị ───────────────────────────────────────────────────
  final String? coSoBaoCao;         // CategoryCode: CoSoBaoCao
  final String? donViDieuTra;       // CategoryCode: DonViDieuTra
  final String? coSoDieuTri;        // CategoryCode: CoSoDieuTri
  final String? phongKham;

  // ── Token / trạng thái ────────────────────────────────────────────────
  final int? soThuTu;
  final String? trangThai;          // "Chờ" | "Đang khám" | "Đã khám"
  final DateTime? ngayDangKy;
  final DateTime? ngayCapNhat;

  const BenhNhan({
    required this.id,
    required this.hoTen,
    this.ngaySinh,
    this.gioiTinh,
    this.danToc,
    this.ngheNghiep,
    this.soDienThoai,
    this.cccd,
    this.baoHiemYTe,
    this.diaChi,
    this.tinh,
    this.phuong,
    this.phuongMoiHCM,
    this.nhomMau,
    this.benhNen,
    this.benhTruyenNhiem,
    this.tinhTrangTiemChung,
    this.coKhong,
    this.dieuTri,
    this.hinhThucDieuTri,
    this.chanDoanBenh,
    this.phanLoaiChanDoan,
    this.phanDoBenh,
    this.loaiBenhPham,
    this.loaiXetNghiem,
    this.ketQuaXetNghiem,
    this.coSoBaoCao,
    this.donViDieuTra,
    this.coSoDieuTri,
    this.phongKham,
    this.soThuTu,
    this.trangThai,
    this.ngayDangKy,
    this.ngayCapNhat,
  });

  factory BenhNhan.fromFirestore(Map<String, dynamic> data, String docId) {
    DateTime? parseTimestamp(dynamic val) {
      if (val == null) return null;
      if (val is Timestamp) return val.toDate();
      return null;
    }

    return BenhNhan(
      id: docId,
      hoTen: data['hoTen'] ?? '',
      ngaySinh: data['ngaySinh'],
      gioiTinh: data['gioiTinh'],
      danToc: data['danToc'],
      ngheNghiep: data['ngheNghiep'],
      soDienThoai: data['soDienThoai'],
      cccd: data['cccd'],
      baoHiemYTe: data['baoHiemYTe'],
      diaChi: data['diaChi'],
      tinh: data['tinh'],
      phuong: data['phuong'],
      phuongMoiHCM: data['phuongMoiHCM'],
      nhomMau: data['nhomMau'],
      benhNen: data['benhNen'],
      benhTruyenNhiem: data['benhTruyenNhiem'],
      tinhTrangTiemChung: data['tinhTrangTiemChung'],
      coKhong: data['coKhong'],
      dieuTri: data['dieuTri'],
      hinhThucDieuTri: data['hinhThucDieuTri'],
      chanDoanBenh: data['chanDoanBenh'],
      phanLoaiChanDoan: data['phanLoaiChanDoan'],
      phanDoBenh: data['phanDoBenh'],
      loaiBenhPham: data['loaiBenhPham'],
      loaiXetNghiem: data['loaiXetNghiem'],
      ketQuaXetNghiem: data['ketQuaXetNghiem'],
      coSoBaoCao: data['coSoBaoCao'],
      donViDieuTra: data['donViDieuTra'],
      coSoDieuTri: data['coSoDieuTri'],
      phongKham: data['phongKham'],
      soThuTu: data['soThuTu'] is int ? data['soThuTu'] : null,
      trangThai: data['trangThai'] ?? 'Chờ',
      ngayDangKy: parseTimestamp(data['ngayDangKy']),
      ngayCapNhat: parseTimestamp(data['ngayCapNhat']),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'hoTen': hoTen,
      if (ngaySinh != null) 'ngaySinh': ngaySinh,
      if (gioiTinh != null) 'gioiTinh': gioiTinh,
      if (danToc != null) 'danToc': danToc,
      if (ngheNghiep != null) 'ngheNghiep': ngheNghiep,
      if (soDienThoai != null) 'soDienThoai': soDienThoai,
      if (cccd != null) 'cccd': cccd,
      if (baoHiemYTe != null) 'baoHiemYTe': baoHiemYTe,
      if (diaChi != null) 'diaChi': diaChi,
      if (tinh != null) 'tinh': tinh,
      if (phuong != null) 'phuong': phuong,
      if (phuongMoiHCM != null) 'phuongMoiHCM': phuongMoiHCM,
      if (nhomMau != null) 'nhomMau': nhomMau,
      if (benhNen != null) 'benhNen': benhNen,
      if (benhTruyenNhiem != null) 'benhTruyenNhiem': benhTruyenNhiem,
      if (tinhTrangTiemChung != null) 'tinhTrangTiemChung': tinhTrangTiemChung,
      if (coKhong != null) 'coKhong': coKhong,
      if (dieuTri != null) 'dieuTri': dieuTri,
      if (hinhThucDieuTri != null) 'hinhThucDieuTri': hinhThucDieuTri,
      if (chanDoanBenh != null) 'chanDoanBenh': chanDoanBenh,
      if (phanLoaiChanDoan != null) 'phanLoaiChanDoan': phanLoaiChanDoan,
      if (phanDoBenh != null) 'phanDoBenh': phanDoBenh,
      if (loaiBenhPham != null) 'loaiBenhPham': loaiBenhPham,
      if (loaiXetNghiem != null) 'loaiXetNghiem': loaiXetNghiem,
      if (ketQuaXetNghiem != null) 'ketQuaXetNghiem': ketQuaXetNghiem,
      if (coSoBaoCao != null) 'coSoBaoCao': coSoBaoCao,
      if (donViDieuTra != null) 'donViDieuTra': donViDieuTra,
      if (coSoDieuTri != null) 'coSoDieuTri': coSoDieuTri,
      if (phongKham != null) 'phongKham': phongKham,
      if (soThuTu != null) 'soThuTu': soThuTu,
      'trangThai': trangThai ?? 'Chờ',
      'ngayDangKy': ngayDangKy ?? FieldValue.serverTimestamp(),
      'ngayCapNhat': FieldValue.serverTimestamp(),
    };
  }
}
