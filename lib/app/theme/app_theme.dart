// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF6750A4),
          onPrimary: Colors.white,
          primaryContainer: Color(0xFFEDE7FF),
          onPrimaryContainer: Color(0xFF6750A4),
          surface: Color(0xFFFFFBFE),
          onSurface: Color(0xFF1C1B1F),
          surfaceContainerHighest: Color(0xFFF4EFF4),
          onSurfaceVariant: Color(0xFF79747E),
          outlineVariant: Color(0xFFE7E0EC),
          shadow: Color(0xFF1C1B1F),
        ),
        scaffoldBackgroundColor: const Color(0xFFF7F5FF),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFFFFBFE),
          foregroundColor: Color(0xFF1C1B1F),
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            color: Color(0xFF1C1B1F),
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        navigationBarTheme: NavigationBarThemeData(
          height: 80,
          backgroundColor: const Color(0xFFFFFBFE),
          indicatorColor: const Color(0xFFEDE7FF),
          indicatorShape: const StadiumBorder(),
          labelTextStyle: WidgetStateProperty.resolveWith(
            (states) => TextStyle(
              color: states.contains(WidgetState.selected)
                  ? const Color(0xFF6750A4)
                  : const Color(0xFF79747E),
              fontSize: 12,
              fontWeight: states.contains(WidgetState.selected)
                  ? FontWeight.w600
                  : FontWeight.w500,
            ),
          ),
        ),
      );

  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6750A4),
          brightness: Brightness.dark,
        ),
      );
}
