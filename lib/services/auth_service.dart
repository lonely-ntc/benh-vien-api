// AuthService — quản lý đăng nhập
// - Admin tổng: lưu trong collection "adminConfig" / doc "admin"
// - Tài khoản thường: lưu trong collection "taiKhoan"

import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';

class AuthService {
  static final AuthService _i = AuthService._();
  factory AuthService() => _i;
  AuthService._();

  final _db = FirebaseFirestore.instance;

  static const _colAdmin    = 'adminConfig';
  static const _docAdmin    = 'admin';
  static const _colTaiKhoan = 'taiKhoan';
  static const _defaultUser = 'admin';
  static const _defaultPass = 'admin123';

  // ── Session trong memory ────────────────────────────────────────────────
  bool _isLoggedIn = false;
  bool _isAdmin    = false;
  String? _currentUsername;

  bool    get isLoggedIn       => _isLoggedIn;
  bool    get isAdmin          => _isAdmin;
  String? get currentUsername  => _currentUsername;

  // ── Hash SHA-256 ─────────────────────────────────────────────────────────
  String hash(String password) =>
      sha256.convert(utf8.encode(password)).toString();

  // ── Khởi tạo tài khoản admin mặc định ────────────────────────────────────
  Future<void> khoiTao() async {
    final doc = await _db.collection(_colAdmin).doc(_docAdmin).get();
    if (!doc.exists) {
      await _db.collection(_colAdmin).doc(_docAdmin).set({
        'username':     _defaultUser,
        'passwordHash': hash(_defaultPass),
        'ngayTao':      FieldValue.serverTimestamp(),
        'ngayCapNhat':  FieldValue.serverTimestamp(),
      });
    }
  }

  // ── Đăng nhập ─────────────────────────────────────────────────────────────
  Future<String?> dangNhap(String username, String password) async {
    try {
      final u = username.trim();
      final h = hash(password);

      // 1. Kiểm tra admin
      final adminDoc = await _db.collection(_colAdmin).doc(_docAdmin).get();
      if (adminDoc.exists) {
        final d = adminDoc.data()!;
        if (u == (d['username'] ?? _defaultUser)) {
          if (h != (d['passwordHash'] ?? hash(_defaultPass))) {
            return 'Mật khẩu không đúng.';
          }
          _isLoggedIn      = true;
          _isAdmin         = true;
          _currentUsername = u;
          return null;
        }
      }

      // 2. Kiểm tra tài khoản thường
      final snap = await _db
          .collection(_colTaiKhoan)
          .where('username', isEqualTo: u)
          .where('hoatDong', isEqualTo: true)
          .limit(1)
          .get();

      if (snap.docs.isEmpty) return 'Tên đăng nhập không tồn tại.';
      final tkData = snap.docs.first.data();
      if (h != (tkData['passwordHash'] ?? '')) return 'Mật khẩu không đúng.';

      _isLoggedIn      = true;
      _isAdmin         = false;
      _currentUsername = u;
      return null;
    } catch (e) {
      return 'Lỗi kết nối: $e';
    }
  }

  // ── Đăng xuất ─────────────────────────────────────────────────────────────
  void dangXuat() {
    _isLoggedIn      = false;
    _isAdmin         = false;
    _currentUsername = null;
  }

  // ── Lấy username admin từ Firestore ──────────────────────────────────────
  Future<String> layUsernameAdmin() async {
    try {
      final doc = await _db.collection(_colAdmin).doc(_docAdmin).get();
      return doc.data()?['username'] ?? _defaultUser;
    } catch (_) {
      return _defaultUser;
    }
  }

  // ── Stream danh sách tài khoản ────────────────────────────────────────────
  Stream<List<Map<String, dynamic>>> streamDanhSachTaiKhoan() {
    return _db
        .collection(_colTaiKhoan)
        .orderBy('ngayTao', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => {'id': d.id, ...d.data()}).toList());
  }

  // ── Tạo tài khoản mới ─────────────────────────────────────────────────────
  Future<String?> taoTaiKhoan({
    required String username,
    required String password,
    String? hoTen,
  }) async {
    try {
      final u = username.trim();
      if (u.isEmpty)        return 'Tên đăng nhập không được để trống.';
      if (password.length < 6) return 'Mật khẩu phải ít nhất 6 ký tự.';

      // Trùng với admin
      final adminDoc = await _db.collection(_colAdmin).doc(_docAdmin).get();
      if (adminDoc.exists && adminDoc.data()?['username'] == u) {
        return 'Tên đăng nhập đã tồn tại.';
      }

      // Trùng trong taiKhoan
      final exist = await _db
          .collection(_colTaiKhoan)
          .where('username', isEqualTo: u)
          .limit(1)
          .get();
      if (exist.docs.isNotEmpty) return 'Tên đăng nhập đã tồn tại.';

      await _db.collection(_colTaiKhoan).add({
        'username':     u,
        'passwordHash': hash(password),
        'hoTen':        hoTen?.trim().isNotEmpty == true ? hoTen!.trim() : u,
        'hoatDong':     true,
        'ngayTao':      FieldValue.serverTimestamp(),
        'ngayCapNhat':  FieldValue.serverTimestamp(),
      });
      return null;
    } catch (e) {
      return 'Lỗi: $e';
    }
  }

  // ── Đổi mật khẩu tài khoản thường ────────────────────────────────────────
  Future<String?> doiMatKhauTaiKhoan(String id, String matKhauMoi) async {
    try {
      if (matKhauMoi.length < 6) return 'Mật khẩu phải ít nhất 6 ký tự.';
      await _db.collection(_colTaiKhoan).doc(id).update({
        'passwordHash': hash(matKhauMoi),
        'ngayCapNhat':  FieldValue.serverTimestamp(),
      });
      return null;
    } catch (e) {
      return 'Lỗi: $e';
    }
  }

  // ── Bật / Tắt tài khoản ───────────────────────────────────────────────────
  Future<void> doiTrangThai(String id, bool hoatDong) async {
    await _db.collection(_colTaiKhoan).doc(id).update({'hoatDong': hoatDong});
  }

  // ── Xóa tài khoản ─────────────────────────────────────────────────────────
  Future<void> xoaTaiKhoan(String id) async {
    await _db.collection(_colTaiKhoan).doc(id).delete();
  }
}
