import 'package:flutter/material.dart';

class EmergencyTheme {
  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      );

  static ThemeData get criticalHighContrastTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF1A0000),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFFF2222),
          secondary: Color(0xFFFFD700),
          surface: Color(0xFF2A0000),
          onPrimary: Colors.white,
          onSurface: Colors.white,
        ),
        cardTheme: const CardThemeData(color: Color(0xFF330000)),
        appBarTheme: const AppBarTheme(backgroundColor: Color(0xFF2A0000), foregroundColor: Colors.white),
      );
}