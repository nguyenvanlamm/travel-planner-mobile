import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travel_planner/config/theme.dart';
import 'package:travel_planner/features/history/screens/history_screen.dart';
import 'package:travel_planner/services/storage.dart';

import '../../helpers/sample_plan.dart';

const _key = 'travel-planner-history';

Widget _wrap() => MaterialApp(
      theme: AppTheme.light,
      home: const HistoryScreen(),
    );

Map<String, dynamic> _entry({
  required String id,
  required String destination,
  required int days,
  required String startDate,
  required DateTime createdAt,
}) =>
    {
      'id': id,
      'title': '$destination · $days ngày',
      'destination': destination,
      'departure': 'Hà Nội',
      'start_date': startDate,
      'days': days,
      'created_at': createdAt.toIso8601String(),
      'plan': samplePlanJson(overview: 'Kế hoạch $destination'),
    };

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  testWidgets('hiện trạng thái đang tải rồi tới danh sách', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(_wrap());

    expect(find.text('Đang tải kế hoạch đã lưu…'), findsOneWidget);
    await tester.pumpAndSettle();
    expect(find.text('Đang tải kế hoạch đã lưu…'), findsNothing);
  });

  testWidgets('trạng thái rỗng khi chưa lưu kế hoạch nào', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(_wrap());
    await tester.pumpAndSettle();

    expect(find.text('Chưa có kế hoạch nào'), findsOneWidget);
    expect(find.text('Lập kế hoạch đầu tiên  →'), findsOneWidget);
  });

  testWidgets('liệt kê kế hoạch mới nhất trước kèm ngày và thời điểm lưu',
      (tester) async {
    final now = DateTime.now();
    SharedPreferences.setMockInitialValues({
      _key: jsonEncode([
        _entry(
          id: '1',
          destination: 'Huế',
          days: 2,
          startDate: '2026-02-01',
          createdAt: now.subtract(const Duration(days: 3)),
        ),
        _entry(
          id: '2',
          destination: 'Đà Nẵng',
          days: 4,
          startDate: '2026-08-12',
          createdAt: now.subtract(const Duration(hours: 2)),
        ),
      ]),
    });

    await tester.pumpWidget(_wrap());
    await tester.pumpAndSettle();

    final destinations = tester
        .widgetList<Text>(find.byType(Text))
        .map((t) => t.data)
        .whereType<String>()
        .where((s) => s == 'Đà Nẵng' || s == 'Huế')
        .toList();
    expect(destinations, ['Đà Nẵng', 'Huế']);

    expect(find.text('🗓  12/08 – 15/08/2026 · 4 ngày'), findsOneWidget);
    expect(find.text('🕐  Đã lưu 2 giờ trước'), findsOneWidget);
    expect(find.text('✈️  Từ Hà Nội'), findsNWidgets(2));
  });

  testWidgets('chạm vào một mục sẽ mở đầy đủ kế hoạch', (tester) async {
    SharedPreferences.setMockInitialValues({
      _key: jsonEncode([
        _entry(
          id: '1',
          destination: 'Đà Nẵng',
          days: 4,
          startDate: '2026-08-12',
          createdAt: DateTime.now(),
        ),
      ]),
    });

    await tester.pumpWidget(_wrap());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Đà Nẵng'));
    await tester.pumpAndSettle();

    expect(find.text('Kế hoạch của bạn'), findsOneWidget);
    expect(find.text('Kế hoạch Đà Nẵng'), findsOneWidget);
  });

  testWidgets('xóa một mục làm nó biến mất và không còn trong bộ nhớ',
      (tester) async {
    SharedPreferences.setMockInitialValues({
      _key: jsonEncode([
        _entry(
          id: '1',
          destination: 'Huế',
          days: 2,
          startDate: '2026-02-01',
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
        _entry(
          id: '2',
          destination: 'Đà Nẵng',
          days: 4,
          startDate: '2026-08-12',
          createdAt: DateTime.now(),
        ),
      ]),
    });

    await tester.pumpWidget(_wrap());
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.delete_outline).first);
    await tester.pumpAndSettle();
    expect(find.text('Xóa kế hoạch?'), findsOneWidget);

    await tester.tap(find.text('Xóa'));
    await tester.pumpAndSettle();

    expect(find.text('Đà Nẵng'), findsNothing);
    expect(find.text('Huế'), findsOneWidget);
    expect((await PlanStorage.loadHistory()).map((p) => p.destination),
        ['Huế']);
  });

  testWidgets('trạng thái lỗi kèm nút thử lại khi dữ liệu hỏng',
      (tester) async {
    SharedPreferences.setMockInitialValues({_key: 'not json'});
    await tester.pumpWidget(_wrap());
    await tester.pumpAndSettle();

    expect(find.text('Không tải được lịch sử'), findsOneWidget);
    expect(find.text('Thử lại'), findsOneWidget);

    SharedPreferences.setMockInitialValues({});
    await tester.tap(find.text('Thử lại'));
    await tester.pumpAndSettle();
    expect(find.text('Chưa có kế hoạch nào'), findsOneWidget);
  });

  group('định dạng', () {
    test('formatSavedAt rút gọn theo khoảng cách thời gian', () {
      final now = DateTime(2026, 7, 26, 12);
      expect(formatSavedAt(null), 'không rõ thời điểm');
      expect(formatSavedAt(now, now: now), 'vừa xong');
      expect(
          formatSavedAt(now.subtract(const Duration(minutes: 20)), now: now),
          '20 phút trước');
      expect(formatSavedAt(now.subtract(const Duration(hours: 5)), now: now),
          '5 giờ trước');
      expect(formatSavedAt(now.subtract(const Duration(days: 3)), now: now),
          '3 ngày trước');
      expect(formatSavedAt(now.subtract(const Duration(days: 30)), now: now),
          'ngày 26/06/2026');
    });

    test('formatPlanDates rút gọn khi thiếu dữ liệu', () {
      expect(
        formatPlanDates(SavedPlan(
          id: '1',
          title: 'Huế · 2 ngày',
          destination: 'Huế',
          startDate: '2026-02-01',
          days: 2,
          plan: samplePlan(),
        )),
        '01/02 – 02/02/2026 · 2 ngày',
      );
      expect(
        formatPlanDates(SavedPlan(
          id: '1',
          title: 'Huế · 2 ngày',
          destination: 'Huế',
          days: 2,
          plan: samplePlan(),
        )),
        '2 ngày',
      );
      expect(
        formatPlanDates(SavedPlan(
          id: '1',
          title: 'Huế',
          destination: 'Huế',
          plan: samplePlan(),
        )),
        'Chưa rõ ngày đi',
      );
    });
  });
}
