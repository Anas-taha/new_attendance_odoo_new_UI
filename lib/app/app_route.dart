import 'package:get/get.dart';
import 'package:hr_app_odoo/features/home/presentation/controllers/home_controller.dart';
import 'package:hr_app_odoo/features/home/presentation/pages/home_screen.dart';
import 'package:hr_app_odoo/features/notification/presentation/controller/notifi_controller.dart';
import 'package:hr_app_odoo/features/notification/presentation/pages/notification_screen.dart';
import 'package:hr_app_odoo/screens/attendance_report_screen.dart';
import 'package:hr_app_odoo/screens/attendance_screen.dart';
import 'package:hr_app_odoo/screens/contracts_screen.dart';
import 'package:hr_app_odoo/screens/expense_create_screen.dart';
import 'package:hr_app_odoo/screens/expense_screen.dart';
import 'package:hr_app_odoo/screens/face_attendance_screen.dart';
import 'package:hr_app_odoo/screens/login_screen.dart';
import 'package:hr_app_odoo/screens/payslip_screen.dart';
import 'package:hr_app_odoo/screens/team_off_screen.dart';

class AppRoutes {
  static const login = '/login';
  static const home = '/home';
  static const attendance = '/attendance';
  static const attendanceReport = '/attendance-report';
  static const faceAttendance = '/face-attendance';
  static const expenses = '/expenses';
  static const expenseCreate = '/expense-create';
  static const payslips = '/payslips';
  static const contracts = '/contracts';
  static const timeOff = '/time-off';

  static const notifications = '/notifications';
}

class AppPages {
  static final pages = [
    GetPage(name: AppRoutes.login, page: () => const LoginScreen()),
    GetPage(
      name: AppRoutes.home,
      page: () => HomeScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<HomeController>(() => HomeController());
      }),
    ),
    GetPage(
      name: AppRoutes.notifications,
      page: () => NotificationScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<NotificationController>((() => NotificationController()));
      }),
    ),
    GetPage(name: AppRoutes.attendance, page: () => const AttendanceScreen()),
    GetPage(
      name: AppRoutes.attendanceReport,
      page: () => const AttendanceReportScreen(),
    ),
    GetPage(
      name: AppRoutes.faceAttendance,
      page: () => const FaceAttendanceScreen(),
    ),
    GetPage(name: AppRoutes.expenses, page: () => const ExpenseScreen()),
    GetPage(
      name: AppRoutes.expenseCreate,
      page: () => const ExpenseCreateScreen(),
    ),
    GetPage(name: AppRoutes.payslips, page: () => const PayslipScreen()),
    GetPage(name: AppRoutes.contracts, page: () => const ContractsScreen()),
    GetPage(name: AppRoutes.timeOff, page: () => const TeamOffScreen()),
  ];
}


