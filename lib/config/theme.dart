import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Bảng màu "tạp chí du lịch" — đồng bộ với bản web.
class AppColors {
  static const cream = Color(0xFFFAF5EC);
  static const paper = Color(0xFFFFFDF8);
  static const ink = Color(0xFF1F2D33);
  static const muted = Color(0xFF5D6B60);
  static const teal = Color(0xFF0E6B63);
  static const tealDeep = Color(0xFF0A524C);
  static const tealTint = Color(0xFFE3EFE9);
  static const coral = Color(0xFFE76F51);
  static const gold = Color(0xFFC9962E);
  static const line = Color(0xFFE7DCC6);

  // Dark
  static const dBg = Color(0xFF14201D);
  static const dPaper = Color(0xFF1D2B28);
  static const dInk = Color(0xFFE9E4D6);
  static const dMuted = Color(0xFFA3B2A5);
  static const dTeal = Color(0xFF2F9A8B);
  static const dTealDeep = Color(0xFF8FD0C3);
  static const dTealTint = Color(0xFF24403A);
  static const dCoral = Color(0xFFF08A6A);
  static const dLine = Color(0xFF32433E);
}

class AppTheme {
  static TextTheme _textTheme(Color ink, Color muted) {
    final body = GoogleFonts.beVietnamProTextTheme();
    return body
        .copyWith(
          displaySmall: GoogleFonts.fraunces(
              fontSize: 32, fontWeight: FontWeight.w600, color: ink, height: 1.15),
          headlineSmall: GoogleFonts.fraunces(
              fontSize: 22, fontWeight: FontWeight.w600, color: ink),
          titleMedium: GoogleFonts.fraunces(
              fontSize: 17, fontWeight: FontWeight.w600, color: ink),
          bodyMedium: GoogleFonts.beVietnamPro(fontSize: 14.5, color: ink, height: 1.5),
          bodySmall: GoogleFonts.beVietnamPro(fontSize: 12.5, color: muted),
          labelLarge: GoogleFonts.beVietnamPro(fontWeight: FontWeight.w600),
        )
        .apply(bodyColor: ink, displayColor: ink);
  }

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: AppColors.cream,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.teal,
          primary: AppColors.teal,
          secondary: AppColors.coral,
          surface: AppColors.paper,
          brightness: Brightness.light,
        ),
        textTheme: _textTheme(AppColors.ink, AppColors.muted),
        cardTheme: const CardThemeData(
          color: AppColors.paper,
          elevation: 1,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
            side: BorderSide(color: AppColors.line),
          ),
          margin: EdgeInsets.only(bottom: 16),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.paper,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.line),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.line),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.teal, width: 2),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.teal,
            foregroundColor: AppColors.paper,
            padding: const EdgeInsets.symmetric(vertical: 16),
            textStyle: GoogleFonts.beVietnamPro(
                fontSize: 16, fontWeight: FontWeight.w600),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: AppColors.paper,
          selectedColor: AppColors.teal,
          side: const BorderSide(color: AppColors.line),
          labelStyle: GoogleFonts.beVietnamPro(fontSize: 13),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        ),
      );

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.dBg,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.dTeal,
          primary: AppColors.dTeal,
          secondary: AppColors.dCoral,
          surface: AppColors.dPaper,
          brightness: Brightness.dark,
        ),
        textTheme: _textTheme(AppColors.dInk, AppColors.dMuted),
        cardTheme: const CardThemeData(
          color: AppColors.dPaper,
          elevation: 1,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
            side: BorderSide(color: AppColors.dLine),
          ),
          margin: EdgeInsets.only(bottom: 16),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.dPaper,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.dLine),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.dLine),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.dTeal, width: 2),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.dTeal,
            foregroundColor: AppColors.paper,
            padding: const EdgeInsets.symmetric(vertical: 16),
            textStyle: GoogleFonts.beVietnamPro(
                fontSize: 16, fontWeight: FontWeight.w600),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: AppColors.dPaper,
          selectedColor: AppColors.dTeal,
          side: const BorderSide(color: AppColors.dLine),
          labelStyle: GoogleFonts.beVietnamPro(fontSize: 13),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        ),
      );
}
