import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hr_app_odoo/generated/l10n/app_localizations.dart';
import 'package:hr_app_odoo/models/hr_attendance.dart';
import 'package:hr_app_odoo/models/hr_employee.dart';
import 'package:hr_app_odoo/screens/login_screen.dart';
import 'package:hr_app_odoo/services/hr_service.dart';
import 'package:hr_app_odoo/services/local_storage_service.dart';
import 'package:hr_app_odoo/services/odoo_rpc_service.dart';
import 'package:hr_app_odoo/theme/app_theme.dart';

 class HomeController extends GetxController {
  RxInt seconds = 0.obs;
  RxBool isCheckedIn = false.obs;
  Rx<DateTime?> checkInDateTime = DateTime.now().obs;
  Timer? timer;
  Rx<HrEmployee?> currentEmployee = Rx<HrEmployee?>(null);
  Rx<String> checkInTime = Rx<String>("--:--:--");
  String checkOutTime = "--:--:--";
  Rx<String> totalToday = Rx<String>("00:00:00");
  Rx<String> beforeTime = Rx<String>("00:00");

  final HrService hrService = HrService();
  final OdooRPCService odooService = OdooRPCService.instance;

  Rx<List<HrAttendance>> todayAttendance = Rx<List<HrAttendance>>([]);
  void startTimer() {
    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (isCheckedIn.value && checkInDateTime.value != null) {
        final now = DateTime.now();
        final duration = now.difference(checkInDateTime.value!);
        seconds.value = duration.inSeconds;
      }
    });
  }

  void stopTimer() {
    timer?.cancel();
    timer = null;
    seconds.value = 0;
  }

  @override
  void onClose() {
    timer?.cancel();
    super.onClose();
  }

  Future<void> loadEmployeeData() async {
    try {
      final employee = await hrService.getCurrentEmployee();
      if (employee != null) {
        currentEmployee.value = employee;
      }
    } catch (e) {
      print('Error loading employee data: $e');
    }
  }

  String getCurrentTime() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }

  Future<void> loadTodayAttendance() async {
    try {
      final summary = await hrService.getTodayAttendanceSummary();
      if (summary['total_worked_hours'] != null) {
        totalToday.value = summary['total_worked_hours'] ?? '00:00:00';
      }
      if (summary['is_checked_in'] != null) {
        isCheckedIn.value = summary['is_checked_in'] ?? false;
      }
      if (summary['today_records'] != null) {
        todayAttendance.value = summary['today_records'] ?? [];
      }

      // Set check-in time if available
      if (summary['current_check_in'] != null) {
        DateTime checkInTime = summary['current_check_in'] as DateTime;
        checkInDateTime.value = checkInTime;
        checkInTime =
            '${checkInTime.hour.toString().padLeft(2, '0')}:${checkInTime.minute.toString().padLeft(2, '0')}:${checkInTime.second.toString().padLeft(2, '0')}'
                as DateTime;
      } else {
        checkInDateTime.value = null;
      }

      // Start or stop timer based on check-in status
      if (isCheckedIn.value && checkInDateTime.value != null) {
        startTimer();
      } else {
        stopTimer();
      }
    } catch (e) {
      print('Error loading attendance data: $e');
    }
  }

  String getGreeting(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final hour = DateTime.now().hour;
    final now = DateTime.now();
    final weekday = now.weekday;

    String timeGreeting;
    if (hour >= 5 && hour < 12) {
      timeGreeting = l10n.goodMorning;
    } else if (hour >= 12 && hour < 17) {
      timeGreeting = l10n.goodAfternoon;
    } else if (hour >= 17 && hour < 22) {
      timeGreeting = l10n.goodEvening;
    } else {
      timeGreeting = l10n.goodNight;
    }

    String dayName;
    switch (weekday) {
      case 1:
        dayName = l10n.monday;
        break;
      case 2:
        dayName = l10n.tuesday;
        break;
      case 3:
        dayName = l10n.wednesday;
        break;
      case 4:
        dayName = l10n.thursday;
        break;
      case 5:
        dayName = l10n.friday;
        break;
      case 6:
        dayName = l10n.saturday;
        break;
      case 7:
        dayName = l10n.sunday;
        break;
      default:
        dayName = '';
    }

    return l10n.greetingHappyDay(timeGreeting, dayName);
  }

  /// Handle logout
  Future<void> handleLogout() async {
    try {
      final l10n = AppLocalizations.of(Get.context!)!;
      final shouldLogout = await showDialog<bool>(
        context: Get.context!,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(l10n.logout),
            content: Text(l10n.logoutConfirm),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(l10n.cancel),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(l10n.logout),
              ),
            ],
          );
        },
      );

      if (shouldLogout == true) {
        // Clear all data
        final storage = LocalStorageService();
        await storage.clearAllData();

        // Clear Odoo service state
        odooService.logout();

        Get.snackbar(
          'Success',
          AppLocalizations.of(Get.context!)!.loggedOutSuccess,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        // ScaffoldMessenger.of(Get.context!).showSnackBar(
        //   SnackBar(
        //     content: Text(AppLocalizations.of(Get.context!)!.loggedOutSuccess),
        //     backgroundColor: Colors.green,
        //   ),
        // );

        // Navigate to login screen
        Get.offAll(() => const LoginScreen());
      }
    } catch (e) {
      Get.snackbar(
        'Failed',
        AppLocalizations.of(Get.context!)!.logoutError(e.toString()),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: Text(
      //       AppLocalizations.of(context)!.logoutError(e.toString()),
      //     ),
      //     backgroundColor: Colors.red,
      //   ),
      // );
    }
  }

  /// Handle check in/out with Odoo
  Future<void> handleCheckInOut() async {
    try {
      bool success;
      if (isCheckedIn.value) {
        // Check out
        success = await hrService.checkOut();
        if (success) {
          isCheckedIn.value = false;
          checkOutTime =
              '${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}:${DateTime.now().second.toString().padLeft(2, '0')}';
          checkInDateTime.value = null;

          stopTimer();
          // Reload attendance data
          loadTodayAttendance();
          Get.snackbar(
            'Success',
            AppLocalizations.of(Get.context!)!.successCheckedOut,
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
          // ScaffoldMessenger.of(context).showSnackBar(
          //   SnackBar(
          //     content: Text(AppLocalizations.of(context)!.successCheckedOut),
          //     backgroundColor: Colors.green,
          //   ),
          // );
        }
      } else {
        // Check in
        success = await hrService.checkIn();
        if (success) {
          final now = DateTime.now();

          isCheckedIn.value = true;
          checkInDateTime.value = now;
          checkInTime.value =
              '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
          checkOutTime = '--:--:--';
          seconds.value = 0;

          startTimer();
          Get.snackbar(
            'Success',
            AppLocalizations.of(Get.context!)!.successCheckedIn,
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
          // ScaffoldMessenger.of(context).showSnackBar(
          //   SnackBar(
          //     content: Text(AppLocalizations.of(context)!.successCheckedIn),
          //     backgroundColor: Colors.green,
          //   ),
          // );
        }
      }

      if (!success) {
        Get.snackbar(
          'Failed',
          AppLocalizations.of(Get.context!)!.failedUpdateAttendance,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
        );
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(
        //     content: Text(AppLocalizations.of(context)!.failedUpdateAttendance),
        //     backgroundColor: Colors.red,
        //     duration: const Duration(seconds: 4),
        //   ),
        // );
      }
    } catch (e) {
      Get.snackbar(
        'Failed',
        AppLocalizations.of(Get.context!)!.errorGeneric(e.toString()),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: Text(
      //       AppLocalizations.of(context)!.errorGeneric(e.toString()),
      //     ),
      //     backgroundColor: Colors.red,
      //   ),
      // );
    }
  }
}
