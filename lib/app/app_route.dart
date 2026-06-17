import 'package:get/get.dart';
import 'package:hr_app_odoo/features/attendance/presentation/controllers/attendance_controller.dart';
import 'package:hr_app_odoo/features/attendance/presentation/pages/attendance_screen.dart';
import 'package:hr_app_odoo/features/auth/presentation/controller/login_controller.dart';
import 'package:hr_app_odoo/features/auth/presentation/controller/register_face_controller.dart';
import 'package:hr_app_odoo/features/auth/presentation/pages/login_screen.dart';
import 'package:hr_app_odoo/features/auth/presentation/pages/register_face_screen.dart';
import 'package:hr_app_odoo/features/holidays/presentation/controller/holidays_controller.dart';
import 'package:hr_app_odoo/features/holidays/presentation/pages/holidays_screen.dart';
import 'package:hr_app_odoo/features/holidays/presentation/pages/request_holiday_screen.dart';
import 'package:hr_app_odoo/features/home/presentation/controllers/home_controller.dart';
import 'package:hr_app_odoo/features/home/presentation/pages/home_screen.dart';
import 'package:hr_app_odoo/features/notification/presentation/controllers/notification_controller.dart';
import 'package:hr_app_odoo/features/notification/presentation/pages/notification_screen.dart';
import 'package:hr_app_odoo/features/payslip/presentaion/controller/payslip_controller.dart';
import 'package:hr_app_odoo/features/payslip/presentaion/pages/payslip_screen.dart';
import 'package:hr_app_odoo/features/profile/presentation/controller/profile_controller.dart';
import 'package:hr_app_odoo/features/profile/presentation/controllers/profile_controller.dart';
import 'package:hr_app_odoo/features/profile/presentation/pages/profile_screen.dart';
import 'package:hr_app_odoo/features/payslip/presentation/controllers/payslip_controller.dart';
// import 'package:hr_app_odoo/features/payslip/presentation/pages/payslip_screen.dart';
import 'package:hr_app_odoo/screens/attendance_report_screen.dart';
import 'package:hr_app_odoo/screens/contracts_screen.dart';
import 'package:hr_app_odoo/screens/expense_create_screen.dart';
import 'package:hr_app_odoo/screens/expense_screen.dart';
import 'package:hr_app_odoo/screens/face_attendance_screen.dart';
import 'package:hr_app_odoo/screens/team_off_screen.dart';

class AppRoutes {
  static const login = '/login';
  static const registerFace = '/register-face';
  static const home = '/home';
  static const notifications = '/notifications';
  static const attendance = '/attendance';
  static const attendanceReport = '/attendance-report';
  static const faceAttendance = '/face-attendance';
  static const expenses = '/expenses';
  static const expenseCreate = '/expense-create';
  static const payslips = '/payslips';
  static const salaries = '/salaries';
  static const contracts = '/contracts';
  static const timeOff = '/time-off';
  static const holidays = '/holidays';
  static const requestHoliday = '/requestHoliday';
  static const profile = '/profile';
}

class AppPages {
  static final pages = [
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<LoginController>(() => LoginController(), fenix: true);
      }),
    ),
    GetPage(
      name: AppRoutes.registerFace,
      page: () => RegisterFaceScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<RegisterFaceController>(
          () => RegisterFaceController(),
          fenix: true,
        );
      }),
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeScreen(),
      binding: BindingsBuilder(() {
        Get.put(HomeController());
      }),
    ),
    GetPage(
      name: AppRoutes.notifications,
      page: () => NotificationScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<NotificationController>(
          () => NotificationController(),
          fenix: true,
        );
      }),
    ),
    GetPage(
      name: AppRoutes.attendance,
      page: () => const AttendanceScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<AttendanceController>(
          () => AttendanceController(),
          fenix: true,
        );
      }),
    ),
    GetPage(
      name: AppRoutes.attendanceReport,
      page: () => const AttendanceReportScreen(),
    ),
    // GetPage(
    //   name: AppRoutes.faceAttendance,
    //   page: () => const FaceAttendanceScreen(),
    // ),
    GetPage(name: AppRoutes.expenses, page: () => const ExpenseScreen()),
    // GetPage(
    //   name: AppRoutes.expenseCreate,
    //   page: () => const ExpenseCreateScreen(),
    // ),
    // GetPage(name: AppRoutes.payslips, page: () => const PayslipScreen()),
    GetPage(
      name: AppRoutes.payslips,
      page: () => PayslipScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<PayslipController>(() => PayslipController(), fenix: true);
      }),
    ),
    // GetPage(name: AppRoutes.contracts, page: () => const ContractsScreen()),
    // GetPage(name: AppRoutes.timeOff, page: () => const TeamOffScreen()),
    GetPage(
      name: AppRoutes.requestHoliday,
      page: () => const RequestHolidayScreen(),
    ),
    GetPage(
      name: AppRoutes.profile,
      page: () => ProfileScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<ProfileController>(() => ProfileController(), fenix: true);
      }),
    ),
    GetPage(
      name: AppRoutes.holidays,
      page: () => const HolidaysScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<HolidaysController>(
          () => HolidaysController(),
          fenix: true,
        );
      }),
    ),
  ];
}
