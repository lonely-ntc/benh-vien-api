import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class DangNhapScreen extends StatefulWidget {
  const DangNhapScreen({super.key});
  @override
  State<DangNhapScreen> createState() => _DangNhapScreenState();
}

class _DangNhapScreenState extends State<DangNhapScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _isLoading = false;
  bool _hienMatKhau = false;
  String? _loi;

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _dangNhap() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _isLoading = true; _loi = null; });

    final loi = await AuthService().dangNhap(
      _usernameCtrl.text.trim(),
      _passwordCtrl.text,
    );

    if (mounted) {
      setState(() => _isLoading = false);
      if (loi != null) {
        setState(() => _loi = loi);
      } else {
        // Đăng nhập thành công → về HomeScreen
        Navigator.pushReplacementNamed(context, '/home');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1565C0),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ── Logo ──
                Container(
                  width: 100, height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: Colors.black.withAlpha(40), blurRadius: 20, offset: const Offset(0, 8))],
                  ),
                  child: const Icon(Icons.local_hospital, size: 56, color: Color(0xFF1565C0)),
                ),
                const SizedBox(height: 24),
                const Text('Quản lý Bệnh viện',
                    style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                const SizedBox(height: 6),
                Text('Hệ thống quản lý bệnh nhân & bệnh truyền nhiễm',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white.withAlpha(200), fontSize: 13)),
                const SizedBox(height: 40),

                // ── Form đăng nhập ──
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.black.withAlpha(30), blurRadius: 20, offset: const Offset(0, 8))],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('Đăng nhập Admin',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1565C0))),
                      const SizedBox(height: 20),

                      // Username
                      TextFormField(
                        controller: _usernameCtrl,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          labelText: 'Tên đăng nhập',
                          prefixIcon: const Icon(Icons.person_outline, color: Color(0xFF1565C0)),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFF1565C0), width: 2)),
                          filled: true,
                          fillColor: const Color(0xFFF5F7FF),
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Nhập tên đăng nhập' : null,
                      ),
                      const SizedBox(height: 14),

                      // Password
                      TextFormField(
                        controller: _passwordCtrl,
                        obscureText: !_hienMatKhau,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _dangNhap(),
                        decoration: InputDecoration(
                          labelText: 'Mật khẩu',
                          prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF1565C0)),
                          suffixIcon: IconButton(
                            icon: Icon(_hienMatKhau ? Icons.visibility_off : Icons.visibility,
                                color: Colors.grey.shade500),
                            onPressed: () => setState(() => _hienMatKhau = !_hienMatKhau),
                          ),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFF1565C0), width: 2)),
                          filled: true,
                          fillColor: const Color(0xFFF5F7FF),
                        ),
                        validator: (v) => (v == null || v.isEmpty) ? 'Nhập mật khẩu' : null,
                      ),

                      // Lỗi
                      if (_loi != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.red.shade200),
                          ),
                          child: Row(children: [
                            Icon(Icons.error_outline, color: Colors.red.shade600, size: 18),
                            const SizedBox(width: 8),
                            Expanded(child: Text(_loi!, style: TextStyle(color: Colors.red.shade700, fontSize: 13))),
                          ]),
                        ),
                      ],

                      const SizedBox(height: 20),

                      // Nút đăng nhập
                      SizedBox(
                        width: double.infinity, height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _dangNhap,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1565C0),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 2,
                          ),
                          child: _isLoading
                              ? const SizedBox(width: 22, height: 22,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : const Text('Đăng nhập',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ]),
                  ),
                ),

                const SizedBox(height: 24),
                Text('Mặc định: admin / admin123',
                    style: TextStyle(color: Colors.white.withAlpha(150), fontSize: 12)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
