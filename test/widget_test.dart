import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travel_planner/app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('App renders form screen', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const TravelPlannerApp());
    await tester.pump();
    expect(find.text('✈  TRAVEL PLANNER'), findsOneWidget);
    expect(find.text('Điểm xuất phát *'), findsOneWidget);
  });

  testWidgets('History screen is reachable from the form screen',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const TravelPlannerApp());
    await tester.pump();

    await tester.tap(find.byIcon(Icons.history));
    await tester.pumpAndSettle();

    expect(find.text('Kế hoạch đã lưu'), findsOneWidget);
    expect(find.text('Chưa có kế hoạch nào'), findsOneWidget);
  });
}
