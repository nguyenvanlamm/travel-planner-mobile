import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travel_planner/config/theme.dart';
import 'package:travel_planner/features/plan/screens/plan_form_screen.dart';
import 'package:travel_planner/services/storage.dart';

import '../../helpers/failing_prefs.dart';
import '../../helpers/sample_plan.dart';

Widget _wrap() => MaterialApp(
  theme: AppTheme.light,
  home: PlanFormScreen(createPlan: (_) async => samplePlan()),
);

/// Điền hai trường bắt buộc rồi bấm nút lập kế hoạch.
Future<void> _fillAndSubmit(WidgetTester tester) async {
  await tester.enterText(
    find.widgetWithText(TextFormField, 'Điểm xuất phát *'),
    'Hà Nội',
  );
  await tester.enterText(
    find.widgetWithText(TextFormField, 'Điểm đến *'),
    'Đà Nẵng',
  );

  final button = find.widgetWithText(FilledButton, 'Lập kế hoạch du lịch  →');
  // Trang có nhiều Scrollable (mỗi ô nhập là một), lấy chính ListView của form.
  await tester.scrollUntilVisible(
    button,
    300,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.tap(button);

  // Rời màn hình chờ khi createPlan giả trả về ngay, rồi để route chạy xong.
  await tester.pump();
  await tester.pump();
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  testWidgets('lập kế hoạch xong thì lưu lịch sử và mở kế hoạch', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(_wrap());
    await tester.pumpAndSettle();
    await _fillAndSubmit(tester);

    expect(find.text('Kế hoạch của bạn'), findsOneWidget);
    expect(find.byType(SnackBar), findsNothing);
    expect((await PlanStorage.loadHistory()).map((p) => p.destination), [
      'Đà Nẵng',
    ]);
  });

  testWidgets('lưu lịch sử thất bại thì báo lỗi nhưng vẫn mở kế hoạch', (
    tester,
  ) async {
    setMockValuesWithFailingWrites({});

    await tester.pumpWidget(_wrap());
    await tester.pumpAndSettle();
    await _fillAndSubmit(tester);

    expect(
      find.widgetWithText(
        SnackBar,
        'Không lưu được kế hoạch vào lịch sử — bạn vẫn xem được kế hoạch vừa tạo',
      ),
      findsOneWidget,
    );
    expect(find.text('Kế hoạch của bạn'), findsOneWidget);
  });
}
