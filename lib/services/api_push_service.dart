// Service đẩy dữ liệu bệnh nhân lên API server kèm JWT token
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiPushService {
  static final ApiPushService _i = ApiPushService._();
  factory ApiPushService() => _i;
  ApiPushService._();

  static const String _baseUrl = 'https://benh-vien-api.onrender.com';

  // Kết quả đẩy từng bản ghi
  static const String ok      = 'success';
  static const String loi     = 'error';
  static const String dayCo   = 'exists'; // đã có trên server

  /// Đẩy một bệnh nhân lên API
  /// Trả về: { 'status': ok/loi/dayCo, 'message': '...' }
  Future<Map<String, String>> dayMotBenhNhan(
      String token, Map<String, dynamic> data) async {
    try {
      final resp = await http.post(
        Uri.parse('$_baseUrl/api/benhNhan/push'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(data),
      ).timeout(const Duration(seconds: 20));

      if (resp.statusCode == 200 || resp.statusCode == 201) {
        return {'status': ok, 'message': 'Đẩy thành công'};
      } else if (resp.statusCode == 409) {
        return {'status': dayCo, 'message': 'Bản ghi đã tồn tại'};
      } else {
        final body = jsonDecode(resp.body);
        return {'status': loi, 'message': body['message'] ?? 'Lỗi ${resp.statusCode}'};
      }
    } catch (e) {
      return {'status': loi, 'message': e.toString()};
    }
  }

  /// Đẩy nhiều bệnh nhân — trả về kết quả từng bản ghi
  Future<List<PushKetQua>> dayNhieuBenhNhan(
      String token, List<Map<String, dynamic>> danhSach) async {
    final results = <PushKetQua>[];
    for (final item in danhSach) {
      final ket = await dayMotBenhNhan(token, item);
      results.add(PushKetQua(
        id:       item['id'] as String? ?? '',
        hoTen:    item['hoTen'] as String? ?? '',
        soThuTu:  item['soThuTu'] as int?,
        status:   ket['status']!,
        message:  ket['message']!,
      ));
    }
    return results;
  }

  /// Đẩy một ca bệnh truyền nhiễm lên API
  Future<Map<String, String>> dayMotBTN(
      String token, Map<String, dynamic> data) async {
    try {
      final resp = await http.post(
        Uri.parse('$_baseUrl/api/benhTruyenNhiem/push'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(data),
      ).timeout(const Duration(seconds: 20));

      if (resp.statusCode == 200 || resp.statusCode == 201) {
        return {'status': ok, 'message': 'Đẩy thành công'};
      } else if (resp.statusCode == 409) {
        return {'status': dayCo, 'message': 'Bản ghi đã tồn tại'};
      } else {
        final body = jsonDecode(resp.body);
        return {'status': loi, 'message': body['message'] ?? 'Lỗi ${resp.statusCode}'};
      }
    } catch (e) {
      return {'status': loi, 'message': e.toString()};
    }
  }

  /// Đẩy nhiều ca BTN
  Future<List<PushKetQua>> dayNhieuBTN(
      String token, List<Map<String, dynamic>> danhSach) async {
    final results = <PushKetQua>[];
    for (final item in danhSach) {
      final ket = await dayMotBTN(token, item);
      results.add(PushKetQua(
        id:      item['id'] as String? ?? '',
        hoTen:   item['hoTen'] as String? ?? '',
        status:  ket['status']!,
        message: ket['message']!,
      ));
    }
    return results;
  }

  /// Lấy token từ username/password
  Future<String?> layToken(String username, String password) async {
    try {
      final resp = await http.post(
        Uri.parse('$_baseUrl/api/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      ).timeout(const Duration(seconds: 30));

      if (resp.statusCode == 200) {
        return jsonDecode(resp.body)['token'] as String?;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Lấy dữ liệu bệnh nhân đã chọn từ server theo ids
  /// → POST /api/benhNhan/byIds  { ids: [...] }
  /// Trả về list dữ liệu từ server (đã qua API)
  Future<LayDuLieuKetQua> layBenhNhanDaChon(
      String token, List<String> ids) async {
    try {
      final resp = await http.post(
        Uri.parse('$_baseUrl/api/benhNhan/byIds'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'ids': ids}),
      ).timeout(const Duration(seconds: 30));

      final body = jsonDecode(resp.body) as Map<String, dynamic>;
      if (resp.statusCode == 200 && body['success'] == true) {
        final data = (body['data'] as List?)
            ?.map((e) => e as Map<String, dynamic>)
            .toList() ?? [];
        return LayDuLieuKetQua(
          success: true,
          total: body['total'] as int? ?? data.length,
          data: data,
        );
      }
      return LayDuLieuKetQua(
        success: false,
        message: body['message'] as String? ?? 'Lỗi ${resp.statusCode}',
      );
    } catch (e) {
      return LayDuLieuKetQua(success: false, message: e.toString());
    }
  }

  /// Lấy dữ liệu ca bệnh TN đã chọn từ server theo ids
  /// → POST /api/benhTruyenNhiem/byIds  { ids: [...] }
  Future<LayDuLieuKetQua> layBTNDaChon(
      String token, List<String> ids) async {
    try {
      final resp = await http.post(
        Uri.parse('$_baseUrl/api/benhTruyenNhiem/byIds'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'ids': ids}),
      ).timeout(const Duration(seconds: 30));

      final body = jsonDecode(resp.body) as Map<String, dynamic>;
      if (resp.statusCode == 200 && body['success'] == true) {
        final data = (body['data'] as List?)
            ?.map((e) => e as Map<String, dynamic>)
            .toList() ?? [];
        return LayDuLieuKetQua(
          success: true,
          total: body['total'] as int? ?? data.length,
          data: data,
        );
      }
      return LayDuLieuKetQua(
        success: false,
        message: body['message'] as String? ?? 'Lỗi ${resp.statusCode}',
      );
    } catch (e) {
      return LayDuLieuKetQua(success: false, message: e.toString());
    }
  }

  /// Lấy tất cả bệnh nhân
  /// → GET /api/benhNhan/tatca
  Future<LayDuLieuKetQua> layTatCaBenhNhan(String token) async {
    try {
      final resp = await http.get(
        Uri.parse('$_baseUrl/api/benhNhan/tatca'),
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(const Duration(seconds: 30));

      final body = jsonDecode(resp.body) as Map<String, dynamic>;
      if (resp.statusCode == 200 && body['success'] == true) {
        final data = (body['data'] as List?)
            ?.map((e) => e as Map<String, dynamic>)
            .toList() ?? [];
        return LayDuLieuKetQua(
          success: true,
          total: body['total'] as int? ?? data.length,
          data: data,
        );
      }
      return LayDuLieuKetQua(
        success: false,
        message: body['message'] as String? ?? 'Lỗi ${resp.statusCode}',
      );
    } catch (e) {
      return LayDuLieuKetQua(success: false, message: e.toString());
    }
  }

  /// Lấy tất cả bệnh truyền nhiễm
  /// → GET /api/benhTruyenNhiem/tatca
  Future<LayDuLieuKetQua> layTatCaBTN(String token) async {
    try {
      final resp = await http.get(
        Uri.parse('$_baseUrl/api/benhTruyenNhiem/tatca'),
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(const Duration(seconds: 30));

      final body = jsonDecode(resp.body) as Map<String, dynamic>;
      if (resp.statusCode == 200 && body['success'] == true) {
        final data = (body['data'] as List?)
            ?.map((e) => e as Map<String, dynamic>)
            .toList() ?? [];
        return LayDuLieuKetQua(
          success: true,
          total: body['total'] as int? ?? data.length,
          data: data,
        );
      }
      return LayDuLieuKetQua(
        success: false,
        message: body['message'] as String? ?? 'Lỗi ${resp.statusCode}',
      );
    } catch (e) {
      return LayDuLieuKetQua(success: false, message: e.toString());
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Kết quả đẩy từng bản ghi
// ═══════════════════════════════════════════════════════════════════════════
class PushKetQua {
  final String id;
  final String hoTen;
  final int? soThuTu;
  final String status;
  final String message;

  const PushKetQua({
    required this.id,
    required this.hoTen,
    this.soThuTu,
    required this.status,
    required this.message,
  });

  bool get isOk => status == ApiPushService.ok;
}

// ═══════════════════════════════════════════════════════════════════════════
// Kết quả khi lấy dữ liệu từ server
// ═══════════════════════════════════════════════════════════════════════════
class LayDuLieuKetQua {
  final bool success;
  final int total;
  final List<Map<String, dynamic>> data;
  final String? message;

  const LayDuLieuKetQua({
    required this.success,
    this.total = 0,
    this.data = const [],
    this.message,
  });
}
