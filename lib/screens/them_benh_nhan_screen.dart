import 'package:flutter/material.dart';
import '../models/benh_nhan.dart';
import '../models/category_options.dart';
import '../services/firestore_service.dart';

class ThemBenhNhanScreen extends StatefulWidget {
  const ThemBenhNhanScreen({super.key});

  @override
  State<ThemBenhNhanScreen> createState() => _ThemBenhNhanScreenState();
}

class _ThemBenhNhanScreenState extends State<ThemBenhNhanScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // trạng thái kiểm tra trùng lặp
  bool _dangKiemTra = false;
  List<BenhNhan> _danhSachTrungTenNSinh = []; // trùng tên+ngày sinh
  bool _cccdBatBuoc = false;                  // true khi phát hiện trùng tên+nsinh
  String? _loiCCCD;                           // lỗi CCCD đã tồn tại

  // ── Controllers ────────────────────────────────────────────────────────
  final _hoTenCtrl = TextEditingController();
  final _ngaySinhCtrl = TextEditingController();
  final _soDienThoaiCtrl = TextEditingController();
  final _cccdCtrl = TextEditingController();
  final _baoHiemYTeCtrl = TextEditingController();
  final _diaChiCtrl = TextEditingController();
  final _phongKhamCtrl = TextEditingController();
  final _coSoBaoCaoCtrl = TextEditingController();
  final _donViDieuTraCtrl = TextEditingController();
  final _coSoDieuTriCtrl = TextEditingController();

  // ── Dropdown values ────────────────────────────────────────────────────
  String? _gioiTinh;
  String? _danToc;
  String? _ngheNghiep;
  String? _nhomMau;
  String? _tinh;
  String? _phuong;
  String? _benhNen;
  String? _benhTruyenNhiem;
  String? _tinhTrangTiemChung;
  String? _coKhong;
  String? _dieuTri;
  String? _hinhThucDieuTri;
  String? _chanDoanBenh;
  String? _phanLoaiChanDoan;
  String? _phanDoBenh;
  String? _loaiBenhPham;
  String? _loaiXetNghiem;
  String? _ketQuaXetNghiem;
  String? _trangThai = 'Chờ';

  @override
  void dispose() {
    _hoTenCtrl.dispose();
    _ngaySinhCtrl.dispose();
    _soDienThoaiCtrl.dispose();
    _cccdCtrl.dispose();
    _baoHiemYTeCtrl.dispose();
    _diaChiCtrl.dispose();
    _phongKhamCtrl.dispose();
    _coSoBaoCaoCtrl.dispose();
    _donViDieuTraCtrl.dispose();
    _coSoDieuTriCtrl.dispose();
    super.dispose();
  }

  Future<void> _chonNgaySinh() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 30),
      firstDate: DateTime(1900),
      lastDate: now,
      locale: const Locale('vi', 'VN'),
    );
    if (picked != null) {
      _ngaySinhCtrl.text =
          '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
      // Sau khi chọn ngày sinh, kiểm tra trùng ngay nếu đã có tên
      if (_hoTenCtrl.text.trim().isNotEmpty) {
        await _kiemTraTrungTenNgaySinh();
      }
    }
  }

  /// Kiểm tra trùng tên + ngày sinh — gọi khi rời field hoTen hoặc ngaySinh
  Future<void> _kiemTraTrungTenNgaySinh() async {
    final ten = _hoTenCtrl.text.trim();
    final dob = _ngaySinhCtrl.text.trim();
    if (ten.isEmpty || dob.isEmpty) return;

    setState(() => _dangKiemTra = true);
    try {
      final ket = await FirestoreService().kiemTraTrungLap(
        hoTen: ten,
        ngaySinh: dob,
        cccd: '', // chỉ kiểm tra tên+ngày sinh ở bước này
      );
      final ds = ket['trungTenNSinh'] ?? [];
      setState(() {
        _danhSachTrungTenNSinh = ds;
        _cccdBatBuoc = ds.isNotEmpty;
      });
    } finally {
      setState(() => _dangKiemTra = false);
    }
  }

  /// Kiểm tra CCCD có trùng không — gọi khi rời field CCCD
  Future<void> _kiemTraCCCD() async {
    final cccd = _cccdCtrl.text.trim();
    if (cccd.isEmpty) {
      setState(() => _loiCCCD = null);
      return;
    }
    setState(() => _dangKiemTra = true);
    try {
      final ket = await FirestoreService().kiemTraTrungLap(
        hoTen: '',
        ngaySinh: '',
        cccd: cccd,
      );
      final trung = ket['trungCCCD'] ?? [];
      setState(() {
        _loiCCCD = trung.isNotEmpty
            ? 'CCCD này đã tồn tại: ${trung.first.hoTen}'
            : null;
      });
    } finally {
      setState(() => _dangKiemTra = false);
    }
  }

  Future<void> _luu() async {
    if (!_formKey.currentState!.validate()) return;

    // Chặn nếu CCCD đã tồn tại
    if (_loiCCCD != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(_loiCCCD!),
        backgroundColor: Colors.red.shade600,
      ));
      return;
    }

    // Nếu trùng tên+ngày sinh mà chưa nhập CCCD → bắt buộc
    if (_cccdBatBuoc && _cccdCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Row(children: [
          Icon(Icons.warning_amber, color: Colors.white),
          SizedBox(width: 8),
          Expanded(
              child: Text(
                  'Phát hiện trùng tên + ngày sinh — vui lòng nhập CCCD để phân biệt')),
        ]),
        backgroundColor: Colors.orange.shade700,
        duration: const Duration(seconds: 4),
      ));
      return;
    }

    // Kiểm tra lần cuối trước khi lưu
    setState(() => _isLoading = true);
    try {
      final ket = await FirestoreService().kiemTraTrungLap(
        hoTen: _hoTenCtrl.text.trim(),
        ngaySinh: _ngaySinhCtrl.text.trim(),
        cccd: _cccdCtrl.text.trim(),
      );

      final trungCCCD = ket['trungCCCD'] ?? [];
      if (trungCCCD.isNotEmpty) {
        if (mounted) {
          setState(() => _isLoading = false);
          _hienDialogTrungCCCD(trungCCCD.first);
        }
        return;
      }

      final trungTen = ket['trungTenNSinh'] ?? [];
      // Nếu tên+ngày sinh trùng nhưng CCCD khác → hỏi xác nhận
      if (trungTen.isNotEmpty && _cccdCtrl.text.trim().isNotEmpty) {
        final xacNhan = await _hienDialogXacNhan(trungTen.first);
        if (!xacNhan) {
          setState(() => _isLoading = false);
          return;
        }
      }

      // Lưu bệnh nhân
      final benhNhan = BenhNhan(
        id: '',
        hoTen: _hoTenCtrl.text.trim(),
        ngaySinh: _ngaySinhCtrl.text.isNotEmpty ? _ngaySinhCtrl.text : null,
        gioiTinh: _gioiTinh,
        danToc: _danToc,
        ngheNghiep: _ngheNghiep,
        soDienThoai:
            _soDienThoaiCtrl.text.isNotEmpty ? _soDienThoaiCtrl.text : null,
        cccd: _cccdCtrl.text.isNotEmpty ? _cccdCtrl.text : null,
        baoHiemYTe:
            _baoHiemYTeCtrl.text.isNotEmpty ? _baoHiemYTeCtrl.text : null,
        diaChi: _diaChiCtrl.text.isNotEmpty ? _diaChiCtrl.text : null,
        tinh: _tinh,
        phuong: _phuong,
        nhomMau: _nhomMau,
        benhNen: _benhNen,
        benhTruyenNhiem: _benhTruyenNhiem,
        tinhTrangTiemChung: _tinhTrangTiemChung,
        coKhong: _coKhong,
        dieuTri: _dieuTri,
        hinhThucDieuTri: _hinhThucDieuTri,
        chanDoanBenh: _chanDoanBenh,
        phanLoaiChanDoan: _phanLoaiChanDoan,
        phanDoBenh: _phanDoBenh,
        loaiBenhPham: _loaiBenhPham,
        loaiXetNghiem: _loaiXetNghiem,
        ketQuaXetNghiem: _ketQuaXetNghiem,
        coSoBaoCao:
            _coSoBaoCaoCtrl.text.isNotEmpty ? _coSoBaoCaoCtrl.text : null,
        donViDieuTra:
            _donViDieuTraCtrl.text.isNotEmpty ? _donViDieuTraCtrl.text : null,
        coSoDieuTri:
            _coSoDieuTriCtrl.text.isNotEmpty ? _coSoDieuTriCtrl.text : null,
        phongKham:
            _phongKhamCtrl.text.isNotEmpty ? _phongKhamCtrl.text : null,
        trangThai: _trangThai,
      );

      await FirestoreService().themBenhNhan(benhNhan);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Row(children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Text('Đã thêm bệnh nhân thành công'),
          ]),
          backgroundColor: Colors.green.shade600,
          duration: const Duration(seconds: 3),
        ));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Lỗi: $e'),
          backgroundColor: Colors.red.shade600,
        ));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Dialog: CCCD đã tồn tại → không cho lưu
  void _hienDialogTrungCCCD(BenhNhan existing) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Row(children: [
          Icon(Icons.error_outline, color: Colors.red),
          SizedBox(width: 8),
          Text('CCCD đã tồn tại', style: TextStyle(fontSize: 16)),
        ]),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('Số CCCD này đã được đăng ký cho bệnh nhân:',
              style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Row(children: [
              const Icon(Icons.person, color: Colors.red),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(existing.hoTen,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15)),
                      if (existing.ngaySinh != null)
                        Text('Ngày sinh: ${existing.ngaySinh}',
                            style: const TextStyle(fontSize: 13)),
                      Text('STT: ${existing.soThuTu ?? '-'}',
                          style: const TextStyle(fontSize: 13)),
                    ]),
              ),
            ]),
          ),
          const SizedBox(height: 8),
          const Text('Vui lòng kiểm tra lại số CCCD.',
              style: TextStyle(fontSize: 13)),
        ]),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  // Dialog: trùng tên+ngày sinh nhưng CCCD khác → xác nhận
  Future<bool> _hienDialogXacNhan(BenhNhan existing) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Row(children: [
          Icon(Icons.warning_amber_outlined, color: Colors.orange),
          SizedBox(width: 8),
          Text('Trùng tên & ngày sinh', style: TextStyle(fontSize: 16)),
        ]),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('Đã tìm thấy bệnh nhân có cùng họ tên và ngày sinh:',
              style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Row(children: [
              Icon(Icons.person, color: Colors.orange.shade700),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(existing.hoTen,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15)),
                      if (existing.ngaySinh != null)
                        Text('Ngày sinh: ${existing.ngaySinh}',
                            style: const TextStyle(fontSize: 13)),
                      Text(
                          'CCCD: ${existing.cccd ?? '(chưa có)'}',
                          style: const TextStyle(fontSize: 13)),
                    ]),
              ),
            ]),
          ),
          const SizedBox(height: 10),
          const Text(
              'CCCD khác nhau nên đây là 2 người khác nhau.\nXác nhận thêm bệnh nhân mới?',
              style: TextStyle(fontSize: 13)),
        ]),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Huỷ', style: TextStyle(color: Colors.grey.shade600)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1565C0),
                foregroundColor: Colors.white),
            child: const Text('Xác nhận thêm'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        title: const Row(
          children: [
            Icon(Icons.person_add, size: 22),
            SizedBox(width: 8),
            Text('Thêm bệnh nhân',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2)),
            )
          else
            TextButton.icon(
              onPressed: _luu,
              icon: const Icon(Icons.save, color: Colors.white, size: 20),
              label: const Text('Lưu',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ── 1. Thông tin cá nhân ──────────────────────────────────
            _FormSection(
              title: 'Thông tin cá nhân',
              icon: Icons.person_outline,
              children: [
                _buildTextField(
                  controller: _hoTenCtrl,
                  label: 'Họ và tên *',
                  icon: Icons.badge_outlined,
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Vui lòng nhập họ tên' : null,
                  onEditingComplete: _kiemTraTrungTenNgaySinh,
                ),
                _buildTextField(
                  controller: _ngaySinhCtrl,
                  label: 'Ngày sinh',
                  icon: Icons.cake_outlined,
                  readOnly: true,
                  onTap: _chonNgaySinh,
                  suffixIcon: Icons.calendar_today,
                ),

                // ── Banner cảnh báo trùng tên+ngày sinh ──
                if (_dangKiemTra)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(children: [
                      const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2)),
                      const SizedBox(width: 8),
                      Text('Đang kiểm tra trùng lặp...',
                          style: TextStyle(
                              fontSize: 13, color: Colors.grey.shade600)),
                    ]),
                  ),

                if (!_dangKiemTra && _danhSachTrungTenNSinh.isNotEmpty)
                  _BannerCanhBao(
                    danhSach: _danhSachTrungTenNSinh,
                    cccdBatBuoc: _cccdBatBuoc,
                  ),

                _buildDropdown(
                  label: 'Giới tính',
                  icon: Icons.wc_outlined,
                  value: _gioiTinh,
                  items: CategoryOptions.gioiTinh,
                  onChanged: (v) => setState(() => _gioiTinh = v),
                ),
                _buildDropdown(
                  label: 'Dân tộc',
                  icon: Icons.people_outline,
                  value: _danToc,
                  items: CategoryOptions.danToc,
                  onChanged: (v) => setState(() => _danToc = v),
                ),
                _buildDropdown(
                  label: 'Nghề nghiệp',
                  icon: Icons.work_outline,
                  value: _ngheNghiep,
                  items: CategoryOptions.ngheNghiep,
                  onChanged: (v) => setState(() => _ngheNghiep = v),
                ),
                _buildTextField(
                  controller: _soDienThoaiCtrl,
                  label: 'Số điện thoại',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                ),
                // ── CCCD — bắt buộc nếu trùng tên+ngày sinh ──
                _buildTextField(
                  controller: _cccdCtrl,
                  label: _cccdBatBuoc ? 'CCCD / CMND *  (bắt buộc để phân biệt)' : 'CCCD / CMND',
                  icon: Icons.credit_card_outlined,
                  keyboardType: TextInputType.number,
                  labelColor: _cccdBatBuoc ? Colors.orange.shade700 : null,
                  errorText: _loiCCCD,
                  validator: (v) {
                    if (_cccdBatBuoc && (v == null || v.trim().isEmpty)) {
                      return 'Vui lòng nhập CCCD để phân biệt bệnh nhân trùng tên';
                    }
                    return null;
                  },
                  onEditingComplete: _kiemTraCCCD,
                ),
                _buildTextField(
                  controller: _baoHiemYTeCtrl,
                  label: 'Bảo hiểm y tế',
                  icon: Icons.verified_user_outlined,
                ),
              ],
            ),
            const SizedBox(height: 12),

            // ── 2. Địa chỉ ───────────────────────────────────────────
            _FormSection(
              title: 'Địa chỉ',
              icon: Icons.location_on_outlined,
              children: [
                _buildDropdown(
                  label: 'Tỉnh / Thành phố',
                  icon: Icons.map_outlined,
                  value: _tinh,
                  items: CategoryOptions.tinh,
                  onChanged: (v) => setState(() => _tinh = v),
                ),
                _buildTextField(
                  controller: _diaChiCtrl,
                  label: 'Địa chỉ chi tiết',
                  icon: Icons.home_outlined,
                  maxLines: 2,
                ),
              ],
            ),
            const SizedBox(height: 12),

            // ── 3. Thông tin y tế ─────────────────────────────────────
            _FormSection(
              title: 'Thông tin y tế',
              icon: Icons.medical_information_outlined,
              children: [
                _buildDropdown(
                  label: 'Nhóm máu',
                  icon: Icons.bloodtype_outlined,
                  value: _nhomMau,
                  items: CategoryOptions.nhomMau,
                  onChanged: (v) => setState(() => _nhomMau = v),
                ),
                _buildDropdown(
                  label: 'Bệnh nền',
                  icon: Icons.monitor_heart_outlined,
                  value: _benhNen,
                  items: CategoryOptions.benhNen,
                  onChanged: (v) => setState(() => _benhNen = v),
                ),
                _buildDropdown(
                  label: 'Bệnh truyền nhiễm',
                  icon: Icons.coronavirus_outlined,
                  value: _benhTruyenNhiem,
                  items: CategoryOptions.benhTruyenNhiem,
                  onChanged: (v) => setState(() => _benhTruyenNhiem = v),
                ),
                _buildDropdown(
                  label: 'Tình trạng tiêm chủng',
                  icon: Icons.vaccines_outlined,
                  value: _tinhTrangTiemChung,
                  items: CategoryOptions.tinhTrangTiemChung,
                  onChanged: (v) => setState(() => _tinhTrangTiemChung = v),
                ),
                _buildDropdown(
                  label: 'Dị ứng (Có / Không)',
                  icon: Icons.warning_amber_outlined,
                  value: _coKhong,
                  items: CategoryOptions.coKhong,
                  onChanged: (v) => setState(() => _coKhong = v),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // ── 4. Chẩn đoán & Điều trị ───────────────────────────────
            _FormSection(
              title: 'Chẩn đoán & Điều trị',
              icon: Icons.local_hospital_outlined,
              children: [
                _buildDropdown(
                  label: 'Chẩn đoán bệnh',
                  icon: Icons.content_paste_search_outlined,
                  value: _chanDoanBenh,
                  items: CategoryOptions.benhTruyenNhiem,
                  onChanged: (v) => setState(() => _chanDoanBenh = v),
                ),
                _buildDropdown(
                  label: 'Phân loại chẩn đoán',
                  icon: Icons.category_outlined,
                  value: _phanLoaiChanDoan,
                  items: CategoryOptions.phanLoaiChanDoan,
                  onChanged: (v) => setState(() => _phanLoaiChanDoan = v),
                ),
                _buildDropdown(
                  label: 'Phân độ bệnh',
                  icon: Icons.bar_chart_outlined,
                  value: _phanDoBenh,
                  items: CategoryOptions.phanDoBenh,
                  onChanged: (v) => setState(() => _phanDoBenh = v),
                ),
                _buildDropdown(
                  label: 'Điều trị',
                  icon: Icons.medical_services_outlined,
                  value: _dieuTri,
                  items: CategoryOptions.dieuTri,
                  onChanged: (v) => setState(() => _dieuTri = v),
                ),
                _buildDropdown(
                  label: 'Hình thức điều trị',
                  icon: Icons.health_and_safety_outlined,
                  value: _hinhThucDieuTri,
                  items: CategoryOptions.hinhThucDieuTri,
                  onChanged: (v) => setState(() => _hinhThucDieuTri = v),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // ── 5. Xét nghiệm ─────────────────────────────────────────
            _FormSection(
              title: 'Xét nghiệm',
              icon: Icons.biotech_outlined,
              children: [
                _buildDropdown(
                  label: 'Loại bệnh phẩm',
                  icon: Icons.science_outlined,
                  value: _loaiBenhPham,
                  items: CategoryOptions.loaiBenhPham,
                  onChanged: (v) => setState(() => _loaiBenhPham = v),
                ),
                _buildDropdown(
                  label: 'Loại xét nghiệm',
                  icon: Icons.manage_search_outlined,
                  value: _loaiXetNghiem,
                  items: CategoryOptions.loaiXetNghiem,
                  onChanged: (v) => setState(() => _loaiXetNghiem = v),
                ),
                _buildDropdown(
                  label: 'Kết quả xét nghiệm',
                  icon: Icons.assignment_turned_in_outlined,
                  value: _ketQuaXetNghiem,
                  items: CategoryOptions.ketQuaXetNghiem,
                  onChanged: (v) => setState(() => _ketQuaXetNghiem = v),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // ── 6. Cơ sở & Đơn vị ────────────────────────────────────
            _FormSection(
              title: 'Cơ sở & Đơn vị',
              icon: Icons.account_balance_outlined,
              children: [
                _buildTextField(
                  controller: _coSoBaoCaoCtrl,
                  label: 'Cơ sở báo cáo',
                  icon: Icons.business_outlined,
                ),
                _buildTextField(
                  controller: _donViDieuTraCtrl,
                  label: 'Đơn vị điều tra',
                  icon: Icons.domain_outlined,
                ),
                _buildTextField(
                  controller: _coSoDieuTriCtrl,
                  label: 'Cơ sở điều trị',
                  icon: Icons.local_hospital_outlined,
                ),
                _buildTextField(
                  controller: _phongKhamCtrl,
                  label: 'Phòng khám',
                  icon: Icons.door_front_door_outlined,
                ),
              ],
            ),
            const SizedBox(height: 12),

            // ── 7. Trạng thái ─────────────────────────────────────────
            _FormSection(
              title: 'Trạng thái khám',
              icon: Icons.info_outline,
              children: [
                _buildDropdown(
                  label: 'Trạng thái',
                  icon: Icons.pending_actions_outlined,
                  value: _trangThai,
                  items: CategoryOptions.trangThai,
                  onChanged: (v) => setState(() => _trangThai = v),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // ── Nút Lưu ───────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _luu,
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.save),
                label: Text(_isLoading ? 'Đang lưu...' : 'Lưu bệnh nhân',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1565C0),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // ── Builder helpers ─────────────────────────────────────────────────────

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    bool readOnly = false,
    VoidCallback? onTap,
    VoidCallback? onEditingComplete,
    IconData? suffixIcon,
    int maxLines = 1,
    Color? labelColor,
    String? errorText,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        readOnly: readOnly,
        onTap: onTap,
        maxLines: maxLines,
        validator: validator,
        onEditingComplete: onEditingComplete,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: labelColor ?? Colors.grey.shade600,
            fontWeight:
                labelColor != null ? FontWeight.bold : FontWeight.normal,
          ),
          errorText: errorText,
          prefixIcon: Icon(icon, size: 20, color: labelColor ?? Colors.grey.shade500),
          suffixIcon: suffixIcon != null
              ? Icon(suffixIcon, size: 18, color: Colors.grey.shade400)
              : null,
          filled: true,
          fillColor: errorText != null
              ? Colors.red.shade50
              : (labelColor != null ? Colors.orange.shade50 : Colors.white),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
                color: errorText != null
                    ? Colors.red.shade300
                    : labelColor != null
                        ? Colors.orange.shade300
                        : Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
                color: errorText != null
                    ? Colors.red
                    : labelColor ?? const Color(0xFF1565C0),
                width: 1.5),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required IconData icon,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        initialValue: value,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, size: 20, color: Colors.grey.shade500),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide:
                const BorderSide(color: Color(0xFF1565C0), width: 1.5),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        ),
        isExpanded: true,
        hint: Text('Chọn $label',
            style: TextStyle(color: Colors.grey.shade400, fontSize: 14)),
        items: items
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }
}

// ── Section widget ──────────────────────────────────────────────────────────
class _FormSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _FormSection({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(12),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1565C0).withAlpha(20),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 18, color: const Color(0xFF1565C0)),
                ),
                const SizedBox(width: 10),
                Text(title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1565C0),
                    )),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }
}

// ── Banner cảnh báo trùng tên + ngày sinh ───────────────────────────────────
class _BannerCanhBao extends StatelessWidget {
  final List<BenhNhan> danhSach;
  final bool cccdBatBuoc;
  const _BannerCanhBao({required this.danhSach, required this.cccdBatBuoc});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.orange.shade300, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(Icons.warning_amber_rounded,
                color: Colors.orange.shade700, size: 18),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                'Phát hiện ${danhSach.length} bệnh nhân trùng tên & ngày sinh',
                style: TextStyle(
                    color: Colors.orange.shade800,
                    fontWeight: FontWeight.bold,
                    fontSize: 13),
              ),
            ),
          ]),
          const SizedBox(height: 8),
          ...danhSach.map((bn) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(children: [
                  const SizedBox(width: 24),
                  Icon(Icons.person_outline,
                      size: 14, color: Colors.orange.shade700),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '${bn.hoTen}  •  STT ${bn.soThuTu ?? '-'}'
                      '${bn.cccd != null ? '  •  CCCD: ${bn.cccd}' : ''}',
                      style: TextStyle(
                          fontSize: 12, color: Colors.orange.shade900),
                    ),
                  ),
                ]),
              )),
          const SizedBox(height: 6),
          Text(
            cccdBatBuoc
                ? '⚠️  Vui lòng nhập CCCD để xác định đây là người khác.'
                : 'Nhập CCCD để phân biệt nếu đây là người khác.',
            style: TextStyle(
                fontSize: 12,
                color: Colors.orange.shade800,
                fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }
}
