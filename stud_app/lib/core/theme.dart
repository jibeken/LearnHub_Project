import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary = Color(0xFF3B82F6);
  static const Color primaryDark = Color(0xFF2563EB);
  static const Color accent = Color(0xFF7C3AED);
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFEF4444);
  static const Color primaryLight = Color(0xFFEFF6FF);
  static const Color successLight = Color(0xFFECFDF5);
  static const Color warningLight = Color(0xFFFFFBEB);
  static const Color dangerLight = Color(0xFFFEF2F2);

  static const Color primaryDim = Color(0xFF1E3A5F);
  static const Color successDim = Color(0xFF064E3B);
  static const Color warningDim = Color(0xFF78350F);
  static const Color dangerDim = Color(0xFF7F1D1D);

  static const Color bgPrimary = Color(0xFFFFFFFF);
  static const Color bgSecondary = Color(0xFFF8FAFC);
  static const Color bgTertiary = Color(0xFFF1F5F9);

  static const Color darkBgPrimary = Color(0xFF0F172A);
  static const Color darkBgSecondary = Color(0xFF1E293B);
  static const Color darkBgTertiary = Color(0xFF334155);

  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF475569);
  static const Color textTertiary = Color(0xFF94A3B8);

  static const Color darkTextPrimary = Color(0xFFF1F5F9);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
  static const Color darkTextTertiary = Color(0xFF475569);

  static const Color border = Color(0xFFE2E8F0);

  static const Color darkBorder = Color(0xFF334155);

  static const List<Color> courseColors = [
    Color(0xFFEFF6FF),
    Color(0xFFF0FDF4),
    Color(0xFFFAF5FF),
    Color(0xFFFFF7ED),
    Color(0xFFFFF1F2),
  ];
  static const List<Color> darkCourseColors = [
    Color(0xFF1E3A5F),
    Color(0xFF064E3B),
    Color(0xFF3B0764),
    Color(0xFF431407),
    Color(0xFF4C0519),
  ];
  static const List<Color> courseIconColors = [
    Color(0xFF3B82F6),
    Color(0xFF10B981),
    Color(0xFF7C3AED),
    Color(0xFFEA580C),
    Color(0xFFE11D48),
  ];

  static ThemeData get lightTheme => _build(dark: false);

  static ThemeData get darkTheme => _build(dark: true);

  static ThemeData _build({required bool dark}) {
    final bg1 = dark ? darkBgPrimary : bgPrimary;
    final bg2 = dark ? darkBgSecondary : bgSecondary;
    final bg3 = dark ? darkBgTertiary : bgTertiary;
    final text1 = dark ? darkTextPrimary : textPrimary;
    final text2 = dark ? darkTextSecondary : textSecondary;
    final text3 = dark ? darkTextTertiary : textTertiary;
    final brd = dark ? darkBorder : border;

    return ThemeData(
      useMaterial3: true,
      brightness: dark ? Brightness.dark : Brightness.light,
      fontFamily: 'SF Pro Display',
      colorScheme: ColorScheme(
        brightness: dark ? Brightness.dark : Brightness.light,
        primary: primary,
        onPrimary: Colors.white,
        secondary: accent,
        onSecondary: Colors.white,
        error: danger,
        onError: Colors.white,
        surface: bg1,
        onSurface: text1,
      ),
      scaffoldBackgroundColor: bg2,

      appBarTheme: AppBarTheme(
        backgroundColor: bg1,
        foregroundColor: text1,
        elevation: 0,
        scrolledUnderElevation: 1,
        shadowColor: Colors.black12,
        titleTextStyle: TextStyle(
          fontFamily: 'SF Pro Display',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: text1,
        ),
        iconTheme: IconThemeData(color: text2),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: primary.withValues(alpha: 0.5),
          disabledForegroundColor: Colors.white70,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: const TextStyle(
            fontFamily: 'SF Pro Display',
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: bg3,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: brd),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: brd),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: danger),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        hintStyle: TextStyle(
          color: text3,
          fontSize: 15,
          fontWeight: FontWeight.w400,
        ),
        labelStyle: TextStyle(
          color: text2,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),

      cardTheme: CardThemeData(
        color: bg1,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: brd),
        ),
      ),

      dividerTheme: DividerThemeData(color: brd, thickness: 1, space: 1),

      tabBarTheme: TabBarThemeData(
        labelColor: primary,
        unselectedLabelColor: text3,
        indicatorColor: primary,
        dividerColor: brd,
      ),

      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: bg1,
        selectedItemColor: primary,
        unselectedItemColor: text3,
        elevation: 0,
      ),

      iconTheme: IconThemeData(color: text2),
    );
  }
}

/// Usage: context.colors.bgPrimary
extension ThemeColors on BuildContext {
  ResolvedColors get colors {
    final dark = Theme.of(this).brightness == Brightness.dark;
    return ResolvedColors(dark: dark);
  }
}

class ResolvedColors {
  final bool dark;
  const ResolvedColors({required this.dark});

  Color get bgPrimary => dark ? AppTheme.darkBgPrimary : AppTheme.bgPrimary;
  Color get bgSecondary =>
      dark ? AppTheme.darkBgSecondary : AppTheme.bgSecondary;
  Color get bgTertiary => dark ? AppTheme.darkBgTertiary : AppTheme.bgTertiary;

  Color get textPrimary =>
      dark ? AppTheme.darkTextPrimary : AppTheme.textPrimary;
  Color get textSecondary =>
      dark ? AppTheme.darkTextSecondary : AppTheme.textSecondary;
  Color get textTertiary =>
      dark ? AppTheme.darkTextTertiary : AppTheme.textTertiary;

  Color get border => dark ? AppTheme.darkBorder : AppTheme.border;

  Color get primaryLight => dark ? AppTheme.primaryDim : AppTheme.primaryLight;
  Color get successLight => dark ? AppTheme.successDim : AppTheme.successLight;
  Color get warningLight => dark ? AppTheme.warningDim : AppTheme.warningLight;
  Color get dangerLight => dark ? AppTheme.dangerDim : AppTheme.dangerLight;

  List<Color> get courseColors =>
      dark ? AppTheme.darkCourseColors : AppTheme.courseColors;
}
