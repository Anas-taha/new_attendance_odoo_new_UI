import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hr_app_odoo/custom_widgets/custom_calender/custom_calender.dart';
import 'package:hr_app_odoo/features/attendance/data/model/attendance_model.dart';
import 'package:hr_app_odoo/features/attendance/data/repositories/attendance_repository_impl.dart';
import 'package:hr_app_odoo/features/attendance/domain/repositories/attendance_repository.dart';
import 'package:hr_app_odoo/generated/l10n/app_localizations.dart';
import 'package:hr_app_odoo/models/hr_attendance.dart';
import 'package:hr_app_odoo/models/hr_employee.dart';
import 'package:hr_app_odoo/theme/app_theme.dart';

enum AttendanceStateEnum { leaveEarly, absences, holidays, lateArrival }

class AttendanceController extends GetxController {
  AttendanceController({AttendanceRepository? attendanceRepository})
    : _attendanceRepository =
          attendanceRepository ?? AttendanceRepositoryImpl();

  final AttendanceRepository _attendanceRepository;
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
  RxInt selectedWeekCard = 0.obs;
  Rx<List<AttendanceModel>> allAttendanceRecords = Rx<List<AttendanceModel>>(
    [],
  );
  Rx<List<WeekInfoModel>> weekInfo = Rx<List<WeekInfoModel>>([]);

  void init() {
    selectedWeekCard.value = -1;
    getAttendanceRecords();
  }

  Future<void> getAttendanceRecords() async {
    isLoading.value = true;
    final result = await _attendanceRepository.getAllAttendance();
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
      for (var item in data) {
        DateTime date = DateTime.parse(item.checkIn!);
        int weekNumber = ((date.day - 1) ~/ 7) + 1;
        weeksMap.putIfAbsent(weekNumber, () => []);
        weeksMap[weekNumber]!.add(item);
      }

      List<WeekInfoModel> result = [];
      weeksMap.forEach((week, items) {
        items.sort(
          (a, b) =>
              DateTime.parse(a.checkIn!).compareTo(DateTime.parse(b.checkIn!)),
        );

        DateTime start = DateTime.parse(items.first.checkIn!);
        DateTime end = DateTime.parse(items.last.checkIn!);

        final l10n = _tryLocalizations();
        List<DayInfoModel> days = items.map((item) {
          DateTime date = DateTime.parse(item.checkIn!);
          return DayInfoModel(
            date: _formatDate(date),
            description: _getDescription(item, l10n),
          );
        }).toList();

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
            weekNum: l10n?.attendanceWeekNumber(week) ?? 'Week $week',
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

  String _formatDate(DateTime date) => "${date.year}-${date.month}-${date.day}";

  AppLocalizations? _tryLocalizations() {
    final ctx = Get.context;
    if (ctx == null) {
      return null;
    }
    return AppLocalizations.of(ctx);
  }

  String _getDescription(AttendanceModel item, AppLocalizations? l10n) {
    num hours = item.workedHours ?? 0;
    if (l10n == null) {
      if (hours == 0) {
        return 'Absent';
      }
      if (hours < 1) {
        return 'Left early';
      }
      if (hours < 8) {
        return 'Late';
      }
      return 'Full day';
    }
    if (hours == 0) {
      return l10n.attendanceStatusAbsent;
    }
    if (hours < 1) {
      return l10n.attendanceStatusLeftEarly;
    }
    if (hours < 8) {
      return l10n.attendanceStatusLate;
    }
    return l10n.attendanceStatusFullDay;
  }

  void selectWeekCard(int index) {
    selectedWeekCard.value = index;
  }

  void selectDate() {
    final ctx = Get.context;
    final title = ctx == null ? '' : AppLocalizations.of(ctx)!.selectDate;
    CustomCalender.calenderDialog(contorller: dateController, title: title);
  }

  Future<void> loadAttendanceData() async {
    isLoading.value = true;
    try {
      currentEmployee = await _attendanceRepository.getCurrentEmployee();
      if (currentEmployee != null) {
        final summary = await _attendanceRepository.getTodayAttendanceSummary(
          employeeId: currentEmployee!.profile?.id,
        );
        log(summary.toString(), name: "is_checked_in");

        isCheckedIn = summary['is_checked_in'] ?? false;
        totalWorkedHours = summary['total_worked_hours'] ?? '00:00:00';
        todayRecords = List<HrAttendance>.from(summary['today_records'] ?? []);
        isLoading.value = false;

        if (summary['current_check_in'] != null) {
          final currentCheckIn = summary['current_check_in'] as DateTime;
          checkInDateTime = currentCheckIn;
          checkInTime =
              '${currentCheckIn.hour.toString().padLeft(2, '0')}:${currentCheckIn.minute.toString().padLeft(2, '0')}:${currentCheckIn.second.toString().padLeft(2, '0')}';
        } else {
          checkInDateTime = null;
          checkInTime = '--:--:--';
        }

        if (isCheckedIn && checkInDateTime != null) {
          startTimer();
          pulseController.repeat();
        } else {
          stopTimer();
          pulseController.stop();
        }
      }
    } catch (e) {
      isLoading.value = false;
    }
  }

  Future<void> refreshAttendanceState() async {
    try {
      final summary = await _attendanceRepository.getTodayAttendanceSummary();
      if (summary.isNotEmpty) {
        isCheckedIn = summary['is_checked_in'] ?? false;
        totalWorkedHours = summary['total_worked_hours'] ?? '00:00:00';

        if (summary['current_check_in'] != null) {
          final currentCheckIn = summary['current_check_in'] as DateTime;
          checkInDateTime = currentCheckIn;
          checkInTime =
              '${currentCheckIn.hour.toString().padLeft(2, '0')}:${currentCheckIn.minute.toString().padLeft(2, '0')}:${currentCheckIn.second.toString().padLeft(2, '0')}';
        } else {
          checkInDateTime = null;
          checkInTime = '--:--:--';
        }

        if (isCheckedIn && checkInDateTime != null) {
          startTimer();
          pulseController.repeat();
        } else {
          stopTimer();
          pulseController.stop();
        }

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
    } catch (_) {}
  }

  Future<void> handleCheckInOut() async {
    try {
      bool success;
      if (isCheckedIn) {
        success = await _attendanceRepository.checkOut(
          employeeId: currentEmployee?.profile?.id,
        );
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
        success = await _attendanceRepository.checkIn(
          employeeId: currentEmployee?.profile?.id,
        );
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
        await loadAttendanceData();
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
