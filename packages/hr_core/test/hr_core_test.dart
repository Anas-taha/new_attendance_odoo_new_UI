import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hr_core/hr_core.dart';

void main() {
  test('TenantConfig holds branding values', () {
    const config = TenantConfig(
      appName: 'Test HR',
      odooBaseUrl: 'https://example.com/mobile/',
      odooDatabase: 'test_db',
      primaryColor: Color(0xFF670379),
      secondaryColor: Color(0xFF89734e),
    );

    expect(config.appName, 'Test HR');
    expect(config.odooBaseUrl, 'https://example.com/mobile/');
    expect(config.odooDatabase, 'test_db');
  });
}
