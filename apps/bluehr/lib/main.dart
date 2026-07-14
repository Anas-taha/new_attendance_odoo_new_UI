import 'package:flutter/material.dart';
import 'package:hr_core/hr_core.dart';

void main() {
  runHrCoreApp(
    config: const TenantConfig(
      appName: 'BLUE HR',
      odooBaseUrl: 'http://168.231.106.200:8193/mobile/',
      odooDatabase: 'hr_mobile_test',
      primaryColor: Color(0xFF670379),
      secondaryColor: Color(0xFF89734e),
      logoAssetPath: 'assets/branding/logo.png',
    ),
  );
}
