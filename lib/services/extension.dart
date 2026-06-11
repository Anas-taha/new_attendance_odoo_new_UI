import 'package:flutter/material.dart';
import 'package:hr_app_odoo/generated/l10n/app_localizations.dart';
import 'package:intl/intl.dart';

extension LanguageExtension on BuildContext {
  AppLocalizations get appWords => AppLocalizations.of(this)!;
}

extension DateExtension on String? {
  String getDateOnly({String fallback = ''}) {
    final value = this;

    if (value == null || value.trim().isEmpty) {
      return fallback;
    }

    final date = DateTime.tryParse(value);

    if (date == null) {
      return fallback;
    }

    return DateFormat('dd/MM/yyyy').format(date);
  }
}
