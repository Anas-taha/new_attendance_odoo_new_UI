import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hr_app_odoo/app/app_bending.dart';

import 'app/locale_scope.dart';
import 'generated/l10n/app_localizations.dart';
import 'services/local_storage_service.dart';
import 'theme/app_theme.dart';
import 'screens/login_screen.dart';
import 'features/home/presentation/pages/home_screen.dart';
import 'screens/attendance_screen.dart';
import 'screens/attendance_report_screen.dart';
import 'screens/face_attendance_screen.dart';
import 'screens/expense_screen.dart';
import 'screens/expense_create_screen.dart';
import 'screens/payslip_screen.dart';
import 'screens/contracts_screen.dart';
import 'screens/team_off_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const HrApp());
}

class HrApp extends StatefulWidget {
  const HrApp({super.key});

  @override
  State<HrApp> createState() => _HrAppState();
}

class _HrAppState extends State<HrApp> {
  Locale? _locale;
  final LocalStorageService _storage = LocalStorageService();

  @override
  void initState() {
    super.initState();
    _loadSavedLocale();
  }

  Future<void> _loadSavedLocale() async {
    final languageCode = await _storage.getSavedLocaleLanguage();
    if (languageCode != null && languageCode.isNotEmpty) {
      final countryCode = await _storage.getSavedLocaleCountry();
      if (mounted) {
        setState(() {
          _locale = Locale(languageCode, countryCode);
        });
      }
    }
  }

  /// Call this from anywhere (e.g. home screen language menu) to switch app language.
  Future<void> setLocale(String languageCode) async {
    await _storage.saveLocale(languageCode);
    if (mounted) {
      setState(() {
        _locale = Locale(languageCode);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return LocaleScope(
      setLocale: setLocale,
      child: ScreenUtilInit(
        splitScreenMode: true,
        designSize: Size(375, 812),
        child: GetMaterialApp(
          initialBinding: AppBinding(),
          debugShowCheckedModeBanner: false,
          title: 'HR App',
          theme: appTheme,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: _locale,
          home: const LoginScreen(),
          routes: {
            '/login': (context) => const LoginScreen(),
            '/home': (context) => const HomeScreen(),
            '/attendance': (context) => const AttendanceScreen(),
            '/attendance-report': (context) => const AttendanceReportScreen(),
            '/face-attendance': (context) => const FaceAttendanceScreen(),
            '/expenses': (context) => const ExpenseScreen(),
            '/expense-create': (context) => const ExpenseCreateScreen(),
            '/payslips': (context) => const PayslipScreen(),
            '/contracts': (context) => const ContractsScreen(),
            '/time-off': (context) => const TeamOffScreen(),
          },
        ),
      ),
    );
  }
}
