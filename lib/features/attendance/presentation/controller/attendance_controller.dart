import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hr_app_odoo/custom_widgets/custom_calender/custom_calender.dart';
import 'package:hr_app_odoo/features/attendance/data/model/attendance_model.dart';
import 'package:hr_app_odoo/generated/l10n/app_localizations.dart';
import 'package:hr_app_odoo/models/hr_attendance.dart';
import 'package:hr_app_odoo/models/hr_employee.dart';
import 'package:hr_app_odoo/services/attendance_report_service.dart';
import 'package:hr_app_odoo/services/hr_service.dart';
import 'package:hr_app_odoo/theme/app_theme.dart';

enum AttendanceStateEnum { leaveEarly, absences, holidays, lateArrival }

class AttendanceController extends GetxController {
  final HrService hrService = HrService();
  HrEmployee? currentEmployee;
  List<HrAttendance> todayRecords = [];
  RxBool isLoading = false.obs;
  bool isCheckedIn = false;
  DateTime? checkInDateTime;
  String checkInTime = '--:--:--';
  RxString totalWorkedHours = '00:00:00'.obs;
  int seconds = 0;
  Timer? timer;
  late AnimationController pulseController;
  late AnimationController slideController;
  TextEditingController dateController = TextEditingController();
  RxList<String> weekCards = ['Week 1', 'Week 2', 'Week 3', 'Week 4'].obs;
  //-------------------------------------------------------
  RxInt selectedWeekCard = 0.obs;
  final AttendanceReportService reportService =
      AttendanceReportService.instance;
  Rx<List<AttendanceModel>> allAttendanceRecords = Rx<List<AttendanceModel>>(
    [],
  );
  Rx<List<WeekInfoModel>> weekInfo = Rx<List<WeekInfoModel>>([]);

  void init() {
    selectedWeekCard.value = -1;
    getAttendanceRecords();

    //  _pulseController = AnimationController(
    //   duration: const Duration(seconds: 2),
    //   vsync: this,
    // );
    // _slideController = AnimationController(
    //   duration: const Duration(milliseconds: 800),
    //   vsync: this,
    // );

    // // Initialize with passed values if available
    // if (widget.initialIsCheckedIn != null) {
    //   _isCheckedIn = widget.initialIsCheckedIn!;
    // }
    // if (widget.initialCheckInDateTime != null) {
    //   _checkInDateTime = widget.initialCheckInDateTime!;
    // }
    // if (widget.initialCheckInTime != null) {
    //   _checkInTime = widget.initialCheckInTime!;
    // }
    // if (widget.initialTotalWorkedHours != null) {
    //   _totalWorkedHours = widget.initialTotalWorkedHours!;
    // }

    // loadAttendanceData();
    // slideController.forward();
  }

  void getAttendanceRecords() async {
    isLoading.value = true;
    final result = await reportService.getAllAttendance();
    if (result.isNotEmpty) {
      allAttendanceRecords.value = result;
      weekInfo.value = mapToWeeks(result);
      isLoading.value = false;
    } else {
      allAttendanceRecords.value = [];
      isLoading.value = false;
    }
  }

  List<WeekInfoModel> mapToWeeks(List<AttendanceModel> data) {
    try {
      Map<int, List<AttendanceModel>> weeksMap = {};

      /// 🔹 تقسيم حسب الأسبوع
      for (var item in data) {
        DateTime date = DateTime.parse(item.checkIn!);
        int weekNumber = ((date.day - 1) ~/ 7) + 1;

        weeksMap.putIfAbsent(weekNumber, () => []);
        weeksMap[weekNumber]!.add(item);
      }

      /// 🔹 تحويل لـ WeekInfoModel
      List<WeekInfoModel> result = [];

      weeksMap.forEach((week, items) {
        items.sort(
          (a, b) =>
              DateTime.parse(a.checkIn!).compareTo(DateTime.parse(b.checkIn!)),
        );

        DateTime start = DateTime.parse(items.first.checkIn!);
        DateTime end = DateTime.parse(items.last.checkIn!);

        List<DayInfoModel> days = items.map((item) {
          DateTime date = DateTime.parse(item.checkIn!);

          return DayInfoModel(
            date: _formatDate(date),
            description: _getDescription(item),
          );
        }).toList();

        /// 🔥 counters (تقدر تطورهم بعدين حسب business logic)
        int late = 0;
        int early = 0;
        int absence = 0;
        int holidays = 0;

        for (var item in items) {
          num hours = item.workedHours ?? 0;

          if (hours == 0) {
            absence++;
          } else if (hours < 1) {
            early++;
          } else if (hours < 8) {
            late++;
          }
        }

        result.add(
          WeekInfoModel(
            weekNum: "Week $week",
            startDate: _formatDate(start),
            endDate: _formatDate(end),
            leaveEarlyNum: early,
            absencesNum: absence,
            holidaysNum: holidays,
            lateArrivalNum: late,
            days: days,
          ),
        );
      });

      return result;
    } catch (e) {
      log(name: 'weeksInfoList', 'mapToWeeks error: $e');
      return [];
    }
  }

  String _formatDate(DateTime date) {
    return "${date.year}-${date.month}-${date.day}";
  }

  String _getDescription(AttendanceModel item) {
    num hours = item.workedHours ?? 0;

    if (hours == 0) return "Absent ❌";
    if (hours < 1) return "Left Early ⚠️";
    if (hours < 8) return "Late ⏰";

    return "Full Day ✅";
  }

  void selectWeekCard(int index) {
    selectedWeekCard.value = index;
  }

  void selectDate() {
    CustomCalender.calenderDialog(contorller: dateController);
  }

  Future<void> loadAttendanceData() async {
    isLoading.value = true;

    try {
      // Get current employee
      currentEmployee = await hrService.getCurrentEmployee();

      if (currentEmployee != null) {
        // Get today's attendance summary
        final summary = await hrService.getTodayAttendanceSummary(
          employeeId: currentEmployee!.id,
        );
        log(summary.toString(), name: "is_checked_in");

        isCheckedIn = summary['is_checked_in'] ?? false;
        totalWorkedHours = summary['total_worked_hours'] ?? '00:00:00';
        todayRecords = List<HrAttendance>.from(summary['today_records'] ?? []);
        isLoading.value = false;

        // Set check-in time if available
        if (summary['current_check_in'] != null) {
          final _checkInTime = summary['current_check_in'] as DateTime;
          checkInDateTime = _checkInTime;
          checkInTime =
              '${_checkInTime.hour.toString().padLeft(2, '0')}:${_checkInTime.minute.toString().padLeft(2, '0')}:${_checkInTime.second.toString().padLeft(2, '0')}';
        } else {
          checkInDateTime = null;
          checkInTime = '--:--:--';
        }

        // Start or stop timer based on check-in status
        if (isCheckedIn && checkInDateTime != null) {
          startTimer();
          pulseController.repeat();
        } else {
          stopTimer();
          pulseController.stop();
        }
      }
    } catch (e) {
      print('Error loading attendance data: $e');

      isLoading.value = false;
    }
  }

  Future<void> refreshAttendanceState() async {
    try {
      final summary = await hrService.getTodayAttendanceSummary();
      if (summary.isNotEmpty) {
        isCheckedIn = summary['is_checked_in'] ?? false;
        totalWorkedHours = summary['total_worked_hours'] ?? '00:00:00';

        // Set check-in time if available
        if (summary['current_check_in'] != null) {
          final _checkInTime = summary['current_check_in'] as DateTime;
          checkInDateTime = _checkInTime;
          checkInTime =
              '${_checkInTime.hour.toString().padLeft(2, '0')}:${_checkInTime.minute.toString().padLeft(2, '0')}:${_checkInTime.second.toString().padLeft(2, '0')}';
        } else {
          checkInDateTime = null;
          checkInTime = '--:--:--';
        }

        // Start or stop timer based on check-in status
        if (isCheckedIn && checkInDateTime != null) {
          startTimer();
          pulseController.repeat();
        } else {
          stopTimer();
          pulseController.stop();
        }

        // Show appropriate message based on check-in status
        if (isCheckedIn) {
          final l10n = AppLocalizations.of(Get.context!)!;
          ScaffoldMessenger.of(Get.context!).showSnackBar(
            SnackBar(
              content: Text(l10n.alreadyCheckedInSnack(checkInTime)),
              backgroundColor: AppColors.primary600,
              duration: const Duration(seconds: 4),
              action: SnackBarAction(
                label: l10n.dismiss,
                textColor: Colors.white,
                onPressed: () {
                  ScaffoldMessenger.of(Get.context!).hideCurrentSnackBar();
                },
              ),
            ),
          );
        }
      }
    } catch (e) {
      print('Error refreshing attendance state: $e');
    }
  }

  Future<void> handleCheckInOut() async {
    try {
      bool success;
      if (isCheckedIn) {
        // Check out
        success = await hrService.checkOut(employeeId: currentEmployee?.id);
        if (success) {
          isCheckedIn = false;
          checkInDateTime = null;
          checkInTime = '--:--:--';

          stopTimer();
          pulseController.stop();

          ScaffoldMessenger.of(Get.context!).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(Get.context!)!.successCheckedOutShort,
              ),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        // Check in
        success = await hrService.checkIn(employeeId: currentEmployee?.id);
        if (success) {
          final now = DateTime.now();

          isCheckedIn = true;
          checkInDateTime = now;
          checkInTime =
              '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';

          startTimer();
          pulseController.repeat();
          ScaffoldMessenger.of(Get.context!).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(Get.context!)!.successCheckedInShort,
              ),
              backgroundColor: Colors.green,
            ),
          );
        }
      }

      if (success) {
        await loadAttendanceData(); // Reload data
      } else {
        ScaffoldMessenger.of(Get.context!).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(Get.context!)!.failedUpdateAttendanceShort,
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(Get.context!).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(Get.context!)!.errorGeneric(e.toString()),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void startTimer() {
    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (isCheckedIn && checkInDateTime != null) {
        final now = DateTime.now();
        final duration = now.difference(checkInDateTime!);

        seconds = duration.inSeconds;
      }
    });
  }

  void stopTimer() {
    timer?.cancel();
    timer = null;

    seconds = 0;
  }
}

class WeekInfoModel {
  final String weekNum;
  final String startDate;
  final String endDate;
  final int leaveEarlyNum;
  final int absencesNum;
  final int holidaysNum;
  final int lateArrivalNum;
  final List<DayInfoModel> days;

  const WeekInfoModel({
    required this.weekNum,
    required this.startDate,
    required this.endDate,
    required this.leaveEarlyNum,
    required this.absencesNum,
    required this.holidaysNum,
    required this.lateArrivalNum,
    required this.days,
  });
}

class DayInfoModel {
  final String date;
  final String description;

  const DayInfoModel({required this.date, required this.description});
}
