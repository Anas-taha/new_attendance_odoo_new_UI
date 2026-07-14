import 'package:flutter/material.dart';
import 'package:hr_core/hr_core.dart';

void main() {
  runHrCoreApp(
    config: const TenantConfig(
      appName: '{{APP_NAME}}',
      odooBaseUrl: '{{ODOO_BASE_URL}}',
      odooDatabase: '{{ODOO_DATABASE}}',
      primaryColor: Color(0xFF{{PRIMARY_COLOR}}),
      secondaryColor: Color(0xFF{{SECONDARY_COLOR}}),
      logoAssetPath: 'assets/branding/logo.png',
    ),
  );
}
