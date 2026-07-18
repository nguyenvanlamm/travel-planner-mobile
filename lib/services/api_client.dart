import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/api_config.dart';
import '../models/travel_models.dart';

class ApiClient {
  static const _fallbackDestinations = [
    'Hà Nội', 'TP. Hồ Chí Minh', 'Đà Nẵng', 'Hội An', 'Huế',
    'Nha Trang', 'Phú Quốc', 'Đà Lạt', 'Sapa', 'Hạ Long',
  ];

  static Future<TravelPlan> createPlan(TravelInput input) async {
    final res = await http
        .post(
          Uri.parse('$kApiBaseUrl/api/plan'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(input.toJson()),
        )
        .timeout(const Duration(minutes: 4));
    if (res.statusCode != 200) {
      String detail = 'Lỗi máy chủ (${res.statusCode})';
      try {
        detail = jsonDecode(utf8.decode(res.bodyBytes))['detail'] ?? detail;
      } catch (_) {}
      throw Exception(detail);
    }
    return TravelPlan.fromJson(jsonDecode(utf8.decode(res.bodyBytes)));
  }

  static Future<List<String>> fetchDestinations() async {
    try {
      final res = await http
          .get(Uri.parse('$kApiBaseUrl/api/destinations'))
          .timeout(const Duration(seconds: 90));
      if (res.statusCode == 200) {
        final list = jsonDecode(utf8.decode(res.bodyBytes))['destinations'];
        if (list is List && list.isNotEmpty) return List<String>.from(list);
      }
    } catch (_) {}
    return _fallbackDestinations;
  }
}
