import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

// ── Đổi URL này sau khi deploy lên Render ──────────────────────────────────
// Ví dụ: 'https://benh-vien-api.onrender.com'
const String _apiBaseUrl = 'https://benh-vien-api.onrender.com';

class LayApiTokenScreen extends StatefulWidget {
  const LayApiTokenScreen({super.key});
  @override
  State<LayApiTokenScreen> createState() => _LayApiTokenScreenState();
}

class _LayApiTokenScreenState extends State<LayApiTokenScreen> {
  final _formKey  = GlobalKey<FormState>();
  final _userCtrl = TextEditingController();
  final _mkCtrl   = TextEditingController();
  bool _hienMK    = false;
  bool _isLoading = false;

  // Kết quả
  String? _token;
  String? _role;
  String? _hoTen;
  String? _expiresIn;
  String? _loi;

  @override
  void dispose() {
    _userCtrl.dispose();
    _mkCtrl.dispose();
    super.dispose();
  }

  Future<void> _layToken() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _isLoading = true; _loi = null; _token = null; });

    try {
      final uri = Uri.parse('$_apiBaseUrl/api/auth/login');
      final resp = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': _userCtrl.text.trim(),
          'password': _mkCtrl.text,
        }),
      ).timeout(const Duration(seconds: 30));

      final body = jsonDecode(resp.body) as Map<String, dynamic>;

      if (resp.statusCode == 200 && body['success'] == true) {
        setState(() {
          _token     = body['token'] as String?;
          _role      = body['role'] as String?;
          _hoTen     = body['hoTen'] as String?;
          _expiresIn = body['expiresIn'] as String?;
        });
      } else {
        setState(() => _loi = body['message'] as String? ?? 'Lỗi không xác định.');
      }
    } catch (e) {
      String msg = 'Không kết nối được API.';
      if (e.toString().contains('Timeout') || e.toString().contains('timeout')) {
        msg = 'API timeout — Render free tier có thể đang sleep (30s đầu chậm), vui lòng thử lại.';
      } else if (e.toString().contains('SocketException') || e.toString().contains('Failed host lookup')) {
        msg = 'Không có kết nối mạng hoặc không tìm thấy server.';
      }
      setState(() => _loi = msg);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _copyToken() {
    if (_token == null) return;
    Clipboard.setData(ClipboardData(text: _token!));
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Row(children: [
        Icon(Icons.check_circle, color: Colors.white),
        SizedBox(width: 8),
        Text('Đã copy JWT Token'),
      ]),
      backgroundColor: Colors.green,
      duration: Duration(seconds: 2),
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
        padding: const EdgeInsets.all(20),
        child: Column(children: [

          // ── Giới thiệu ──────────────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6A1B9A), Color(0xFF4A148C)],
                begin: Alignment.topLeft, end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Row(children: [
                Icon(Icons.info_outline, color: Colors.white70, size: 18),
                SizedBox(width: 8),
                Text('JWT Token là gì?', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
              ]),
              const SizedBox(height: 8),
              Text(
                'Dùng token này để gọi API từ app/hệ thống khác.\nĐặt vào header: Authorization: Bearer <token>',
                style: TextStyle(color: Colors.white.withAlpha(210), fontSize: 13, height: 1.5),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: Colors.white.withAlpha(20), borderRadius: BorderRadius.circular(8)),
                child: Text(
                  _apiBaseUrl,
                  style: const TextStyle(color: Colors.white, fontFamily: 'monospace', fontSize: 12),
                ),
              ),
            ]),
          ),
          const SizedBox(height: 20),

          // ── Form đăng nhập ───────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [BoxShadow(color: Colors.black.withAlpha(12), blurRadius: 10, offset: const Offset(0, 2))],
            ),
            child: Form(
              key: _formKey,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Xác thực tài khoản', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF6A1B9A))),
                const SizedBox(height: 16),

                // Username
                TextFormField(
                  controller: _userCtrl,
                  textInputAction: TextInputAction.next,
                  decoration: _dec('Username', Icons.alternate_email),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Nhập username' : null,
                ),
                const SizedBox(height: 12),

                // Password
                TextFormField(
                  controller: _mkCtrl,
                  obscureText: !_hienMK,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _layToken(),
                  decoration: _dec('Password', Icons.lock_outline, suffix: IconButton(
                    icon: Icon(_hienMK ? Icons.visibility_off : Icons.visibility, size: 20, color: Colors.grey.shade500),
                    onPressed: () => setState(() => _hienMK = !_hienMK),
                  )),
                  validator: (v) => (v == null || v.isEmpty) ? 'Nhập password' : null,
                ),

                // Lỗi
                if (_loi != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.red.shade200)),
                    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Icon(Icons.error_outline, color: Colors.red.shade600, size: 18),
                      const SizedBox(width: 8),
                      Expanded(child: Text(_loi!, style: TextStyle(color: Colors.red.shade700, fontSize: 13))),
                    ]),
                  ),
                ],

                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity, height: 48,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _layToken,
                    icon: _isLoading
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Icon(Icons.vpn_key),
                    label: Text(_isLoading ? 'Đang lấy token...' : 'Lấy JWT Token',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6A1B9A), foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ]),
            ),
          ),

          // ── Kết quả Token ────────────────────────────────────────────────
          if (_token != null) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.green.shade300, width: 1.5),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                // Header
                Row(children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.green.shade100, shape: BoxShape.circle),
                    child: Icon(Icons.check_circle, color: Colors.green.shade700, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Token tạo thành công!', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green.shade800, fontSize: 15)),
                    Text('Hết hạn sau: $_expiresIn  •  Role: $_role${_hoTen != null ? '  •  $_hoTen' : ''}',
                        style: TextStyle(fontSize: 12, color: Colors.green.shade700)),
                  ])),
                ]),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 12),

                // Token display
                const Text('Bearer Token:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A2E),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Expanded(
                        child: Text(
                          _token!,
                          style: const TextStyle(color: Color(0xFF00FF88), fontFamily: 'monospace', fontSize: 11, height: 1.5),
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ]),
                  ]),
                ),
                const SizedBox(height: 12),

                // Copy button
                SizedBox(
                  width: double.infinity, height: 44,
                  child: ElevatedButton.icon(
                    onPressed: _copyToken,
                    icon: const Icon(Icons.copy, size: 18),
                    label: const Text('Copy Token', style: TextStyle(fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade700, foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Hướng dẫn sử dụng
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(10)),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Cách dùng token:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.blue.shade800)),
                    const SizedBox(height: 6),
                    _codeBlock('GET $_apiBaseUrl/api/benhNhan'),
                    const SizedBox(height: 4),
                    _codeBlock('Authorization: Bearer <token>'),
                  ]),
                ),
              ]),
            ),
          ],
          const SizedBox(height: 32),
        ]),
      ),
    );
  }

  Widget _codeBlock(String text) => Container(
    margin: const EdgeInsets.only(top: 2),
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(color: Colors.blue.shade100, borderRadius: BorderRadius.circular(6)),
    child: Text(text, style: TextStyle(fontFamily: 'monospace', fontSize: 11, color: Colors.blue.shade900)),
  );

  InputDecoration _dec(String label, IconData icon, {Widget? suffix}) => InputDecoration(
    labelText: label,
    prefixIcon: Icon(icon, size: 20, color: const Color(0xFF6A1B9A)),
    suffixIcon: suffix,
    filled: true, fillColor: const Color(0xFFF5F0FF),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.purple.shade200)),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.purple.shade200)),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF6A1B9A), width: 1.5)),
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
  );
}
