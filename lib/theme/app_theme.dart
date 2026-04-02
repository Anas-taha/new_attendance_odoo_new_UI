import 'package:flutter/material.dart';

/// App color palette (same as main.dart theme)
abstract class AppColors {
  // primary
  static const Color appPrimaryColor = Color(0xFF22004C);
  //secodry
  static const Color app5700A8Sedondary1 = Color(0xFFF8F9FF);
  static const Color app670379Sedondary2 = Color(0xFF670379);
  static const Color appC6B8FFSedondary3 = Color(0xFFC6B8FF);
  // text
  static const Color app1A1A1AText1 = Color(0xFF1A1A1A);
  static const Color appA0A0A0Text2 = Color(0xFFA0A0A0);
  static const Color appF5F5F7Text3 = Color(0xFFF5F5F7);
  static const Color app9F9F9FText4 = Color(0xFF9F9F9F);
  // background
  static const Color appFFFFFFBackGround1 = Color(0xFFFFFFFF);
  static const Color appFAFAFABackGround2 = Color(0xFFFAFAFA);
  static const Color appE5E5E5Border = Color(0xFFE5E5E5);
  static const Color appE1CDE4CardBG = Color(0xFFE1CDE4);
  // system State
  static const Color app4CAF50Success = Color(0xFF4CAF50);
  static const Color appF44336Error = Color(0xFFF44336);
  static const Color appF59E0BWorning = Color(0xFFF59E0B);

  static const Color primary50 = Color(0xFFF8F9FF);
  static const Color primary100 = Color(0xFFE9EBF5);
  static const Color primary200 = Color(0xFFC3CBE1);
  static const Color primary300 = Color(0xFF9DA4CA);
  static const Color primary400 = Color(0xFF767DB3);
  static const Color primary500 = Color(0xFF6B46C1);
  static const Color primary600 = Color(0xFF5230A2);
  static const Color primary700 = Color(0xFF402484);
  static const Color primary800 = Color(0xFF2D1B66);
  static const Color primary900 = Color(0xFF1B1148);

  static const Color primary = Color(0xFF6B46C1);
  static const Color secondary = Color(0xFFFF573D);
}

/// Primary swatch for the app
final MaterialColor appPrimarySwatch =
    MaterialColor(0xFF22004C, const <int, Color>{
      50: AppColors.primary50,
      100: AppColors.primary100,
      200: AppColors.primary200,
      300: AppColors.primary300,
      400: AppColors.primary400,
      500: AppColors.primary500,
      600: AppColors.primary600,
      700: AppColors.primary700,
      800: AppColors.primary800,
      900: AppColors.primary900,
    });

/// App theme using the same colors as the original main.dart
ThemeData get appTheme => ThemeData(
  primarySwatch: appPrimarySwatch,
  colorScheme: ColorScheme.fromSeed(
    seedColor: AppColors.primary,
    primary: AppColors.primary,
    secondary: AppColors.secondary,
  ),
  useMaterial3: true,
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.primary,
    foregroundColor: Colors.white,
    elevation: 0,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 2,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      minimumSize: const Size(88, 48),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  ),
);
