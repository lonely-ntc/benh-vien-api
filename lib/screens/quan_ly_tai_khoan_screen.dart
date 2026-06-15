import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'lay_api_token_screen.dart';

class QuanLyTaiKhoanScreen extends StatefulWidget {
  const QuanLyTaiKhoanScreen({super.key});
  @override
  State<QuanLyTaiKhoanScreen> createState() => _QuanLyTaiKhoanScreenState();
}

class _QuanLyTaiKhoanScreenState extends State<QuanLyTaiKhoanScreen> {
  // ── Tạo tài khoản mới ────────────────────────────────────────────────────
  void _moFormTao() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _FormTaoTaiKhoan(),
    );
  }

  // ── Đổi mật khẩu ─────────────────────────────────────────────────────────
  void _moFormDoiMatKhau(String id, String username) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _FormDoiMatKhau(id: id, username: username),
    );
  }

  // ── Xóa tài khoản ────────────────────────────────────────────────────────
  void _xacNhanXoa(String id, String username) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Row(children: [
          Icon(Icons.warning_amber_rounded, color: Colors.red),
          SizedBox(width: 8),
          Text('Xóa tài khoản', style: TextStyle(fontSize: 17)),
        ]),
        content: Text('Xóa tài khoản "$username"?\nHành động không thể hoàn tác.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Huỷ')),
          ElevatedButton.icon(
            onPressed: () async {
              Navigator.pop(context);
              await AuthService().xoaTaiKhoan(id);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Đã xóa tài khoản "$username"'), backgroundColor: Colors.red));
              }
            },
            icon: const Icon(Icons.delete),
            label: const Text('Xóa'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Row(children: [
          Icon(Icons.manage_accounts, size: 22),
          SizedBox(width: 8),
          Text('Quản lý tài khoản', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        ]),
        actions: [
          // Nút lấy API Token
          IconButton(
            icon: const Icon(Icons.token, color: Colors.white),
            tooltip: 'Lấy API Token',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const LayApiTokenScreen()),
            ),
          ),
          // Badge tổng số tài khoản
          StreamBuilder<List<Map<String, dynamic>>>(
            stream: AuthService().streamDanhSachTaiKhoan(),
            builder: (_, snap) {
              final total = snap.data?.length ?? 0;
              return Container(
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(12)),
                child: Text('$total TK', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _moFormTao,
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add),
        label: const Text('Tạo tài khoản', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: AuthService().streamDanhSachTaiKhoan(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Lỗi: ${snap.error}'));
          }
          final danhSach = snap.data ?? [];

          if (danhSach.isEmpty) {
            return Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.people_outline, size: 80, color: Colors.grey.shade300),
                const SizedBox(height: 12),
                Text('Chưa có tài khoản nào', style: TextStyle(fontSize: 16, color: Colors.grey.shade500)),
                const SizedBox(height: 8),
                Text('Nhấn "Tạo tài khoản" để bắt đầu', style: TextStyle(fontSize: 13, color: Colors.grey.shade400)),
              ]),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            itemCount: danhSach.length,
            itemBuilder: (_, i) {
              final tk = danhSach[i];
              final id = tk['id'] as String;
              final username = tk['username'] as String? ?? '';
              final hoTen = tk['hoTen'] as String? ?? username;
              final hoatDong = tk['hoatDong'] as bool? ?? true;
              final ngayTao = tk['ngayTao'];
              String ngayTaoStr = '';
              if (ngayTao != null) {
                try {
                  final dt = (ngayTao as dynamic).toDate() as DateTime;
                  ngayTaoStr = '${dt.day.toString().padLeft(2,'0')}/${dt.month.toString().padLeft(2,'0')}/${dt.year}';
                } catch (_) {}
              }

              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(children: [
                    // Avatar
                    Container(
                      width: 50, height: 50,
                      decoration: BoxDecoration(
                        color: hoatDong
                            ? const Color(0xFF1565C0).withAlpha(20)
                            : Colors.grey.withAlpha(30),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: hoatDong ? const Color(0xFF1565C0).withAlpha(80) : Colors.grey.withAlpha(60),
                          width: 1.5,
                        ),
                      ),
                      child: Icon(
                        Icons.person,
                        color: hoatDong ? const Color(0xFF1565C0) : Colors.grey,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Thông tin
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(children: [
                          Expanded(
                            child: Text(hoTen,
                                style: const TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1A237E))),
                          ),
                          if (!hoatDong)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text('Tắt', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                            ),
                        ]),
                        const SizedBox(height: 3),
                        Row(children: [
                          Icon(Icons.alternate_email, size: 13, color: Colors.grey.shade500),
                          const SizedBox(width: 4),
                          Text(username, style: TextStyle(fontSize: 13, color: Colors.grey.shade700)),
                        ]),
                        if (ngayTaoStr.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Row(children: [
                            Icon(Icons.calendar_today_outlined, size: 12, color: Colors.grey.shade400),
                            const SizedBox(width: 4),
                            Text('Tạo: $ngayTaoStr', style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                          ]),
                        ],
                      ]),
                    ),

                    // Actions
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert, color: Colors.grey),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      onSelected: (val) async {
                        switch (val) {
                          case 'doi_mk':
                            _moFormDoiMatKhau(id, username);
                            break;
                          case 'bat_tat':
                            await AuthService().doiTrangThai(id, !hoatDong);
                            break;
                          case 'xoa':
                            _xacNhanXoa(id, username);
                            break;
                        }
                      },
                      itemBuilder: (_) => [
                        const PopupMenuItem(
                          value: 'doi_mk',
                          child: Row(children: [
                            Icon(Icons.lock_reset, size: 18, color: Color(0xFF1565C0)),
                            SizedBox(width: 10),
                            Text('Đổi mật khẩu'),
                          ]),
                        ),
                        PopupMenuItem(
                          value: 'bat_tat',
                          child: Row(children: [
                            Icon(hoatDong ? Icons.block : Icons.check_circle_outline,
                                size: 18, color: hoatDong ? Colors.orange : Colors.green),
                            const SizedBox(width: 10),
                            Text(hoatDong ? 'Tắt tài khoản' : 'Bật tài khoản'),
                          ]),
                        ),
                        const PopupMenuDivider(),
                        const PopupMenuItem(
                          value: 'xoa',
                          child: Row(children: [
                            Icon(Icons.delete_outline, size: 18, color: Colors.red),
                            SizedBox(width: 10),
                            Text('Xóa tài khoản', style: TextStyle(color: Colors.red)),
                          ]),
                        ),
                      ],
                    ),
                  ]),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// ── Form tạo tài khoản ───────────────────────────────────────────────────────
class _FormTaoTaiKhoan extends StatefulWidget {
  const _FormTaoTaiKhoan();
  @override
  State<_FormTaoTaiKhoan> createState() => _FormTaoTaiKhoanState();
}

class _FormTaoTaiKhoanState extends State<_FormTaoTaiKhoan> {
  final _formKey = GlobalKey<FormState>();
  final _hoTenCtrl   = TextEditingController();
  final _userCtrl    = TextEditingController();
  final _mkCtrl      = TextEditingController();
  final _xacNhanCtrl = TextEditingController();
  bool _hienMK = false, _hienXN = false, _isLoading = false;

  @override
  void dispose() {
    _hoTenCtrl.dispose(); _userCtrl.dispose();
    _mkCtrl.dispose(); _xacNhanCtrl.dispose();
    super.dispose();
  }

  Future<void> _tao() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    final loi = await AuthService().taoTaiKhoan(
      username: _userCtrl.text.trim(),
      password: _mkCtrl.text,
      hoTen: _hoTenCtrl.text.trim().isNotEmpty ? _hoTenCtrl.text.trim() : null,
    );
    setState(() => _isLoading = false);
    if (!mounted) return;
    if (loi != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(loi), backgroundColor: Colors.red));
    } else {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Row(children: [
          const Icon(Icons.check_circle, color: Colors.white),
          const SizedBox(width: 8),
          Text('Đã tạo tài khoản "${_userCtrl.text.trim()}"'),
        ]),
        backgroundColor: Colors.green.shade600,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Handle
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(
              color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 16),

            Row(children: [
              Container(padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: const Color(0xFF1565C0).withAlpha(20), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.person_add, color: Color(0xFF1565C0), size: 22)),
              const SizedBox(width: 12),
              const Text('Tạo tài khoản mới',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1565C0))),
            ]),
            const SizedBox(height: 20),

            // Họ tên (tuỳ chọn)
            _field(_hoTenCtrl, 'Họ và tên (tuỳ chọn)', Icons.badge_outlined),
            const SizedBox(height: 12),

            // Username
            _field(_userCtrl, 'Tên đăng nhập *', Icons.alternate_email,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Nhập tên đăng nhập' : null),
            const SizedBox(height: 12),

            // Mật khẩu
            _pwField(_mkCtrl, 'Mật khẩu *', _hienMK,
                onToggle: () => setState(() => _hienMK = !_hienMK),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Nhập mật khẩu';
                  if (v.length < 6) return 'Tối thiểu 6 ký tự';
                  return null;
                }),
            const SizedBox(height: 12),

            // Xác nhận mật khẩu
            _pwField(_xacNhanCtrl, 'Xác nhận mật khẩu *', _hienXN,
                onToggle: () => setState(() => _hienXN = !_hienXN),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Xác nhận mật khẩu';
                  if (v != _mkCtrl.text) return 'Mật khẩu không khớp';
                  return null;
                }),
            const SizedBox(height: 24),

            // Nút tạo
            SizedBox(
              width: double.infinity, height: 50,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _tao,
                icon: _isLoading
                    ? const SizedBox(width: 20, height: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.check),
                label: Text(_isLoading ? 'Đang tạo...' : 'Tạo tài khoản',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1565C0), foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ]),
        ),
      ),
    );
  }

  Widget _field(TextEditingController ctrl, String label, IconData icon,
      {String? Function(String?)? validator}) =>
      TextFormField(
        controller: ctrl,
        validator: validator,
        decoration: _dec(label, icon),
      );

  Widget _pwField(TextEditingController ctrl, String label, bool show,
      {required VoidCallback onToggle, String? Function(String?)? validator}) =>
      TextFormField(
        controller: ctrl,
        obscureText: !show,
        validator: validator,
        decoration: _dec(label, Icons.lock_outline,
            suffix: IconButton(
              icon: Icon(show ? Icons.visibility_off : Icons.visibility, size: 20, color: Colors.grey.shade500),
              onPressed: onToggle,
            )),
      );

  InputDecoration _dec(String label, IconData icon, {Widget? suffix}) => InputDecoration(
    labelText: label,
    prefixIcon: Icon(icon, size: 20, color: const Color(0xFF1565C0)),
    suffixIcon: suffix,
    filled: true, fillColor: const Color(0xFFF5F7FF),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF1565C0), width: 1.5)),
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
  );
}

// ── Form đổi mật khẩu ────────────────────────────────────────────────────────
class _FormDoiMatKhau extends StatefulWidget {
  final String id, username;
  const _FormDoiMatKhau({required this.id, required this.username});
  @override
  State<_FormDoiMatKhau> createState() => _FormDoiMatKhauState();
}

class _FormDoiMatKhauState extends State<_FormDoiMatKhau> {
  final _formKey = GlobalKey<FormState>();
  final _mkMoiCtrl = TextEditingController();
  final _xacNhanCtrl = TextEditingController();
  bool _hienMoi = false, _hienXN = false, _isLoading = false;

  @override
  void dispose() { _mkMoiCtrl.dispose(); _xacNhanCtrl.dispose(); super.dispose(); }

  Future<void> _luu() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    final loi = await AuthService().doiMatKhauTaiKhoan(widget.id, _mkMoiCtrl.text);
    setState(() => _isLoading = false);
    if (!mounted) return;
    if (loi != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(loi), backgroundColor: Colors.red));
    } else {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Đã đổi mật khẩu cho "${widget.username}"'),
        backgroundColor: Colors.green.shade600,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(
              color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 16),
            Row(children: [
              Container(padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.orange.withAlpha(20), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.lock_reset, color: Colors.orange, size: 22)),
              const SizedBox(width: 12),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Đổi mật khẩu', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text(widget.username, style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
              ]),
            ]),
            const SizedBox(height: 20),

            TextFormField(
              controller: _mkMoiCtrl,
              obscureText: !_hienMoi,
              decoration: InputDecoration(
                labelText: 'Mật khẩu mới *',
                prefixIcon: const Icon(Icons.lock_outline, size: 20, color: Colors.orange),
                suffixIcon: IconButton(
                  icon: Icon(_hienMoi ? Icons.visibility_off : Icons.visibility, size: 20, color: Colors.grey.shade500),
                  onPressed: () => setState(() => _hienMoi = !_hienMoi),
                ),
                filled: true, fillColor: Colors.orange.shade50,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.orange.shade200)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.orange, width: 1.5)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Nhập mật khẩu mới';
                if (v.length < 6) return 'Tối thiểu 6 ký tự';
                return null;
              },
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: _xacNhanCtrl,
              obscureText: !_hienXN,
              decoration: InputDecoration(
                labelText: 'Xác nhận mật khẩu *',
                prefixIcon: const Icon(Icons.lock_outline, size: 20, color: Colors.orange),
                suffixIcon: IconButton(
                  icon: Icon(_hienXN ? Icons.visibility_off : Icons.visibility, size: 20, color: Colors.grey.shade500),
                  onPressed: () => setState(() => _hienXN = !_hienXN),
                ),
                filled: true, fillColor: Colors.orange.shade50,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.orange.shade200)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.orange, width: 1.5)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Xác nhận mật khẩu';
                if (v != _mkMoiCtrl.text) return 'Mật khẩu không khớp';
                return null;
              },
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity, height: 50,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _luu,
                icon: _isLoading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.save),
                label: Text(_isLoading ? 'Đang lưu...' : 'Lưu mật khẩu mới',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange, foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ]),
        ),
      ),
    );
  }
}
