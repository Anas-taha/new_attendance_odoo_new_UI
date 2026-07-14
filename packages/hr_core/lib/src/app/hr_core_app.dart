import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hr_core/generated/l10n/app_localizations.dart';
import 'package:hr_core/src/app/app_locale.dart';
import 'package:hr_core/src/app/app_route.dart';
import 'package:hr_core/src/config/odoo_config.dart';
import 'package:hr_core/src/config/tenant_config.dart';
import 'package:hr_core/src/theme/app_theme.dart';

/// Root widget for a white-label HR app backed by [hr_core].
class HrCoreApp extends StatelessWidget {
  const HrCoreApp({super.key, required this.config});

  final TenantConfig config;

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
            title: config.appName,
            theme: buildAppTheme(
              seedColor: config.primaryColor,
              secondaryColor: config.secondaryColor,
            ),
            locale: controller.locale,
            fallbackLocale: const Locale('ar'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
          ),
        );
      },
    );
  }
}

/// Initializes GetX, Odoo config, and runs the shared HR application.
void runHrCoreApp({required TenantConfig config}) {
  WidgetsFlutterBinding.ensureInitialized();
  OdooConfig.init(config);
  Get.put(AppLocaleController());
  runApp(HrCoreApp(config: config));
}
