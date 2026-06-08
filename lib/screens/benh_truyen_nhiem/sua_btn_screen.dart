import 'package:flutter/material.dart';
import '../../models/benh_truyen_nhiem.dart';
import '../../models/category_options.dart';
import '../../services/benh_truyen_nhiem_service.dart';

class SuaBTNScreen extends StatefulWidget {
  final BenhTruyenNhiem benhAn;
  const SuaBTNScreen({super.key, required this.benhAn});

  @override
  State<SuaBTNScreen> createState() => _SuaBTNScreenState();
}

class _SuaBTNScreenState extends State<SuaBTNScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // ── Controllers ─────────────────────────────────────────────────────────
  late final TextEditingController _hoTenCtrl;
  late final TextEditingController _ngaySinhCtrl;
  late final TextEditingController _maDinhDanhCtrl;
  late final TextEditingController _tenNguoiBaoHoCtrl;
  late final TextEditingController _sdtCtrl;
  late final TextEditingController _tuanThaiCtrl;
  late final TextEditingController _noiLamViecCtrl;
  late final TextEditingController _diaChiLamViecCtrl;
  late final TextEditingController _noiOHienNayCtrl;
  late final TextEditingController _khuPhoApCtrl;
  late final TextEditingController _soHSBACtrl;
  late final TextEditingController _coSoDieuTriCtrl;
  late final TextEditingController _chanDoanBienChungCtrl;
  late final TextEditingController _chanDoanKemTheoCtrl;
  late final TextEditingController _ngayKhoiPhatCtrl;
  late final TextEditingController _ngayNhapVienCtrl;
  late final TextEditingController _ngayXVTVCVCtrl;
  late final TextEditingController _donViXNCtrl;
  late final TextEditingController _ngayLayMauCtrl;
  late final TextEditingController _soMuiTiemCtrl;
  late final TextEditingController _tienSuDichTeCtrl;
  late final TextEditingController _nguoiDieuTraCtrl;
  late final TextEditingController _sdtDieuTraCtrl;
  late final TextEditingController _donViDieuTraCtrl;
  late final TextEditingController _emailDieuTraCtrl;
  late final TextEditingController _ngayBaoCaoCtrl;
  late final TextEditingController _nguoiBaoCaoCtrl;
  late final TextEditingController _sdtBaoCaoCtrl;
  late final TextEditingController _emailBaoCaoCtrl;
  late final TextEditingController _phanDoBenhTextCtrl;

  // ── Dropdown values ──────────────────────────────────────────────────────
  String? _gioiTinh, _danToc, _ngheNghiep;
  String? _coThai, _cityIdHoc, _wardIdHoc;
  String? _cityId, _wardId;
  String? _hinhThucDieuTri, _chanDoanBenh, _phanDoBenh, _thongTinDieuTri;
  String? _benhNenKemTheo, _phanLoaiChanDoan;
  String? _cityIdCSDT;
  String? _layMauXN, _loaiBenhPham, _loaiXN, _ketQuaXN;
  String? _tinhTrangTiem;

  @override
  void initState() {
    super.initState();
    final b = widget.benhAn;
    _hoTenCtrl           = TextEditingController(text: b.hoTen);
    _ngaySinhCtrl        = TextEditingController(text: b.ngaySinh ?? '');
    _maDinhDanhCtrl      = TextEditingController(text: b.maDinhDanhCaNhan ?? '');
    _tenNguoiBaoHoCtrl   = TextEditingController(text: b.tenNguoiBaoHo ?? '');
    _sdtCtrl             = TextEditingController(text: b.sdt ?? '');
    _tuanThaiCtrl        = TextEditingController(text: b.tuanThai?.toString() ?? '');
    _noiLamViecCtrl      = TextEditingController(text: b.noiLamViecHoc ?? '');
    _diaChiLamViecCtrl   = TextEditingController(text: b.diaChinoiLamViecHoc ?? '');
    _noiOHienNayCtrl     = TextEditingController(text: b.noiOHienNay ?? '');
    _khuPhoApCtrl        = TextEditingController(text: b.khuPhoAp ?? '');
    _soHSBACtrl          = TextEditingController(text: b.soHSBA ?? '');
    _coSoDieuTriCtrl     = TextEditingController(text: b.coSoDieuTri ?? '');
    _chanDoanBienChungCtrl = TextEditingController(text: b.chanDoanBienChung ?? '');
    _chanDoanKemTheoCtrl = TextEditingController(text: b.chanDoanBenhKemTheo ?? '');
    _ngayKhoiPhatCtrl    = TextEditingController(text: b.ngayKhoiPhat ?? '');
    _ngayNhapVienCtrl    = TextEditingController(text: b.ngayNhapVien ?? '');
    _ngayXVTVCVCtrl      = TextEditingController(text: b.ngayXVTVCV ?? '');
    _donViXNCtrl         = TextEditingController(text: b.donViThucHienXN ?? '');
    _ngayLayMauCtrl      = TextEditingController(text: b.ngayLayMau ?? '');
    _soMuiTiemCtrl       = TextEditingController(text: b.soMuiTiemUong?.toString() ?? '');
    _tienSuDichTeCtrl    = TextEditingController(text: b.tienSuDichTe ?? '');
    _nguoiDieuTraCtrl    = TextEditingController(text: b.nguoiDieuTraDichTe ?? '');
    _sdtDieuTraCtrl      = TextEditingController(text: b.sdtNguoiDieuTraDTe ?? '');
    _donViDieuTraCtrl    = TextEditingController(text: b.donViDieuTra ?? '');
    _emailDieuTraCtrl    = TextEditingController(text: b.emailDonViDieuTra ?? '');
    _ngayBaoCaoCtrl      = TextEditingController(text: b.ngayBaoCao ?? '');
    _nguoiBaoCaoCtrl     = TextEditingController(text: b.nguoiBaoCao ?? '');
    _sdtBaoCaoCtrl       = TextEditingController(text: b.sdtNguoiBaoCao ?? '');
    _emailBaoCaoCtrl     = TextEditingController(text: b.emailNguoiBaoCao ?? '');
    _phanDoBenhTextCtrl  = TextEditingController(text: b.phanDoBenhText ?? '');

    _gioiTinh        = b.gioiTinh;
    _danToc          = b.danTocId;
    _ngheNghiep      = b.ngheNghiep;
    _coThai          = b.coThai;
    _cityIdHoc       = b.cityIdHoc;
    _wardIdHoc       = b.wardIdHoc;
    _cityId          = b.cityId;
    _wardId          = b.wardId;
    _hinhThucDieuTri = b.hinhThucDieuTri;
    _chanDoanBenh    = b.chanDoanBenh;
    _phanDoBenh      = b.phanDoBenh;
    _thongTinDieuTri = b.thongTinDieuTri;
    _benhNenKemTheo  = b.benhNenKemTheoId;
    _phanLoaiChanDoan= b.phanLoaiChanDoan;
    _cityIdCSDT      = b.cityIdCSDT;
    _layMauXN        = b.layMauXN;
    _loaiBenhPham    = b.loaiBenhPham;
    _loaiXN          = b.loaiXN;
    _ketQuaXN        = b.ketQuaXN;
    _tinhTrangTiem   = b.tinhTrangTiem;
  }

  @override
  void dispose() {
    for (final c in [
      _hoTenCtrl, _ngaySinhCtrl, _maDinhDanhCtrl, _tenNguoiBaoHoCtrl,
      _sdtCtrl, _tuanThaiCtrl, _noiLamViecCtrl, _diaChiLamViecCtrl,
      _noiOHienNayCtrl, _khuPhoApCtrl, _soHSBACtrl, _coSoDieuTriCtrl,
      _chanDoanBienChungCtrl, _chanDoanKemTheoCtrl, _ngayKhoiPhatCtrl,
      _ngayNhapVienCtrl, _ngayXVTVCVCtrl, _donViXNCtrl, _ngayLayMauCtrl,
      _soMuiTiemCtrl, _tienSuDichTeCtrl, _nguoiDieuTraCtrl, _sdtDieuTraCtrl,
      _donViDieuTraCtrl, _emailDieuTraCtrl, _ngayBaoCaoCtrl, _nguoiBaoCaoCtrl,
      _sdtBaoCaoCtrl, _emailBaoCaoCtrl, _phanDoBenhTextCtrl,
    ]) { c.dispose(); }
    super.dispose();
  }

  Future<void> _pickDate(TextEditingController ctrl, {bool withTime = false}) async {
    final now = DateTime.now();
    final d = await showDatePicker(
      context: context, initialDate: now, firstDate: DateTime(1900), lastDate: DateTime(now.year + 1),
    );
    if (d == null) return;
    if (!withTime) { ctrl.text = '${_p(d.day)}/${_p(d.month)}/${d.year}'; return; }
    if (!mounted) return;
    final t = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (t == null) return;
    ctrl.text = '${_p(d.day)}/${_p(d.month)}/${d.year} ${_p(t.hour)}:${_p(t.minute)}';
  }

  String _p(int n) => n.toString().padLeft(2, '0');

  Future<void> _luu() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final updated = BenhTruyenNhiem(
        id: widget.benhAn.id,
        hoTen: _hoTenCtrl.text.trim(),
        benhAnId: widget.benhAn.benhAnId, // giữ nguyên ID cũ
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
        ngayTao: widget.benhAn.ngayTao,
      );
      await BenhTruyenNhiemService().capNhat(widget.benhAn.id, updated);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Row(children: [Icon(Icons.check_circle, color: Colors.white), SizedBox(width: 8), Text('Đã cập nhật bệnh án')]),
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
    final b = widget.benhAn;
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Chỉnh sửa bệnh án', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          if (b.benhAnId != null)
            Text(b.benhAnId!, style: const TextStyle(fontSize: 12, color: Colors.white70)),
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
            // Chip hiển thị Bệnh án ID (không đổi được)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1565C0).withAlpha(12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF1565C0).withAlpha(60)),
                ),
                child: Row(children: [
                  const Icon(Icons.badge, color: Color(0xFF1565C0), size: 20),
                  const SizedBox(width: 12),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('1. Bệnh án ID', style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                    const SizedBox(height: 2),
                    Text(b.benhAnId ?? '—',
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1565C0), letterSpacing: 1)),
                  ]),
                ]),
              ),
            ),

            _Sec('Thông tin cá nhân (2–15)', Icons.person_outline, [
              _tf(_hoTenCtrl, '2. Họ và tên *', Icons.badge_outlined, validator: (v) => (v == null || v.trim().isEmpty) ? 'Bắt buộc' : null),
              _dateTf(_ngaySinhCtrl, '3. Ngày sinh (DD/MM/YYYY)', Icons.cake_outlined),
              _dd('4. Giới tính', Icons.wc_outlined, _gioiTinh, CategoryOptions.gioiTinh, (v) => setState(() => _gioiTinh = v)),
              _dd('5. Dân tộc', Icons.people_outline, _danToc, CategoryOptions.danToc, (v) => setState(() => _danToc = v)),
              _tf(_maDinhDanhCtrl, '6. Mã định danh (CCCD/000)', Icons.credit_card_outlined, type: TextInputType.number),
              _tf(_tenNguoiBaoHoCtrl, '7. Tên người bảo hộ', Icons.family_restroom_outlined),
              _tf(_sdtCtrl, '8. Số điện thoại', Icons.phone_outlined, type: TextInputType.phone),
              _dd('9. Có thai', Icons.pregnant_woman_outlined, _coThai, CategoryOptions.coKhong, (v) => setState(() => _coThai = v)),
              _tf(_tuanThaiCtrl, '10. Tuần thai', Icons.access_time_outlined, type: TextInputType.number),
              _dd('11. Nghề nghiệp', Icons.work_outline, _ngheNghiep, CategoryOptions.ngheNghiep, (v) => setState(() => _ngheNghiep = v)),
              _tf(_noiLamViecCtrl, '12. Nơi làm việc/học', Icons.business_outlined),
              _tf(_diaChiLamViecCtrl, '13. Địa chỉ nơi làm/học', Icons.location_on_outlined),
              _dd('14. Tỉnh nơi làm/học', Icons.map_outlined, _cityIdHoc, CategoryOptions.tinh, (v) => setState(() => _cityIdHoc = v)),
            ]),
            const SizedBox(height: 12),

            _Sec('Địa chỉ hiện tại (16–20)', Icons.home_outlined, [
              _tf(_noiOHienNayCtrl, '16. Nơi ở hiện nay', Icons.home_outlined),
              _dd('17. Tỉnh nơi ở', Icons.map_outlined, _cityId, CategoryOptions.tinh, (v) => setState(() => _cityId = v)),
              _tf(_khuPhoApCtrl, '19. Khu phố/ấp', Icons.location_city_outlined),
              _tf(_soHSBACtrl, '20. Số HSBA', Icons.folder_outlined),
            ]),
            const SizedBox(height: 12),

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
              _dateTf(_ngayKhoiPhatCtrl, '30. Ngày khởi phát', Icons.today_outlined),
              _dateTf(_ngayNhapVienCtrl, '31. Ngày nhập viện', Icons.login_outlined),
              _dateTimeTf(_ngayXVTVCVCtrl, '32. Ngày XV/TV/CV', Icons.logout_outlined),
              _dd('33. Phân loại chẩn đoán', Icons.category_outlined, _phanLoaiChanDoan, CategoryOptions.phanLoaiChanDoan, (v) => setState(() => _phanLoaiChanDoan = v)),
            ]),
            const SizedBox(height: 12),

            _Sec('Xét nghiệm (34–39)', Icons.biotech_outlined, [
              _dd('34. Lấy mẫu XN', Icons.science_outlined, _layMauXN, CategoryOptions.coKhong, (v) => setState(() => _layMauXN = v)),
              _dd('35. Loại bệnh phẩm', Icons.water_drop_outlined, _loaiBenhPham, CategoryOptions.loaiBenhPham, (v) => setState(() => _loaiBenhPham = v)),
              _tf(_donViXNCtrl, '36. Đơn vị thực hiện XN', Icons.domain_outlined),
              _dateTf(_ngayLayMauCtrl, '37. Ngày lấy mẫu', Icons.calendar_today_outlined),
              _dd('38. Loại xét nghiệm', Icons.manage_search_outlined, _loaiXN, CategoryOptions.loaiXetNghiem, (v) => setState(() => _loaiXN = v)),
              _dd('39. Kết quả XN', Icons.assignment_turned_in_outlined, _ketQuaXN, CategoryOptions.ketQuaXetNghiem, (v) => setState(() => _ketQuaXN = v)),
            ]),
            const SizedBox(height: 12),

            _Sec('Tiêm chủng (40–41)', Icons.vaccines_outlined, [
              _dd('40. Tình trạng tiêm', Icons.vaccines_outlined, _tinhTrangTiem, CategoryOptions.tinhTrangTiemChung, (v) => setState(() => _tinhTrangTiem = v)),
              _tf(_soMuiTiemCtrl, '41. Số mũi tiêm/uống', Icons.format_list_numbered_outlined, type: TextInputType.number),
            ]),
            const SizedBox(height: 12),

            _Sec('Dịch tễ (42–46)', Icons.travel_explore_outlined, [
              _tf(_tienSuDichTeCtrl, '42. Tiền sử dịch tễ', Icons.history_outlined, lines: 2),
              _tf(_nguoiDieuTraCtrl, '43. Người điều tra dịch tễ', Icons.person_search_outlined),
              _tf(_sdtDieuTraCtrl, '44. SĐT người điều tra', Icons.phone_outlined, type: TextInputType.phone),
              _tf(_donViDieuTraCtrl, '45. Đơn vị điều tra', Icons.account_balance_outlined),
              _tf(_emailDieuTraCtrl, '46. Email đơn vị điều tra', Icons.email_outlined, type: TextInputType.emailAddress),
            ]),
            const SizedBox(height: 12),

            _Sec('Báo cáo (47–51)', Icons.summarize_outlined, [
              _dateTimeTf(_ngayBaoCaoCtrl, '47. Ngày báo cáo', Icons.calendar_today_outlined),
              _tf(_nguoiBaoCaoCtrl, '48. Người báo cáo', Icons.person_outlined),
              _tf(_sdtBaoCaoCtrl, '49. SĐT người báo cáo', Icons.phone_outlined, type: TextInputType.phone),
              _tf(_emailBaoCaoCtrl, '50. Email người báo cáo', Icons.email_outlined, type: TextInputType.emailAddress),
              _tf(_phanDoBenhTextCtrl, '51. Phân độ bệnh (text)', Icons.text_fields_outlined),
            ]),
            const SizedBox(height: 24),

            SizedBox(
              height: 52, width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _luu,
                icon: _isLoading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
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

  Widget _tf(TextEditingController ctrl, String label, IconData icon,
      {TextInputType type = TextInputType.text, String? Function(String?)? validator, int lines = 1}) =>
      Padding(padding: const EdgeInsets.only(bottom: 12),
          child: TextFormField(controller: ctrl, keyboardType: type, maxLines: lines, validator: validator, decoration: _dec(label, icon)));

  Widget _dateTf(TextEditingController ctrl, String label, IconData icon) =>
      Padding(padding: const EdgeInsets.only(bottom: 12),
          child: TextFormField(controller: ctrl, readOnly: true, onTap: () => _pickDate(ctrl), decoration: _dec(label, icon, suffix: Icons.calendar_today)));

  Widget _dateTimeTf(TextEditingController ctrl, String label, IconData icon) =>
      Padding(padding: const EdgeInsets.only(bottom: 12),
          child: TextFormField(controller: ctrl, readOnly: true, onTap: () => _pickDate(ctrl, withTime: true), decoration: _dec(label, icon, suffix: Icons.access_time)));

  Widget _dd(String label, IconData icon, String? value, List<String> items, void Function(String?) onChanged) =>
      Padding(padding: const EdgeInsets.only(bottom: 12),
          child: DropdownButtonFormField<String>(
            initialValue: value, decoration: _dec(label, icon), isExpanded: true,
            hint: Text('Chọn...', style: TextStyle(color: Colors.grey.shade400, fontSize: 14)),
            items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: onChanged,
          ));

  InputDecoration _dec(String label, IconData icon, {IconData? suffix}) => InputDecoration(
    labelText: label,
    prefixIcon: Icon(icon, size: 20, color: Colors.grey.shade500),
    suffixIcon: suffix != null ? Icon(suffix, size: 18, color: Colors.grey.shade400) : null,
    filled: true, fillColor: Colors.white,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF1565C0), width: 1.5)),
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
  );
}

class _Sec extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;
  const _Sec(this.title, this.icon, this.children);
  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(12), blurRadius: 8, offset: const Offset(0, 2))]),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(children: [
            Container(padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: const Color(0xFF1565C0).withAlpha(20), borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, size: 18, color: const Color(0xFF1565C0))),
            const SizedBox(width: 10),
            Expanded(child: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0D47A1)))),
          ])),
      const Divider(height: 1),
      Padding(padding: const EdgeInsets.fromLTRB(12, 12, 12, 4), child: Column(children: children)),
    ]),
  );
}
