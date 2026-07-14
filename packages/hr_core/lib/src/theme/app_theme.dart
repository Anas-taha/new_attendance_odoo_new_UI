import 'package:flutter/material.dart';

/// App color palette (same as main.dart theme)
abstract class AppColors {
  // primary
  static const Color appPrimaryColor = Color(0xFF39493f);
  //secodry
  static const Color app5700A8Sedondary1 = Color(0xFFF8F9FF);
  static final Color app670379Sedondary2 = primary900;
  static const Color appC6B8FFSedondary3 = Color(0xFFC6B8FF);
  static final Color app8A3159Sedondary4 = primary500;
  // text
  static const Color app1A1A1AText1 = Color(0xFF1A1A1A);
  static const Color appA0A0A0Text2 = Color(0xFFA0A0A0);
  static const Color appF5F5F7Text3 = Color(0xFFF5F5F7);
  static const Color app9F9F9FText4 = Color(0xFF9F9F9F);
  static const Color app212529Text5 = Color(0xFF212529);
  static const Color app6C757DText5 = Color(0xFF6C757D);
  static const Color app796DFFText6 = Color(0xFF796DFF);
  static const Color appF9F9F9Text7 = Color(0xFFF9F9F9);
  // background
  static const Color appFFFFFFBackGround1 = Color(0xFFFFFFFF);
  static const Color appFAFAFABackGround2 = Color(0xFFFAFAFA);
  // border
  static const Color appE5E5E5Border = Color(0xFFE5E5E5);
  static const Color app6A5CFFBorder2 = Color(0xFF6A5CFF);
  // card
  static const Color appE1CDE4CardBG = Color(0xFFE1CDE4);
  static const Color appFDD9D7CardBG2 = Color(0xFFFDD9D7);
  static const Color appEEF7EECardBG3 = Color(0xFFEEF7EE);
  static const Color appF9F5FACardBG4 = Color(0xFFF9F5FA);
  static const Color appF5F8FFCardBG5 = Color(0xFFF5F8FF);
  static const Color appFFF7F4CardBG6 = Color(0xFFFFF7F4);
  static const Color appFFF7F5CardBG6 = Color(0xFFFFF7F5);
  static const Color appF0E6F2CardBG6 = Color(0xFFF0E6F2);
  static const Color appDEDBFFCardBG6 = Color(0xFFDEDBFF);
  static const Color appFFDFAACardBG6 = Color(0xFFFFDFAA);
  static const Color appFDD0CDCardBG6 = Color(0xFFFDD0CD);
  static const Color appF9E8E6CardBG6 = Color(0xFFF9E8E6);
  static const Color appF9E8CACardBG6 = Color(0xFFF9E8CA);
  // system State
  static const Color app4CAF50Success = Color(0xFF4CAF50);
  static const Color appF44336Error = Color(0xFFF44336);
  static const Color appF59E0BWorning = Color(0xFFF59E0B);

  static const Color primary = Color(0xFFa41526);
  static const Color secondary = Color(0xFF000000);

  static Color get primary50 => primaryShadesFrom(primary)[50]!;
  static Color get primary100 => primaryShadesFrom(primary)[100]!;
  static Color get primary200 => primaryShadesFrom(primary)[200]!;
  static Color get primary300 => primaryShadesFrom(primary)[300]!;
  static Color get primary400 => primaryShadesFrom(primary)[400]!;
  static Color get primary500 => primaryShadesFrom(primary)[500]!;
  static Color get primary600 => primaryShadesFrom(primary)[600]!;
  static Color get primary700 => primaryShadesFrom(primary)[700]!;
  static Color get primary800 => primaryShadesFrom(primary)[800]!;
  static Color get primary900 => primaryShadesFrom(primary)[900]!;
}

/// Builds Material-style primary shades (50–900) from a base [color].
Map<int, Color> primaryShadesFrom(Color color) {
  const shadeKeys = [50, 100, 200, 300, 400, 500, 600, 700, 800, 900];
  const strengths = [0.05, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9];

  return Map.fromIterables(
    shadeKeys,
    strengths.map((strength) => _shadeFromPrimary(color, strength)),
  );
}

Color _shadeFromPrimary(Color color, double strength) {
  final blend = 0.5 - strength;
  int channel(double component) {
    final value = (component * 255).round();
    return (value + ((blend < 0 ? value : (255 - value)) * blend))
        .round()
        .clamp(0, 255);
  }

  return Color.fromARGB(
    (color.a * 255).round(),
    channel(color.r),
    channel(color.g),
    channel(color.b),
  );
}

/// Primary swatch for the app
final MaterialColor appPrimarySwatch = MaterialColor(
  AppColors.primary.toARGB32(),
  primaryShadesFrom(AppColors.primary),
);

/// App theme; pass [seedColor] for tenant primary branding and
/// [secondaryColor] for action buttons.
ThemeData buildAppTheme({
  Color? seedColor,
  Color? secondaryColor,
}) {
  final primary = seedColor ?? AppColors.primary;
  final secondary = secondaryColor ?? AppColors.secondary;
  final swatch = MaterialColor(
    primary.toARGB32(),
    primaryShadesFrom(primary),
  );

  return ThemeData(
    fontFamily: 'NotoSansArabic',
    primarySwatch: swatch,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primary,
      primary: primary,
      secondary: secondary,
    ),
    useMaterial3: true,
    appBarTheme: AppBarTheme(
      backgroundColor: primary,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    dropdownMenuTheme: DropdownMenuThemeData(
      menuStyle: MenuStyle(
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: secondary,
        foregroundColor: Colors.white,
        elevation: 2,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        minimumSize: const Size(88, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: secondary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        minimumSize: const Size(88, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
  );
}

/// Default theme for non-flavor local runs.
ThemeData get appTheme => buildAppTheme();
