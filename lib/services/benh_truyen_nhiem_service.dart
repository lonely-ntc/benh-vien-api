import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/benh_truyen_nhiem.dart';

class BenhTruyenNhiemService {
  static final BenhTruyenNhiemService _i = BenhTruyenNhiemService._();
  factory BenhTruyenNhiemService() => _i;
  BenhTruyenNhiemService._();

  final _db = FirebaseFirestore.instance;
  static const _col = 'benhTruyenNhiem';

  // ── Stream danh sách ──────────────────────────────────────────────────
  Stream<List<BenhTruyenNhiem>> streamDanhSach() {
    return _db
        .collection(_col)
        .orderBy('ngayTao', descending: true)
        .snapshots()
        .map((s) => s.docs
            .map((d) => BenhTruyenNhiem.fromFirestore(d.data(), d.id))
            .toList());
  }

  // ── Stream chi tiết ───────────────────────────────────────────────────
  Stream<BenhTruyenNhiem?> streamChiTiet(String id) {
    return _db.collection(_col).doc(id).snapshots().map((d) =>
        d.exists && d.data() != null
            ? BenhTruyenNhiem.fromFirestore(d.data()!, d.id)
            : null);
  }

  // ── Thêm mới ──────────────────────────────────────────────────────────
  Future<String> them(BenhTruyenNhiem obj) async {
    final data = obj.toFirestore();
    data['ngayTao'] = FieldValue.serverTimestamp();
    data['ngayCapNhat'] = FieldValue.serverTimestamp();
    final ref = await _db.collection(_col).add(data);
    return ref.id;
  }

  // ── Cập nhật ──────────────────────────────────────────────────────────
  Future<void> capNhat(String id, BenhTruyenNhiem obj) async {
    final data = obj.toFirestore();
    data['ngayCapNhat'] = FieldValue.serverTimestamp();
    await _db.collection(_col).doc(id).update(data);
  }

  // ── Xóa ───────────────────────────────────────────────────────────────
  Future<void> xoa(String id) => _db.collection(_col).doc(id).delete();

  // ── Tìm theo benhAnId (liên kết bệnh nhân) ───────────────────────────
  Future<List<BenhTruyenNhiem>> layTheoBenhNhan(String benhAnId) async {
    final snap = await _db
        .collection(_col)
        .where('benhAnId', isEqualTo: benhAnId)
        .get();
    return snap.docs
        .map((d) => BenhTruyenNhiem.fromFirestore(d.data(), d.id))
        .toList();
  }
}
