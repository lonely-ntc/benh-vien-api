import 'package:flutter/material.dart';
import '../models/benh_nhan.dart';
import '../models/benh_truyen_nhiem.dart';
import '../services/firestore_service.dart';
import '../services/benh_truyen_nhiem_service.dart';
import '../services/api_push_service.dart';

class DayDuLieuScreen extends StatefulWidget {
  const DayDuLieuScreen({super.key});
  @override
  State<DayDuLieuScreen> createState() => _DayDuLieuScreenState();
}

class _DayDuLieuScreenState extends State<DayDuLieuScreen>
    with SingleTickerProviderStateMixin {

  late final TabController _tabCtrl;

  // ── Shared auth ──────────────────────────────────────────────────────────
  final _userCtrl = TextEditingController();
  final _mkCtrl   = TextEditingController();
  bool _hienMK       = false;
  bool _layingToken  = false;
  String? _token;
  String? _tokenError;

  // ── Bệnh nhân ────────────────────────────────────────────────────────────
  final Set<String> _selBN    = {};
  bool _pushingBN             = false;
  List<PushKetQua> _ketQuaBN  = [];
  bool _hienKetQuaBN          = false;

  // ── Bệnh truyền nhiễm ────────────────────────────────────────────────────
  final Set<String> _selBTN   = {};
  bool _pushingBTN            = false;
  List<PushKetQua> _ketQuaBTN = [];
  bool _hienKetQuaBTN         = false;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _userCtrl.dispose();
    _mkCtrl.dispose();
    super.dispose();
  }

  // ── Lấy token ─────────────────────────────────────────────────────────────
  Future<void> _layToken() async {
    if (_userCtrl.text.trim().isEmpty || _mkCtrl.text.isEmpty) {
      setState(() => _tokenError = 'Vui lòng nhập username và password');
      return;
    }
    setState(() { _layingToken = true; _tokenError = null; });
    final tok = await ApiPushService().layToken(_userCtrl.text.trim(), _mkCtrl.text);
    setState(() {
      _layingToken = false;
      _token = tok;
      _tokenError = tok == null
          ? 'Sai tài khoản hoặc không kết nối được API (Render có thể đang sleep, thử lại sau 30s)'
          : null;
    });
  }

  // ── Đẩy bệnh nhân ─────────────────────────────────────────────────────────
  Future<void> _dayBN(List<BenhNhan> ds) async {
    if (_token == null) { _nhacToken(); return; }
    if (_selBN.isEmpty) { _nhacChon(); return; }
    setState(() { _pushingBN = true; _ketQuaBN = []; _hienKetQuaBN = false; });

    final list = ds.where((e) => _selBN.contains(e.id))
        .map((e) => {'id': e.id, ...e.toFirestore(), 'soThuTu': e.soThuTu}).toList();
    final r = await ApiPushService().dayNhieuBenhNhan(_token!, list);

    setState(() { _pushingBN = false; _ketQuaBN = r; _hienKetQuaBN = true; });
  }

  // ── Đẩy bệnh truyền nhiễm ─────────────────────────────────────────────────
  Future<void> _dayBTN(List<BenhTruyenNhiem> ds) async {
    if (_token == null) { _nhacToken(); return; }
    if (_selBTN.isEmpty) { _nhacChon('ca bệnh'); return; }
    setState(() { _pushingBTN = true; _ketQuaBTN = []; _hienKetQuaBTN = false; });

    // Dùng toApiPayload() — chỉ lấy id (String) cho các trường danh mục
    final list = ds.where((e) => _selBTN.contains(e.id))
        .map((e) => {'id': e.id, ...e.toApiPayload()}).toList();
    final r = await ApiPushService().dayNhieuBTN(_token!, list);

    setState(() { _pushingBTN = false; _ketQuaBTN = r; _hienKetQuaBTN = true; });
  }

  void _nhacToken() => ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Vui lòng lấy token trước'), backgroundColor: Colors.orange));

  void _nhacChon([String loai = 'bệnh nhân']) => ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Chọn ít nhất 1 $loai'), backgroundColor: Colors.orange));

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        title: const Row(children: [
          Icon(Icons.upload_rounded, size: 22),
          SizedBox(width: 8),
          Text('Đẩy dữ liệu lên API', style: TextStyle(fontWeight: FontWeight.bold)),
        ]),
        bottom: TabBar(
          controller: _tabCtrl,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          tabs: const [
            Tab(icon: Icon(Icons.people, size: 18), text: 'Bệnh nhân'),
            Tab(icon: Icon(Icons.coronavirus, size: 18), text: 'Bệnh TN'),
          ],
        ),
      ),
      body: Column(children: [
        // ── Phần xác thực (dùng chung 2 tab) ──────────────────────────────
        _buildAuthSection(),
        const Divider(height: 1),

        // ── Tab nội dung ───────────────────────────────────────────────────
        Expanded(
          child: TabBarView(
            controller: _tabCtrl,
            children: [
              _TabBenhNhan(
                token: _token,
                selected: _selBN,
                pushing: _pushingBN,
                ketQua: _ketQuaBN,
                hienKetQua: _hienKetQuaBN,
                onDay: _dayBN,
                onToggle: (id) => setState(() {
                  if (_selBN.contains(id)) { _selBN.remove(id); }
                  else { _selBN.add(id); }
                }),
                onChonTatCa: (ds) => setState(() {
                  if (_selBN.length == ds.length) { _selBN.clear(); }
                  else { _selBN.addAll(ds.map((e) => e.id)); }
                }),
              ),
              _TabBTN(
                token: _token,
                selected: _selBTN,
                pushing: _pushingBTN,
                ketQua: _ketQuaBTN,
                hienKetQua: _hienKetQuaBTN,
                onDay: _dayBTN,
                onToggle: (id) => setState(() {
                  if (_selBTN.contains(id)) { _selBTN.remove(id); }
                  else { _selBTN.add(id); }
                }),
                onChonTatCa: (ds) => setState(() {
                  if (_selBTN.length == ds.length) { _selBTN.clear(); }
                  else { _selBTN.addAll(ds.map((e) => e.id)); }
                }),
              ),
            ],
          ),
        ),
      ]),
    );
  }

  Widget _buildAuthSection() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('1. Xác thực tài khoản API',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1565C0))),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(child: _inputField(_userCtrl, 'Username', Icons.person_outline)),
          const SizedBox(width: 8),
          Expanded(child: _inputField(_mkCtrl, 'Password', Icons.lock_outline,
              obscure: !_hienMK,
              suffix: IconButton(
                icon: Icon(_hienMK ? Icons.visibility_off : Icons.visibility, size: 18),
                onPressed: () => setState(() => _hienMK = !_hienMK),
              ))),
        ]),
        if (_tokenError != null) ...[
          const SizedBox(height: 4),
          Text(_tokenError!, style: const TextStyle(color: Colors.red, fontSize: 11)),
        ],
        const SizedBox(height: 8),
        Row(children: [
          Expanded(
            child: SizedBox(
              height: 40,
              child: ElevatedButton.icon(
                onPressed: _layingToken ? null : _layToken,
                icon: _layingToken
                    ? const SizedBox(width: 14, height: 14,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.vpn_key, size: 16),
                label: Text(_layingToken ? 'Đang lấy...' : 'Lấy Token',
                    style: const TextStyle(fontSize: 13)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1565C0), foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
          ),
          if (_token != null) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                  color: Colors.green.shade50, borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade300)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.check_circle, color: Colors.green.shade600, size: 15),
                const SizedBox(width: 4),
                Text('Token OK', style: TextStyle(color: Colors.green.shade700, fontSize: 12, fontWeight: FontWeight.bold)),
              ]),
            ),
          ],
        ]),
      ]),
    );
  }

  Widget _inputField(TextEditingController ctrl, String label, IconData icon,
      {bool obscure = false, Widget? suffix}) =>
      TextField(
        controller: ctrl,
        obscureText: obscure,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, size: 17, color: Colors.grey.shade500),
          suffixIcon: suffix,
          isDense: true,
          filled: true, fillColor: const Color(0xFFF5F7FF),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF1565C0), width: 1.5)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        ),
      );
}

// ── Tab Bệnh nhân ────────────────────────────────────────────────────────────
class _TabBenhNhan extends StatelessWidget {
  final String? token;
  final Set<String> selected;
  final bool pushing;
  final List<PushKetQua> ketQua;
  final bool hienKetQua;
  final void Function(List<BenhNhan>) onDay;
  final void Function(String) onToggle;
  final void Function(List<BenhNhan>) onChonTatCa;

  const _TabBenhNhan({
    required this.token, required this.selected, required this.pushing,
    required this.ketQua, required this.hienKetQua, required this.onDay,
    required this.onToggle, required this.onChonTatCa,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<BenhNhan>>(
      stream: FirestoreService().streamDanhSachBenhNhan(),
      builder: (_, snap) {
        final ds = snap.data ?? [];
        return _buildBody(context, ds);
      },
    );
  }

  Widget _buildBody(BuildContext context, List<BenhNhan> ds) {
    return Column(children: [
      _header('2. Chọn bệnh nhân cần đẩy', ds.length, selected.length,
          () => onChonTatCa(ds)),
      const Divider(height: 1),
      Expanded(
        child: ds.isEmpty
            ? const Center(child: Text('Chưa có bệnh nhân nào'))
            : ListView.builder(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                itemCount: ds.length,
                itemBuilder: (_, i) {
                  final bn = ds[i];
                  final checked = selected.contains(bn.id);
                  final kq = ketQua.where((k) => k.id == bn.id).firstOrNull;
                  return _ItemCard(
                    checked: checked,
                    label: bn.hoTen,
                    sub: bn.ngaySinh ?? '',
                    badge: '${bn.soThuTu ?? '-'}',
                    ketQua: kq,
                    color: const Color(0xFF1565C0),
                    onTap: () => onToggle(bn.id),
                  );
                },
              ),
      ),
      if (hienKetQua && ketQua.isNotEmpty) _ketQuaBox(ketQua),
      _dayButton(context, ds),
    ]);
  }

  Widget _dayButton(BuildContext context, List<BenhNhan> ds) => Container(
    padding: const EdgeInsets.all(12),
    color: Colors.white,
    child: SizedBox(
      width: double.infinity, height: 48,
      child: ElevatedButton.icon(
        onPressed: (pushing || selected.isEmpty) ? null : () => onDay(ds),
        icon: pushing
            ? const SizedBox(width: 18, height: 18,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : const Icon(Icons.upload_rounded),
        label: Text(
          pushing ? 'Đang đẩy...'
              : selected.isEmpty ? 'Chọn bệnh nhân để đẩy'
              : 'Đẩy ${selected.length} bệnh nhân lên API',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: selected.isEmpty ? Colors.grey : const Color(0xFF1565C0),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    ),
  );
}

// ── Tab Bệnh truyền nhiễm ─────────────────────────────────────────────────────
class _TabBTN extends StatelessWidget {
  final String? token;
  final Set<String> selected;
  final bool pushing;
  final List<PushKetQua> ketQua;
  final bool hienKetQua;
  final void Function(List<BenhTruyenNhiem>) onDay;
  final void Function(String) onToggle;
  final void Function(List<BenhTruyenNhiem>) onChonTatCa;

  const _TabBTN({
    required this.token, required this.selected, required this.pushing,
    required this.ketQua, required this.hienKetQua, required this.onDay,
    required this.onToggle, required this.onChonTatCa,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<BenhTruyenNhiem>>(
      stream: BenhTruyenNhiemService().streamDanhSach(),
      builder: (_, snap) {
        final ds = snap.data ?? [];
        return _buildBody(context, ds);
      },
    );
  }

  Widget _buildBody(BuildContext context, List<BenhTruyenNhiem> ds) {
    return Column(children: [
      _header('2. Chọn ca bệnh TN cần đẩy', ds.length, selected.length,
          () => onChonTatCa(ds)),
      const Divider(height: 1),
      Expanded(
        child: ds.isEmpty
            ? const Center(child: Text('Chưa có ca bệnh nào'))
            : ListView.builder(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                itemCount: ds.length,
                itemBuilder: (_, i) {
                  final btn = ds[i];
                  final checked = selected.contains(btn.id);
                  final kq = ketQua.where((k) => k.id == btn.id).firstOrNull;
                  return _ItemCard(
                    checked: checked,
                    label: btn.hoTen,
                    sub: btn.chanDoanBenh ?? btn.ngaySinh ?? '',
                    badge: btn.benhAnId ?? '—',
                    badgeSmall: true,
                    ketQua: kq,
                    color: const Color(0xFF2E7D32),
                    onTap: () => onToggle(btn.id),
                  );
                },
              ),
      ),
      if (hienKetQua && ketQua.isNotEmpty) _ketQuaBox(ketQua),
      _dayButton(ds),
    ]);
  }

  Widget _dayButton(List<BenhTruyenNhiem> ds) => Container(
    padding: const EdgeInsets.all(12),
    color: Colors.white,
    child: SizedBox(
      width: double.infinity, height: 48,
      child: ElevatedButton.icon(
        onPressed: (pushing || selected.isEmpty) ? null : () => onDay(ds),
        icon: pushing
            ? const SizedBox(width: 18, height: 18,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : const Icon(Icons.upload_rounded),
        label: Text(
          pushing ? 'Đang đẩy...'
              : selected.isEmpty ? 'Chọn ca bệnh để đẩy'
              : 'Đẩy ${selected.length} ca bệnh TN lên API',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: selected.isEmpty ? Colors.grey : const Color(0xFF2E7D32),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    ),
  );
}

// ── Shared widgets ────────────────────────────────────────────────────────────

Widget _header(String title, int total, int selCount, VoidCallback onChonTatCa) =>
    Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(children: [
        Expanded(child: Text(title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1565C0)))),
        if (total > 0) TextButton.icon(
          onPressed: onChonTatCa,
          icon: Icon(selCount == total ? Icons.deselect : Icons.select_all, size: 15),
          label: Text(selCount == total ? 'Bỏ tất cả' : 'Chọn tất cả',
              style: const TextStyle(fontSize: 12)),
          style: TextButton.styleFrom(foregroundColor: const Color(0xFF1565C0),
              padding: const EdgeInsets.symmetric(horizontal: 8)),
        ),
      ]),
    );

Widget _ketQuaBox(List<PushKetQua> ketQua) {
  final ok = ketQua.where((k) => k.isOk).length;
  return Container(
    width: double.infinity,
    color: Colors.white,
    padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Kết quả: $ok/${ketQua.length} thành công',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
      const SizedBox(height: 4),
      ...ketQua.map((k) => Padding(
        padding: const EdgeInsets.only(bottom: 3),
        child: Row(children: [
          Icon(k.isOk ? Icons.check_circle : Icons.error_outline,
              size: 14, color: k.isOk ? Colors.green.shade600 : Colors.red.shade600),
          const SizedBox(width: 6),
          Expanded(child: Text('${k.hoTen} — ${k.message}',
              style: TextStyle(fontSize: 11,
                  color: k.isOk ? Colors.green.shade700 : Colors.red.shade700))),
        ]),
      )),
      const SizedBox(height: 6),
    ]),
  );
}

class _ItemCard extends StatelessWidget {
  final bool checked;
  final String label;
  final String sub;
  final String badge;
  final bool badgeSmall;
  final PushKetQua? ketQua;
  final Color color;
  final VoidCallback onTap;

  const _ItemCard({
    required this.checked, required this.label, required this.sub,
    required this.badge, this.badgeSmall = false,
    this.ketQua, required this.color, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: checked ? 3 : 1,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(children: [
            // Checkbox
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 22, height: 22,
              decoration: BoxDecoration(
                color: checked ? color : Colors.white,
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: checked ? color : Colors.grey.shade400, width: 2),
              ),
              child: checked ? const Icon(Icons.check, color: Colors.white, size: 14) : null,
            ),
            const SizedBox(width: 10),
            // Badge
            Container(
              width: badgeSmall ? 44 : 34, height: 34,
              decoration: BoxDecoration(
                color: color.withAlpha(18), borderRadius: BorderRadius.circular(7)),
              child: Center(child: Text(badge,
                  style: TextStyle(fontWeight: FontWeight.bold,
                      fontSize: badgeSmall ? 10 : 13, color: color),
                  overflow: TextOverflow.ellipsis)),
            ),
            const SizedBox(width: 10),
            // Tên
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14,
                  color: color.withAlpha(220))),
              if (sub.isNotEmpty)
                Text(sub, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
            ])),
            // Status icon
            if (ketQua != null)
              Icon(ketQua!.isOk ? Icons.cloud_done : Icons.cloud_off,
                  size: 18,
                  color: ketQua!.isOk ? Colors.green.shade600 : Colors.red.shade400),
          ]),
        ),
      ),
    );
  }
}
