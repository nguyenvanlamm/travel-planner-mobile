import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/travel_models.dart';

/// Lỗi khi đọc/ghi lịch sử kế hoạch đã lưu.
class PlanStorageException implements Exception {
  final String message;
  const PlanStorageException(this.message);

  @override
  String toString() => message;
}

/// Một kế hoạch đã được lưu lại sau khi tạo.
///
/// Các bản ghi cũ chỉ có `id`, `title`, `plan`; những trường còn lại được suy
/// ra từ `title` và `id` để lịch sử cũ vẫn hiển thị được.
class SavedPlan {
  final String id;
  final String title;
  final String destination;
  final String? departure;

  /// yyyy-MM-dd — ngày khởi hành, null với bản ghi cũ.
  final String? startDate;
  final int? days;

  /// Thời điểm kế hoạch được lưu, null nếu không suy ra được.
  final DateTime? createdAt;
  final TravelPlan plan;

  SavedPlan({
    required this.id,
    required this.title,
    required this.destination,
    required this.plan,
    this.departure,
    this.startDate,
    this.days,
    this.createdAt,
  });

  factory SavedPlan.fromJson(Map<String, dynamic> j) {
    final id = (j['id'] ?? '').toString();
    final title = (j['title'] ?? '').toString();
    return SavedPlan(
      id: id,
      title: title,
      destination:
          (j['destination'] as String?) ?? _destinationFromTitle(title),
      departure: j['departure'] as String?,
      startDate: j['start_date'] as String?,
      days: j['days'] is int ? j['days'] as int : _daysFromTitle(title),
      createdAt: _parseCreatedAt(j['created_at'], id),
      plan: TravelPlan.fromJson(Map<String, dynamic>.from(j['plan'] ?? {})),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'destination': destination,
    'departure': departure,
    'start_date': startDate,
    'days': days,
    'created_at': createdAt?.toIso8601String(),
    'plan': plan.raw,
  };

  /// Ngày kết thúc suy ra từ ngày bắt đầu và số ngày (bao gồm ngày đầu).
  DateTime? get endDate {
    final start = startDateTime;
    if (start == null || days == null || days! < 1) return null;
    return start.add(Duration(days: days! - 1));
  }

  DateTime? get startDateTime =>
      startDate == null ? null : DateTime.tryParse(startDate!);

  /// Tiêu đề cũ có dạng "Đà Nẵng · 3 ngày".
  static String _destinationFromTitle(String title) =>
      title.split(' · ').first.trim();

  static int? _daysFromTitle(String title) {
    final match = RegExp(r'(\d+)\s*ngày').firstMatch(title);
    return match == null ? null : int.tryParse(match.group(1)!);
  }

  static DateTime? _parseCreatedAt(dynamic raw, String id) {
    if (raw is String) {
      final parsed = DateTime.tryParse(raw);
      if (parsed != null) return parsed;
    }
    // Bản ghi cũ: id chính là millisecondsSinceEpoch lúc lưu.
    final ms = int.tryParse(id);
    return ms == null ? null : DateTime.fromMillisecondsSinceEpoch(ms);
  }
}

/// Lịch sử kế hoạch được lưu ngay trên máy (SharedPreferences).
///
/// Backend chưa có API lịch sử, nên đây là nguồn dữ liệu duy nhất; khi API
/// sẵn sàng chỉ cần thay phần đọc/ghi bên dưới.
class PlanStorage {
  static const _key = 'travel-planner-history';
  static const _max = 20;

  /// Đọc lịch sử, mới nhất trước.
  ///
  /// Ném [PlanStorageException] khi dữ liệu hỏng hoặc không đọc được để màn
  /// hình lịch sử hiển thị được trạng thái lỗi.
  static Future<List<SavedPlan>> loadHistory() async {
    List<dynamic> list;
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key);
      if (raw == null) return [];
      list = jsonDecode(raw) as List;
    } catch (_) {
      throw const PlanStorageException('Không đọc được lịch sử đã lưu');
    }

    final plans = <SavedPlan>[];
    for (final e in list) {
      try {
        plans.add(SavedPlan.fromJson(Map<String, dynamic>.from(e as Map)));
      } catch (_) {
        // Bỏ qua bản ghi hỏng thay vì mất toàn bộ lịch sử.
      }
    }
    return _newestFirst(plans);
  }

  /// Như [loadHistory] nhưng trả về danh sách rỗng khi lỗi — dùng cho những
  /// chỗ chỉ hiển thị phụ, không cần báo lỗi cho người dùng.
  static Future<List<SavedPlan>> loadHistoryOrEmpty() async {
    try {
      return await loadHistory();
    } catch (_) {
      return [];
    }
  }

  /// Lưu kế hoạch vừa tạo vào đầu lịch sử.
  ///
  /// Ném [PlanStorageException] khi không ghi được để màn hình báo lại cho
  /// người dùng — nếu nuốt lỗi, người dùng sẽ tưởng kế hoạch đã được lưu.
  static Future<void> save(TravelPlan plan, TravelInput input) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final history = await loadHistoryOrEmpty();
      final entry = SavedPlan(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: '${input.destination} · ${input.days} ngày',
        destination: input.destination,
        departure: input.departure,
        startDate: input.startDate,
        days: input.days,
        createdAt: DateTime.now(),
        plan: plan,
      );
      final all = [entry, ...history].take(_max).toList();
      await prefs.setString(
        _key,
        jsonEncode(all.map((p) => p.toJson()).toList()),
      );
    } catch (_) {
      throw const PlanStorageException('Không lưu được kế hoạch vào lịch sử');
    }
  }

  /// Xóa một kế hoạch khỏi lịch sử.
  ///
  /// Đọc bằng [loadHistory] chứ không phải [loadHistoryOrEmpty]: nếu dữ liệu
  /// không đọc được thì ghi đè danh sách rỗng sẽ xóa sạch lịch sử, nên lỗi đọc
  /// phải thành [PlanStorageException] để màn hình báo lại cho người dùng.
  static Future<void> remove(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final history = await loadHistory();
      final all = history.where((h) => h.id != id).map((h) => h.toJson());
      await prefs.setString(_key, jsonEncode(all.toList()));
    } catch (_) {
      throw const PlanStorageException('Không xóa được kế hoạch');
    }
  }

  /// Sắp xếp mới nhất trước, giữ nguyên thứ tự lưu với bản ghi thiếu thời gian.
  static List<SavedPlan> _newestFirst(List<SavedPlan> plans) {
    final indexed = plans.indexed.toList()
      ..sort((a, b) {
        final at = a.$2.createdAt, bt = b.$2.createdAt;
        if (at != null && bt != null) {
          final byTime = bt.compareTo(at);
          if (byTime != 0) return byTime;
        } else if (at == null && bt != null) {
          return 1;
        } else if (at != null && bt == null) {
          return -1;
        }
        return a.$1.compareTo(b.$1);
      });
    return indexed.map((e) => e.$2).toList();
  }
}
