import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'config/odoo_config.dart';
import 'screens/odoo_config_screen.dart';
import 'screens/home_screen.dart';
import 'screens/attendance_screen.dart';
import 'screens/attendance_report_screen.dart';
import 'screens/face_attendance_screen.dart';
import 'screens/expense_screen.dart';
import 'screens/expense_create_screen.dart';
import 'screens/payslip_screen.dart';
import 'screens/contracts_screen.dart';
import 'screens/team_off_screen.dart';
import 'services/local_storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load Odoo configuration on app start
  await OdooConfig.loadConfiguration();

  runApp(const HrApp());
}

class HrApp extends StatelessWidget {
  const HrApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'HR App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.blue[600],
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      home: const _StartupRouter(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/config': (context) => const OdooConfigScreen(),
        '/attendance': (context) => const AttendanceScreen(),
        '/attendance-report': (context) => const AttendanceReportScreen(),
        '/face-attendance': (context) => const FaceAttendanceScreen(),
        '/expenses': (context) => const ExpenseScreen(),
        '/expense-create': (context) => const ExpenseCreateScreen(),
        '/payslips': (context) => const PayslipScreen(),
        '/contracts': (context) => const ContractsScreen(),
        '/time-off': (context) => const TeamOffScreen(),
      },
    );
  }
}

enum _StartupDestination { config, login }

class _StartupRouter extends StatelessWidget {
  const _StartupRouter({super.key});

  Future<_StartupDestination> _resolveDestination() async {
    final storage = LocalStorageService();
    final savedUrl = await storage.getOdooUrl();
    final savedDatabase = await storage.getOdooDatabase();
    final isFirstLogin = await storage.isFirstLogin();

    final hasConfig =
        (savedUrl != null && savedUrl.isNotEmpty) &&
        (savedDatabase != null && savedDatabase.isNotEmpty);

    if (!hasConfig || isFirstLogin) {
      return _StartupDestination.config;
    }

    return _StartupDestination.login;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_StartupDestination>(
      future: _resolveDestination(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.data == _StartupDestination.config) {
          return const OdooConfigScreen();
        }

        return const LoginScreen();
      },
    );
  }
}
