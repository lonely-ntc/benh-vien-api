// Service tương tác với Firestore

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/benh_nhan.dart';

class FirestoreService {
  static final FirestoreService _instance = FirestoreService._internal();
  factory FirestoreService() => _instance;
  FirestoreService._internal();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  static const String _collection = 'benhNhan';

  // ── Đọc ────────────────────────────────────────────────────────────────

  /// Stream realtime toàn bộ danh sách, sắp xếp theo số thứ tự
  /// — Tự động lọc trùng lặp trước khi trả về
  Stream<List<BenhNhan>> streamDanhSachBenhNhan() {
    return _db
        .collection(_collection)
        .orderBy('soThuTu', descending: false)
        .snapshots()
        .map((snap) {
          final all = snap.docs
              .map((d) => BenhNhan.fromFirestore(d.data(), d.id))
              .toList();
          return _locTrungLap(all);
        });
  }

  /// Lọc trùng lặp — giữ lại 1 bản ghi đại diện cho mỗi bệnh nhân.
  ///
  /// Quy tắc:
  ///   - Nếu bệnh nhân có CCCD → dùng CCCD làm key (mỗi CCCD = 1 người duy nhất)
  ///   - Nếu KHÔNG có CCCD → dùng tên + ngày sinh làm key
  ///   - Hai người trùng tên + ngày sinh nhưng CCCD KHÁC NHAU → là 2 người khác nhau, hiển thị cả 2
  ///
  /// Trong nhóm trùng key → giữ doc có [soThuTu] nhỏ nhất.
  List<BenhNhan> _locTrungLap(List<BenhNhan> danhSach) {
    final Map<String, BenhNhan> seen = {};

    for (final bn in danhSach) {
      final String key = _buildDedupKey(bn);

      if (!seen.containsKey(key)) {
        seen[key] = bn;
      } else {
        final existing = seen[key]!;
        final existingSTT = existing.soThuTu ?? 999999;
        final currentSTT  = bn.soThuTu ?? 999999;
        if (currentSTT < existingSTT) {
          seen[key] = bn;
        }
      }
    }

    final result = seen.values.toList()
      ..sort((a, b) => (a.soThuTu ?? 999999).compareTo(b.soThuTu ?? 999999));
    return result;
  }

  /// Tạo key nhận diện trùng lặp:
  ///   - Có CCCD    : key = "cccd:[số]"           — unique per person
  ///   - Không CCCD : key = "name:[tên]|dob:[ngày]" — fallback
  ///
  /// Hai bản ghi có CCCD KHÁC NHAU luôn sinh ra key khác nhau
  /// — không bao giờ bị gộp lại dù trùng tên và ngày sinh.
  String _buildDedupKey(BenhNhan bn) {
    final cccd = (bn.cccd ?? '').trim();
    if (cccd.isNotEmpty) {
      return 'cccd:$cccd';
    }
    // Chỉ fallback về tên+ngày sinh khi KHÔNG có CCCD
    final ten = bn.hoTen.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
    final dob = (bn.ngaySinh ?? '').trim();
    // Thêm Firestore doc ID vào key nếu không có đủ thông tin để phân biệt
    if (ten.isEmpty || dob.isEmpty) {
      return 'id:${bn.id}'; // mỗi doc là duy nhất
    }
    return 'name:$ten|dob:$dob';
  }

  /// Kiểm tra trùng lặp trước khi thêm mới.
  ///
  /// Trả về map gồm:
  ///   - 'trungCCCD'    : danh sách bệnh nhân trùng số CCCD
  ///   - 'trungTenNSinh': danh sách bệnh nhân trùng họ tên + ngày sinh
  Future<Map<String, List<BenhNhan>>> kiemTraTrungLap({
    required String hoTen,
    required String ngaySinh,
    required String cccd,
  }) async {
    final snap = await _db.collection(_collection).get();
    final all = snap.docs
        .map((d) => BenhNhan.fromFirestore(d.data(), d.id))
        .toList();

    final cccdClean = cccd.trim();
    final tenClean =
        hoTen.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
    final dobClean = ngaySinh.trim();

    // Trùng CCCD — không được phép lưu
    final trungCCCD = cccdClean.isNotEmpty
        ? all
            .where((bn) =>
                (bn.cccd ?? '').trim().isNotEmpty &&
                (bn.cccd ?? '').trim() == cccdClean)
            .toList()
        : <BenhNhan>[];

    // Trùng tên + ngày sinh — cần CCCD để phân biệt
    final trungTenNSinh = (tenClean.isNotEmpty && dobClean.isNotEmpty)
        ? all
            .where((bn) =>
                bn.hoTen.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ') ==
                    tenClean &&
                (bn.ngaySinh ?? '').trim() == dobClean)
            .toList()
        : <BenhNhan>[];

    return {
      'trungCCCD': trungCCCD,
      'trungTenNSinh': trungTenNSinh,
    };
  }
  Stream<BenhNhan?> streamBenhNhan(String id) {
    return _db.collection(_collection).doc(id).snapshots().map((doc) =>
        doc.exists && doc.data() != null
            ? BenhNhan.fromFirestore(doc.data()!, doc.id)
            : null);
  }

  // ── Ghi ────────────────────────────────────────────────────────────────

  /// Thêm bệnh nhân mới — tự sinh số thứ tự tiếp theo
  Future<String> themBenhNhan(BenhNhan benhNhan) async {
    final soThuTu = await _laysoThuTuTiepTheo();
    final data = benhNhan.toFirestore();
    data['soThuTu'] = soThuTu;
    // Tự động tạo benhNhanId từ soThuTu (VD: BN0001, BN0301)
    data['benhNhanId'] = 'BN${soThuTu.toString().padLeft(4, '0')}';
    data['ngayDangKy'] = FieldValue.serverTimestamp();
    data['ngayCapNhat'] = FieldValue.serverTimestamp();
    final docRef = await _db.collection(_collection).add(data);
    return docRef.id;
  }

  /// Cập nhật bệnh nhân đã có
  Future<void> capNhatBenhNhan(String id, BenhNhan benhNhan) async {
    final data = benhNhan.toFirestore();
    data['ngayCapNhat'] = FieldValue.serverTimestamp();
    await _db.collection(_collection).doc(id).update(data);
  }

  /// Xóa bệnh nhân
  Future<void> xoaBenhNhan(String id) async {
    await _db.collection(_collection).doc(id).delete();
  }

  // ── Nội bộ ─────────────────────────────────────────────────────────────

  /// Lấy số thứ tự lớn nhất hiện tại rồi +1
  Future<int> _laysoThuTuTiepTheo() async {
    final snap = await _db
        .collection(_collection)
        .orderBy('soThuTu', descending: true)
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return 1;
    final max = snap.docs.first.data()['soThuTu'];
    return (max is int ? max : 0) + 1;
  }
}
