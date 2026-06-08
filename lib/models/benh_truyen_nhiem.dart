// Model Bệnh Truyền Nhiễm — 51 trường theo chuẩn API
// Tham chiếu: Tài liệu 2.3 Chi tiết cấu trúc body

import 'package:cloud_firestore/cloud_firestore.dart';

class BenhTruyenNhiem {
  final String id; // Firestore document ID

  // ── 1-6: Thông tin cá nhân ────────────────────────────────────────────
  final String? benhAnId;           // 1. Id — Bệnh án ID (liên kết benhNhan)
  final String hoTen;               // 2. HoTen
  final String? ngaySinh;           // 3. NgaySinh — DD/MM/YYYY
  final String? gioiTinh;           // 4. GioiTinh — CategoryCode
  final String? danTocId;           // 5. DanTocId — CategoryCode DanToc
  final String? maDinhDanhCaNhan;   // 6. MaDinhDanhCaNhan — CCCD/CMND, nếu không có nhập 000
  final String? tenNguoiBaoHo;      // 7. TenNguoiBaoHo
  final String? sdt;                // 8. SDT — 10 chữ số
  final String? coThai;             // 9. CoThai — CategoryCode CoKhong
  final int? tuanThai;              // 10. TuanThai — số nguyên 1,2,3...
  final String? ngheNghiep;         // 11. NgheNghiep — CategoryCode
  final String? noiLamViecHoc;     // 12. noiLamViecHoc — nơi làm việc/học tập
  final String? diaChinoiLamViecHoc; // 13. DiaChinoiLamViecHoc
  final String? cityIdHoc;         // 14. cityIdHoc — tỉnh nơi làm/học (CategoryCode Tinh)
  final String? wardIdHoc;         // 15. wardIdHoc — phường xã nơi làm/học

  // ── 16-20: Địa chỉ hiện tại ───────────────────────────────────────────
  final String? noiOHienNay;        // 16. NoiOHienNay
  final String? cityId;             // 17. CityId — tỉnh nơi ở hiện tại
  final String? wardId;             // 18. WardId — phường xã nơi ở hiện tại
  final String? khuPhoAp;           // 19. KhuPhoAp — khu phố/ấp
  final String? soHSBA;             // 20. SoHSBA — số hồ sơ bệnh án

  // ── 21-26: Điều trị & chẩn đoán ──────────────────────────────────────
  final String? coSoDieuTri;        // 21. CoSoDieuTri — CategoryCode
  final String? cityIdCSDT;        // 22. cityIdCSDT — tỉnh cơ sở điều trị
  final String? hinhThucDieuTri;    // 23. HinhThucDieuTri — CategoryCode
  final String? chanDoanBenh;       // 24. ChanDoanBenh — CategoryCode ChanDoanBenh
  final String? phanDoBenh;         // 25. PhanDoBenh — CategoryCode
  final String? thongTinDieuTri;    // 26. ThongTinDieuTri — CategoryCode DieuTri

  // ── 27-32: Chẩn đoán bổ sung & ngày ──────────────────────────────────
  final String? chanDoanBienChung;  // 27. ChanDoanBienChung — biến chứng
  final String? chanDoanBenhKemTheo; // 28. ChanDoanBenhKemTheo
  final String? benhNenKemTheoId;   // 29. BenhNenKemTheoId — CategoryCode BenhNen
  final String? ngayKhoiPhat;       // 30. NgayKhoiPhat — DD/MM/YYYY
  final String? ngayNhapVien;       // 31. NgayNhapVien — DD/MM/YYYY
  final String? ngayXVTVCV;       // 32. ngayXVTVCV — xuất viện/tử vong/chuyển viện DD/MM/YYYY HH:mm

  // ── 33-39: Xét nghiệm ────────────────────────────────────────────────
  final String? phanLoaiChanDoan;   // 33. PhanLoaiChanDoan — CategoryCode
  final String? layMauXN;           // 34. LayMauXN — có/không lấy mẫu (CategoryCode CoKhong)
  final String? loaiBenhPham;       // 35. LoaiBenhPham — CategoryCode
  final String? donViThucHienXN;    // 36. DonViThucHienXN — đơn vị thực hiện XN
  final String? ngayLayMau;         // 37. NgayLayMau — DD/MM/YYYY
  final String? loaiXN;             // 38. LoaiXN — CategoryCode LoaiXetNghiem
  final String? ketQuaXN;           // 39. KetQuaXN — CategoryCode KetQuaXetNghiem

  // ── 40-41: Tiêm chủng ────────────────────────────────────────────────
  final String? tinhTrangTiem;      // 40. TinhTrangTiem — CategoryCode TinhTrangTiemChung
  final int? soMuiTiemUong;         // 41. SoMuiTiemUong — số nguyên

  // ── 42-44: Dịch tễ ───────────────────────────────────────────────────
  final String? tienSuDichTe;       // 42. TienSuDichTe
  final String? nguoiDieuTraDichTe; // 43. NguoiDieuTraDichTe
  final String? sdtNguoiDieuTraDTe; // 44. SDTNguoiDieuTraDTe — 10 số

  // ── 45-46: Đơn vị điều tra ───────────────────────────────────────────
  final String? donViDieuTra;       // 45. DonViDieuTra — CategoryCode
  final String? emailDonViDieuTra;  // 46. EmailDonViDieuTra

  // ── 47-50: Báo cáo ───────────────────────────────────────────────────
  final String? ngayBaoCao;         // 47. NgayBaoCao — DD/MM/YYYY HH:mm
  final String? nguoiBaoCao;        // 48. NguoiBaoCao
  final String? sdtNguoiBaoCao;     // 49. SDTNguoiBaoCao — 10 số
  final String? emailNguoiBaoCao;   // 50. EmailNguoiBaoCao

  // ── 51: Phân độ text ──────────────────────────────────────────────────
  final String? phanDoBenhText;     // 51. PhanDoBenhText — text nếu không có trong danh mục

  // ── Metadata ──────────────────────────────────────────────────────────
  final DateTime? ngayTao;
  final DateTime? ngayCapNhat;

  const BenhTruyenNhiem({
    required this.id,
    required this.hoTen,
    this.benhAnId,
    this.ngaySinh,
    this.gioiTinh,
    this.danTocId,
    this.maDinhDanhCaNhan,
    this.tenNguoiBaoHo,
    this.sdt,
    this.coThai,
    this.tuanThai,
    this.ngheNghiep,
    this.noiLamViecHoc,
    this.diaChinoiLamViecHoc,
    this.cityIdHoc,
    this.wardIdHoc,
    this.noiOHienNay,
    this.cityId,
    this.wardId,
    this.khuPhoAp,
    this.soHSBA,
    this.coSoDieuTri,
    this.cityIdCSDT,
    this.hinhThucDieuTri,
    this.chanDoanBenh,
    this.phanDoBenh,
    this.thongTinDieuTri,
    this.chanDoanBienChung,
    this.chanDoanBenhKemTheo,
    this.benhNenKemTheoId,
    this.ngayKhoiPhat,
    this.ngayNhapVien,
    this.ngayXVTVCV,
    this.phanLoaiChanDoan,
    this.layMauXN,
    this.loaiBenhPham,
    this.donViThucHienXN,
    this.ngayLayMau,
    this.loaiXN,
    this.ketQuaXN,
    this.tinhTrangTiem,
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

  factory BenhTruyenNhiem.fromFirestore(Map<String, dynamic> d, String docId) {
    DateTime? ts(dynamic v) =>
        v is Timestamp ? v.toDate() : null;
    int? toInt(dynamic v) =>
        v is int ? v : (v is String ? int.tryParse(v) : null);

    return BenhTruyenNhiem(
      id: docId,
      hoTen: d['hoTen'] ?? '',
      benhAnId: d['benhAnId'],
      ngaySinh: d['ngaySinh'],
      gioiTinh: d['gioiTinh'],
      danTocId: d['danTocId'],
      maDinhDanhCaNhan: d['maDinhDanhCaNhan'],
      tenNguoiBaoHo: d['tenNguoiBaoHo'],
      sdt: d['sdt'],
      coThai: d['coThai'],
      tuanThai: toInt(d['tuanThai']),
      ngheNghiep: d['ngheNghiep'],
      noiLamViecHoc: d['noiLamViecHoc'],
      diaChinoiLamViecHoc: d['diaChinoiLamViecHoc'],
      cityIdHoc: d['cityIdHoc'],
      wardIdHoc: d['wardIdHoc'],
      noiOHienNay: d['noiOHienNay'],
      cityId: d['cityId'],
      wardId: d['wardId'],
      khuPhoAp: d['khuPhoAp'],
      soHSBA: d['soHSBA'],
      coSoDieuTri: d['coSoDieuTri'],
      cityIdCSDT: d['cityIdCSDT'],
      hinhThucDieuTri: d['hinhThucDieuTri'],
      chanDoanBenh: d['chanDoanBenh'],
      phanDoBenh: d['phanDoBenh'],
      thongTinDieuTri: d['thongTinDieuTri'],
      chanDoanBienChung: d['chanDoanBienChung'],
      chanDoanBenhKemTheo: d['chanDoanBenhKemTheo'],
      benhNenKemTheoId: d['benhNenKemTheoId'],
      ngayKhoiPhat: d['ngayKhoiPhat'],
      ngayNhapVien: d['ngayNhapVien'],
      ngayXVTVCV: d['ngayXVTVCV'],
      phanLoaiChanDoan: d['phanLoaiChanDoan'],
      layMauXN: d['layMauXN'],
      loaiBenhPham: d['loaiBenhPham'],
      donViThucHienXN: d['donViThucHienXN'],
      ngayLayMau: d['ngayLayMau'],
      loaiXN: d['loaiXN'],
      ketQuaXN: d['ketQuaXN'],
      tinhTrangTiem: d['tinhTrangTiem'],
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
      ngayTao: ts(d['ngayTao']),
      ngayCapNhat: ts(d['ngayCapNhat']),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'hoTen': hoTen,
        if (benhAnId != null) 'benhAnId': benhAnId,
        if (ngaySinh != null) 'ngaySinh': ngaySinh,
        if (gioiTinh != null) 'gioiTinh': gioiTinh,
        if (danTocId != null) 'danTocId': danTocId,
        if (maDinhDanhCaNhan != null) 'maDinhDanhCaNhan': maDinhDanhCaNhan,
        if (tenNguoiBaoHo != null) 'tenNguoiBaoHo': tenNguoiBaoHo,
        if (sdt != null) 'sdt': sdt,
        if (coThai != null) 'coThai': coThai,
        if (tuanThai != null) 'tuanThai': tuanThai,
        if (ngheNghiep != null) 'ngheNghiep': ngheNghiep,
        if (noiLamViecHoc != null) 'noiLamViecHoc': noiLamViecHoc,
        if (diaChinoiLamViecHoc != null) 'diaChinoiLamViecHoc': diaChinoiLamViecHoc,
        if (cityIdHoc != null) 'cityIdHoc': cityIdHoc,
        if (wardIdHoc != null) 'wardIdHoc': wardIdHoc,
        if (noiOHienNay != null) 'noiOHienNay': noiOHienNay,
        if (cityId != null) 'cityId': cityId,
        if (wardId != null) 'wardId': wardId,
        if (khuPhoAp != null) 'khuPhoAp': khuPhoAp,
        if (soHSBA != null) 'soHSBA': soHSBA,
        if (coSoDieuTri != null) 'coSoDieuTri': coSoDieuTri,
        if (cityIdCSDT != null) 'cityIdCSDT': cityIdCSDT,
        if (hinhThucDieuTri != null) 'hinhThucDieuTri': hinhThucDieuTri,
        if (chanDoanBenh != null) 'chanDoanBenh': chanDoanBenh,
        if (phanDoBenh != null) 'phanDoBenh': phanDoBenh,
        if (thongTinDieuTri != null) 'thongTinDieuTri': thongTinDieuTri,
        if (chanDoanBienChung != null) 'chanDoanBienChung': chanDoanBienChung,
        if (chanDoanBenhKemTheo != null) 'chanDoanBenhKemTheo': chanDoanBenhKemTheo,
        if (benhNenKemTheoId != null) 'benhNenKemTheoId': benhNenKemTheoId,
        if (ngayKhoiPhat != null) 'ngayKhoiPhat': ngayKhoiPhat,
        if (ngayNhapVien != null) 'ngayNhapVien': ngayNhapVien,
        if (ngayXVTVCV != null) 'ngayXVTVCV': ngayXVTVCV,
        if (phanLoaiChanDoan != null) 'phanLoaiChanDoan': phanLoaiChanDoan,
        if (layMauXN != null) 'layMauXN': layMauXN,
        if (loaiBenhPham != null) 'loaiBenhPham': loaiBenhPham,
        if (donViThucHienXN != null) 'donViThucHienXN': donViThucHienXN,
        if (ngayLayMau != null) 'ngayLayMau': ngayLayMau,
        if (loaiXN != null) 'loaiXN': loaiXN,
        if (ketQuaXN != null) 'ketQuaXN': ketQuaXN,
        if (tinhTrangTiem != null) 'tinhTrangTiem': tinhTrangTiem,
        if (soMuiTiemUong != null) 'soMuiTiemUong': soMuiTiemUong,
        if (tienSuDichTe != null) 'tienSuDichTe': tienSuDichTe,
        if (nguoiDieuTraDichTe != null) 'nguoiDieuTraDichTe': nguoiDieuTraDichTe,
        if (sdtNguoiDieuTraDTe != null) 'sdtNguoiDieuTraDTe': sdtNguoiDieuTraDTe,
        if (donViDieuTra != null) 'donViDieuTra': donViDieuTra,
        if (emailDonViDieuTra != null) 'emailDonViDieuTra': emailDonViDieuTra,
        if (ngayBaoCao != null) 'ngayBaoCao': ngayBaoCao,
        if (nguoiBaoCao != null) 'nguoiBaoCao': nguoiBaoCao,
        if (sdtNguoiBaoCao != null) 'sdtNguoiBaoCao': sdtNguoiBaoCao,
        if (emailNguoiBaoCao != null) 'emailNguoiBaoCao': emailNguoiBaoCao,
        if (phanDoBenhText != null) 'phanDoBenhText': phanDoBenhText,
        'ngayTao': ngayTao ?? FieldValue.serverTimestamp(),
        'ngayCapNhat': FieldValue.serverTimestamp(),
      };
}
