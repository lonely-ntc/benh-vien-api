import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/benh_nhan.dart';
import '../services/firestore_service.dart';
import 'chi_tiet_benh_nhan_screen.dart';
import 'them_benh_nhan_screen.dart';

class DanhSachBenhNhanScreen extends StatefulWidget {
  const DanhSachBenhNhanScreen({super.key});

  @override
  State<DanhSachBenhNhanScreen> createState() => _DanhSachBenhNhanScreenState();
}

class _DanhSachBenhNhanScreenState extends State<DanhSachBenhNhanScreen> {
  final FirestoreService _service = FirestoreService();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Color _mauTrangThai(String? trangThai) {
    switch (trangThai) {
      case 'Đang khám':
        return Colors.orange.shade700;
      case 'Đã khám':
        return Colors.green.shade600;
      default:
        return Colors.blue.shade600;
    }
  }

  IconData _iconTrangThai(String? trangThai) {
    switch (trangThai) {
      case 'Đang khám':
        return Icons.medical_services;
      case 'Đã khám':
        return Icons.check_circle;
      default:
        return Icons.hourglass_top;
    }
  }

  List<BenhNhan> _loc(List<BenhNhan> danhSach) {
    if (_searchQuery.isEmpty) return danhSach;
    final q = _searchQuery.toLowerCase();
    return danhSach.where((bn) {
      return bn.hoTen.toLowerCase().contains(q) ||
          (bn.soDienThoai ?? '').contains(q) ||
          (bn.cccd ?? '').contains(q) ||
          (bn.soThuTu?.toString() ?? '').contains(q) ||
          bn.id.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ThemBenhNhanScreen()),
        ),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add),
        label: const Text('Thêm bệnh nhân',
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Row(
          children: [
            Icon(Icons.local_hospital, size: 24),
            SizedBox(width: 8),
            Text(
              'Danh sách bệnh nhân',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        actions: [
          StreamBuilder<List<BenhNhan>>(
            stream: _service.streamDanhSachBenhNhan(),
            builder: (ctx, snap) {
              final total = snap.data?.length ?? 0;
              return Container(
                margin: const EdgeInsets.only(right: 12),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$total BN',
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Thanh tìm kiếm ──
          Container(
            color: const Color(0xFF1565C0),
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _searchQuery = v),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Tìm tên, SĐT, CCCD, số thứ tự, ID...',
                hintStyle: TextStyle(color: Colors.white.withAlpha(180)),
                prefixIcon: const Icon(Icons.search, color: Colors.white70),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.white70),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white.withAlpha(30),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // ── Danh sách ──
          Expanded(
            child: StreamBuilder<List<BenhNhan>>(
              stream: _service.streamDanhSachBenhNhan(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline,
                            size: 60, color: Colors.redAccent),
                        const SizedBox(height: 12),
                        Text('Lỗi: ${snapshot.error}',
                            textAlign: TextAlign.center),
                      ],
                    ),
                  );
                }

                final danhSach = _loc(snapshot.data ?? []);

                if (danhSach.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.person_search,
                            size: 80,
                            color: Colors.grey.shade400),
                        const SizedBox(height: 12),
                        Text(
                          _searchQuery.isEmpty
                              ? 'Chưa có bệnh nhân nào'
                              : 'Không tìm thấy kết quả',
                          style: TextStyle(
                              fontSize: 16, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 100),
                  itemCount: danhSach.length,
                  itemBuilder: (context, index) {
                    final bn = danhSach[index];
                    return _BenhNhanCard(
                      benhNhan: bn,
                      mauTrangThai: _mauTrangThai(bn.trangThai),
                      iconTrangThai: _iconTrangThai(bn.trangThai),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              ChiTietBenhNhanScreen(benhNhanId: bn.id),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Card bệnh nhân ──────────────────────────────────────────────────────────
class _BenhNhanCard extends StatelessWidget {
  final BenhNhan benhNhan;
  final Color mauTrangThai;
  final IconData iconTrangThai;
  final VoidCallback onTap;

  const _BenhNhanCard({
    required this.benhNhan,
    required this.mauTrangThai,
    required this.iconTrangThai,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bn = benhNhan;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              // Số thứ tự / Avatar
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: mauTrangThai.withAlpha(25),
                  borderRadius: BorderRadius.circular(12),
                  border:
                      Border.all(color: mauTrangThai.withAlpha(80), width: 1.5),
                ),
                child: Center(
                  child: bn.soThuTu != null
                      ? Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${bn.soThuTu}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: mauTrangThai,
                              ),
                            ),
                            Text(
                              'STT',
                              style: TextStyle(
                                  fontSize: 9, color: mauTrangThai),
                            ),
                          ],
                        )
                      : Icon(Icons.person, color: mauTrangThai, size: 28),
                ),
              ),
              const SizedBox(width: 14),

              // Thông tin chính
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bn.hoTen,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A237E),
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (bn.ngaySinh != null)
                      _InfoRow(icon: Icons.cake_outlined, text: bn.ngaySinh!),
                    if (bn.soDienThoai != null)
                      _InfoRow(icon: Icons.phone_outlined, text: bn.soDienThoai!),
                    if (bn.cccd != null)
                      _InfoRow(icon: Icons.credit_card_outlined, text: 'CCCD: ${bn.cccd!}'),
                    if (bn.phongKham != null)
                      _InfoRow(icon: Icons.door_front_door_outlined, text: bn.phongKham!),
                    // ── Dòng ID ──
                    const SizedBox(height: 4),
                    _IdRow(id: bn.id),
                  ],
                ),
              ),

              // Trạng thái
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: mauTrangThai.withAlpha(25),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: mauTrangThai.withAlpha(100)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(iconTrangThai,
                            size: 12, color: mauTrangThai),
                        const SizedBox(width: 4),
                        Text(
                          bn.trangThai ?? 'Chờ',
                          style: TextStyle(
                            fontSize: 11,
                            color: mauTrangThai,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Icon(Icons.chevron_right,
                      color: Colors.grey, size: 20),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Row(
        children: [
          Icon(icon, size: 13, color: Colors.grey.shade500),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              text,
              style:
                  TextStyle(fontSize: 12, color: Colors.grey.shade700),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// ── ID row với nút copy nhanh ────────────────────────────────────────────────
class _IdRow extends StatelessWidget {
  final String id;
  const _IdRow({required this.id});

  // Rút gọn ID: 6 ký tự đầu + ... + 4 ký tự cuối
  String get _short =>
      id.length > 12 ? '${id.substring(0, 6)}…${id.substring(id.length - 4)}' : id;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Clipboard.setData(ClipboardData(text: id));
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Đã copy ID bệnh nhân'),
          duration: Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
        ));
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
          color: const Color(0xFF1565C0).withAlpha(12),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
              color: const Color(0xFF1565C0).withAlpha(40), width: 0.8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.fingerprint,
                size: 12, color: Colors.grey.shade500),
            const SizedBox(width: 4),
            Text(
              'ID: $_short',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade600,
                fontFamily: 'monospace',
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.copy, size: 10, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
}
