import 'package:flutter/material.dart';
import '../../models/benh_truyen_nhiem.dart';
import '../../services/benh_truyen_nhiem_service.dart';
import 'them_btn_screen.dart';
import 'chi_tiet_btn_screen.dart';

class DanhSachBTNScreen extends StatefulWidget {
  const DanhSachBTNScreen({super.key});

  @override
  State<DanhSachBTNScreen> createState() => _DanhSachBTNScreenState();
}

class _DanhSachBTNScreenState extends State<DanhSachBTNScreen> {
  final _service = BenhTruyenNhiemService();
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<BenhTruyenNhiem> _loc(List<BenhTruyenNhiem> ds) {
    if (_query.isEmpty) return ds;
    final q = _query.toLowerCase();
    return ds.where((b) =>
        b.hoTen.toLowerCase().contains(q) ||
        (b.maDinhDanhCaNhan ?? '').contains(q) ||
        (b.sdt ?? '').contains(q) ||
        (b.chanDoanBenh ?? '').toLowerCase().contains(q) ||
        b.id.toLowerCase().contains(q)).toList();
  }

  Color _mauKetQua(String? kq) {
    switch (kq) {
      case 'Dương tính': return Colors.red.shade600;
      case 'Âm tính':   return Colors.green.shade600;
      case 'Nghi ngờ':  return Colors.orange.shade600;
      default:           return Colors.grey.shade500;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => const ThemBTNScreen())),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Thêm ca bệnh', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Row(children: [
          Icon(Icons.coronavirus, size: 22),
          SizedBox(width: 8),
          Text('Bệnh Truyền Nhiễm', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        ]),
        actions: [
          StreamBuilder<List<BenhTruyenNhiem>>(
            stream: _service.streamDanhSach(),
            builder: (_, snap) {
              final total = snap.data?.length ?? 0;
              return Container(
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(12)),
                child: Text('$total ca', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              );
            },
          ),
        ],
      ),
      body: Column(children: [
        // ── Thanh tìm kiếm ──
        Container(
          color: const Color(0xFF2E7D32),
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
          child: TextField(
            controller: _searchCtrl,
            onChanged: (v) => setState(() => _query = v),
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Tìm tên, CCCD, SĐT, chẩn đoán, ID...',
              hintStyle: TextStyle(color: Colors.white.withAlpha(170)),
              prefixIcon: const Icon(Icons.search, color: Colors.white70),
              suffixIcon: _query.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: Colors.white70),
                      onPressed: () { _searchCtrl.clear(); setState(() => _query = ''); })
                  : null,
              filled: true,
              fillColor: Colors.white.withAlpha(30),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
        ),

        // ── Danh sách ──
        Expanded(
          child: StreamBuilder<List<BenhTruyenNhiem>>(
            stream: _service.streamDanhSach(),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snap.hasError) {
                return Center(child: Text('Lỗi: ${snap.error}', textAlign: TextAlign.center));
              }
              final ds = _loc(snap.data ?? []);
              if (ds.isEmpty) {
                return Center(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.coronavirus_outlined, size: 72, color: Colors.grey.shade300),
                    const SizedBox(height: 12),
                    Text(_query.isEmpty ? 'Chưa có ca bệnh nào' : 'Không tìm thấy kết quả',
                        style: TextStyle(fontSize: 16, color: Colors.grey.shade500)),
                  ]),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 100),
                itemCount: ds.length,
                itemBuilder: (_, i) => _BtnCard(
                  btn: ds[i],
                  mauKetQua: _mauKetQua(ds[i].ketQuaXN),
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => ChiTietBTNScreen(btnId: ds[i].id))),
                ),
              );
            },
          ),
        ),
      ]),
    );
  }
}

// ── Card ────────────────────────────────────────────────────────────────────
class _BtnCard extends StatelessWidget {
  final BenhTruyenNhiem btn;
  final Color mauKetQua;
  final VoidCallback onTap;
  const _BtnCard({required this.btn, required this.mauKetQua, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final b = btn;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(children: [
            // Avatar / icon bệnh
            Container(
              width: 52, height: 52,
              decoration: BoxDecoration(
                color: mauKetQua.withAlpha(20),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: mauKetQua.withAlpha(80), width: 1.5),
              ),
              child: Icon(Icons.coronavirus, color: mauKetQua, size: 26),
            ),
            const SizedBox(width: 14),

            // Thông tin chính
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(b.hoTen,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20))),
                const SizedBox(height: 3),
                if (b.ngaySinh != null)
                  _Row(Icons.cake_outlined, b.ngaySinh!),
                if (b.chanDoanBenh != null)
                  _Row(Icons.content_paste_search_outlined, 'Chẩn đoán: ${b.chanDoanBenh!}'),
                if (b.maDinhDanhCaNhan != null && b.maDinhDanhCaNhan != '000')
                  _Row(Icons.credit_card_outlined, 'CCCD: ${b.maDinhDanhCaNhan!}'),
                if (b.ngayKhoiPhat != null)
                  _Row(Icons.calendar_today_outlined, 'Khởi phát: ${b.ngayKhoiPhat!}'),
                const SizedBox(height: 4),
              ]),
            ),

            // Kết quả XN badge + chevron
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              if (b.ketQuaXN != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: mauKetQua.withAlpha(20),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: mauKetQua.withAlpha(100)),
                  ),
                  child: Text(b.ketQuaXN!,
                      style: TextStyle(fontSize: 11, color: mauKetQua, fontWeight: FontWeight.bold)),
                ),
              const SizedBox(height: 6),
              const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
            ]),
          ]),
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final IconData icon;
  final String text;
  const _Row(this.icon, this.text);
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 2),
        child: Row(children: [
          Icon(icon, size: 13, color: Colors.grey.shade500),
          const SizedBox(width: 4),
          Expanded(child: Text(text,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
              overflow: TextOverflow.ellipsis)),
        ]),
      );
}
