import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/benh_nhan.dart';
import '../services/firestore_service.dart';
import 'sua_benh_nhan_screen.dart';

class ChiTietBenhNhanScreen extends StatelessWidget {
  final String benhNhanId;
  const ChiTietBenhNhanScreen({super.key, required this.benhNhanId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<BenhNhan?>(
      stream: FirestoreService().streamBenhNhan(benhNhanId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasError || snapshot.data == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Chi tiết bệnh nhân')),
            body: const Center(child: Text('Không tìm thấy bệnh nhân.')),
          );
        }
        return _ChiTietView(benhNhan: snapshot.data!);
      },
    );
  }
}

class _ChiTietView extends StatelessWidget {
  final BenhNhan benhNhan;
  const _ChiTietView({required this.benhNhan});

  Color get _mauTrangThai {
    switch (benhNhan.trangThai) {
      case 'Đang khám':
        return Colors.orange.shade700;
      case 'Đã khám':
        return Colors.green.shade600;
      default:
        return Colors.blue.shade600;
    }
  }

  void _hienDialogXoa(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Row(children: [
          Icon(Icons.warning_amber_rounded, color: Colors.red),
          SizedBox(width: 8),
          Text('Xóa bệnh nhân', style: TextStyle(fontSize: 17)),
        ]),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('Bạn có chắc muốn xóa bệnh nhân này?'),
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
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(benhNhan.hoTen,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                if (benhNhan.ngaySinh != null)
                  Text('Ngày sinh: ${benhNhan.ngaySinh}', style: const TextStyle(fontSize: 13)),
                Text('STT: ${benhNhan.soThuTu ?? '-'}', style: const TextStyle(fontSize: 13)),
              ])),
            ]),
          ),
          const SizedBox(height: 8),
          const Text('Hành động này không thể hoàn tác.',
              style: TextStyle(fontSize: 12, color: Colors.red)),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Huỷ')),
          ElevatedButton.icon(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await FirestoreService().xoaBenhNhan(benhNhan.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Đã xóa bệnh nhân'),
                    backgroundColor: Colors.red,
                  ));
                  Navigator.pop(context);
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Lỗi: $e'), backgroundColor: Colors.red));
                }
              }
            },
            icon: const Icon(Icons.delete),
            label: const Text('Xóa'),
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, foregroundColor: Colors.white),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? dt) {
    if (dt == null) return '';
    return '${dt.day.toString().padLeft(2, '0')}/'
        '${dt.month.toString().padLeft(2, '0')}/'
        '${dt.year}  '
        '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final bn = benhNhan;
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      body: CustomScrollView(
        slivers: [
          // ── SliverAppBar ──────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 230,
            pinned: true,
            backgroundColor: const Color(0xFF1565C0),
            foregroundColor: Colors.white,
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                tooltip: 'Chỉnh sửa',
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SuaBenhNhanScreen(benhNhan: bn),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                tooltip: 'Xóa bệnh nhân',
                onPressed: () => _hienDialogXoa(context),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF1565C0), Color(0xFF0D47A1)],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 56, 20, 16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Avatar / STT
                        Container(
                          width: 76,
                          height: 76,
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(30),
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: Colors.white.withAlpha(100), width: 2),
                          ),
                          child: bn.soThuTu != null
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('${bn.soThuTu}',
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 26,
                                            fontWeight: FontWeight.bold)),
                                    const Text('STT',
                                        style: TextStyle(
                                            color: Colors.white70,
                                            fontSize: 10)),
                                  ],
                                )
                              : const Icon(Icons.person,
                                  color: Colors.white, size: 36),
                        ),
                        const SizedBox(width: 16),
                        // Tên + badges
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(bn.hoTen,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(height: 6),
                              Wrap(
                                spacing: 6,
                                runSpacing: 4,
                                children: [
                                  if (bn.gioiTinh != null)
                                    _Badge(
                                        label: bn.gioiTinh!,
                                        icon: bn.gioiTinh == 'Nam'
                                            ? Icons.male
                                            : Icons.female),
                                  if (bn.nhomMau != null)
                                    _Badge(
                                        label: 'Nhóm ${bn.nhomMau}',
                                        icon: Icons.bloodtype,
                                        color: Colors.red.shade200),
                                  if (bn.danToc != null)
                                    _Badge(
                                        label: bn.danToc!,
                                        icon: Icons.people_outline),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _mauTrangThai.withAlpha(200),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(bn.trangThai ?? 'Chờ khám',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Nội dung ──────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // 1. Thông tin cá nhân
                  _Section(title: 'Thông tin cá nhân', icon: Icons.person_outline, tiles: [
                    _Tile('Họ và tên', bn.hoTen, Icons.badge_outlined),
                    _Tile('Ngày sinh', bn.ngaySinh, Icons.cake_outlined),
                    _Tile('Giới tính', bn.gioiTinh, Icons.wc_outlined),
                    _Tile('Dân tộc', bn.danToc, Icons.people_outline),
                    _Tile('Nghề nghiệp', bn.ngheNghiep, Icons.work_outline),
                    _Tile('Số điện thoại', bn.soDienThoai, Icons.phone_outlined, copyable: true),
                    _Tile('CCCD / CMND', bn.cccd, Icons.credit_card_outlined, copyable: true),
                    _Tile('Bảo hiểm y tế', bn.baoHiemYTe, Icons.verified_user_outlined, copyable: true),
                  ]),
                  const SizedBox(height: 12),

                  // 2. Địa chỉ
                  _Section(title: 'Địa chỉ', icon: Icons.location_on_outlined, tiles: [
                    _Tile('Tỉnh / Thành phố', bn.tinh, Icons.map_outlined),
                    _Tile('Phường / Xã', bn.phuong, Icons.location_city_outlined),
                    _Tile('Phường mới HCM', bn.phuongMoiHCM, Icons.place_outlined),
                    _Tile('Địa chỉ', bn.diaChi, Icons.home_outlined),
                  ]),
                  const SizedBox(height: 12),

                  // 3. Thông tin y tế
                  _Section(title: 'Thông tin y tế', icon: Icons.medical_information_outlined, tiles: [
                    _Tile('Nhóm máu', bn.nhomMau, Icons.bloodtype_outlined),
                    _Tile('Bệnh nền', bn.benhNen, Icons.monitor_heart_outlined),
                    _Tile('Bệnh truyền nhiễm', bn.benhTruyenNhiem, Icons.coronavirus_outlined),
                    _Tile('Tình trạng tiêm chủng', bn.tinhTrangTiemChung, Icons.vaccines_outlined),
                    _Tile('Dị ứng (Có/Không)', bn.coKhong, Icons.warning_amber_outlined),
                  ]),
                  const SizedBox(height: 12),

                  // 4. Chẩn đoán & Điều trị
                  _Section(title: 'Chẩn đoán & Điều trị', icon: Icons.local_hospital_outlined, tiles: [
                    _Tile('Chẩn đoán bệnh', bn.chanDoanBenh, Icons.content_paste_search_outlined),
                    _Tile('Phân loại chẩn đoán', bn.phanLoaiChanDoan, Icons.category_outlined),
                    _Tile('Phân độ bệnh', bn.phanDoBenh, Icons.bar_chart_outlined),
                    _Tile('Điều trị', bn.dieuTri, Icons.medical_services_outlined),
                    _Tile('Hình thức điều trị', bn.hinhThucDieuTri, Icons.health_and_safety_outlined),
                  ]),
                  const SizedBox(height: 12),

                  // 5. Xét nghiệm
                  _Section(title: 'Xét nghiệm', icon: Icons.biotech_outlined, tiles: [
                    _Tile('Loại bệnh phẩm', bn.loaiBenhPham, Icons.science_outlined),
                    _Tile('Loại xét nghiệm', bn.loaiXetNghiem, Icons.manage_search_outlined),
                    _Tile('Kết quả xét nghiệm', bn.ketQuaXetNghiem, Icons.assignment_turned_in_outlined,
                        valueColor: bn.ketQuaXetNghiem == 'Dương tính'
                            ? Colors.red.shade700
                            : bn.ketQuaXetNghiem == 'Âm tính'
                                ? Colors.green.shade700
                                : null),
                  ]),
                  const SizedBox(height: 12),

                  // 6. Cơ sở & Đơn vị
                  _Section(title: 'Cơ sở & Đơn vị', icon: Icons.account_balance_outlined, tiles: [
                    _Tile('Cơ sở báo cáo', bn.coSoBaoCao, Icons.business_outlined),
                    _Tile('Đơn vị điều tra', bn.donViDieuTra, Icons.domain_outlined),
                    _Tile('Cơ sở điều trị', bn.coSoDieuTri, Icons.local_hospital_outlined),
                    _Tile('Phòng khám', bn.phongKham, Icons.door_front_door_outlined),
                  ]),
                  const SizedBox(height: 12),

                  // 7. Thông tin khám
                  _Section(title: 'Thông tin khám', icon: Icons.confirmation_number_outlined, tiles: [
                    _Tile('Số thứ tự', bn.soThuTu?.toString(), Icons.confirmation_number_outlined),
                    _Tile('Trạng thái', bn.trangThai, Icons.info_outline, valueColor: _mauTrangThai),
                    _Tile('Ngày đăng ký', _formatDate(bn.ngayDangKy), Icons.calendar_today_outlined),
                    _Tile('Cập nhật lần cuối', _formatDate(bn.ngayCapNhat), Icons.update_outlined),
                  ]),
                  const SizedBox(height: 28),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Widgets ─────────────────────────────────────────────────────────────────

class _Badge extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color? color;
  const _Badge({required this.label, required this.icon, this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color ?? Colors.white.withAlpha(50),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 12, color: Colors.white),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 11)),
      ]),
    );
  }
}

class _Tile {
  final String label;
  final String? value;
  final IconData icon;
  final bool copyable;
  final Color? valueColor;
  const _Tile(this.label, this.value, this.icon,
      {this.copyable = false, this.valueColor});
}

class _Section extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<_Tile> tiles;
  const _Section({required this.title, required this.icon, required this.tiles});

  @override
  Widget build(BuildContext context) {
    final visible = tiles.where((t) => t.value != null && t.value!.isNotEmpty).toList();
    if (visible.isEmpty) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(12), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(children: [
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
                    fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1565C0))),
          ]),
        ),
        const Divider(height: 1),
        ...visible.map((t) => _TileWidget(tile: t)),
      ]),
    );
  }
}

class _TileWidget extends StatelessWidget {
  final _Tile tile;
  const _TileWidget({required this.tile});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: tile.copyable
          ? () {
              Clipboard.setData(ClipboardData(text: tile.value!));
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('Đã copy ${tile.label}'),
                duration: const Duration(seconds: 1),
              ));
            }
          : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(tile.icon, size: 18, color: Colors.grey.shade400),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(tile.label,
                  style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w500)),
              const SizedBox(height: 2),
              Text(tile.value!,
                  style: TextStyle(
                      fontSize: 14,
                      color: tile.valueColor ?? const Color(0xFF1A237E),
                      fontWeight: FontWeight.w500)),
            ]),
          ),
          if (tile.copyable) Icon(Icons.copy, size: 14, color: Colors.grey.shade400),
        ]),
      ),
    );
  }
}

