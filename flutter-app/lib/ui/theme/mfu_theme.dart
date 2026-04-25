import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MfuTheme {
  static const Color primary = Color(0xFFC8102E);
  static const Color primaryDark = Color(0xFF9E0B22);
  static const Color onPrimary = Colors.white;
  static const Color bgPage = Color(0xFFF9F9F9);
  static const Color bgCard = Colors.white;
  static const Color bgChip = Color(0xFFF5F5F5);
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSub = Color(0xFF888888);
  static const Color textHint = Color(0xFFBBBBBB);
  static const Color border = Color(0xFFEEEEEE);
  static const Color statusIn = Color(0xFF1A8A4A);
  static const Color statusInBg = Color(0xFFE6F9EF);
  static const Color statusOut = Color(0xFFC8102E);
  static const Color statusOutBg = Color(0xFFFFF0F0);
  static const Color green = Color(0xFF2ECC71);

  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        colorScheme: const ColorScheme(
          brightness: Brightness.light,
          primary: primary,
          onPrimary: onPrimary,
          secondary: primary,
          onSecondary: onPrimary,
          error: Color(0xFFB00020),
          onError: Colors.white,
          surface: bgCard,
          onSurface: textPrimary,
        ),
        scaffoldBackgroundColor: bgPage,
        appBarTheme: const AppBarTheme(
          backgroundColor: primary,
          foregroundColor: onPrimary,
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light,
          ),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: bgCard,
          selectedItemColor: primary,
          unselectedItemColor: textHint,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          selectedLabelStyle:
              TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
          unselectedLabelStyle: TextStyle(fontSize: 10),
        ),
        cardTheme: const CardThemeData(
          color: bgCard,
          elevation: 2,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            // ใช้ BorderRadius.all ร่วมกับ Radius.circular เพื่อให้เป็น const ได้สมบูรณ์
            borderRadius: BorderRadius.all(Radius.circular(12)),
            side: BorderSide(color: border, width: 0.5),
          ),
        ),
        dividerColor: border,
        dividerTheme:
            const DividerThemeData(color: border, thickness: 0.5, space: 0),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: bgChip,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(28),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(28),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(28),
            borderSide: const BorderSide(color: primary, width: 1.5),
          ),
          hintStyle: const TextStyle(color: textHint, fontSize: 13),
        ),
      );
}
