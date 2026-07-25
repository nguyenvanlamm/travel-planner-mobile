import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travel_planner/services/storage.dart';

import '../helpers/sample_plan.dart';

const _key = 'travel-planner-history';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('lịch sử rỗng khi chưa lưu gì', () async {
    SharedPreferences.setMockInitialValues({});
    expect(await PlanStorage.loadHistory(), isEmpty);
  });

  test('save giữ lại điểm đến, ngày đi, số ngày và thời điểm lưu', () async {
    SharedPreferences.setMockInitialValues({});
    await PlanStorage.save(samplePlan(), sampleInput());

    final history = await PlanStorage.loadHistory();
    expect(history, hasLength(1));
    final saved = history.first;
    expect(saved.destination, 'Đà Nẵng');
    expect(saved.departure, 'Hà Nội');
    expect(saved.startDate, '2026-08-12');
    expect(saved.days, 4);
    expect(saved.createdAt, isNotNull);
    expect(saved.endDate, DateTime(2026, 8, 15));
    expect(saved.plan.tongQuan, 'Chuyến đi thử');
  });

  test('lịch sử được sắp xếp mới nhất trước', () async {
    SharedPreferences.setMockInitialValues({
      _key: jsonEncode([
        {
          'id': '1',
          'title': 'Huế · 2 ngày',
          'destination': 'Huế',
          'created_at': DateTime(2026, 1, 1).toIso8601String(),
          'plan': samplePlanJson(),
        },
        {
          'id': '2',
          'title': 'Sapa · 3 ngày',
          'destination': 'Sapa',
          'created_at': DateTime(2026, 5, 1).toIso8601String(),
          'plan': samplePlanJson(),
        },
      ]),
    });

    final history = await PlanStorage.loadHistory();
    expect(history.map((h) => h.destination), ['Sapa', 'Huế']);
  });

  test('bản ghi cũ suy ra điểm đến, số ngày và thời điểm lưu', () async {
    final createdMs = DateTime(2026, 3, 4, 9, 30).millisecondsSinceEpoch;
    SharedPreferences.setMockInitialValues({
      _key: jsonEncode([
        {
          'id': '$createdMs',
          'title': 'Hội An · 5 ngày',
          'plan': samplePlanJson(),
        },
      ]),
    });

    final saved = (await PlanStorage.loadHistory()).single;
    expect(saved.destination, 'Hội An');
    expect(saved.days, 5);
    expect(saved.startDate, isNull);
    expect(saved.createdAt, DateTime(2026, 3, 4, 9, 30));
  });

  test('bản ghi hỏng bị bỏ qua, phần còn lại vẫn đọc được', () async {
    SharedPreferences.setMockInitialValues({
      _key: jsonEncode([
        'không phải object',
        {'id': '2', 'title': 'Sapa · 3 ngày', 'plan': samplePlanJson()},
      ]),
    });

    final history = await PlanStorage.loadHistory();
    expect(history.map((h) => h.destination), ['Sapa']);
  });

  test('dữ liệu hỏng hoàn toàn ném PlanStorageException', () async {
    SharedPreferences.setMockInitialValues({_key: 'not json at all'});
    expect(PlanStorage.loadHistory(), throwsA(isA<PlanStorageException>()));
  });

  test('loadHistoryOrEmpty nuốt lỗi và trả về danh sách rỗng', () async {
    SharedPreferences.setMockInitialValues({_key: 'not json at all'});
    expect(await PlanStorage.loadHistoryOrEmpty(), isEmpty);
  });

  test('save chỉ giữ lại 20 kế hoạch mới nhất', () async {
    SharedPreferences.setMockInitialValues({
      _key: jsonEncode([
        for (var i = 20; i >= 1; i--)
          {
            'id': '$i',
            'title': 'Điểm $i · 2 ngày',
            'destination': 'Điểm $i',
            'created_at': DateTime(2026, 1, i).toIso8601String(),
            'plan': samplePlanJson(),
          },
      ]),
    });

    await PlanStorage.save(samplePlan(), sampleInput());

    final history = await PlanStorage.loadHistory();
    expect(history, hasLength(20));
    expect(history.first.destination, 'Đà Nẵng');
    expect(history.last.destination, 'Điểm 2');
    expect(history.map((h) => h.destination), isNot(contains('Điểm 1')));
  });

  test('remove xóa đúng kế hoạch và giữ lại phần còn lại', () async {
    SharedPreferences.setMockInitialValues({
      _key: jsonEncode([
        {'id': '1', 'title': 'Huế · 2 ngày', 'plan': samplePlanJson()},
        {'id': '2', 'title': 'Sapa · 3 ngày', 'plan': samplePlanJson()},
      ]),
    });

    await PlanStorage.remove('1');
    final history = await PlanStorage.loadHistory();
    expect(history.map((h) => h.destination), ['Sapa']);
  });
}
