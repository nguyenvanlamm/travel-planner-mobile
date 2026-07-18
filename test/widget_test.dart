import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:travel_planner/app.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('App renders form screen', (WidgetTester tester) async {
    await tester.pumpWidget(const TravelPlannerApp());
    await tester.pump();
    expect(find.text('✈  TRAVEL PLANNER'), findsOneWidget);
    expect(find.text('Điểm xuất phát *'), findsOneWidget);
  });
}
