import 'package:flutter/material.dart';

/// Provides a way for screens to change the app locale (e.g. language menu).
class LocaleScope extends InheritedWidget {
  const LocaleScope({
    super.key,
    required this.setLocale,
    required super.child,
  });

  final Future<void> Function(String languageCode) setLocale;

  static LocaleScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<LocaleScope>();
    assert(scope != null, 'No LocaleScope found in context');
    return scope!;
  }

  @override
  bool updateShouldNotify(LocaleScope oldWidget) =>
      setLocale != oldWidget.setLocale;
}
