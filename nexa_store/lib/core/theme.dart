import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF0F172A); // أزرق داكن أنيق
  static const Color accentColor = Color(0xFF38BDF8); // سماوي نيون
  static const Color backgroundColor = Color(0xFF0B1121); // خلفية داكنة

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: primaryColor,
      secondary: accentColor,
      surface: Color(0xFF1E293B),
      background: backgroundColor,
    ),
    scaffoldBackgroundColor: backgroundColor,
    appBarTheme: const AppBarTheme(
      backgroundColor: backgroundColor,
      elevation: 0,
    ),
    fontFamily: 'Roboto', // يمكن تغييره لاحقاً
  );
}
