import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/benh_truyen_nhiem.dart';
import '../../services/benh_truyen_nhiem_service.dart';
import 'sua_btn_screen.dart';

class ChiTietBTNScreen extends StatelessWidget {
  final String btnId;
  const ChiTietBTNScreen({super.key, required this.btnId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<BenhTruyenNhiem?>(
      stream: BenhTruyenNhiemService().streamChiTiet(btnId),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (snap.data == null) {
          return Scaffold(appBar: AppBar(title: const Text('Chi tiết')),
              body: const Center(child: Text('Không tìm thấy.')));
        }
        return _ChiTietView(b: snap.data!);
      },
    );
  }
}

class _ChiTietView extends StatelessWidget {
  final BenhTruyenNhiem b;
  const _ChiTietView({required this.b});

  Color get _mauKQ {
    switch (b.ketQuaXN) {
      case 'Dương tính': return Colors.red.shade600;
      case 'Âm tính':   return Colors.green.shade600;
      default:           return Colors.grey.shade500;
    }
  }

  void _hienDialogXoa(BuildContext context, BenhTruyenNhiem benhAn) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Row(children: [
          Icon(Icons.warning_amber_rounded, color: Colors.red),
          SizedBox(width: 8),
          Text('Xóa bệnh án', style: TextStyle(fontSize: 17)),
        ]),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('Bạn có chắc muốn xóa bệnh án này không?'),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.red.shade200)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              if (benhAn.benhAnId != null)
                Text(benhAn.benhAnId!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF2E7D32))),
              Text(benhAn.hoTen, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              if (benhAn.chanDoanBenh != null)
                Text(benhAn.chanDoanBenh!, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
            ]),
          ),
          const SizedBox(height: 8),
          const Text('Hành động này không thể hoàn tác.', style: TextStyle(fontSize: 12, color: Colors.red)),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Huỷ')),
          ElevatedButton.icon(
            onPressed: () async {
              Navigator.pop(context); // đóng dialog
              try {
                await BenhTruyenNhiemService().xoa(benhAn.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Đã xóa bệnh án'),
                    backgroundColor: Colors.red,
                  ));
                  Navigator.pop(context); // quay về danh sách
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red));
                }
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
      body: CustomScrollView(slivers: [
        // ── AppBar ──
        SliverAppBar(
          expandedHeight: 210,
          pinned: true,
          backgroundColor: const Color(0xFF2E7D32),
          foregroundColor: Colors.white,
          actions: [
            // Nút sửa
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Chỉnh sửa',
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => SuaBTNScreen(benhAn: b)),
              ),
            ),
            // Nút xóa
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Xóa bệnh án',
              onPressed: () => _hienDialogXoa(context, b),
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF2E7D32), Color(0xFF1B5E20)],
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 56, 20, 16),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    Container(
                      width: 72, height: 72,
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(30), shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withAlpha(80), width: 2),
                      ),
                      child: const Icon(Icons.coronavirus, color: Colors.white, size: 34),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end, children: [
                        Text(b.hoTen, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        if (b.chanDoanBenh != null)
                          Text(b.chanDoanBenh!, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                        const SizedBox(height: 4),
                        if (b.ketQuaXN != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(color: _mauKQ.withAlpha(200), borderRadius: BorderRadius.circular(8)),
                            child: Text(b.ketQuaXN!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                          ),
                      ]),
                    ),
                  ]),
                ),
              ),
            ),
          ),
        ),

        // ── Nội dung ──
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: [

              _Section('Thông tin cá nhân', Icons.person_outline, [
                _T('1. Bệnh án ID', b.benhAnId, Icons.link),
                _T('2. Họ và tên', b.hoTen, Icons.badge_outlined),
                _T('3. Ngày sinh', b.ngaySinh, Icons.cake_outlined),
                _T('4. Giới tính', b.gioiTinh, Icons.wc_outlined),
                _T('5. Dân tộc', b.danTocId, Icons.people_outline),
                _T('6. Mã định danh', b.maDinhDanhCaNhan, Icons.credit_card_outlined, copy: true),
                _T('7. Tên người bảo hộ', b.tenNguoiBaoHo, Icons.family_restroom_outlined),
                _T('8. Số điện thoại', b.sdt, Icons.phone_outlined, copy: true),
                _T('9. Có thai', b.coThai, Icons.pregnant_woman_outlined),
                _T('10. Tuần thai', b.tuanThai?.toString(), Icons.access_time_outlined),
                _T('11. Nghề nghiệp', b.ngheNghiep, Icons.work_outline),
                _T('12. Nơi làm việc/học', b.noiLamViecHoc, Icons.business_outlined),
                _T('13. Địa chỉ nơi làm/học', b.diaChinoiLamViecHoc, Icons.location_on_outlined),
                _T('14. Tỉnh nơi làm/học', b.cityIdHoc, Icons.map_outlined),
                _T('15. Phường xã nơi làm/học', b.wardIdHoc, Icons.place_outlined),
              ]),
              const SizedBox(height: 12),

              _Section('Địa chỉ hiện tại', Icons.home_outlined, [
                _T('16. Nơi ở hiện nay', b.noiOHienNay, Icons.home_outlined),
                _T('17. Tỉnh nơi ở hiện nay', b.cityId, Icons.map_outlined),
                _T('18. Phường xã nơi ở', b.wardId, Icons.place_outlined),
                _T('19. Khu phố/ấp', b.khuPhoAp, Icons.location_city_outlined),
                _T('20. Số HSBA', b.soHSBA, Icons.folder_outlined, copy: true),
              ]),
              const SizedBox(height: 12),

              _Section('Điều trị & Chẩn đoán', Icons.local_hospital_outlined, [
                _T('21. Cơ sở điều trị', b.coSoDieuTri, Icons.local_hospital_outlined),
                _T('22. Tỉnh cơ sở điều trị', b.cityIdCSDT, Icons.map_outlined),
                _T('23. Hình thức điều trị', b.hinhThucDieuTri, Icons.health_and_safety_outlined),
                _T('24. Chẩn đoán bệnh', b.chanDoanBenh, Icons.content_paste_search_outlined),
                _T('25. Phân độ bệnh', b.phanDoBenh, Icons.bar_chart_outlined),
                _T('26. Thông tin điều trị', b.thongTinDieuTri, Icons.medical_services_outlined),
                _T('27. Chẩn đoán biến chứng', b.chanDoanBienChung, Icons.warning_amber_outlined),
                _T('28. Chẩn đoán bệnh kèm theo', b.chanDoanBenhKemTheo, Icons.add_circle_outline),
                _T('29. Bệnh nền kèm theo', b.benhNenKemTheoId, Icons.monitor_heart_outlined),
                _T('30. Ngày khởi phát', b.ngayKhoiPhat, Icons.today_outlined),
                _T('31. Ngày nhập viện', b.ngayNhapVien, Icons.login_outlined),
                _T('32. Ngày XV/TV/CV', b.ngayXVTVCV, Icons.logout_outlined),
                _T('33. Phân loại chẩn đoán', b.phanLoaiChanDoan, Icons.category_outlined),
                _T('51. Phân độ bệnh (text)', b.phanDoBenhText, Icons.text_fields_outlined),
              ]),
              const SizedBox(height: 12),

              _Section('Xét nghiệm', Icons.biotech_outlined, [
                _T('34. Lấy mẫu XN', b.layMauXN, Icons.science_outlined),
                _T('35. Loại bệnh phẩm', b.loaiBenhPham, Icons.water_drop_outlined),
                _T('36. Đơn vị thực hiện XN', b.donViThucHienXN, Icons.domain_outlined),
                _T('37. Ngày lấy mẫu', b.ngayLayMau, Icons.calendar_today_outlined),
                _T('38. Loại xét nghiệm', b.loaiXN, Icons.manage_search_outlined),
                _T('39. Kết quả XN', b.ketQuaXN, Icons.assignment_turned_in_outlined,
                    valueColor: b.ketQuaXN == 'Dương tính' ? Colors.red.shade700 : b.ketQuaXN == 'Âm tính' ? Colors.green.shade700 : null),
              ]),
              const SizedBox(height: 12),

              _Section('Tiêm chủng', Icons.vaccines_outlined, [
                _T('40. Tình trạng tiêm', b.tinhTrangTiem, Icons.vaccines_outlined),
                _T('41. Số mũi tiêm/uống', b.soMuiTiemUong?.toString(), Icons.format_list_numbered_outlined),
              ]),
              const SizedBox(height: 12),

              _Section('Dịch tễ', Icons.travel_explore_outlined, [
                _T('42. Tiền sử dịch tễ', b.tienSuDichTe, Icons.history_outlined),
                _T('43. Người điều tra dịch tễ', b.nguoiDieuTraDichTe, Icons.person_search_outlined),
                _T('44. SĐT người điều tra DT', b.sdtNguoiDieuTraDTe, Icons.phone_outlined, copy: true),
                _T('45. Đơn vị điều tra', b.donViDieuTra, Icons.account_balance_outlined),
                _T('46. Email đơn vị điều tra', b.emailDonViDieuTra, Icons.email_outlined),
              ]),
              const SizedBox(height: 12),

              _Section('Báo cáo', Icons.summarize_outlined, [
                _T('47. Ngày báo cáo', b.ngayBaoCao, Icons.calendar_today_outlined),
                _T('48. Người báo cáo', b.nguoiBaoCao, Icons.person_outlined),
                _T('49. SĐT người báo cáo', b.sdtNguoiBaoCao, Icons.phone_outlined, copy: true),
                _T('50. Email người báo cáo', b.emailNguoiBaoCao, Icons.email_outlined),
              ]),
              const SizedBox(height: 28),
            ]),
          ),
        ),
      ]),
    );
  }
}

// ── Helpers ─────────────────────────────────────────────────────────────────

class _T {
  final String label;
  final String? value;
  final IconData icon;
  final bool copy;
  final Color? valueColor;
  const _T(this.label, this.value, this.icon, {this.copy = false, this.valueColor});
}

class _Section extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<_T> tiles;
  const _Section(this.title, this.icon, this.tiles);

  @override
  Widget build(BuildContext context) {
    final visible = tiles.where((t) => t.value != null && t.value!.isNotEmpty).toList();
    if (visible.isEmpty) return const SizedBox.shrink();
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
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
            Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20))),
          ]),
        ),
        const Divider(height: 1),
        ...visible.map((t) => _TileW(t: t)),
      ]),
    );
  }
}

class _TileW extends StatelessWidget {
  final _T t;
  const _TileW({required this.t});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: t.copy ? () {
        Clipboard.setData(ClipboardData(text: t.value!));
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Đã copy ${t.label}'), duration: const Duration(seconds: 1)));
      } : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(t.icon, size: 17, color: Colors.grey.shade400),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(t.label, style: TextStyle(fontSize: 11, color: Colors.grey.shade500, fontWeight: FontWeight.w500)),
            const SizedBox(height: 2),
            Text(t.value!, style: TextStyle(fontSize: 14, color: t.valueColor ?? const Color(0xFF1B5E20), fontWeight: FontWeight.w500)),
          ])),
          if (t.copy) Icon(Icons.copy, size: 14, color: Colors.grey.shade400),
        ]),
      ),
    );
  }
}

