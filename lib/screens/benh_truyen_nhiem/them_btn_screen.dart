import 'package:flutter/material.dart';
import 'dart:math';
import '../../models/benh_truyen_nhiem.dart';
import '../../models/category_options.dart';
import '../../services/benh_truyen_nhiem_service.dart';

class ThemBTNScreen extends StatefulWidget {
  const ThemBTNScreen({super.key});
  @override
  State<ThemBTNScreen> createState() => _ThemBTNScreenState();
}

class _ThemBTNScreenState extends State<ThemBTNScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // ── Text controllers ────────────────────────────────────────────────────
  final _hoTenCtrl            = TextEditingController();
  final _ngaySinhCtrl         = TextEditingController();
  final _maDinhDanhCtrl       = TextEditingController();
  final _tenNguoiBaoHoCtrl    = TextEditingController();
  final _sdtCtrl              = TextEditingController();
  final _tuanThaiCtrl         = TextEditingController();
  final _noiLamViecCtrl       = TextEditingController();
  final _diaChiLamViecCtrl    = TextEditingController();
  final _noiOHienNayCtrl      = TextEditingController();
  final _khuPhoApCtrl         = TextEditingController();
  final _soHSBACtrl           = TextEditingController();
  final _coSoDieuTriCtrl      = TextEditingController();
  final _chanDoanBienChungCtrl = TextEditingController();
  final _chanDoanKemTheoCtrl  = TextEditingController();
  final _ngayKhoiPhatCtrl     = TextEditingController();
  final _ngayNhapVienCtrl     = TextEditingController();
  final _ngayXVTVCVCtrl       = TextEditingController();
  final _donViXNCtrl          = TextEditingController();
  final _ngayLayMauCtrl       = TextEditingController();
  final _soMuiTiemCtrl        = TextEditingController();
  final _tienSuDichTeCtrl     = TextEditingController();
  final _nguoiDieuTraCtrl     = TextEditingController();
  final _sdtDieuTraCtrl       = TextEditingController();
  final _donViDieuTraCtrl     = TextEditingController();
  final _emailDieuTraCtrl     = TextEditingController();
  final _ngayBaoCaoCtrl       = TextEditingController();
  final _nguoiBaoCaoCtrl      = TextEditingController();
  final _sdtBaoCaoCtrl        = TextEditingController();
  final _emailBaoCaoCtrl      = TextEditingController();
  final _phanDoBenhTextCtrl   = TextEditingController();

  // ── Dropdown values ─────────────────────────────────────────────────────
  String? _gioiTinh, _danToc, _ngheNghiep;
  String? _coThai, _cityIdHoc, _wardIdHoc;
  String? _cityId, _wardId;
  String? _hinhThucDieuTri, _chanDoanBenh, _phanDoBenh, _thongTinDieuTri;
  String? _benhNenKemTheo, _phanLoaiChanDoan;
  String? _cityIdCSDT;
  String? _layMauXN, _loaiBenhPham, _loaiXN, _ketQuaXN;
  String? _tinhTrangTiem;

  @override
  void dispose() {
    for (final c in [
      _hoTenCtrl, _ngaySinhCtrl, _maDinhDanhCtrl, _tenNguoiBaoHoCtrl,
      _sdtCtrl, _tuanThaiCtrl, _noiLamViecCtrl, _diaChiLamViecCtrl, _noiOHienNayCtrl,
      _khuPhoApCtrl, _soHSBACtrl, _coSoDieuTriCtrl, _chanDoanBienChungCtrl,
      _chanDoanKemTheoCtrl, _ngayKhoiPhatCtrl, _ngayNhapVienCtrl, _ngayXVTVCVCtrl,
      _donViXNCtrl, _ngayLayMauCtrl, _soMuiTiemCtrl, _tienSuDichTeCtrl,
      _nguoiDieuTraCtrl, _sdtDieuTraCtrl, _donViDieuTraCtrl, _emailDieuTraCtrl,
      _ngayBaoCaoCtrl, _nguoiBaoCaoCtrl, _sdtBaoCaoCtrl, _emailBaoCaoCtrl,
      _phanDoBenhTextCtrl,
    ]) { c.dispose(); }
    super.dispose();
  }

  Future<void> _pickDate(TextEditingController ctrl, {bool withTime = false}) async {
    final now = DateTime.now();
    final d = await showDatePicker(
      context: context, initialDate: now, firstDate: DateTime(1900), lastDate: DateTime(now.year + 1),
    );
    if (d == null) return;
    if (!withTime) {
      ctrl.text = '${_p(d.day)}/${_p(d.month)}/${d.year}';
      return;
    }
    if (!mounted) return;
    final t = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (t == null) return;
    ctrl.text = '${_p(d.day)}/${_p(d.month)}/${d.year} ${_p(t.hour)}:${_p(t.minute)}';
  }

  String _p(int n) => n.toString().padLeft(2, '0');

  /// Sinh mã bệnh án ID: "BN" + 4 số ngẫu nhiên có padding (ví dụ: BN0053)
  String _sinhBenhAnId() {
    final rng = Random.secure();
    final so = rng.nextInt(9000) + 1000; // 1000–9999
    return 'BN${so.toString().padLeft(4, '0')}';
  }

  Future<void> _luu() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final obj = BenhTruyenNhiem(
        id: '',
        hoTen: _hoTenCtrl.text.trim(),
        benhAnId: _sinhBenhAnId(), // tự sinh mã ngẫu nhiên
        ngaySinh: _ngaySinhCtrl.text.isNotEmpty ? _ngaySinhCtrl.text : null,
        gioiTinh: _gioiTinh,
        danTocId: _danToc,
        maDinhDanhCaNhan: _maDinhDanhCtrl.text.trim().isNotEmpty ? _maDinhDanhCtrl.text.trim() : '000',
        tenNguoiBaoHo: _tenNguoiBaoHoCtrl.text.trim().isNotEmpty ? _tenNguoiBaoHoCtrl.text.trim() : null,
        sdt: _sdtCtrl.text.trim().isNotEmpty ? _sdtCtrl.text.trim() : null,
        coThai: _coThai,
        tuanThai: int.tryParse(_tuanThaiCtrl.text.trim()),
        ngheNghiep: _ngheNghiep,
        noiLamViecHoc: _noiLamViecCtrl.text.trim().isNotEmpty ? _noiLamViecCtrl.text.trim() : null,
        diaChinoiLamViecHoc: _diaChiLamViecCtrl.text.trim().isNotEmpty ? _diaChiLamViecCtrl.text.trim() : null,
        cityIdHoc: _cityIdHoc,
        wardIdHoc: _wardIdHoc,
        noiOHienNay: _noiOHienNayCtrl.text.trim().isNotEmpty ? _noiOHienNayCtrl.text.trim() : null,
        cityId: _cityId,
        wardId: _wardId,
        khuPhoAp: _khuPhoApCtrl.text.trim().isNotEmpty ? _khuPhoApCtrl.text.trim() : null,
        soHSBA: _soHSBACtrl.text.trim().isNotEmpty ? _soHSBACtrl.text.trim() : null,
        coSoDieuTri: _coSoDieuTriCtrl.text.trim().isNotEmpty ? _coSoDieuTriCtrl.text.trim() : null,
        cityIdCSDT: _cityIdCSDT,
        hinhThucDieuTri: _hinhThucDieuTri,
        chanDoanBenh: _chanDoanBenh,
        phanDoBenh: _phanDoBenh,
        thongTinDieuTri: _thongTinDieuTri,
        chanDoanBienChung: _chanDoanBienChungCtrl.text.trim().isNotEmpty ? _chanDoanBienChungCtrl.text.trim() : null,
        chanDoanBenhKemTheo: _chanDoanKemTheoCtrl.text.trim().isNotEmpty ? _chanDoanKemTheoCtrl.text.trim() : null,
        benhNenKemTheoId: _benhNenKemTheo,
        ngayKhoiPhat: _ngayKhoiPhatCtrl.text.isNotEmpty ? _ngayKhoiPhatCtrl.text : null,
        ngayNhapVien: _ngayNhapVienCtrl.text.isNotEmpty ? _ngayNhapVienCtrl.text : null,
        ngayXVTVCV: _ngayXVTVCVCtrl.text.isNotEmpty ? _ngayXVTVCVCtrl.text : null,
        phanLoaiChanDoan: _phanLoaiChanDoan,
        layMauXN: _layMauXN,
        loaiBenhPham: _loaiBenhPham,
        donViThucHienXN: _donViXNCtrl.text.trim().isNotEmpty ? _donViXNCtrl.text.trim() : null,
        ngayLayMau: _ngayLayMauCtrl.text.isNotEmpty ? _ngayLayMauCtrl.text : null,
        loaiXN: _loaiXN,
        ketQuaXN: _ketQuaXN,
        tinhTrangTiem: _tinhTrangTiem,
        soMuiTiemUong: int.tryParse(_soMuiTiemCtrl.text.trim()),
        tienSuDichTe: _tienSuDichTeCtrl.text.trim().isNotEmpty ? _tienSuDichTeCtrl.text.trim() : null,
        nguoiDieuTraDichTe: _nguoiDieuTraCtrl.text.trim().isNotEmpty ? _nguoiDieuTraCtrl.text.trim() : null,
        sdtNguoiDieuTraDTe: _sdtDieuTraCtrl.text.trim().isNotEmpty ? _sdtDieuTraCtrl.text.trim() : null,
        donViDieuTra: _donViDieuTraCtrl.text.trim().isNotEmpty ? _donViDieuTraCtrl.text.trim() : null,
        emailDonViDieuTra: _emailDieuTraCtrl.text.trim().isNotEmpty ? _emailDieuTraCtrl.text.trim() : null,
        ngayBaoCao: _ngayBaoCaoCtrl.text.isNotEmpty ? _ngayBaoCaoCtrl.text : null,
        nguoiBaoCao: _nguoiBaoCaoCtrl.text.trim().isNotEmpty ? _nguoiBaoCaoCtrl.text.trim() : null,
        sdtNguoiBaoCao: _sdtBaoCaoCtrl.text.trim().isNotEmpty ? _sdtBaoCaoCtrl.text.trim() : null,
        emailNguoiBaoCao: _emailBaoCaoCtrl.text.trim().isNotEmpty ? _emailBaoCaoCtrl.text.trim() : null,
        phanDoBenhText: _phanDoBenhTextCtrl.text.trim().isNotEmpty ? _phanDoBenhTextCtrl.text.trim() : null,
      );
      await BenhTruyenNhiemService().them(obj);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Row(children: [Icon(Icons.check_circle, color: Colors.white), SizedBox(width: 8), Text('Đã thêm ca bệnh truyền nhiễm')]),
          backgroundColor: Colors.green.shade600,
        ));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        title: const Row(children: [
          Icon(Icons.add_circle_outline, size: 20),
          SizedBox(width: 8),
          Text('Thêm ca bệnh truyền nhiễm', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ]),
        actions: [
          _isLoading
              ? const Padding(padding: EdgeInsets.all(16), child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)))
              : TextButton.icon(
                  onPressed: _luu,
                  icon: const Icon(Icons.save, color: Colors.white, size: 20),
                  label: const Text('Lưu', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [

            // ── 1–15: Thông tin cá nhân ──
            _Sec('Thông tin cá nhân (1–15)', Icons.person_outline, [
              // Bệnh án ID tự sinh — chỉ hiển thị thông báo, không nhập tay
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E7D32).withAlpha(12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFF2E7D32).withAlpha(60)),
                  ),
                  child: Row(children: [
                    const Icon(Icons.auto_awesome, size: 18, color: Color(0xFF2E7D32)),
                    const SizedBox(width: 10),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('1. Bệnh án ID',
                          style: TextStyle(fontSize: 11, color: Color(0xFF2E7D32), fontWeight: FontWeight.w600)),
                      const SizedBox(height: 2),
                      Text('Tự động sinh khi lưu (định dạng BN0000)',
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                    ])),
                  ]),
                ),
              ),
              _tf(_hoTenCtrl, '2. Họ và tên *', Icons.badge_outlined,
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Bắt buộc' : null),
              _dateTf(_ngaySinhCtrl, '3. Ngày sinh (DD/MM/YYYY)', Icons.cake_outlined),
              _dd('4. Giới tính', Icons.wc_outlined, _gioiTinh, CategoryOptions.gioiTinh, (v) => setState(() => _gioiTinh = v)),
              _dd('5. Dân tộc', Icons.people_outline, _danToc, CategoryOptions.danToc, (v) => setState(() => _danToc = v)),
              _tf(_maDinhDanhCtrl, '6. Mã định danh (CCCD/000)', Icons.credit_card_outlined, type: TextInputType.number),
              _tf(_tenNguoiBaoHoCtrl, '7. Tên người bảo hộ', Icons.family_restroom_outlined),
              _tf(_sdtCtrl, '8. Số điện thoại (10 số)', Icons.phone_outlined, type: TextInputType.phone),
              _dd('9. Có thai', Icons.pregnant_woman_outlined, _coThai, CategoryOptions.coKhong, (v) => setState(() => _coThai = v)),
              _tf(_tuanThaiCtrl, '10. Tuần thai', Icons.access_time_outlined, type: TextInputType.number),
              _dd('11. Nghề nghiệp', Icons.work_outline, _ngheNghiep, CategoryOptions.ngheNghiep, (v) => setState(() => _ngheNghiep = v)),
              _tf(_noiLamViecCtrl, '12. Nơi làm việc/học tập', Icons.business_outlined),
              _tf(_diaChiLamViecCtrl, '13. Địa chỉ nơi làm/học', Icons.location_on_outlined),
              _dd('14. Tỉnh nơi làm/học', Icons.map_outlined, _cityIdHoc, CategoryOptions.tinh, (v) => setState(() => _cityIdHoc = v)),
              _tf(TextEditingController(), '15. Phường xã nơi làm/học', Icons.place_outlined),
            ]),
            const SizedBox(height: 12),

            // ── 16–20: Địa chỉ hiện tại ──
            _Sec('Địa chỉ hiện tại (16–20)', Icons.home_outlined, [
              _tf(_noiOHienNayCtrl, '16. Nơi ở hiện nay', Icons.home_outlined),
              _dd('17. Tỉnh nơi ở hiện nay', Icons.map_outlined, _cityId, CategoryOptions.tinh, (v) => setState(() => _cityId = v)),
              _tf(TextEditingController(), '18. Phường xã nơi ở', Icons.place_outlined),
              _tf(_khuPhoApCtrl, '19. Khu phố/ấp', Icons.location_city_outlined),
              _tf(_soHSBACtrl, '20. Số hồ sơ bệnh án (HSBA)', Icons.folder_outlined),
            ]),
            const SizedBox(height: 12),

            // ── 21–33: Điều trị & chẩn đoán ──
            _Sec('Điều trị & Chẩn đoán (21–33)', Icons.local_hospital_outlined, [
              _tf(_coSoDieuTriCtrl, '21. Cơ sở điều trị', Icons.local_hospital_outlined),
              _dd('22. Tỉnh cơ sở điều trị', Icons.map_outlined, _cityIdCSDT, CategoryOptions.tinh, (v) => setState(() => _cityIdCSDT = v)),
              _dd('23. Hình thức điều trị', Icons.health_and_safety_outlined, _hinhThucDieuTri, CategoryOptions.hinhThucDieuTri, (v) => setState(() => _hinhThucDieuTri = v)),
              _dd('24. Chẩn đoán bệnh', Icons.content_paste_search_outlined, _chanDoanBenh, CategoryOptions.benhTruyenNhiem, (v) => setState(() => _chanDoanBenh = v)),
              _dd('25. Phân độ bệnh', Icons.bar_chart_outlined, _phanDoBenh, CategoryOptions.phanDoBenh, (v) => setState(() => _phanDoBenh = v)),
              _dd('26. Thông tin điều trị', Icons.medical_services_outlined, _thongTinDieuTri, CategoryOptions.dieuTri, (v) => setState(() => _thongTinDieuTri = v)),
              _tf(_chanDoanBienChungCtrl, '27. Chẩn đoán biến chứng', Icons.warning_amber_outlined),
              _tf(_chanDoanKemTheoCtrl, '28. Chẩn đoán bệnh kèm theo', Icons.add_circle_outline),
              _dd('29. Bệnh nền kèm theo', Icons.monitor_heart_outlined, _benhNenKemTheo, CategoryOptions.benhNen, (v) => setState(() => _benhNenKemTheo = v)),
              _dateTf(_ngayKhoiPhatCtrl, '30. Ngày khởi phát (DD/MM/YYYY)', Icons.today_outlined),
              _dateTf(_ngayNhapVienCtrl, '31. Ngày nhập viện (DD/MM/YYYY)', Icons.login_outlined),
              _dateTimeTf(_ngayXVTVCVCtrl, '32. Ngày XV/TV/CV (DD/MM/YYYY HH:mm)', Icons.logout_outlined),
              _dd('33. Phân loại chẩn đoán', Icons.category_outlined, _phanLoaiChanDoan, CategoryOptions.phanLoaiChanDoan, (v) => setState(() => _phanLoaiChanDoan = v)),
            ]),
            const SizedBox(height: 12),

            // ── 34–39: Xét nghiệm ──
            _Sec('Xét nghiệm (34–39)', Icons.biotech_outlined, [
              _dd('34. Lấy mẫu xét nghiệm', Icons.science_outlined, _layMauXN, CategoryOptions.coKhong, (v) => setState(() => _layMauXN = v)),
              _dd('35. Loại bệnh phẩm', Icons.water_drop_outlined, _loaiBenhPham, CategoryOptions.loaiBenhPham, (v) => setState(() => _loaiBenhPham = v)),
              _tf(_donViXNCtrl, '36. Đơn vị thực hiện XN', Icons.domain_outlined),
              _dateTf(_ngayLayMauCtrl, '37. Ngày lấy mẫu (DD/MM/YYYY)', Icons.calendar_today_outlined),
              _dd('38. Loại xét nghiệm', Icons.manage_search_outlined, _loaiXN, CategoryOptions.loaiXetNghiem, (v) => setState(() => _loaiXN = v)),
              _dd('39. Kết quả xét nghiệm', Icons.assignment_turned_in_outlined, _ketQuaXN, CategoryOptions.ketQuaXetNghiem, (v) => setState(() => _ketQuaXN = v)),
            ]),
            const SizedBox(height: 12),

            // ── 40–41: Tiêm chủng ──
            _Sec('Tiêm chủng (40–41)', Icons.vaccines_outlined, [
              _dd('40. Tình trạng tiêm chủng', Icons.vaccines_outlined, _tinhTrangTiem, CategoryOptions.tinhTrangTiemChung, (v) => setState(() => _tinhTrangTiem = v)),
              _tf(_soMuiTiemCtrl, '41. Số mũi tiêm/uống', Icons.format_list_numbered_outlined, type: TextInputType.number),
            ]),
            const SizedBox(height: 12),

            // ── 42–46: Dịch tễ ──
            _Sec('Dịch tễ (42–46)', Icons.travel_explore_outlined, [
              _tf(_tienSuDichTeCtrl, '42. Tiền sử dịch tễ', Icons.history_outlined, lines: 2),
              _tf(_nguoiDieuTraCtrl, '43. Người điều tra dịch tễ', Icons.person_search_outlined),
              _tf(_sdtDieuTraCtrl, '44. SĐT người điều tra DT', Icons.phone_outlined, type: TextInputType.phone),
              _tf(_donViDieuTraCtrl, '45. Đơn vị điều tra', Icons.account_balance_outlined),
              _tf(_emailDieuTraCtrl, '46. Email đơn vị điều tra', Icons.email_outlined, type: TextInputType.emailAddress),
            ]),
            const SizedBox(height: 12),

            // ── 47–51: Báo cáo ──
            _Sec('Báo cáo (47–51)', Icons.summarize_outlined, [
              _dateTimeTf(_ngayBaoCaoCtrl, '47. Ngày báo cáo (DD/MM/YYYY HH:mm)', Icons.calendar_today_outlined),
              _tf(_nguoiBaoCaoCtrl, '48. Người báo cáo', Icons.person_outlined),
              _tf(_sdtBaoCaoCtrl, '49. SĐT người báo cáo', Icons.phone_outlined, type: TextInputType.phone),
              _tf(_emailBaoCaoCtrl, '50. Email người báo cáo', Icons.email_outlined, type: TextInputType.emailAddress),
              _tf(_phanDoBenhTextCtrl, '51. Phân độ bệnh (text)', Icons.text_fields_outlined),
            ]),
            const SizedBox(height: 24),

            // Nút lưu
            SizedBox(
              height: 52, width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _luu,
                icon: _isLoading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.save),
                label: Text(_isLoading ? 'Đang lưu...' : 'Lưu ca bệnh',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32), foregroundColor: Colors.white,
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

  Widget _tf(TextEditingController ctrl, String label, IconData icon,
      {TextInputType type = TextInputType.text, String? Function(String?)? validator, int lines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: ctrl, keyboardType: type, maxLines: lines, validator: validator,
        decoration: _dec(label, icon),
      ),
    );
  }

  Widget _dateTf(TextEditingController ctrl, String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: ctrl, readOnly: true,
        onTap: () => _pickDate(ctrl),
        decoration: _dec(label, icon, suffix: Icons.calendar_today),
      ),
    );
  }

  Widget _dateTimeTf(TextEditingController ctrl, String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: ctrl, readOnly: true,
        onTap: () => _pickDate(ctrl, withTime: true),
        decoration: _dec(label, icon, suffix: Icons.access_time),
      ),
    );
  }

  Widget _dd(String label, IconData icon, String? value, List<String> items, void Function(String?) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        initialValue: value,
        decoration: _dec(label, icon),
        isExpanded: true,
        hint: Text('Chọn...', style: TextStyle(color: Colors.grey.shade400, fontSize: 14)),
        items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
        onChanged: onChanged,
      ),
    );
  }

  InputDecoration _dec(String label, IconData icon, {IconData? suffix}) => InputDecoration(
    labelText: label,
    prefixIcon: Icon(icon, size: 20, color: Colors.grey.shade500),
    suffixIcon: suffix != null ? Icon(suffix, size: 18, color: Colors.grey.shade400) : null,
    filled: true, fillColor: Colors.white,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 1.5)),
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
  );
}

// ── Section widget ────────────────────────────────────────────────────────────
class _Sec extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;
  const _Sec(this.title, this.icon, this.children);

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
            decoration: BoxDecoration(color: const Color(0xFF2E7D32).withAlpha(20), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, size: 18, color: const Color(0xFF2E7D32)),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20)))),
        ]),
      ),
      const Divider(height: 1),
      Padding(padding: const EdgeInsets.fromLTRB(12, 12, 12, 4), child: Column(children: children)),
    ]),
  );
}
