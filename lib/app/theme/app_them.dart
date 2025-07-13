// lib/app/theme/app_theme.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  // --- تعريف باليتة الألوان الجديدة ---
  static const Color primaryColor = Color(0xFF5603AD);
  static const Color primaryColorDarkTheme = Color(0xFF8367C7);
  static const Color secondaryColor = Color(0xFFB3E9C7);
  static const Color accentColor = Color(0xFFC2F8CB);
  static const Color backgroundLight = Color(0xFFF0FFF1);

  // الألوان القياسية للوضع الداكن (موصى بها من ماتيريال ديزاين)
  static const Color backgroundDark = Color(0xFF121212);
  static const Color cardDark = Color(0xFF1E1E1E);

  // --- تعريف الثيم الفاتح (Light Theme) ---
  static final ThemeData light = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,

    // استخدام الألوان الجديدة
    colorScheme: const ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
      background: Colors.white,
      surface: Colors.white, // لون الكروت والأوراق سيكون أبيض نقي
      error: Colors.red,
      onPrimary: Colors.white, // لون النص فوق اللون الأساسي (أبيض على بنفسجي)
      onSecondary: Colors.black, // لون النص فوق اللون الثانوي (أسود على أخضر فاتح)
      onBackground: Colors.black87,
      onSurface: Colors.black87,
      onError: Colors.white,
    ),

    scaffoldBackgroundColor: Color(0xFFF0FFF1),


    textTheme: GoogleFonts.cairoTextTheme(ThemeData.light().textTheme),

    appBarTheme: const AppBarTheme(
      elevation: 1,
      centerTitle: true,
      backgroundColor: primaryColor,
      foregroundColor: Colors.white, // لون الأيقونات والنص في الـ AppBar
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
    ),

    // cardTheme: CardTheme(
    //   elevation: 2,
    //   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    //   color: Colors.white,
    // ),
  );

  // --- تعريف الثيم الداكن (Dark Theme) ---
  static final ThemeData dark = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,

    // استخدام الألوان الجديدة للوضع الداكن
    colorScheme: const ColorScheme.dark(
      primary: primaryColorDarkTheme, // استخدام البنفسجي الفاتح
      secondary: secondaryColor,
      background: backgroundDark,
      surface: cardDark,
      error: Colors.redAccent,
      onPrimary: Colors.black, // لون النص فوق اللون الأساسي (أسود على بنفسجي فاتح)
      onSecondary: Colors.black,
      onBackground: Colors.white70,
      onSurface: Colors.white,
      onError: Colors.black,
    ),

    scaffoldBackgroundColor: backgroundDark,

    textTheme: GoogleFonts.cairoTextTheme(ThemeData.dark().textTheme),

    appBarTheme: const AppBarTheme(
      elevation: 1,
      centerTitle: true,
      backgroundColor: cardDark,
      foregroundColor: primaryColorDarkTheme,
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColorDarkTheme,
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: cardDark,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.grey),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryColorDarkTheme, width: 2),
      ),
    ),

    // cardTheme: CardTheme(
    //   elevation: 2,
    //   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    //   color: cardDark,
    // ),
  );
}