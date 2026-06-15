import 'package:flutter/material.dart';
import '../models/benh_nhan.dart';
import '../services/firestore_service.dart';
import '../services/api_push_service.dart';

class DayDuLieuScreen extends StatefulWidget {
  const DayDuLieuScreen({super.key});
  @override
  State<DayDuLieuScreen> createState() => _DayDuLieuScreenState();
}

class _DayDuLieuScreenState extends State<DayDuLieuScreen> {
  final _service = FirestoreService();
  final _userCtrl = TextEditingController();
  final _mkCtrl   = TextEditingController();

  final Set<String> _selected = {}; // id đã chọn
  bool _hienMK       = false;
  bool _layingToken  = false;
  bool _pushing      = false;
  String? _token;
  String? _tokenError;
  List<PushKetQua> _ketQua = [];
  bool _hienKetQua = false;

  @override
  void dispose() {
    _userCtrl.dispose();
    _mkCtrl.dispose();
    super.dispose();
  }

  // Lấy token
  Future<void> _layToken() async {
    if (_userCtrl.text.trim().isEmpty || _mkCtrl.text.isEmpty) {
      setState(() => _tokenError = 'Vui lòng nhập username và password');
      return;
    }
    setState(() { _layingToken = true; _tokenError = null; });
    final tok = await ApiPushService().layToken(
        _userCtrl.text.trim(), _mkCtrl.text);
    setState(() {
      _layingToken = false;
      _token = tok;
      _tokenError = tok == null ? 'Sai username/password hoặc không kết nối được API' : null;
    });
  }

  // Đẩy dữ liệu đã chọn
  Future<void> _dayDuLieu(List<BenhNhan> danhSach) async {
    if (_token == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Vui lòng lấy token trước'), backgroundColor: Colors.orange));
      return;
    }
    if (_selected.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Chọn ít nhất 1 bệnh nhân'), backgroundColor: Colors.orange));
      return;
    }

    setState(() { _pushing = true; _ketQua = []; _hienKetQua = false; });

    final selectedList = danhSach.where((bn) => _selected.contains(bn.id)).toList();
    final dataList = selectedList.map((bn) => {
      'id': bn.id, ...bn.toFirestore(),
      'soThuTu': bn.soThuTu,
    }).toList();

    final results = await ApiPushService().dayNhieuBenhNhan(_token!, dataList);

    setState(() {
      _pushing   = false;
      _ketQua    = results;
      _hienKetQua = true;
    });
  }

  void _chonTatCa(List<BenhNhan> ds) {
    setState(() {
      if (_selected.length == ds.length) {
        _selected.clear();
      } else {
        _selected.addAll(ds.map((e) => e.id));
      }
    });
  }

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
      ),
      body: StreamBuilder<List<BenhNhan>>(
        stream: _service.streamDanhSachBenhNhan(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final danhSach = snap.data ?? [];

          return Column(children: [
            // ── Phần token ──────────────────────────────────────────────
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('1. Xác thực tài khoản API',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1565C0))),
                const SizedBox(height: 10),
                Row(children: [
                  Expanded(
                    child: TextField(
                      controller: _userCtrl,
                      decoration: _inputDec('Username', Icons.person_outline),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _mkCtrl,
                      obscureText: !_hienMK,
                      decoration: _inputDec('Password', Icons.lock_outline,
                          suffix: IconButton(
                            icon: Icon(_hienMK ? Icons.visibility_off : Icons.visibility, size: 18),
                            onPressed: () => setState(() => _hienMK = !_hienMK),
                          )),
                    ),
                  ),
                ]),
                if (_tokenError != null) ...[
                  const SizedBox(height: 6),
                  Text(_tokenError!, style: const TextStyle(color: Colors.red, fontSize: 12)),
                ],
                const SizedBox(height: 8),
                Row(children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _layingToken ? null : _layToken,
                      icon: _layingToken
                          ? const SizedBox(width: 16, height: 16,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Icon(Icons.vpn_key, size: 16),
                      label: Text(_layingToken ? 'Đang lấy...' : 'Lấy Token',
                          style: const TextStyle(fontSize: 13)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1565C0), foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
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
                        Icon(Icons.check_circle, color: Colors.green.shade600, size: 16),
                        const SizedBox(width: 4),
                        Text('Token OK', style: TextStyle(color: Colors.green.shade700, fontSize: 12, fontWeight: FontWeight.bold)),
                      ]),
                    ),
                  ],
                ]),
              ]),
            ),
            const Divider(height: 1),

            // ── Header chọn ─────────────────────────────────────────────
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(children: [
                const Text('2. Chọn bệnh nhân cần đẩy',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1565C0))),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => _chonTatCa(danhSach),
                  icon: Icon(_selected.length == danhSach.length && danhSach.isNotEmpty
                      ? Icons.deselect : Icons.select_all, size: 16),
                  label: Text(_selected.length == danhSach.length && danhSach.isNotEmpty
                      ? 'Bỏ chọn tất cả' : 'Chọn tất cả',
                      style: const TextStyle(fontSize: 12)),
                  style: TextButton.styleFrom(foregroundColor: const Color(0xFF1565C0)),
                ),
              ]),
            ),
            const Divider(height: 1),

            // ── Danh sách ───────────────────────────────────────────────
            Expanded(
              child: danhSach.isEmpty
                  ? const Center(child: Text('Chưa có bệnh nhân nào'))
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(12, 8, 12, 80),
                      itemCount: danhSach.length,
                      itemBuilder: (_, i) {
                        final bn = danhSach[i];
                        final checked = _selected.contains(bn.id);
                        return Card(
                          margin: const EdgeInsets.only(bottom: 6),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          elevation: checked ? 3 : 1,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(10),
                            onTap: () => setState(() {
                              if (checked) { _selected.remove(bn.id); }
                              else { _selected.add(bn.id); }
                            }),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              child: Row(children: [
                                // Checkbox
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 150),
                                  width: 24, height: 24,
                                  decoration: BoxDecoration(
                                    color: checked ? const Color(0xFF1565C0) : Colors.white,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                        color: checked ? const Color(0xFF1565C0) : Colors.grey.shade400,
                                        width: 2),
                                  ),
                                  child: checked
                                      ? const Icon(Icons.check, color: Colors.white, size: 16)
                                      : null,
                                ),
                                const SizedBox(width: 12),

                                // STT badge
                                Container(
                                  width: 36, height: 36,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1565C0).withAlpha(15),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Center(
                                    child: Text('${bn.soThuTu ?? '-'}',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                            color: Color(0xFF1565C0))),
                                  ),
                                ),
                                const SizedBox(width: 10),

                                // Tên + info
                                Expanded(
                                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                    Text(bn.hoTen,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w600, fontSize: 14,
                                            color: Color(0xFF1A237E))),
                                    if (bn.ngaySinh != null)
                                      Text(bn.ngaySinh!,
                                          style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                                  ]),
                                ),

                                // Trạng thái đẩy (nếu đã đẩy rồi)
                                if (_hienKetQua) ...[
                                  _buildStatusIcon(bn.id),
                                ],
                              ]),
                            ),
                          ),
                        );
                      },
                    ),
            ),

            // ── Kết quả đẩy ─────────────────────────────────────────────
            if (_hienKetQua && _ketQua.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                color: Colors.white,
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Kết quả đẩy (${_ketQua.where((k) => k.isOk).length}/${_ketQua.length} thành công):',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 6),
                  ..._ketQua.map((k) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(children: [
                      Icon(k.isOk ? Icons.check_circle : Icons.error_outline,
                          size: 16,
                          color: k.isOk ? Colors.green.shade600 : Colors.red.shade600),
                      const SizedBox(width: 6),
                      Expanded(child: Text(
                        '${k.hoTen} (STT ${k.soThuTu ?? '-'}) — ${k.message}',
                        style: TextStyle(
                            fontSize: 12,
                            color: k.isOk ? Colors.green.shade700 : Colors.red.shade700),
                      )),
                    ]),
                  )),
                ]),
              ),

            // ── Nút đẩy ────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: SizedBox(
                width: double.infinity, height: 50,
                child: ElevatedButton.icon(
                  onPressed: (_pushing || _selected.isEmpty)
                      ? null
                      : () => _dayDuLieu(danhSach),
                  icon: _pushing
                      ? const SizedBox(width: 20, height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.upload_rounded),
                  label: Text(
                    _pushing
                        ? 'Đang đẩy...'
                        : _selected.isEmpty
                            ? 'Chọn bệnh nhân để đẩy'
                            : 'Đẩy ${_selected.length} bệnh nhân lên API',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selected.isEmpty ? Colors.grey : const Color(0xFF1565C0),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ),
          ]);
        },
      ),
    );
  }

  Widget _buildStatusIcon(String id) {
    final k = _ketQua.where((r) => r.id == id).firstOrNull;
    if (k == null) return const SizedBox.shrink();
    return Icon(
      k.isOk ? Icons.cloud_done : Icons.cloud_off,
      size: 18,
      color: k.isOk ? Colors.green.shade600 : Colors.red.shade400,
    );
  }

  InputDecoration _inputDec(String label, IconData icon, {Widget? suffix}) =>
      InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 18, color: Colors.grey.shade500),
        suffixIcon: suffix,
        isDense: true,
        filled: true, fillColor: const Color(0xFFF5F7FF),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF1565C0), width: 1.5)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      );
}
