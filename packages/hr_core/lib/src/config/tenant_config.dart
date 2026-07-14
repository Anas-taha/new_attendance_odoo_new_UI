import 'package:flutter/material.dart';

/// Runtime tenant branding and Odoo connection settings.
///
/// Each company app shell constructs one instance and passes it to [runHrCoreApp].
class TenantConfig {
  const TenantConfig({
    required this.appName,
    required this.odooBaseUrl,
    required this.odooDatabase,
    required this.primaryColor,
    required this.secondaryColor,
    this.logoAssetPath,
  });

  final String appName;
  final String odooBaseUrl;
  final String odooDatabase;
  final Color primaryColor;
  final Color secondaryColor;

  /// Optional logo asset path declared in the app shell, e.g.
  /// `assets/branding/logo.png`.
  final String? logoAssetPath;
}
