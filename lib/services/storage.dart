import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/travel_models.dart';

class SavedPlan {
  final String id;
  final String title;
  final TravelPlan plan;
  SavedPlan({required this.id, required this.title, required this.plan});
}

class PlanStorage {
  static const _key = 'travel-planner-history';
  static const _max = 5;

  static Future<List<SavedPlan>> loadHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key);
      if (raw == null) return [];
      final list = jsonDecode(raw) as List;
      return list
          .map((e) => SavedPlan(
                id: e['id'],
                title: e['title'],
                plan: TravelPlan.fromJson(e['plan']),
              ))
          .toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> save(TravelPlan plan, TravelInput input) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final history = await loadHistory();
      final entry = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'title': '${input.destination} · ${input.days} ngày',
        'plan': plan.raw,
      };
      final all = [
        entry,
        ...history.map((h) => {'id': h.id, 'title': h.title, 'plan': h.plan.raw}),
      ].take(_max).toList();
      await prefs.setString(_key, jsonEncode(all));
    } catch (_) {}
  }

  static Future<void> remove(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final history = await loadHistory();
      final all = history
          .where((h) => h.id != id)
          .map((h) => {'id': h.id, 'title': h.title, 'plan': h.plan.raw})
          .toList();
      await prefs.setString(_key, jsonEncode(all));
    } catch (_) {}
  }
}
