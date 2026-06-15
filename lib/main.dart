import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'services/auth_service.dart';
import 'screens/dang_nhap_screen.dart';
import 'screens/danh_sach_benh_nhan_screen.dart';
import 'screens/benh_truyen_nhiem/danh_sach_btn_screen.dart';
import 'screens/quan_ly_tai_khoan_screen.dart';
import 'screens/day_du_lieu_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Khởi tạo tài khoản admin mặc định nếu chưa có
  await AuthService().khoiTao();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quản lý Bệnh viện',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1565C0)),
        useMaterial3: true,
      ),
      // Bắt đầu từ màn hình đăng nhập
      initialRoute: '/login',
      routes: {
        '/login': (_) => const DangNhapScreen(),
        '/home':  (_) => const HomeScreen(),
      },
    );
  }
}

// ── Màn hình chính sau đăng nhập ─────────────────────────────────────────────
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tab = 0;

  final _screens = const [
    DanhSachBenhNhanScreen(),
    DanhSachBTNScreen(),
    DayDuLieuScreen(),
    QuanLyTaiKhoanScreen(),
  ];

  void _dangXuat() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Row(children: [
          Icon(Icons.logout, color: Color(0xFF1565C0)),
          SizedBox(width: 8),
          Text('Đăng xuất', style: TextStyle(fontSize: 17)),
        ]),
        content: const Text('Bạn có muốn đăng xuất không?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Huỷ')),
          ElevatedButton(
            onPressed: () {
              AuthService().dangXuat();
              Navigator.pushReplacementNamed(context, '/login');
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1565C0), foregroundColor: Colors.white),
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _tab, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) {
          if (i == 4) {
            _dangXuat();
          } else {
            setState(() => _tab = i);
          }
        },
        backgroundColor: Colors.white,
        indicatorColor: const Color(0xFF1565C0).withAlpha(30),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people, color: Color(0xFF1565C0)),
            label: 'Bệnh nhân',
          ),
          NavigationDestination(
            icon: Icon(Icons.coronavirus_outlined),
            selectedIcon: Icon(Icons.coronavirus, color: Color(0xFF2E7D32)),
            label: 'Bệnh TN',
          ),
          NavigationDestination(
            icon: Icon(Icons.upload_outlined),
            selectedIcon: Icon(Icons.upload_rounded, color: Color(0xFF1565C0)),
            label: 'Đẩy dữ liệu',
          ),
          NavigationDestination(
            icon: Icon(Icons.manage_accounts_outlined),
            selectedIcon: Icon(Icons.manage_accounts, color: Color(0xFF1565C0)),
            label: 'Tài khoản',
          ),
          NavigationDestination(
            icon: Icon(Icons.logout_outlined),
            selectedIcon: Icon(Icons.logout, color: Colors.red),
            label: 'Đăng xuất',
          ),
        ],
      ),
    );
  }
}
