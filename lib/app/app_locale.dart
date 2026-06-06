import 'dart:ui';

import 'package:get/get.dart';
import 'package:hr_app_odoo/services/local_storage_service.dart';

class AppLocaleController extends GetxController {
  final LocalStorageService _storage = LocalStorageService();

  Locale locale = const Locale('ar');
  bool get isArabic => locale.languageCode == 'ar';
  Future<void> changeLang(String langCode) async {
    locale = Locale(langCode);

    await _storage.saveLocale(langCode);
    Get.updateLocale(locale);
    update();
  }

  @override
  void onInit() {
    super.onInit();
    _loadSavedLocale();
  }

  Future<void> _loadSavedLocale() async {
    final lang = await _storage.getSavedLocaleLanguage();
    if (lang != null && lang.isNotEmpty) {
      locale = Locale(lang);
    }
    Get.updateLocale(locale);
    update();
  }
}
