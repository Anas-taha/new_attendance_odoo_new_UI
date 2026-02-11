import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
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

class HrApp extends StatelessWidget {
  const HrApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'HR App',
      theme: appTheme,
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
    );
  }
}
