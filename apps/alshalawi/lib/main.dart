import 'package:flutter/material.dart';
import 'package:hr_core/hr_core.dart';

void main() {
  runHrCoreApp(
    config: const TenantConfig(
      appName: 'ALSHALAWI',
      odooBaseUrl: 'https://al-shalawi.gulftriangle.net/mobile/',
      odooDatabase: 'al-shalawi',
      primaryColor: Color(0xFF39493f),
      secondaryColor: Color(0xFFc7a67c),
      logoAssetPath: 'assets/branding/logo.png',
    ),
  );
}
