import 'package:flutter/material.dart';
import 'config/theme.dart';
import 'features/plan/screens/plan_form_screen.dart';

class TravelPlannerApp extends StatelessWidget {
  const TravelPlannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Travel Planner',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      home: const PlanFormScreen(),
    );
  }
}
