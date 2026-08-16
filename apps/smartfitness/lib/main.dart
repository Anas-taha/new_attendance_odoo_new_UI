import 'package:flutter/material.dart';
import 'package:hr_core/hr_core.dart';

void main() {
  runHrCoreApp(
    config: const TenantConfig(
      appName: 'SMART FITNESS',
      odooBaseUrl: 'https://smartfitness.gulftriangle.net/mobile/',
      odooDatabase: 'main',
      secondaryColor: Color(0xFFa41526),
      primaryColor: Color(0xFF000000),
      logoAssetPath: 'assets/branding/smart_logo.png',
      headerImageAssetPath: 'assets/branding/smart_welcome_logo.png',
    ),
  );
}
