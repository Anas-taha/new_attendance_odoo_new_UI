import 'package:flutter/material.dart';
import 'package:hr_app_odoo/generated/l10n/app_localizations.dart';

extension LanguageExtension on BuildContext {
  AppLocalizations get appWords => AppLocalizations.of(this)!;
}
