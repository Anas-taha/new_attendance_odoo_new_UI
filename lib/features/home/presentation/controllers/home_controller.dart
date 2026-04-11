import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hr_app_odoo/features/home/data/repositories/home_repository_impl.dart';
import 'package:hr_app_odoo/features/home/domain/repositories/home_repository.dart';
import 'package:hr_app_odoo/generated/l10n/app_localizations.dart';
import 'package:hr_app_odoo/models/hr_attendance.dart';
import 'package:hr_app_odoo/models/hr_employee.dart';
import 'package:hr_app_odoo/services/local_storage_service.dart';

sealed class HomeUiEvent {
  const HomeUiEvent();
}

class ShowLogoutConfirmationEvent extends HomeUiEvent {
  const ShowLogoutConfirmationEvent();
}

class LogoutSuccessEvent extends HomeUiEvent {
  const LogoutSuccessEvent();
}

class HomeSuccessMessageEvent extends HomeUiEvent {
  const HomeSuccessMessageEvent(this.messageKey);

  final String messageKey;
}

class HomeErrorMessageEvent extends HomeUiEvent {
  const HomeErrorMessageEvent(this.messageKey, {this.errorDetail});

  final String messageKey;
  final String? errorDetail;
}

class HomeController extends GetxController {
  HomeController({HomeRepository? homeRepository})
    : _homeRepository = homeRepository ?? HomeRepositoryImpl();

  RxInt seconds = 0.obs;
  RxBool isCheckedIn = false.obs;
  Rx<DateTime?> checkInDateTime = DateTime.now().obs;
  Timer? timer;
  Rx<HrEmployee?> currentEmployee = Rx<HrEmployee?>(null);
  Rx<String> checkInTime = Rx<String>("--:--:--");
  String checkOutTime = "--:--:--";
  Rx<String> totalToday = Rx<String>("00:00:00");
  Rx<String> beforeTime = Rx<String>("00:00");
  Rxn<HomeUiEvent> uiEvent = Rxn<HomeUiEvent>();
  RxList<String> lastNotivication = RxList<String>([]);
  RxString userName = ''.obs;

  final HomeRepository _homeRepository;

  Rx<List<HrAttendance>> todayAttendance = Rx<List<HrAttendance>>([]);
  RxString currentDate = ''.obs;
  RxBool isAm = true.obs;
  
  @override
  void onInit() {
    super.onInit();
    _stopTimer();
  }

  void initData() {
    getUserName();
    getCurrentDate();
    timeIsAm();
    // loadEmployeeData();
    // loadTodayAttendance();
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }

  void getUserName() async {
    userName.value = await LocalStorageService().getSavedName() ?? '';
  }

  //--------------------- Date Handling ---------------------
  void getCurrentDate() {
    final now = DateTime.now();

    const months = [
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر',
    ];

    currentDate.value = '${now.day} ${months[now.month - 1]} ${now.year}';
  }

  void timeIsAm() {
    final now = DateTime.now();
    if (now.hour < 12) {
      isAm.value = true;
    } else {
      isAm.value = false;
    }
  }

  //--------------------- Timer Handling ---------------------
  final elapsed = Duration.zero.obs;
  final isRunning = false.obs;

  Timer? _timer;

  void timerSwitchButton() {
    if (isRunning.value) {
      _stopTimer();
    } else {
      _startTimer();
    }
  }

  void _startTimer() {
    isRunning.value = true;
    _timer = Timer.periodic(const Duration(milliseconds: 10), (_) {
      elapsed.value += const Duration(milliseconds: 10);
    });
  }

  void _stopTimer() {
    isRunning.value = false;
    _timer?.cancel();
  }

  void reset() {
    _stopTimer();
    elapsed.value = Duration.zero;
  }

  String get formattedTime {
    final ms = elapsed.value.inMilliseconds;
    final minutes = (ms ~/ 60000).toString().padLeft(2, '0');
    final seconds = ((ms % 60000) ~/ 1000).toString().padLeft(2, '0');
    final centis = ((ms % 1000) ~/ 10).toString().padLeft(2, '0');
    return '$minutes:$seconds.$centis';
  }

  //============================================================//
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

  // @override
  // void onClose() {
  //   timer?.cancel();
  //   super.onClose();
  // }

  Future<void> loadEmployeeData() async {
    try {
      final employee = await _homeRepository.getCurrentEmployee();
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
      final summary = await _homeRepository.getTodayAttendanceSummary();
      totalToday.value =
          (summary['total_worked_hours'] as String?) ?? '00:00:00';
      isCheckedIn.value = (summary['is_checked_in'] as bool?) ?? false;
      todayAttendance.value =
          (summary['today_records'] as List<HrAttendance>?) ?? <HrAttendance>[];
      checkInDateTime.value = summary['current_check_in'] as DateTime?;

      if (checkInDateTime.value != null) {
        final nowCheckIn = checkInDateTime.value!;
        checkInTime.value =
            '${nowCheckIn.hour.toString().padLeft(2, '0')}:${nowCheckIn.minute.toString().padLeft(2, '0')}:${nowCheckIn.second.toString().padLeft(2, '0')}';
      } else {
        checkInTime.value = '--:--:--';
      }

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

  void requestLogout() {
    uiEvent.value = const ShowLogoutConfirmationEvent();
  }

  Future<void> confirmLogout() async {
    try {
      await _homeRepository.logout();
      uiEvent.value = const HomeSuccessMessageEvent('loggedOutSuccess');
      uiEvent.value = const LogoutSuccessEvent();
    } catch (e) {
      uiEvent.value = HomeErrorMessageEvent(
        'logoutError',
        errorDetail: e.toString(),
      );
    }
  }

  Future<void> toggleAttendance() async {
    try {
      if (isCheckedIn.value) {
        final success = await _homeRepository.checkOut();
        if (!success) {
          uiEvent.value = const HomeErrorMessageEvent('failedUpdateAttendance');
          return;
        }

        isCheckedIn.value = false;
        checkOutTime =
            '${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}:${DateTime.now().second.toString().padLeft(2, '0')}';
        checkInDateTime.value = null;
        stopTimer();
        await loadTodayAttendance();
        uiEvent.value = const HomeSuccessMessageEvent('successCheckedOut');
        return;
      }

      final success = await _homeRepository.checkIn();
      if (!success) {
        uiEvent.value = const HomeErrorMessageEvent('failedUpdateAttendance');
        return;
      }

      final checkIn = DateTime.now();
      isCheckedIn.value = true;
      checkInDateTime.value = checkIn;
      checkInTime.value =
          '${checkIn.hour.toString().padLeft(2, '0')}:${checkIn.minute.toString().padLeft(2, '0')}:${checkIn.second.toString().padLeft(2, '0')}';
      checkOutTime = '--:--:--';
      seconds.value = 0;
      startTimer();
      uiEvent.value = const HomeSuccessMessageEvent('successCheckedIn');
    } catch (e) {
      uiEvent.value = HomeErrorMessageEvent(
        'errorGeneric',
        errorDetail: e.toString(),
      );
    }
  }
}
