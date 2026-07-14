import 'package:flutter/material.dart';
import 'package:hr_core/hr_core.dart';

void main() {
  runHrCoreApp(
    config: const TenantConfig(
      appName: 'SMART FITNESS',
      odooBaseUrl: 'https://smartfitnesssa-fitness-gym.odoo.com/',
      odooDatabase: 'smartfitnesssa-fitness-gym-main-17599672',
      primaryColor: Color(0xFFa41526),
      secondaryColor: Color(0xFF000000),
      logoAssetPath: 'assets/branding/logo.png',
    ),
  );
}
