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

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [

        // ── GET /api/benhNhan — bệnh nhân đã chọn ────────────────────────
        _SectionLabel(
          icon: Icons.check_box_outlined,
          label: hasSel
              ? 'Bệnh nhân đã chọn (${widget.selectedBenhNhan.length})'
              : 'Bệnh nhân đã chọn',
          color: const Color(0xFF1565C0),
        ),
        const SizedBox(height: 6),
        if (hasSel) ...[
          _EndpointBox(
            method: 'GET',
            endpoint: '/api/benhNhan',
            description: 'Dữ liệu ${widget.selectedBenhNhan.length} bệnh nhân đã chọn',
            token: _token!,
            baseUrl: _apiBaseUrl,
            onCopy: _copy,
            // Hiển thị danh sách tên bệnh nhân đã chọn
            extraInfo: widget.selectedBenhNhan
                .map((bn) => '• ${bn.hoTen}'
                    '${bn.ngaySinh != null ? "  NS: ${bn.ngaySinh}" : ""}'
                    '${bn.cccd != null ? "  CCCD: ${bn.cccd}" : ""}'
                    '${bn.soDienThoai != null ? "  SĐT: ${bn.soDienThoai}" : ""}')
                .toList(),
          ),
        ] else
          _InfoTile('Chưa chọn bệnh nhân nào.\nVào "Đẩy dữ liệu" → tick bệnh nhân → nhấn icon 🔑 để xem request.'),

        const SizedBox(height: 16),

        // ── GET /api/tatcaBenhNhan — tất cả ──────────────────────────────
        _SectionLabel(
          icon: Icons.people_outline,
          label: 'Tất cả bệnh nhân  →  /api/benhNhan/tatca',
          color: const Color(0xFF1565C0),
        ),
        const SizedBox(height: 6),
        _EndpointBox(
          method: 'GET',
          endpoint: '/api/benhNhan/tatca',
          description: 'Lấy toàn bộ danh sách bệnh nhân trong hệ thống',
          token: _token!,
          baseUrl: _apiBaseUrl,
          onCopy: _copy,
        ),
      ],
    );
  }

  // ── Tab bệnh truyền nhiễm ─────────────────────────────────────────────────
  Widget _buildBTNRequests() {
    final hasSel = widget.selectedBTN.isNotEmpty;

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [

        // ── GET /api/benhTruyenNhiem — ca đã chọn ────────────────────────
        _SectionLabel(
          icon: Icons.check_box_outlined,
          label: hasSel
              ? 'Ca bệnh TN đã chọn (${widget.selectedBTN.length})'
              : 'Ca bệnh TN đã chọn',
          color: const Color(0xFF2E7D32),
        ),
        const SizedBox(height: 6),
        if (hasSel) ...[
          _EndpointBox(
            method: 'GET',
            endpoint: '/api/benhTruyenNhiem',
            description: 'Dữ liệu ${widget.selectedBTN.length} ca bệnh TN đã chọn',
            token: _token!,
            baseUrl: _apiBaseUrl,
            onCopy: _copy,
            color: const Color(0xFF2E7D32),
            extraInfo: widget.selectedBTN
                .map((btn) => '• ${btn.hoTen}'
                    '${btn.ngaySinh != null ? "  NS: ${btn.ngaySinh}" : ""}'
                    '${btn.maDinhDanhCaNhan != null && btn.maDinhDanhCaNhan != "000" ? "  CCCD: ${btn.maDinhDanhCaNhan}" : ""}'
                    '${btn.sdt != null ? "  SĐT: ${btn.sdt}" : ""}'
                    '${btn.benhAnId != null ? "  ID: ${btn.benhAnId}" : ""}')
                .toList(),
          ),
        ] else
          _InfoTile('Chưa chọn ca bệnh nào.\nVào "Đẩy dữ liệu" → tick ca bệnh → nhấn icon 🔑 để xem request.'),

        const SizedBox(height: 16),

        // ── GET /api/tatcaBenhTruyenNhiem — tất cả ────────────────────────
        _SectionLabel(
          icon: Icons.coronavirus_outlined,
          label: 'Tất cả ca bệnh TN  →  /api/benhTruyenNhiem/tatca',
          color: const Color(0xFF2E7D32),
        ),
        const SizedBox(height: 6),
        _EndpointBox(
          method: 'GET',
          endpoint: '/api/benhTruyenNhiem/tatca',
          description: 'Lấy toàn bộ ca bệnh truyền nhiễm trong hệ thống',
          token: _token!,
          baseUrl: _apiBaseUrl,
          onCopy: _copy,
          color: const Color(0xFF2E7D32),
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

// ── Section label ────────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _SectionLabel({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Row(children: [
    Icon(icon, size: 14, color: color),
    const SizedBox(width: 6),
    Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
  ]);
}

// ── Endpoint box — hiển thị request + danh sách bệnh nhân bên trong ──────────
class _EndpointBox extends StatelessWidget {
  final String method;
  final String endpoint;
  final String description;
  final String token;
  final String baseUrl;
  final void Function(String, String) onCopy;
  final Color color;
  final List<String>? extraInfo; // danh sách tên bệnh nhân đã chọn

  const _EndpointBox({
    required this.method,
    required this.endpoint,
    required this.description,
    required this.token,
    required this.baseUrl,
    required this.onCopy,
    this.color = const Color(0xFF1565C0),
    this.extraInfo,
  });

  String get _url => '$baseUrl$endpoint';
  String get _curl =>
      'curl -X $method "$_url" \\\n  -H "Authorization: Bearer $token"';

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color.withAlpha(8),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withAlpha(40)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        // ── Method + Endpoint + Copy URL ──────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 6),
          child: Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                  color: Colors.blue.shade600,
                  borderRadius: BorderRadius.circular(5)),
              child: Text(method, style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(endpoint, style: TextStyle(
                  fontFamily: 'monospace', fontSize: 12, color: color,
                  fontWeight: FontWeight.w600)),
            ),
            GestureDetector(
              onTap: () => onCopy(_url, 'URL'),
              child: Icon(Icons.copy, size: 14, color: Colors.grey.shade500),
            ),
          ]),
        ),

        // Mô tả
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(description,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
        ),

        // ── Danh sách bệnh nhân/BTN đã chọn ──────────────────────────────
        if (extraInfo != null && extraInfo!.isNotEmpty) ...[
          const SizedBox(height: 8),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 10),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(7),
              border: Border.all(color: color.withAlpha(30)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: extraInfo!.map((line) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text(line, style: TextStyle(
                    fontSize: 11, color: Colors.grey.shade800, height: 1.4)),
              )).toList(),
            ),
          ),
        ],

        // ── cURL ──────────────────────────────────────────────────────────
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
          child: GestureDetector(
            onTap: () => onCopy(_curl, 'cURL'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                  color: const Color(0xFF1A1A2E),
                  borderRadius: BorderRadius.circular(7)),
              child: Row(children: [
                Expanded(
                  child: Text(
                    'curl  $endpoint  -H "Authorization: Bearer ..."',
                    style: const TextStyle(color: Color(0xFF00FF88),
                        fontFamily: 'monospace', fontSize: 10),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(Icons.copy, size: 12, color: Colors.white38),
              ]),
            ),
          ),
        ),
      ]),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String text;
  const _InfoTile(this.text);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
        color: Colors.amber.shade50, borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.amber.shade300)),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(Icons.info_outline, size: 16, color: Colors.amber.shade700),
      const SizedBox(width: 8),
      Expanded(child: Text(text, style: TextStyle(fontSize: 12, color: Colors.amber.shade900))),
    ]),
  );
}
