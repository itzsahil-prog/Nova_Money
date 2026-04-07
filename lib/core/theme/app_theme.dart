import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF6C63FF);
  static const Color accentColor = Color(0xFF03DAC6);
  static const Color incomeColor = Color(0xFF4CAF50);
  static const Color expenseColor = Color(0xFFE53935);
  static const Color backgroundLight = Color(0xFFF7F8FC);
  static const Color backgroundDark = Color(0xFF12121F);
  static const Color cardColorLight = Color(0xFFFFFFFF);
  static const Color cardColorDark = Color(0xFF1E1E2E);

  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(seedColor: primaryColor, brightness: Brightness.light),
    scaffoldBackgroundColor: backgroundLight,
    cardColor: cardColorLight,
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFFF7F8FC),
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(color: Color(0xFF1A1A2E), fontSize: 22, fontWeight: FontWeight.w700),
      iconTheme: IconThemeData(color: Color(0xFF1A1A2E)),
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Color(0xFF1A1A2E)),
      headlineMedium: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Color(0xFF1A1A2E)),
      titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF1A1A2E)),
      titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFF1A1A2E)),
      bodyLarge: TextStyle(fontSize: 15, color: Color(0xFF3D3D5C)),
      bodyMedium: TextStyle(fontSize: 13, color: Color(0xFF6B6B8A)),
      labelSmall: TextStyle(fontSize: 11, color: Color(0xFF9999BB)),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFFFFFFFF),
      selectedItemColor: Color(0xFF6C63FF),
      unselectedItemColor: Color(0xFF9999BB),
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
  );

  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(seedColor: primaryColor, brightness: Brightness.dark),
    scaffoldBackgroundColor: backgroundDark,
    cardColor: cardColorDark,
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF12121F),
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(color: Color(0xFFE8E8FF), fontSize: 22, fontWeight: FontWeight.w700),
      iconTheme: IconThemeData(color: Color(0xFFE8E8FF)),
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Color(0xFFE8E8FF)),
      headlineMedium: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Color(0xFFE8E8FF)),
      titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFFE8E8FF)),
      titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFFE8E8FF)),
      bodyLarge: TextStyle(fontSize: 15, color: Color(0xFFB0B0D0)),
      bodyMedium: TextStyle(fontSize: 13, color: Color(0xFF8080A0)),
      labelSmall: TextStyle(fontSize: 11, color: Color(0xFF606080)),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF1E1E2E),
      selectedItemColor: Color(0xFF6C63FF),
      unselectedItemColor: Color(0xFF6060A0),
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
  );
}