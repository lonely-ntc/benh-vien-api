import 'package:cloud_firestore/cloud_firestore.dart';

enum VaiTro { admin, nhanVien }

class TaiKhoan {
  final String id;
  final String username;
  final String passwordHash; // lưu dạng hash đơn giản
  final String hoTen;
  final VaiTro vaiTro;
  final bool hoatDong;
  final DateTime? ngayTao;

  const TaiKhoan({
    required this.id,
    required this.username,
    required this.passwordHash,
    required this.hoTen,
    required this.vaiTro,
    this.hoatDong = true,
    this.ngayTao,
  });

  bool get isAdmin => vaiTro == VaiTro.admin;

  factory TaiKhoan.fromFirestore(Map<String, dynamic> d, String docId) {
    return TaiKhoan(
      id: docId,
      username: d['username'] ?? '',
      passwordHash: d['passwordHash'] ?? '',
      hoTen: d['hoTen'] ?? '',
      vaiTro: d['vaiTro'] == 'admin' ? VaiTro.admin : VaiTro.nhanVien,
      hoatDong: d['hoatDong'] ?? true,
      ngayTao: d['ngayTao'] is Timestamp
          ? (d['ngayTao'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'username': username,
        'passwordHash': passwordHash,
        'hoTen': hoTen,
        'vaiTro': vaiTro == VaiTro.admin ? 'admin' : 'nhanVien',
        'hoatDong': hoatDong,
        'ngayTao': ngayTao ?? FieldValue.serverTimestamp(),
      };
}
