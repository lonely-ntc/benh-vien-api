import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/benh_nhan.dart';
import '../models/benh_truyen_nhiem.dart';
import '../services/firestore_service.dart';
import '../services/benh_truyen_nhiem_service.dart';
import '../services/api_push_service.dart';

// ═══ CẤU HÌNH URL API ═════════════════════════════════════════════════════
// Chọn 1 trong các URL sau tùy theo môi trường test:

// 1. Android Emulator
const String _apiBaseUrl = 'http://10.0.2.2:3000';

// 2. iOS Simulator (uncomment dòng dưới và comment dòng trên)
// const String _apiBaseUrl = 'http://localhost:3000';

// 3. Physical Device - Thay <YOUR_COMPUTER_IP> bằng IP máy tính (uncomment dòng dưới)
// Tìm IP: Windows (ipconfig), Mac/Linux (ifconfig)
// const String _apiBaseUrl = 'http://192.168.1.100:3000';

// 4. Production (uncomment khi deploy)
// const String _apiBaseUrl = 'https://benh-vien-api.onrender.com';

// ═══════════════════════════════════════════════════════════════════════════

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
  String? _token;        // JWT Token chung
  String? _tokenError;

  // ── Bệnh nhân ────────────────────────────────────────────────────────────
  final Set<String> _selBN    = {};
  bool _pushingBN             = false;
  List<PushKetQua> _ketQuaBN  = [];
  bool _hienKetQuaBN          = false;
  List<BenhNhan> _cachedBenhNhan = [];

  // ── Bệnh truyền nhiễm ────────────────────────────────────────────────────
  final Set<String> _selBTN   = {};
  bool _pushingBTN            = false;
  List<PushKetQua> _ketQuaBTN = [];
  bool _hienKetQuaBTN         = false;
  List<BenhTruyenNhiem> _cachedBTN = [];

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

  // ── Đẩy bệnh nhân theo cơ chế token mới ──────────────────────────────────
  Future<void> _dayBN(List<BenhNhan> ds) async {
    if (_token == null) { _nhacToken(); return; }
    if (_selBN.isEmpty) { _nhacChon(); return; }
    
    // Hiển thị dialog xác nhận
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(children: [
          Icon(Icons.info_outline, color: Colors.blue),
          SizedBox(width: 8),
          Text('Xác nhận', style: TextStyle(fontSize: 16)),
        ]),
        content: Text(
          'Tạo data token cho ${_selBN.length} bệnh nhân đã chọn?\n\n'
          'Data token sẽ chứa toàn bộ dữ liệu đã được mã hóa bằng JWT Secret. '
          'Dùng token này để chia sẻ dữ liệu với hệ thống khác.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Tạo Token'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() { _pushingBN = true; _ketQuaBN = []; _hienKetQuaBN = false; });

    try {
      // Lấy benhNhanIds
      final ids = ds
          .where((e) => _selBN.contains(e.id))
          .where((e) => e.benhNhanId != null && e.benhNhanId!.isNotEmpty)
          .map((e) => e.benhNhanId!)
          .toList();

      if (ids.isEmpty) {
        throw Exception('Không có bệnh nhân nào có mã benhNhanId');
      }

      print('🚀 Tạo data token cho ${ids.length} bệnh nhân: $ids');
      
      // Tạo data token
      final tokenResp = await http.post(
        Uri.parse('$_apiBaseUrl/api/benhNhan/byIds'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: jsonEncode({
          'benhNhanIds': ids,
          'benhTNIds': [],
        }),
      ).timeout(const Duration(seconds: 30));

      if (tokenResp.statusCode != 200) {
        throw Exception('Không thể tạo token: ${tokenResp.body}');
      }

      final tokenBody = jsonDecode(tokenResp.body) as Map<String, dynamic>;
      if (tokenBody['success'] != true || tokenBody['token'] == null) {
        throw Exception('API không trả về token: ${tokenBody['message']}');
      }

      final dataToken = tokenBody['token'] as String;
      final summary = tokenBody['summary'] as Map<String, dynamic>?;
      
      print('✅ Data token đã tạo thành công');
      print('   Token: ${dataToken.substring(0, 20)}...');
      print('   Summary: $summary');

      setState(() {
        _pushingBN = false;
        _ketQuaBN = [
          PushKetQua(
            id: 'success',
            hoTen: 'Thành công',
            status: 'ok',
            message: 'Đã tạo data token cho ${summary?['benhNhanCount'] ?? ids.length} bệnh nhân',
          ),
        ];
        _hienKetQuaBN = true;
      });

      // Hiển thị token dialog
      if (mounted) {
        await _xemTatCaToken(context, ds, isBenh: true);
      }
    } catch (e) {
      print('❌ Lỗi: $e');
      setState(() {
        _pushingBN = false;
        _ketQuaBN = [PushKetQua(
          id: 'error',
          hoTen: 'Lỗi',
          status: 'error',
          message: e.toString(),
        )];
        _hienKetQuaBN = true;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Lỗi: $e'),
          backgroundColor: Colors.red,
        ));
      }
    }
  }

  // ── Đẩy bệnh truyền nhiễm theo cơ chế token mới ───────────────────────────
  Future<void> _dayBTN(List<BenhTruyenNhiem> ds) async {
    if (_token == null) { _nhacToken(); return; }
    if (_selBTN.isEmpty) { _nhacChon('ca bệnh'); return; }
    
    // Hiển thị dialog xác nhận
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(children: [
          Icon(Icons.info_outline, color: Colors.blue),
          SizedBox(width: 8),
          Text('Xác nhận', style: TextStyle(fontSize: 16)),
        ]),
        content: Text(
          'Tạo data token cho ${_selBTN.length} ca bệnh đã chọn?\n\n'
          'Data token sẽ chứa toàn bộ dữ liệu đã được mã hóa bằng JWT Secret. '
          'Dùng token này để chia sẻ dữ liệu với hệ thống khác.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Tạo Token'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() { _pushingBTN = true; _ketQuaBTN = []; _hienKetQuaBTN = false; });

    try {
      // Lấy benhAnIds
      final ids = ds
          .where((e) => _selBTN.contains(e.id))
          .where((e) => e.benhAnId != null && e.benhAnId!.isNotEmpty)
          .map((e) => e.benhAnId!)
          .toList();

      if (ids.isEmpty) {
        throw Exception('Không có ca bệnh nào có mã benhAnId');
      }

      print('🚀 Tạo data token cho ${ids.length} ca bệnh: $ids');
      
      // Tạo data token
      final tokenResp = await http.post(
        Uri.parse('$_apiBaseUrl/api/benhTruyenNhiem/byIds'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: jsonEncode({
          'benhNhanIds': [],
          'benhTNIds': ids,
        }),
      ).timeout(const Duration(seconds: 30));

      if (tokenResp.statusCode != 200) {
        throw Exception('Không thể tạo token: ${tokenResp.body}');
      }

      final tokenBody = jsonDecode(tokenResp.body) as Map<String, dynamic>;
      if (tokenBody['success'] != true || tokenBody['token'] == null) {
        throw Exception('API không trả về token: ${tokenBody['message']}');
      }

      final dataToken = tokenBody['token'] as String;
      final summary = tokenBody['summary'] as Map<String, dynamic>?;
      
      print('✅ Data token đã tạo thành công');
      print('   Token: ${dataToken.substring(0, 20)}...');
      print('   Summary: $summary');

      setState(() {
        _pushingBTN = false;
        _ketQuaBTN = [
          PushKetQua(
            id: 'success',
            hoTen: 'Thành công',
            status: 'ok',
            message: 'Đã tạo data token cho ${summary?['benhTNCount'] ?? ids.length} ca bệnh',
          ),
        ];
        _hienKetQuaBTN = true;
      });

      // Hiển thị token dialog
      if (mounted) {
        await _xemTatCaToken(context, ds, isBenh: false);
      }
    } catch (e) {
      print('❌ Lỗi: $e');
      setState(() {
        _pushingBTN = false;
        _ketQuaBTN = [PushKetQua(
          id: 'error',
          hoTen: 'Lỗi',
          status: 'error',
          message: e.toString(),
        )];
        _hienKetQuaBTN = true;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Lỗi: $e'),
          backgroundColor: Colors.red,
        ));
      }
    }
  }

  void _nhacToken() => ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Vui lòng lấy token trước'), backgroundColor: Colors.orange));

  void _nhacChon([String loai = 'bệnh nhân']) => ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Chọn ít nhất 1 $loai'), backgroundColor: Colors.orange));

  // ── Tạo data token cho bệnh nhân đã chọn ──────────────────────────────────
  Future<String?> _taoDataTokenBN(List<BenhNhan> ds) async {
    if (_token == null) {
      print('❌ Token chưa có, không thể tạo data token');
      return null;
    }
    
    print('📋 Bệnh nhân đã chọn: ${_selBN.length}');
    
    // Sử dụng benhNhanId (mã nghiệp vụ) thay vì Firestore document ID
    final ids = ds
        .where((e) => _selBN.contains(e.id))
        .where((e) => e.benhNhanId != null && e.benhNhanId!.isNotEmpty) // Chỉ lấy có benhNhanId
        .map((e) => e.benhNhanId!) // Dùng benhNhanId
        .toList();
    
    if (ids.isEmpty) {
      print('⚠️ Không có bệnh nhân nào có benhNhanId');
      print('   Tất cả bệnh nhân đã chọn:');
      ds.where((e) => _selBN.contains(e.id)).forEach((bn) {
        print('   - ${bn.hoTen}: benhNhanId = ${bn.benhNhanId}');
      });
      return null;
    }

    print('🔍 Tạo token với ${ids.length} benhNhanIds: $ids');
    print('📡 Gửi request đến: $_apiBaseUrl/api/benhNhan/byIds');

    try {
      final resp = await http.post(
        Uri.parse('$_apiBaseUrl/api/benhNhan/byIds'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: jsonEncode({'benhNhanIds': ids, 'benhTNIds': []}),
      ).timeout(const Duration(seconds: 30));

      print('✅ Response status: ${resp.statusCode}');
      print('📦 Response body: ${resp.body}');

      if (resp.statusCode != 200) {
        print('❌ HTTP Error: ${resp.statusCode}');
        return null;
      }

      final body = jsonDecode(resp.body) as Map<String, dynamic>;
      
      if (body['success'] == true && body['token'] != null) {
        print('✅ Data token đã tạo thành công');
        return body['token'] as String;
      } else {
        print('❌ API trả về success=false hoặc không có token');
        print('   Message: ${body['message']}');
      }
    } catch (e) {
      print('❌ Lỗi khi tạo token: $e');
      if (e.toString().contains('TimeoutException')) {
        print('   → Request timeout, kiểm tra API server có đang chạy không');
      } else if (e.toString().contains('SocketException')) {
        print('   → Không kết nối được API, kiểm tra URL: $_apiBaseUrl');
      }
    }
    return null;
  }

  // ── Tạo data token cho bệnh truyền nhiễm đã chọn ──────────────────────────
  Future<String?> _taoDataTokenBTN(List<BenhTruyenNhiem> ds) async {
    if (_token == null) {
      print('❌ Token chưa có, không thể tạo data token');
      return null;
    }
    
    print('📋 Ca bệnh TN đã chọn: ${_selBTN.length}');
    
    // Sử dụng benhAnId (mã nghiệp vụ) thay vì Firestore document ID
    final ids = ds
        .where((e) => _selBTN.contains(e.id))
        .where((e) => e.benhAnId != null && e.benhAnId!.isNotEmpty) // Chỉ lấy có benhAnId
        .map((e) => e.benhAnId!) // Dùng benhAnId
        .toList();
    
    if (ids.isEmpty) {
      print('⚠️ Không có ca bệnh nào có benhAnId');
      print('   Tất cả ca bệnh đã chọn:');
      ds.where((e) => _selBTN.contains(e.id)).forEach((btn) {
        print('   - ${btn.hoTen}: benhAnId = ${btn.benhAnId}');
      });
      return null;
    }

    print('🔍 Tạo token với ${ids.length} benhAnIds: $ids');
    print('📡 Gửi request đến: $_apiBaseUrl/api/benhTruyenNhiem/byIds');

    try {
      final resp = await http.post(
        Uri.parse('$_apiBaseUrl/api/benhTruyenNhiem/byIds'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: jsonEncode({'benhNhanIds': [], 'benhTNIds': ids}),
      ).timeout(const Duration(seconds: 30));

      print('✅ Response status: ${resp.statusCode}');
      print('📦 Response body: ${resp.body}');

      if (resp.statusCode != 200) {
        print('❌ HTTP Error: ${resp.statusCode}');
        return null;
      }

      final body = jsonDecode(resp.body) as Map<String, dynamic>;
      
      if (body['success'] == true && body['token'] != null) {
        print('✅ Data token đã tạo thành công');
        return body['token'] as String;
      } else {
        print('❌ API trả về success=false hoặc không có token');
        print('   Message: ${body['message']}');
      }
    } catch (e) {
      print('❌ Lỗi khi tạo token: $e');
      if (e.toString().contains('TimeoutException')) {
        print('   → Request timeout, kiểm tra API server có đang chạy không');
      } else if (e.toString().contains('SocketException')) {
        print('   → Không kết nối được API, kiểm tra URL: $_apiBaseUrl');
      }
    }
    return null;
  }

  // ── Xem tất cả token (JWT + Data Token) ───────────────────────────────────
  Future<void> _xemTatCaToken(BuildContext context, dynamic ds, {required bool isBenh}) async {
    if (_token == null) {
      _nhacToken();
      return;
    }

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    // Tạo data token
    String? dataToken;
    List<String> sentIds = [];
    
    if (isBenh) {
      final selectedBN = (ds as List<BenhNhan>).where((e) => _selBN.contains(e.id)).toList();
      sentIds = selectedBN.map((e) => e.benhNhanId ?? e.id).toList();
      print('🔍 Gửi IDs cho bệnh nhân: $sentIds');
      
      dataToken = await _taoDataTokenBN(ds);
    } else {
      final selectedBTN = (ds as List<BenhTruyenNhiem>).where((e) => _selBTN.contains(e.id)).toList();
      sentIds = selectedBTN.map((e) => e.benhAnId ?? e.id).toList();
      print('🔍 Gửi IDs cho bệnh TN: $sentIds');
      
      dataToken = await _taoDataTokenBTN(ds);
    }

    // Close loading dialog
    if (context.mounted) Navigator.pop(context);

    // Show token dialog
    if (context.mounted) {
      final selectedItems = isBenh
          ? (ds as List<BenhNhan>).where((e) => _selBN.contains(e.id)).toList()
          : (ds as List<BenhTruyenNhiem>).where((e) => _selBTN.contains(e.id)).toList();
      
      _hienDialogTatCaToken(
        context,
        jwtToken: _token!,
        dataToken: dataToken,
        selectedCount: isBenh ? _selBN.length : _selBTN.length,
        loaiDuLieu: isBenh ? 'bệnh nhân' : 'ca bệnh TN',
        selectedItems: selectedItems,
        isBenh: isBenh,
        sentIds: sentIds, // Truyền thêm IDs đã gửi
      );
    }
  }

  static void _hienDialogTatCaToken(
    BuildContext context, {
    required String jwtToken,
    String? dataToken,
    required int selectedCount,
    required String loaiDuLieu,
    required List<dynamic> selectedItems,
    required bool isBenh,
    List<String>? sentIds, // IDs đã gửi lên API
  }) {
    showDialog(
      context: context,
      builder: (_) => _TatCaTokenDialog(
        jwtToken: jwtToken,
        dataToken: dataToken,
        selectedCount: selectedCount,
        loaiDuLieu: loaiDuLieu,
        selectedItems: selectedItems,
        isBenh: isBenh,
        sentIds: sentIds,
      ),
    );
  }

  // ── Xem payload JSON để copy & kiểm tra ────────────────────────────────────


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
                onXemToken: (ds) => _xemTatCaToken(context, ds, isBenh: true),
                onToggle: (id) => setState(() {
                  if (_selBN.contains(id)) { _selBN.remove(id); }
                  else { _selBN.add(id); }
                }),
                onChonTatCa: (ds) => setState(() {
                  if (_selBN.length == ds.length) { _selBN.clear(); }
                  else { _selBN.addAll(ds.map((e) => e.id)); }
                }),
                onDataLoaded: (ds) {
                  if (_cachedBenhNhan.length != ds.length) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) setState(() => _cachedBenhNhan = ds);
                    });
                  }
                },
              ),
              _TabBTN(
                token: _token,
                selected: _selBTN,
                pushing: _pushingBTN,
                ketQua: _ketQuaBTN,
                hienKetQua: _hienKetQuaBTN,
                onDay: _dayBTN,
                onXemToken: (ds) => _xemTatCaToken(context, ds, isBenh: false),
                onToggle: (id) => setState(() {
                  if (_selBTN.contains(id)) { _selBTN.remove(id); }
                  else { _selBTN.add(id); }
                }),
                onChonTatCa: (ds) => setState(() {
                  if (_selBTN.length == ds.length) { _selBTN.clear(); }
                  else { _selBTN.addAll(ds.map((e) => e.id)); }
                }),
                onDataLoaded: (ds) {
                  if (_cachedBTN.length != ds.length) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) setState(() => _cachedBTN = ds);
                    });
                  }
                },
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
            const SizedBox(width: 6),
            // Nút xem/copy token
            InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () => showDialog(
                context: context,
                builder: (_) => _TokenDialog(
                  title: 'JWT Token hiện tại',
                  token: _token,
                ),
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade300),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.vpn_key, color: Colors.blue.shade700, size: 15),
                  const SizedBox(width: 4),
                  Text('Xem Token', style: TextStyle(
                      color: Colors.blue.shade700, fontSize: 12,
                      fontWeight: FontWeight.bold)),
                ]),
              ),
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
  final void Function(List<BenhNhan>) onXemToken;
  final void Function(String) onToggle;
  final void Function(List<BenhNhan>) onChonTatCa;
  final void Function(List<BenhNhan>) onDataLoaded;

  const _TabBenhNhan({
    required this.token, required this.selected, required this.pushing,
    required this.ketQua, required this.hienKetQua, required this.onDay,
    required this.onXemToken,
    required this.onToggle, required this.onChonTatCa,
    required this.onDataLoaded,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<BenhNhan>>(
      stream: FirestoreService().streamDanhSachBenhNhan(),
      builder: (_, snap) {
        final ds = snap.data ?? [];
        if (ds.isNotEmpty) onDataLoaded(ds);
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
      _dayButton(context, ds, onXemToken),
    ]);
  }

  Widget _dayButton(BuildContext context, List<BenhNhan> ds, void Function(List<BenhNhan>) onXemToken) => Container(
    padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
    color: Colors.white,
    child: Column(children: [
      // Nút Xem Token
      if (selected.isNotEmpty) ...[
        Row(children: [
          Expanded(
            child: SizedBox(
              height: 40,
              child: ElevatedButton.icon(
                onPressed: () => onXemToken(ds),
                icon: const Icon(Icons.token, size: 16),
                label: const Text('Xem Token', style: TextStyle(fontSize: 12)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6A1B9A),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
          ),
        ]),
        const SizedBox(height: 6),
      ],
      SizedBox(
        width: double.infinity, height: 48,
        child: ElevatedButton.icon(
          onPressed: (pushing || selected.isEmpty) ? null : () => onDay(ds),
          icon: pushing
              ? const SizedBox(width: 18, height: 18,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Icon(Icons.lock_outline),
          label: Text(
            pushing ? 'Đang tạo token...'
                : selected.isEmpty ? 'Chọn bệnh nhân để tạo token'
                : 'Tạo Data Token cho ${selected.length} bệnh nhân',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: selected.isEmpty ? Colors.grey : const Color(0xFF1565C0),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ),
    ]),
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
  final void Function(List<BenhTruyenNhiem>) onXemToken;
  final void Function(String) onToggle;
  final void Function(List<BenhTruyenNhiem>) onChonTatCa;
  final void Function(List<BenhTruyenNhiem>) onDataLoaded;

  const _TabBTN({
    required this.token, required this.selected, required this.pushing,
    required this.ketQua, required this.hienKetQua, required this.onDay,
    required this.onXemToken,
    required this.onToggle, required this.onChonTatCa,
    required this.onDataLoaded,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<BenhTruyenNhiem>>(
      stream: BenhTruyenNhiemService().streamDanhSach(),
      builder: (_, snap) {
        final ds = snap.data ?? [];
        if (ds.isNotEmpty) onDataLoaded(ds);
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
      _dayButton(context, ds, onXemToken),
    ]);
  }

  Widget _dayButton(BuildContext context, List<BenhTruyenNhiem> ds, void Function(List<BenhTruyenNhiem>) onXemToken) => Container(
    padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
    color: Colors.white,
    child: Column(children: [
      // Nút Xem Token
      if (selected.isNotEmpty) ...[
        Row(children: [
          Expanded(
            child: SizedBox(
              height: 40,
              child: ElevatedButton.icon(
                onPressed: () => onXemToken(ds),
                icon: const Icon(Icons.token, size: 16),
                label: const Text('Xem Token', style: TextStyle(fontSize: 12)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6A1B9A),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
          ),
        ]),
        const SizedBox(height: 6),
      ],
      SizedBox(
        width: double.infinity, height: 48,
        child: ElevatedButton.icon(
          onPressed: (pushing || selected.isEmpty) ? null : () => onDay(ds),
          icon: pushing
              ? const SizedBox(width: 18, height: 18,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Icon(Icons.lock_outline),
          label: Text(
            pushing ? 'Đang tạo token...'
                : selected.isEmpty ? 'Chọn ca bệnh để tạo token'
                : 'Tạo Data Token cho ${selected.length} ca bệnh TN',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: selected.isEmpty ? Colors.grey : const Color(0xFF2E7D32),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ),
    ]),
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

// ── Dialog hiển thị cả JWT Token và Data Token ─────────────────────────────

class _TatCaTokenDialog extends StatelessWidget {
  final String jwtToken;
  final String? dataToken;
  final int selectedCount;
  final String loaiDuLieu;
  final List<dynamic> selectedItems;
  final bool isBenh;
  final List<String>? sentIds;

  const _TatCaTokenDialog({
    required this.jwtToken,
    this.dataToken,
    required this.selectedCount,
    required this.loaiDuLieu,
    required this.selectedItems,
    required this.isBenh,
    this.sentIds,
  });

  void _copy(BuildContext context, String text, String label) {
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
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
        child: Column(children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 12, 16),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF6A1B9A), Color(0xFF4A148C)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(children: [
              const Icon(Icons.vpn_key, color: Colors.white, size: 24),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'API Tokens',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white70, size: 24),
                onPressed: () => Navigator.pop(context),
                padding: EdgeInsets.zero,
              ),
            ]),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(children: [
                // ── 1. JWT Token (Token chung) ──────────────────────────
                _buildTokenSection(
                  context,
                  title: '1. JWT Token (Token chung)',
                  description: 'Token xác thực cho tất cả các API calls',
                  token: jwtToken,
                  icon: Icons.admin_panel_settings,
                  color: const Color(0xFF1565C0),
                  showBearer: true,
                ),

                const SizedBox(height: 20),

                // ── 2. Data Token (Token cho dữ liệu đã chọn) ────────────
                if (dataToken != null) ...[
                  _buildTokenSection(
                    context,
                    title: '2. Data Token (Token dữ liệu)',
                    description: 'Token để lấy $selectedCount $loaiDuLieu đã chọn',
                    token: dataToken!,
                    icon: Icons.dataset,
                    color: const Color(0xFF2E7D32),
                    showBearer: false,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Danh sách đã chọn
                  _buildSelectedList(context),
                  
                  const SizedBox(height: 16),
                  
                  // Hướng dẫn sử dụng
                  _buildUsageGuide(context),
                ] else ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        Icon(Icons.info_outline, color: Colors.orange.shade700, size: 20),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Không thể tạo data token',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ]),
                      if (sentIds != null && sentIds!.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        const Text('IDs đã gửi lên API:',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: SelectableText(
                            sentIds!.join(', '),
                            style: const TextStyle(fontSize: 10, fontFamily: 'monospace'),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Vui lòng kiểm tra:\n'
                          '• Các ID trên có tồn tại trong database không?\n'
                          '• Field "${isBenh ? "benhNhanId" : "benhAnId"}" có đúng giá trị không?',
                          style: TextStyle(fontSize: 11, color: Colors.grey.shade700, height: 1.4),
                        ),
                      ] else ...[
                        const SizedBox(height: 8),
                        const Text(
                          'Vui lòng thử lại hoặc kiểm tra kết nối.',
                          style: TextStyle(fontSize: 11, height: 1.4),
                        ),
                      ],
                    ]),
                  ),
                ],
              ]),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _buildTokenSection(
    BuildContext context, {
    required String title,
    required String description,
    required String token,
    required IconData icon,
    required Color color,
    required bool showBearer,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withAlpha((0.05 * 255).round()),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha((0.3 * 255).round())),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Title
        Row(children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title,
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14, color: color)),
              const SizedBox(height: 2),
              Text(description,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
            ]),
          ),
        ]),

        const SizedBox(height: 12),

        // Token display
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A2E),
            borderRadius: BorderRadius.circular(8),
          ),
          child: SelectableText(
            token,
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 10,
              color: Color(0xFF00FF88),
              height: 1.5,
            ),
          ),
        ),

        const SizedBox(height: 10),

        // Copy buttons
        Row(children: [
          Expanded(
            child: SizedBox(
              height: 36,
              child: ElevatedButton.icon(
                onPressed: () => _copy(context, token, 'Token'),
                icon: const Icon(Icons.copy, size: 14),
                label: const Text('Copy', style: TextStyle(fontSize: 12)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
          ),
          if (showBearer) ...[
            const SizedBox(width: 8),
            Expanded(
              child: SizedBox(
                height: 36,
                child: OutlinedButton.icon(
                  onPressed: () => _copy(context, 'Bearer $token', 'Bearer Token'),
                  icon: const Icon(Icons.copy_all, size: 14),
                  label: const Text('Bearer', style: TextStyle(fontSize: 12)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: color,
                    side: BorderSide(color: color),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
            ),
          ],
        ]),
      ]),
    );
  }

  Widget _buildSelectedList(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.list_alt, color: Colors.blue.shade700, size: 18),
          const SizedBox(width: 8),
          Text(
            'Dữ liệu đã chọn ($selectedCount)',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: Colors.blue.shade700),
          ),
        ]),
        const SizedBox(height: 10),
        ...selectedItems.take(5).map((item) {
          if (isBenh) {
            final bn = item as BenhNhan;
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(children: [
                Icon(Icons.person, size: 14, color: Colors.grey.shade600),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '${bn.hoTen}'
                    '${bn.ngaySinh != null ? " · ${bn.ngaySinh}" : ""}'
                    '${bn.soDienThoai != null ? " · ${bn.soDienThoai}" : ""}',
                    style: const TextStyle(fontSize: 11),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ]),
            );
          } else {
            final btn = item as BenhTruyenNhiem;
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(children: [
                Icon(Icons.coronavirus, size: 14, color: Colors.grey.shade600),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '${btn.hoTen}'
                    '${btn.ngaySinh != null ? " · ${btn.ngaySinh}" : ""}'
                    '${btn.benhAnId != null ? " · BA: ${btn.benhAnId}" : ""}',
                    style: const TextStyle(fontSize: 11),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ]),
            );
          }
        }),
        if (selectedItems.length > 5)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              '... và ${selectedItems.length - 5} mục khác',
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontStyle: FontStyle.italic),
            ),
          ),
      ]),
    );
  }

  Widget _buildUsageGuide(BuildContext context) {
    final endpoint = isBenh
        ? '/api/benhNhan/thongtinbenhnhan'
        : '/api/benhTruyenNhiem/thongtinbenhan';
    
    final curlExample = 'curl -X GET "https://benh-vien-api.onrender.com$endpoint?token=$dataToken" \\\n'
        '  -H "Authorization: Bearer $jwtToken"';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.lightbulb_outline, color: Colors.green.shade700, size: 18),
          const SizedBox(width: 8),
          Text(
            'Cách sử dụng',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: Colors.green.shade700),
          ),
        ]),
        const SizedBox(height: 10),
        Text(
          '1. Data Token chứa toàn bộ dữ liệu đã được mã hóa',
          style: TextStyle(fontSize: 11, color: Colors.grey.shade800),
        ),
        const SizedBox(height: 4),
        Text(
          '2. JWT Token (token chung) dùng để xác thực VÀ giải mã Data Token',
          style: TextStyle(fontSize: 11, color: Colors.grey.shade800),
        ),
        const SizedBox(height: 4),
        Text(
          '3. Gửi Data Token qua query "?token=xxx" và JWT qua header',
          style: TextStyle(fontSize: 11, color: Colors.grey.shade800),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.orange.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.orange.shade300),
          ),
          child: Row(children: [
            Icon(Icons.security, color: Colors.orange.shade700, size: 14),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                'Data Token được mã hóa bằng JWT Secret - không thể đọc nếu thiếu JWT Token',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.orange.shade900,
                  fontWeight: FontWeight.bold,
                  height: 1.3,
                ),
              ),
            ),
          ]),
        ),
        const SizedBox(height: 10),
        Text(
          'Ví dụ cURL:',
          style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A2E),
            borderRadius: BorderRadius.circular(8),
          ),
          child: SelectableText(
            curlExample,
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 9,
              color: Color(0xFF00FF88),
              height: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(
            child: SizedBox(
              height: 32,
              child: OutlinedButton.icon(
                onPressed: () => _copy(context, curlExample, 'cURL command'),
                icon: const Icon(Icons.copy, size: 12),
                label: const Text('Copy cURL', style: TextStyle(fontSize: 11)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.green.shade700,
                  side: BorderSide(color: Colors.green.shade400),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6)),
                ),
              ),
            ),
          ),
        ]),
      ]),
    );
  }
}

// ── Dialog hiển thị Token đơn giản (legacy - giữ lại cho tương thích) ───────

class _TokenDialog extends StatelessWidget {
  final String title;
  final String? token;
  
  const _TokenDialog({
    required this.title,
    this.token,
  });

  void _copy(BuildContext context, String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        const Icon(Icons.check_circle, color: Colors.white, size: 16),
        const SizedBox(width: 8),
        Text('Đã copy $label'),
      ]),
      backgroundColor: Colors.green.shade700,
      duration: const Duration(seconds: 2),
    ));
  }

  @override
  Widget build(BuildContext context) {
    if (token == null) {
      return AlertDialog(
        title: const Row(children: [
          Icon(Icons.warning_amber, color: Colors.orange),
          SizedBox(width: 8),
          Text('Chưa có Token', style: TextStyle(fontSize: 16)),
        ]),
        content: const Text('Vui lòng lấy JWT Token trước khi xem.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      );
    }

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 12, 16),
            decoration: const BoxDecoration(
              color: Color(0xFF1565C0),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
              ),
            ),
            child: Row(children: [
              const Icon(Icons.vpn_key, color: Colors.white, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white70, size: 22),
                onPressed: () => Navigator.pop(context),
                padding: EdgeInsets.zero,
              ),
            ]),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              // Token display
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F7FF),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF1565C0).withAlpha(50)),
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    const Text(
                      'JWT Token',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Color(0xFF1565C0),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${token!.length} ký tự',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ]),
                  const SizedBox(height: 10),
                  SelectableText(
                    token!,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 11,
                      color: Color(0xFF1B5E20),
                      height: 1.5,
                    ),
                  ),
                ]),
              ),

              const SizedBox(height: 16),

              // Copy buttons
              Row(children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _copy(context, token!, 'Token'),
                    icon: const Icon(Icons.copy, size: 18),
                    label: const Text('Copy Token'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1565C0),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _copy(context, 'Bearer $token', 'Bearer Token'),
                    icon: const Icon(Icons.copy_all, size: 18),
                    label: const Text('Copy Bearer'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF1565C0),
                      side: const BorderSide(color: Color(0xFF1565C0)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ]),

              const SizedBox(height: 12),

              // Info text
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(children: [
                  Icon(Icons.info_outline, size: 16, color: Colors.blue.shade700),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Sử dụng token này trong header "Authorization: Bearer <token>" khi gọi API',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.blue.shade900,
                        height: 1.4,
                      ),
                    ),
                  ),
                ]),
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}
