import 'package:flutter/material.dart';
import '../models/benh_nhan.dart';
import '../models/category_options.dart';
import '../services/firestore_service.dart';

class SuaBenhNhanScreen extends StatefulWidget {
  final BenhNhan benhNhan;
  const SuaBenhNhanScreen({super.key, required this.benhNhan});

  @override
  State<SuaBenhNhanScreen> createState() => _SuaBenhNhanScreenState();
}

class _SuaBenhNhanScreenState extends State<SuaBenhNhanScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _loiCCCD;

  // ── Controllers ─────────────────────────────────────────────────────────
  late final TextEditingController _hoTenCtrl;
  late final TextEditingController _ngaySinhCtrl;
  late final TextEditingController _soDienThoaiCtrl;
  late final TextEditingController _cccdCtrl;
  late final TextEditingController _baoHiemYTeCtrl;
  late final TextEditingController _diaChiCtrl;
  late final TextEditingController _phongKhamCtrl;
  late final TextEditingController _donViDieuTraCtrl;

  // ── Dropdown values ──────────────────────────────────────────────────────
  CategoryItem? _gioiTinh, _danToc;
  String? _ngheNghiep, _nhomMau;
  CategoryItem? _tinh;
  CategoryItem? _benhNen, _benhTruyenNhiem, _tinhTrangTiemChung, _coKhong;
  CategoryItem? _dieuTri, _hinhThucDieuTri, _chanDoanBenh;
  CategoryItem? _phanLoaiChanDoan, _phanDoBenh;
  CategoryItem? _loaiBenhPham, _loaiXetNghiem, _ketQuaXetNghiem;
  String? _trangThai;

  @override
  void initState() {
    super.initState();
    final bn = widget.benhNhan;
    _hoTenCtrl        = TextEditingController(text: bn.hoTen);
    _ngaySinhCtrl     = TextEditingController(text: bn.ngaySinh ?? '');
    _soDienThoaiCtrl  = TextEditingController(text: bn.soDienThoai ?? '');
    _cccdCtrl         = TextEditingController(text: bn.cccd ?? '');
    _baoHiemYTeCtrl   = TextEditingController(text: bn.baoHiemYTe ?? '');
    _diaChiCtrl       = TextEditingController(text: bn.diaChi ?? '');
    _phongKhamCtrl    = TextEditingController(text: bn.phongKham ?? '');
    _donViDieuTraCtrl = TextEditingController(text: bn.donViDieuTra ?? '');

    _gioiTinh           = bn.gioiTinhItem;
    _danToc             = bn.danTocItem;
    _ngheNghiep         = bn.ngheNghiep;
    _nhomMau            = bn.nhomMau;
    _tinh               = bn.tinhItem;
    _benhNen            = bn.benhNenItem;
    _benhTruyenNhiem    = bn.benhTruyenNhiemItem;
    _tinhTrangTiemChung = bn.tinhTrangTiemChungItem;
    _coKhong            = bn.coKhongItem;
    _dieuTri            = bn.dieuTriItem;
    _hinhThucDieuTri    = bn.hinhThucDieuTriItem;
    _chanDoanBenh       = bn.chanDoanBenhItem;
    _phanLoaiChanDoan   = bn.phanLoaiChanDoanItem;
    _phanDoBenh         = bn.phanDoBenhItem;
    _loaiBenhPham       = bn.loaiBenhPhamItem;
    _loaiXetNghiem      = bn.loaiXetNghiemItem;
    _ketQuaXetNghiem    = bn.ketQuaXetNghiemItem;
    _trangThai          = bn.trangThai ?? 'Chờ';
  }

  @override
  void dispose() {
    for (final c in [
      _hoTenCtrl, _ngaySinhCtrl, _soDienThoaiCtrl, _cccdCtrl,
      _baoHiemYTeCtrl, _diaChiCtrl, _phongKhamCtrl, _donViDieuTraCtrl,
    ]) { c.dispose(); }
    super.dispose();
  }

  Future<void> _chonNgaySinh() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 30),
      firstDate: DateTime(1900),
      lastDate: now,
    );
    if (picked != null) {
      _ngaySinhCtrl.text =
          '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
    }
  }

  /// Kiểm tra CCCD trùng — bỏ qua chính bệnh nhân đang sửa
  Future<void> _kiemTraCCCD() async {
    final cccd = _cccdCtrl.text.trim();
    if (cccd.isEmpty || cccd == (widget.benhNhan.cccd ?? '').trim()) {
      setState(() => _loiCCCD = null);
      return;
    }
    final ket = await FirestoreService().kiemTraTrungLap(
      hoTen: '', ngaySinh: '', cccd: cccd,
    );
    final trung = (ket['trungCCCD'] ?? [])
        .where((bn) => bn.id != widget.benhNhan.id)
        .toList();
    setState(() {
      _loiCCCD = trung.isNotEmpty
          ? 'CCCD đã tồn tại: ${trung.first.hoTen}'
          : null;
    });
  }

  Future<void> _luu() async {
    if (!_formKey.currentState!.validate()) return;
    if (_loiCCCD != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(_loiCCCD!), backgroundColor: Colors.red.shade600));
      return;
    }
    setState(() => _isLoading = true);
    try {
      final updated = BenhNhan(
        id: widget.benhNhan.id,
        hoTen: _hoTenCtrl.text.trim(),
        ngaySinh: _ngaySinhCtrl.text.isNotEmpty ? _ngaySinhCtrl.text : null,
        gioiTinhItem: _gioiTinh,
        danTocItem: _danToc,
        ngheNghiep: _ngheNghiep,
        soDienThoai: _soDienThoaiCtrl.text.isNotEmpty ? _soDienThoaiCtrl.text : null,
        cccd: _cccdCtrl.text.isNotEmpty ? _cccdCtrl.text : null,
        baoHiemYTe: _baoHiemYTeCtrl.text.isNotEmpty ? _baoHiemYTeCtrl.text : null,
        diaChi: _diaChiCtrl.text.isNotEmpty ? _diaChiCtrl.text : null,
        tinhItem: _tinh,
        nhomMau: _nhomMau,
        benhNenItem: _benhNen,
        benhTruyenNhiemItem: _benhTruyenNhiem,
        tinhTrangTiemChungItem: _tinhTrangTiemChung,
        coKhongItem: _coKhong,
        dieuTriItem: _dieuTri,
        hinhThucDieuTriItem: _hinhThucDieuTri,
        chanDoanBenhItem: _chanDoanBenh,
        phanLoaiChanDoanItem: _phanLoaiChanDoan,
        phanDoBenhItem: _phanDoBenh,
        loaiBenhPhamItem: _loaiBenhPham,
        loaiXetNghiemItem: _loaiXetNghiem,
        ketQuaXetNghiemItem: _ketQuaXetNghiem,
        coSoBaoCaoItem: widget.benhNhan.coSoBaoCaoItem,
        donViDieuTra: _donViDieuTraCtrl.text.isNotEmpty ? _donViDieuTraCtrl.text : null,
        coSoDieuTriItem: widget.benhNhan.coSoDieuTriItem,
        phongKham: _phongKhamCtrl.text.isNotEmpty ? _phongKhamCtrl.text : null,
        soThuTu: widget.benhNhan.soThuTu,
        trangThai: _trangThai,
        ngayDangKy: widget.benhNhan.ngayDangKy,
      );
      await FirestoreService().capNhatBenhNhan(widget.benhNhan.id, updated);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Row(children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Text('Đã cập nhật bệnh nhân'),
          ]),
          backgroundColor: Colors.green.shade600,
        ));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Lỗi: $e'), backgroundColor: Colors.red.shade600));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bn = widget.benhNhan;
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Chỉnh sửa bệnh nhân',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          Text('STT: ${bn.soThuTu ?? '-'}  •  ${bn.hoTen}',
              style: const TextStyle(fontSize: 11, color: Colors.white70)),
        ]),
        actions: [
          _isLoading
              ? const Padding(
                  padding: EdgeInsets.all(16),
                  child: SizedBox(width: 20, height: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)))
              : TextButton.icon(
                  onPressed: _luu,
                  icon: const Icon(Icons.save, color: Colors.white, size: 20),
                  label: const Text('Lưu',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ── Thông tin cá nhân ──────────────────────────────────
            _Section(title: 'Thông tin cá nhân', icon: Icons.person_outline, children: [
              _tf(_hoTenCtrl, 'Họ và tên *', Icons.badge_outlined,
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Vui lòng nhập họ tên' : null),
              _dateTf(_ngaySinhCtrl, 'Ngày sinh', Icons.cake_outlined),
              _dd('Giới tính', Icons.wc_outlined, _gioiTinh, CategoryOptions.gioiTinh, (v) => setState(() => _gioiTinh = v)),
              _dd('Dân tộc', Icons.people_outline, _danToc, CategoryOptions.danToc, (v) => setState(() => _danToc = v)),
              _ddStr('Nghề nghiệp', Icons.work_outline, _ngheNghiep, CategoryOptions.ngheNghiep, (v) => setState(() => _ngheNghiep = v)),
              _tf(_soDienThoaiCtrl, 'Số điện thoại', Icons.phone_outlined, type: TextInputType.phone),
              _tf(_cccdCtrl, 'CCCD / CMND', Icons.credit_card_outlined,
                  type: TextInputType.number,
                  errorText: _loiCCCD,
                  onEditingComplete: _kiemTraCCCD),
              _tf(_baoHiemYTeCtrl, 'Bảo hiểm y tế', Icons.verified_user_outlined),
            ]),
            const SizedBox(height: 12),

            // ── Địa chỉ ──────────────────────────────────────────
            _Section(title: 'Địa chỉ', icon: Icons.location_on_outlined, children: [
              _dd('Tỉnh / Thành phố', Icons.map_outlined, _tinh, CategoryOptions.tinh, (v) => setState(() => _tinh = v)),
              _tf(_diaChiCtrl, 'Địa chỉ chi tiết', Icons.home_outlined, maxLines: 2),
            ]),
            const SizedBox(height: 12),

            // ── Thông tin y tế ────────────────────────────────────
            _Section(title: 'Thông tin y tế', icon: Icons.medical_information_outlined, children: [
              _ddStr('Nhóm máu', Icons.bloodtype_outlined, _nhomMau, CategoryOptions.nhomMau, (v) => setState(() => _nhomMau = v)),
              _dd('Bệnh nền', Icons.monitor_heart_outlined, _benhNen, CategoryOptions.benhNen, (v) => setState(() => _benhNen = v)),
              _dd('Bệnh truyền nhiễm', Icons.coronavirus_outlined, _benhTruyenNhiem, CategoryOptions.chanDoanBenh, (v) => setState(() => _benhTruyenNhiem = v)),
              _dd('Tình trạng tiêm chủng', Icons.vaccines_outlined, _tinhTrangTiemChung, CategoryOptions.tinhTrangTiemChung, (v) => setState(() => _tinhTrangTiemChung = v)),
              _dd('Dị ứng (Có/Không)', Icons.warning_amber_outlined, _coKhong, CategoryOptions.coKhong, (v) => setState(() => _coKhong = v)),
            ]),
            const SizedBox(height: 12),

            // ── Chẩn đoán & Điều trị ──────────────────────────────
            _Section(title: 'Chẩn đoán & Điều trị', icon: Icons.local_hospital_outlined, children: [
              _dd('Chẩn đoán bệnh', Icons.content_paste_search_outlined, _chanDoanBenh, CategoryOptions.chanDoanBenh, (v) => setState(() => _chanDoanBenh = v)),
              _dd('Phân loại chẩn đoán', Icons.category_outlined, _phanLoaiChanDoan, CategoryOptions.phanLoaiChanDoan, (v) => setState(() => _phanLoaiChanDoan = v)),
              _dd('Phân độ bệnh', Icons.bar_chart_outlined, _phanDoBenh, CategoryOptions.phanDoBenh, (v) => setState(() => _phanDoBenh = v)),
              _dd('Điều trị', Icons.medical_services_outlined, _dieuTri, CategoryOptions.dieuTri, (v) => setState(() => _dieuTri = v)),
              _dd('Hình thức điều trị', Icons.health_and_safety_outlined, _hinhThucDieuTri, CategoryOptions.hinhThucDieuTri, (v) => setState(() => _hinhThucDieuTri = v)),
            ]),
            const SizedBox(height: 12),

            // ── Xét nghiệm ───────────────────────────────────────
            _Section(title: 'Xét nghiệm', icon: Icons.biotech_outlined, children: [
              _dd('Loại bệnh phẩm', Icons.science_outlined, _loaiBenhPham, CategoryOptions.loaiBenhPham, (v) => setState(() => _loaiBenhPham = v)),
              _dd('Loại xét nghiệm', Icons.manage_search_outlined, _loaiXetNghiem, CategoryOptions.loaiXetNghiem, (v) => setState(() => _loaiXetNghiem = v)),
              _dd('Kết quả xét nghiệm', Icons.assignment_turned_in_outlined, _ketQuaXetNghiem, CategoryOptions.ketQuaXetNghiem, (v) => setState(() => _ketQuaXetNghiem = v)),
            ]),
            const SizedBox(height: 12),

            // ── Cơ sở & Đơn vị ───────────────────────────────────
            _Section(title: 'Cơ sở & Đơn vị', icon: Icons.account_balance_outlined, children: [
              _tf(_donViDieuTraCtrl, 'Đơn vị điều tra', Icons.domain_outlined),
              _tf(_phongKhamCtrl, 'Phòng khám', Icons.door_front_door_outlined),
            ]),
            const SizedBox(height: 12),

            // ── Trạng thái ───────────────────────────────────────
            _Section(title: 'Trạng thái khám', icon: Icons.info_outline, children: [
              _ddStr('Trạng thái', Icons.pending_actions_outlined, _trangThai, CategoryOptions.trangThai, (v) => setState(() => _trangThai = v)),
            ]),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity, height: 52,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _luu,
                icon: _isLoading
                    ? const SizedBox(width: 20, height: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.save),
                label: Text(_isLoading ? 'Đang lưu...' : 'Lưu thay đổi',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1565C0), foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // ── Builder helpers ───────────────────────────────────────────────────────

  Widget _tf(TextEditingController ctrl, String label, IconData icon, {
    TextInputType type = TextInputType.text,
    String? Function(String?)? validator,
    int maxLines = 1,
    String? errorText,
    VoidCallback? onEditingComplete,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextFormField(
      controller: ctrl, keyboardType: type, maxLines: maxLines,
      validator: validator, onEditingComplete: onEditingComplete,
      decoration: _dec(label, icon, errorText: errorText),
    ),
  );

  Widget _dateTf(TextEditingController ctrl, String label, IconData icon) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: TextFormField(
          controller: ctrl, readOnly: true, onTap: _chonNgaySinh,
          decoration: _dec(label, icon, suffix: Icons.calendar_today),
        ),
      );

  Widget _dd(String label, IconData icon, CategoryItem? value,
      List<CategoryItem> items, void Function(CategoryItem?) onChanged) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: DropdownButtonFormField<CategoryItem>(
          initialValue: value,
          decoration: _dec(label, icon),
          isExpanded: true,
          hint: Text('Chọn $label', style: TextStyle(color: Colors.grey.shade400, fontSize: 14)),
          items: items.map((e) => DropdownMenuItem(
              value: e, child: Text(e.name, overflow: TextOverflow.ellipsis))).toList(),
          onChanged: onChanged,
        ),
      );

  Widget _ddStr(String label, IconData icon, String? value,
      List<String> items, void Function(String?) onChanged) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: DropdownButtonFormField<String>(
          initialValue: value,
          decoration: _dec(label, icon),
          isExpanded: true,
          hint: Text('Chọn $label', style: TextStyle(color: Colors.grey.shade400, fontSize: 14)),
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: onChanged,
        ),
      );

  InputDecoration _dec(String label, IconData icon, {IconData? suffix, String? errorText}) =>
      InputDecoration(
        labelText: label,
        errorText: errorText,
        prefixIcon: Icon(icon, size: 20, color: Colors.grey.shade500),
        suffixIcon: suffix != null ? Icon(suffix, size: 18, color: Colors.grey.shade400) : null,
        filled: true,
        fillColor: errorText != null ? Colors.red.shade50 : Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: errorText != null ? Colors.red.shade300 : Colors.grey.shade300)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: errorText != null ? Colors.red : const Color(0xFF1565C0), width: 1.5)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      );
}

// ── Section widget ────────────────────────────────────────────────────────────
class _Section extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;
  const _Section({required this.title, required this.icon, required this.children});

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: Colors.white, borderRadius: BorderRadius.circular(14),
      boxShadow: [BoxShadow(color: Colors.black.withAlpha(12), blurRadius: 8, offset: const Offset(0, 2))],
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: const Color(0xFF1565C0).withAlpha(20), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, size: 18, color: const Color(0xFF1565C0)),
          ),
          const SizedBox(width: 10),
          Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1565C0))),
        ]),
      ),
      const Divider(height: 1),
      Padding(padding: const EdgeInsets.fromLTRB(12, 12, 12, 4), child: Column(children: children)),
    ]),
  );
}


