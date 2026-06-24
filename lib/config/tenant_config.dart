import 'package:flutter/material.dart';

/// Compile-time tenant configuration injected via `--dart-define-from-file`.
///
/// Example:
/// `flutter run --flavor alshalawi --dart-define-from-file=tenants/alshalawi.json`
class TenantConfig {
  TenantConfig._();

  static const String tenantId = String.fromEnvironment(
    'TENANT_ID',
    defaultValue: 'bluehr',
  );

  static const String appName = String.fromEnvironment(
    'APP_NAME',
    defaultValue: 'BLUE HR',
  );

  // static const String odooBaseUrl = String.fromEnvironment(
  //   'ODOO_BASE_URL',
  //   defaultValue: 'http://168.231.106.200:8193/mobile/',
  // );  
  static const String odooBaseUrl = String.fromEnvironment(
    'ODOO_BASE_URL',
    defaultValue: 'https://smartfitnesssa-fitness-gym.odoo.com/',
  ); 
  //  static const String odooBaseUrl = String.fromEnvironment(
  //   'ODOO_BASE_URL',
  //   defaultValue: 'https://al-shalawi.gulftriangle.net/mobile/',
  // );

  // static const String odooDatabase = String.fromEnvironment(
  //   'ODOO_DATABASE',
  //   defaultValue: 'al-shalawi',
  // ); 
  static const String odooDatabase = String.fromEnvironment(
    'ODOO_DATABASE',
    defaultValue: 'smartfitnesssa-fitness-gym-main-17599672',
  ); 
  // static const String odooDatabase = String.fromEnvironment(
  //   'ODOO_DATABASE',
  //   defaultValue: 'al-shalawi',
  // );

  /// Android application id / iOS bundle id suffix for this tenant build.
  static const String applicationId = String.fromEnvironment(
    'APPLICATION_ID',
    defaultValue: 'com.smartfitness.hr',
  );

  /// Optional brand primary color as RRGGBB (no `#`), e.g. `670379`.
  static const String primaryColorHex = String.fromEnvironment(
    'PRIMARY_COLOR',
    defaultValue: 'a41526',
  );

  static Color get primaryColor {
    final normalized = primaryColorHex.replaceAll('#', '').toUpperCase();
    if (normalized.length != 6) {
      return const Color(0xFFa41526);
    }
    return Color(int.parse('FF$normalized', radix: 16));
  }
}
