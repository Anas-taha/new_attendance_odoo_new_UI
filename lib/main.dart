import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hr_app_odoo/app/app_bending.dart';
import 'package:hr_app_odoo/app/app_locale.dart';
import 'package:hr_app_odoo/app/app_route.dart';

import 'app/locale_scope.dart';
import 'generated/l10n/app_localizations.dart';
import 'services/local_storage_service.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Get.put(AppLocaleController());
  runApp(const HrApp());
}

class HrApp extends StatelessWidget {
  const HrApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AppLocaleController>(
      builder: (controller) {
        return ScreenUtilInit(
          splitScreenMode: true,
          designSize: const Size(375, 812),
          child: GetMaterialApp(
            initialRoute: AppRoutes.login,
            getPages: AppPages.pages,
            debugShowCheckedModeBanner: false,
            title: 'HR App',
            theme: appTheme,
            locale: controller.locale,
            fallbackLocale: const Locale('en'),
            localizationsDelegates:
                AppLocalizations.localizationsDelegates,
            supportedLocales:
                AppLocalizations.supportedLocales,
          ),
        );
      },
    );
  }
}
// class HrApp extends StatefulWidget {
//   const HrApp({super.key});

//   @override
//   State<HrApp> createState() => _HrAppState();
// }

// class _HrAppState extends State<HrApp> {
//   Locale? _locale;
//   final LocalStorageService _storage = LocalStorageService();

//   @override
//   void initState() {
//     super.initState();
//     _loadSavedLocale();
//     Get.updateLocale(Locale('ar'));
//     // setLocale('ar'); // لا للنعوييم
//   }

//   Future<void> _loadSavedLocale() async {
//     final languageCode = await _storage.getSavedLocaleLanguage();
//     if (languageCode != null && languageCode.isNotEmpty) {
//       final countryCode = await _storage.getSavedLocaleCountry();
//       if (mounted) {
//         setState(() {
//           _locale = Locale(languageCode, countryCode);
//         });
//       }
//     }
//   }

//   /// Call this from anywhere (e.g. home screen language menu) to switch app language.
//   Future<void> setLocale(String languageCode) async {
//     await _storage.saveLocale(languageCode);
//     if (mounted) {
//       setState(() {
//         _locale = Locale(languageCode);
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return LocaleScope(
//       setLocale: setLocale,
//       child: ScreenUtilInit(
//         splitScreenMode: true,
//         designSize: Size(375, 812),
//         child: GetMaterialApp(
//           initialRoute: AppRoutes.login,
//           getPages: AppPages.pages,
//           fallbackLocale: _locale,
//           debugShowCheckedModeBanner: false,
//           title: 'HR App',
//           theme: appTheme,
//           localizationsDelegates: AppLocalizations.localizationsDelegates,
//           supportedLocales: AppLocalizations.supportedLocales,
//           locale: _locale,
//         ),
//       ),
//     );
//   }
// }
