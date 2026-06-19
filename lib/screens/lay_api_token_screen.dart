import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import '../models/benh_nhan.dart';
import '../models/benh_truyen_nhiem.dart';

const String _apiBaseUrl = 'https://benh-vien-api.onrender.com';

class LayApiTokenScreen extends StatefulWidget {
  /// Bệnh nhân đã chọn để preview request
  final List<BenhNhan> selectedBenhNhan;
  /// Ca bệnh truyền nhiễm đã chọn
  final List<BenhTruyenNhiem> selectedBTN;

  const LayApiTokenScreen({
    super.key,
    this.selectedBenhNhan = const [],
    this.selectedBTN = const [],
  });

  @override
  State<LayApiTokenScreen> createState() => _LayApiTokenScreenState();
}

class _LayApiTokenScreenState extends State<LayApiTokenScreen>
    with SingleTickerProviderStateMixin {
  final _formKey  = GlobalKey<FormState>();
  final _userCtrl = TextEditingController();
  final _mkCtrl   = TextEditingController();
  bool _hienMK    = false;
  bool _isLoading = false;

  late final TabController _tabCtrl;

  String? _token;
  String? _role;
  String? _hoTenLogin;
  String? _expiresIn;
  String? _loi;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _userCtrl.dispose();
    _mkCtrl.dispose();
    _tabCtrl.dispose();
    super.dispose();
  }

  Future<void> _layToken() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _isLoading = true; _loi = null; _token = null; });
    try {
      final resp = await http.post(
        Uri.parse('$_apiBaseUrl/api/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': _userCtrl.text.trim(), 'password': _mkCtrl.text}),
      ).timeout(const Duration(seconds: 30));

      final body = jsonDecode(resp.body) as Map<String, dynamic>;
      if (resp.statusCode == 200 && body['success'] == true) {
        setState(() {
          _token      = body['token'] as String?;
          _role       = body['role'] as String?;
          _hoTenLogin = body['hoTen'] as String?;
          _expiresIn  = body['expiresIn'] as String?;
        });
      } else {
        setState(() => _loi = body['message'] as String? ?? 'Lỗi không xác định.');
      }
    } catch (e) {
      String msg = 'Không kết nối được API.';
      if (e.toString().contains('imeout')) {
        msg = 'API timeout — Render free tier đang sleep, thử lại sau 30s.';
      } else if (e.toString().contains('SocketException')) {
        msg = 'Không có kết nối mạng hoặc không tìm thấy server.';
      }
      setState(() => _loi = msg);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _copy(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        const Icon(Icons.check_circle, color: Colors.white, size: 16),
        const SizedBox(width: 8),
        Text('Đã copy $label'),
      ]),
      backgroundColor: Colors.green.shade700,
      duration: const Duration(seconds: 2),
      behavior: SnackBarBehavior.floating,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6A1B9A),
        foregroundColor: Colors.white,
        title: const Row(children: [
          Icon(Icons.token, size: 22),
          SizedBox(width: 8),
          Text('Lấy API Token', style: TextStyle(fontWeight: FontWeight.bold)),
        ]),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [

          // ── Banner API URL ─────────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6A1B9A), Color(0xFF4A148C)],
                begin: Alignment.topLeft, end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(children: [
              const Icon(Icons.api, color: Colors.white70, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(_apiBaseUrl,
                    style: const TextStyle(color: Colors.white,
                        fontFamily: 'monospace', fontSize: 12)),
              ),
              GestureDetector(
                onTap: () => _copy(_apiBaseUrl, 'API URL'),
                child: const Icon(Icons.copy, color: Colors.white70, size: 16),
              ),
            ]),
          ),
          const SizedBox(height: 14),

          // ── Form đăng nhập ─────────────────────────────────────────────
          _buildLoginCard(),

          // ── Kết quả Token ──────────────────────────────────────────────
          if (_token != null) ...[
            const SizedBox(height: 16),
            _buildTokenCard(),
            const SizedBox(height: 16),
            _buildRequestsCard(),
          ],
          const SizedBox(height: 32),
        ]),
      ),
    );
  }

  // ── Login card ────────────────────────────────────────────────────────────
  Widget _buildLoginCard() => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      boxShadow: [BoxShadow(color: Colors.black.withAlpha(12), blurRadius: 10, offset: const Offset(0, 2))],
    ),
    child: Form(
      key: _formKey,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Xác thực tài khoản',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF6A1B9A))),
        const SizedBox(height: 14),
        TextFormField(
          controller: _userCtrl,
          textInputAction: TextInputAction.next,
          decoration: _dec('Username', Icons.alternate_email),
          validator: (v) => (v == null || v.trim().isEmpty) ? 'Nhập username' : null,
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: _mkCtrl,
          obscureText: !_hienMK,
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) => _layToken(),
          decoration: _dec('Password', Icons.lock_outline,
              suffix: IconButton(
                icon: Icon(_hienMK ? Icons.visibility_off : Icons.visibility,
                    size: 20, color: Colors.grey.shade500),
                onPressed: () => setState(() => _hienMK = !_hienMK),
              )),
          validator: (v) => (v == null || v.isEmpty) ? 'Nhập password' : null,
        ),
        if (_loi != null) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: Colors.red.shade50, borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200)),
            child: Row(children: [
              Icon(Icons.error_outline, color: Colors.red.shade600, size: 16),
              const SizedBox(width: 8),
              Expanded(child: Text(_loi!, style: TextStyle(color: Colors.red.shade700, fontSize: 12))),
            ]),
          ),
        ],
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity, height: 46,
          child: ElevatedButton.icon(
            onPressed: _isLoading ? null : _layToken,
            icon: _isLoading
                ? const SizedBox(width: 18, height: 18,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Icon(Icons.vpn_key, size: 18),
            label: Text(_isLoading ? 'Đang lấy token...' : 'Lấy JWT Token',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6A1B9A), foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),
      ]),
    ),
  );

  // ── Token card ────────────────────────────────────────────────────────────
  Widget _buildTokenCard() => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.green.shade50,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: Colors.green.shade300, width: 1.5),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Icon(Icons.check_circle, color: Colors.green.shade700, size: 20),
        const SizedBox(width: 8),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Token tạo thành công!',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green.shade800, fontSize: 14)),
          Text('Hết hạn: $_expiresIn  •  Role: $_role${_hoTenLogin != null ? '  •  $_hoTenLogin' : ''}',
              style: TextStyle(fontSize: 11, color: Colors.green.shade700)),
        ])),
      ]),
      const SizedBox(height: 12),
      // Token display
      Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
            color: const Color(0xFF1A1A2E), borderRadius: BorderRadius.circular(10)),
        child: Column(children: [
          Row(children: [
            Expanded(
              child: Text(_token!,
                  style: const TextStyle(color: Color(0xFF00FF88),
                      fontFamily: 'monospace', fontSize: 10, height: 1.5),
                  maxLines: 3, overflow: TextOverflow.ellipsis),
            ),
          ]),
        ]),
      ),
      const SizedBox(height: 10),
      Row(children: [
        Expanded(
          child: SizedBox(
            height: 40,
            child: ElevatedButton.icon(
              onPressed: () => _copy(_token!, 'Token'),
              icon: const Icon(Icons.copy, size: 16),
              label: const Text('Copy Token', style: TextStyle(fontSize: 12)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade700, foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: SizedBox(
            height: 40,
            child: OutlinedButton.icon(
              onPressed: () => _copy('Bearer $_token', 'Bearer Token'),
              icon: const Icon(Icons.copy_all, size: 16),
              label: const Text('Copy Bearer', style: TextStyle(fontSize: 12)),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.green.shade700,
                side: BorderSide(color: Colors.green.shade500),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
        ),
      ]),
    ]),
  );

  // ── Requests card — 2 tabs: Bệnh nhân / Bệnh TN ──────────────────────────
  Widget _buildRequestsCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(12), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(children: [
        // Header
        Container(
          decoration: const BoxDecoration(
            color: Color(0xFF1565C0),
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(14), topRight: Radius.circular(14)),
          ),
          child: Column(children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(children: [
                Icon(Icons.http, color: Colors.white, size: 18),
                SizedBox(width: 8),
                Text('API Requests', style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
              ]),
            ),
            TabBar(
              controller: _tabCtrl,
              indicatorColor: Colors.white,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white60,
              tabs: [
                Tab(text: 'Bệnh nhân (${widget.selectedBenhNhan.isNotEmpty ? widget.selectedBenhNhan.length : "tất cả"})'),
                Tab(text: 'Bệnh TN (${widget.selectedBTN.isNotEmpty ? widget.selectedBTN.length : "tất cả"})'),
              ],
            ),
          ]),
        ),
        SizedBox(
          height: 420,
          child: TabBarView(
            controller: _tabCtrl,
            children: [
              _buildBenhNhanRequests(),
              _buildBTNRequests(),
            ],
          ),
        ),
      ]),
    );
  }

  // ── Tab bệnh nhân ─────────────────────────────────────────────────────────
  Widget _buildBenhNhanRequests() {
    final hasSel = widget.selectedBenhNhan.isNotEmpty;
    final ids = widget.selectedBenhNhan.map((e) => e.id).toList();
    final bodyJson = jsonEncode({'ids': ids});
    final url = '$_apiBaseUrl/api/benhNhan/byIds';
    final curlSelected = 'curl -X POST "$url" \\\n'
        '  -H "Authorization: Bearer ${_token!}" \\\n'
        '  -H "Content-Type: application/json" \\\n'
        "  -d '$bodyJson'";
    final curlAll = 'curl -X GET "$_apiBaseUrl/api/benhNhan/tatca" \\\n'
        '  -H "Authorization: Bearer ${_token!}"';
    final curlPush = 'curl -X POST "$_apiBaseUrl/api/benhNhan/push" \\\n'
        '  -H "Authorization: Bearer ${_token!}" \\\n'
        '  -H "Content-Type: application/json" \\\n'
        '  -d \'{"hoTen":"...","gioiTinh":"263",...}\'';

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [

        // ── 1. POST byIds — xem dữ liệu đã chọn ──────────────────────────
        _RequestCard(
          badge: '1',
          method: 'POST',
          endpoint: '/api/benhNhan/byIds',
          badgeColor: const Color(0xFF1565C0),
          title: 'Xem bệnh nhân đã chọn',
          description: hasSel
              ? '${widget.selectedBenhNhan.length} bệnh nhân được chọn'
              : 'Chưa chọn bệnh nhân nào',
          curl: hasSel ? curlSelected : null,
          body: hasSel ? bodyJson : null,
          onCopy: _copy,
          // Danh sách tên bệnh nhân đã chọn
          patients: hasSel
              ? widget.selectedBenhNhan.map((bn) =>
                  '${bn.hoTen}'
                  '${bn.ngaySinh != null ? " · NS: ${bn.ngaySinh}" : ""}'
                  '${bn.cccd != null && bn.cccd!.isNotEmpty ? " · CCCD: ${bn.cccd}" : ""}'
                  '${bn.soDienThoai != null ? " · SĐT: ${bn.soDienThoai}" : ""}')
                .toList()
              : null,
          emptyHint: 'Vào "Đẩy dữ liệu" → tick chọn bệnh nhân → nhấn 🔑',
        ),
        const SizedBox(height: 12),

        // ── 2. POST push — cập nhật bệnh nhân đã chọn ────────────────────
        if (hasSel) ...[
          _RequestCard(
            badge: '2',
            method: 'POST',
            endpoint: '/api/benhNhan/push',
            badgeColor: Colors.orange.shade700,
            title: 'Cập nhật bệnh nhân (push)',
            description: 'Thêm hoặc cập nhật 1 bệnh nhân theo payload JSON',
            curl: curlPush,
            onCopy: _copy,
          ),
          const SizedBox(height: 12),
        ],

        // ── 3. GET tatca — tất cả bệnh nhân ──────────────────────────────
        _RequestCard(
          badge: '3',
          method: 'GET',
          endpoint: '/api/benhNhan/tatca',
          badgeColor: Colors.teal.shade700,
          title: 'Xem tất cả bệnh nhân',
          description: 'Trả về toàn bộ danh sách bệnh nhân trong hệ thống',
          curl: curlAll,
          onCopy: _copy,
        ),
      ],
    );
  }

  // ── Tab bệnh truyền nhiễm ─────────────────────────────────────────────────
  Widget _buildBTNRequests() {
    final hasSel = widget.selectedBTN.isNotEmpty;
    final ids = widget.selectedBTN.map((e) => e.id).toList();
    final bodyJson = jsonEncode({'ids': ids});
    final url = '$_apiBaseUrl/api/benhTruyenNhiem/byIds';
    final curlSelected = 'curl -X POST "$url" \\\n'
        '  -H "Authorization: Bearer ${_token!}" \\\n'
        '  -H "Content-Type: application/json" \\\n'
        "  -d '$bodyJson'";
    final curlAll = 'curl -X GET "$_apiBaseUrl/api/benhTruyenNhiem/tatca" \\\n'
        '  -H "Authorization: Bearer ${_token!}"';
    final curlPush = 'curl -X POST "$_apiBaseUrl/api/benhTruyenNhiem/push" \\\n'
        '  -H "Authorization: Bearer ${_token!}" \\\n'
        '  -H "Content-Type: application/json" \\\n'
        '  -d \'{"hoTen":"...","chanDoanBenh":"13",...}\'';

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [

        // ── 1. POST byIds — xem ca đã chọn ───────────────────────────────
        _RequestCard(
          badge: '1',
          method: 'POST',
          endpoint: '/api/benhTruyenNhiem/byIds',
          badgeColor: const Color(0xFF2E7D32),
          title: 'Xem ca bệnh TN đã chọn',
          description: hasSel
              ? '${widget.selectedBTN.length} ca bệnh được chọn'
              : 'Chưa chọn ca bệnh nào',
          curl: hasSel ? curlSelected : null,
          body: hasSel ? bodyJson : null,
          onCopy: _copy,
          patients: hasSel
              ? widget.selectedBTN.map((btn) =>
                  '${btn.hoTen}'
                  '${btn.ngaySinh != null ? " · NS: ${btn.ngaySinh}" : ""}'
                  '${btn.maDinhDanhCaNhan != null && btn.maDinhDanhCaNhan != "000" ? " · CCCD: ${btn.maDinhDanhCaNhan}" : ""}'
                  '${btn.sdt != null ? " · SĐT: ${btn.sdt}" : ""}'
                  '${btn.benhAnId != null ? " · ID: ${btn.benhAnId}" : ""}')
                .toList()
              : null,
          emptyHint: 'Vào "Đẩy dữ liệu" → tick chọn ca bệnh → nhấn 🔑',
        ),
        const SizedBox(height: 12),

        // ── 2. POST push — cập nhật ca bệnh đã chọn ──────────────────────
        if (hasSel) ...[
          _RequestCard(
            badge: '2',
            method: 'POST',
            endpoint: '/api/benhTruyenNhiem/push',
            badgeColor: Colors.orange.shade700,
            title: 'Cập nhật ca bệnh TN (push)',
            description: 'Thêm hoặc cập nhật 1 ca bệnh theo payload JSON',
            curl: curlPush,
            onCopy: _copy,
          ),
          const SizedBox(height: 12),
        ],

        // ── 3. GET tatca — tất cả ca bệnh ─────────────────────────────────
        _RequestCard(
          badge: '3',
          method: 'GET',
          endpoint: '/api/benhTruyenNhiem/tatca',
          badgeColor: Colors.teal.shade700,
          title: 'Xem tất cả ca bệnh TN',
          description: 'Trả về toàn bộ ca bệnh truyền nhiễm trong hệ thống',
          curl: curlAll,
          onCopy: _copy,
        ),
      ],
    );
  }

  InputDecoration _dec(String label, IconData icon, {Widget? suffix}) => InputDecoration(
    labelText: label,
    prefixIcon: Icon(icon, size: 20, color: const Color(0xFF6A1B9A)),
    suffixIcon: suffix,
    filled: true, fillColor: const Color(0xFFF5F0FF),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFCE93D8))),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFCE93D8))),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF6A1B9A), width: 1.5)),
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
  );
}

// ── _RequestCard ──────────────────────────────────────────────────────────────
class _RequestCard extends StatelessWidget {
  final String badge;
  final String method;
  final String endpoint;
  final Color badgeColor;
  final String title;
  final String description;
  final String? curl;
  final String? body;
  final List<String>? patients;
  final String? emptyHint;
  final void Function(String, String) onCopy;

  const _RequestCard({
    required this.badge, required this.method, required this.endpoint,
    required this.badgeColor, required this.title, required this.description,
    required this.onCopy,
    this.curl, this.body, this.patients, this.emptyHint,
  });

  Color get _methodColor {
    switch (method) {
      case 'POST': return Colors.orange.shade700;
      case 'GET':  return Colors.blue.shade700;
      default:     return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: badgeColor.withAlpha(40)),
        boxShadow: [BoxShadow(
            color: Colors.black.withAlpha(8), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: badgeColor.withAlpha(12),
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12), topRight: Radius.circular(12)),
          ),
          child: Row(children: [
            Container(
              width: 24, height: 24,
              decoration: BoxDecoration(color: badgeColor, shape: BoxShape.circle),
              child: Center(child: Text(badge, style: const TextStyle(
                  color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold))),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(color: _methodColor, borderRadius: BorderRadius.circular(5)),
              child: Text(method, style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(endpoint, style: TextStyle(
                fontFamily: 'monospace', fontSize: 11.5,
                color: badgeColor, fontWeight: FontWeight.w600))),
            if (curl != null)
              GestureDetector(
                onTap: () => onCopy(endpoint, 'endpoint'),
                child: Icon(Icons.copy, size: 14, color: Colors.grey.shade500),
              ),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 13, color: badgeColor)),
            const SizedBox(height: 2),
            Text(description, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
            // Danh sách bệnh nhân đã chọn
            if (patients != null && patients!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F7FF),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: badgeColor.withAlpha(30)),
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                    children: patients!.map((p) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(children: [
                        Icon(Icons.person, size: 12, color: badgeColor),
                        const SizedBox(width: 6),
                        Expanded(child: Text(p, style: const TextStyle(fontSize: 11, height: 1.4))),
                      ]),
                    )).toList()),
              ),
            ] else if (emptyHint != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: Colors.amber.shade50, borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.amber.shade300)),
                child: Row(children: [
                  Icon(Icons.info_outline, size: 14, color: Colors.amber.shade700),
                  const SizedBox(width: 6),
                  Expanded(child: Text(emptyHint!,
                      style: TextStyle(fontSize: 11, color: Colors.amber.shade900))),
                ]),
              ),
            ],
            // Body JSON
            if (body != null) ...[
              const SizedBox(height: 8),
              Row(children: [
                Text('Body:', style: TextStyle(fontSize: 11,
                    fontWeight: FontWeight.w600, color: Colors.grey.shade700)),
                const Spacer(),
                GestureDetector(
                  onTap: () => onCopy(body!, 'body JSON'),
                  child: Row(children: [
                    Icon(Icons.copy, size: 12, color: Colors.grey.shade500),
                    const SizedBox(width: 3),
                    Text('Copy', style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
                  ]),
                ),
              ]),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: const Color(0xFF1A1A2E),
                    borderRadius: BorderRadius.circular(7)),
                child: SelectableText(body!, style: const TextStyle(
                    color: Color(0xFFFFCC80), fontFamily: 'monospace',
                    fontSize: 10, height: 1.4)),
              ),
            ],
            // cURL
            if (curl != null) ...[
              const SizedBox(height: 8),
              Row(children: [
                Text('cURL:', style: TextStyle(fontSize: 11,
                    fontWeight: FontWeight.w600, color: Colors.grey.shade700)),
                const Spacer(),
                GestureDetector(
                  onTap: () => onCopy(curl!, 'cURL'),
                  child: Row(children: [
                    Icon(Icons.copy, size: 12, color: Colors.grey.shade500),
                    const SizedBox(width: 3),
                    Text('Copy cURL', style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
                  ]),
                ),
              ]),
              const SizedBox(height: 4),
              GestureDetector(
                onTap: () => onCopy(curl!, 'cURL'),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: const Color(0xFF1A1A2E),
                      borderRadius: BorderRadius.circular(7)),
                  child: Text(curl!, style: const TextStyle(
                      color: Color(0xFF00FF88), fontFamily: 'monospace',
                      fontSize: 10, height: 1.5)),
                ),
              ),
            ],
            const SizedBox(height: 10),
          ]),
        ),
      ]),
    );
  }
}
