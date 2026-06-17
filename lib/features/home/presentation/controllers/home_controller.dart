import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:hr_app_odoo/custom_widgets/custom_button/custom_button.dart';
import 'package:hr_app_odoo/custom_widgets/custom_dialog/custom_dialog.dart';
import 'package:hr_app_odoo/custom_widgets/custom_text/custom_text.dart';
import 'package:hr_app_odoo/custom_widgets/custom_text_field/custom_text_field.dart';
import 'package:hr_app_odoo/features/home/data/repositories/home_repository_impl.dart';
import 'package:hr_app_odoo/features/notification/data/repositories/notification_repository_impl.dart';
import 'package:hr_app_odoo/features/notification/domain/repositories/notification_repository.dart';
import 'package:hr_app_odoo/models/notification_model.dart';
import 'package:hr_app_odoo/features/home/domain/repositories/home_repository.dart';
import 'package:hr_app_odoo/generated/l10n/app_localizations.dart';
import 'package:hr_app_odoo/models/check_in_model.dart';
import 'package:hr_app_odoo/models/hr_attendance.dart';
import 'package:hr_app_odoo/models/hr_employee.dart';
import 'package:hr_app_odoo/services/extension.dart';
import 'package:hr_app_odoo/services/local_storage_service.dart';
import 'package:hr_app_odoo/services/location_service.dart';

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
  HomeController({
    HomeRepository? homeRepository,
    NotificationRepository? notificationRepository,
    LocationService? locationService,
  }) : _homeRepository = homeRepository ?? HomeRepositoryImpl(),
       _notificationRepository =
           notificationRepository ?? NotificationRepositoryImpl(),
       _locationService = locationService ?? LocationService();
  TextEditingController addressController = TextEditingController();
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
  RxList<Notifications> recentNotifications = RxList<Notifications>([]);
  RxString userName = ''.obs;

  final HomeRepository _homeRepository;
  final NotificationRepository _notificationRepository;
  final LocationService _locationService;
  RxBool isResolvingLocation = false.obs;
  RxBool isLoading = false.obs;
  RxString address = ''.obs;
  Rx<List<HrAttendance>> todayAttendance = Rx<List<HrAttendance>>([]);
  RxString currentDate = ''.obs;
  RxBool isAm = true.obs;
  CheckInModel checkInModel = CheckInModel();
  Position position = Position(
    longitude: 0,
    latitude: 0,
    timestamp: DateTime.now(),
    accuracy: 0,
    altitude: 0,
    altitudeAccuracy: 0,
    heading: 0,
    headingAccuracy: 0,
    speed: 0,
    speedAccuracy: 0,
  );

  @override
  void onInit() {
    super.onInit();
    _stopTimer();
  }

  @override
  void onReady() {
    super.onReady();
    getAddress();
    getUserName();
    getCurrentDate();
    timeIsAm();
    resolveLocationAndAddress();
    loadRecentNotifications();
  }

  Future<void> resolveLocationAndAddress({bool forceRefresh = false}) async {
    if (isResolvingLocation.value) {
      return;
    }

    isResolvingLocation.value = true;
    try {
      final currentPosition = await _locationService.getCurrentPosition();
      if (currentPosition == null) {
        if (address.value.isEmpty) {
          _showLocationError();
        }
        return;
      }

      position = currentPosition;

      final locationLabel = await _locationService.getCityDistrictLabel(
        latitude: currentPosition.latitude,
        longitude: currentPosition.longitude,
      );

      if (locationLabel == null || locationLabel.isEmpty) {
        if (address.value.isEmpty) {
          _showLocationError();
        }
        return;
      }

      if (forceRefresh || address.value.isEmpty || address.value != locationLabel) {
        address.value = locationLabel;
        addressController.text = locationLabel;
        await LocalStorageService().saveAddress(locationLabel);
      }
    } catch (e) {
      log('resolveLocationAndAddress failed: $e');
      if (address.value.isEmpty) {
        _showLocationError();
      }
    } finally {
      isResolvingLocation.value = false;
    }
  }

  void _showLocationError() {
    final l10n = Get.context?.appWords;
    if (l10n == null) {
      return;
    }
    Get.snackbar(
      l10n.locationTracking,
      l10n.locationPermissionDenied,
    );
  }

  Future<void> loadRecentNotifications() async {
    try {
      final model = await _notificationRepository.getNotification();
      recentNotifications.assignAll(
        (model.notifications ?? []).take(3).toList(),
      );
    } catch (e) {
      recentNotifications.clear();
    }
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
    var locale = AppLocalizations.of(Get.context!)!;
    List<String> months = [
      locale.january,
      locale.february,
      locale.march,
      locale.april,
      locale.may,
      locale.june,
      locale.july,
      locale.august,
      locale.september,
      locale.october,
      locale.november,
      locale.december,
    ];

    currentDate.value = '${now.day} ${months[now.month - 1]} ${now.year}';

    update();
  }

  void setAddress() {
    address.value = addressController.text;
    LocalStorageService().saveAddress(address.value);
    Get.back();
  }

  void getAddress() async {
    address.value = await LocalStorageService().getSavedAddress() ?? '';
    addressController.text = address.value;
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
    final hours = (ms ~/ 3600000).toString().padLeft(2, '0');
    final minutes = (ms ~/ 60000).toString().padLeft(2, '0');
    final seconds = ((ms % 60000) ~/ 1000).toString().padLeft(2, '0');
    final centis = ((ms % 1000) ~/ 10).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds.$centis';
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

  void checkIn() async {
    if (address.value.isEmpty) {
      await resolveLocationAndAddress(forceRefresh: true);
    }
    if (address.value.isEmpty) {
      addressDialog();
      return;
    }
    isLoading.value = true;
    await _homeRepository.getAttendanceCheck(
      latitude: position.latitude,
      longitude: position.longitude,
      address: address.value,
    );

    timerSwitchButton();
    isLoading.value = false;
  }

  Future<dynamic> addressDialog() async {
    return await CustomDialog.dialog(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomText(text: Get.context!.appWords.enterYourAddress),
          8.verticalSpace,
          CustomTextField(controller: addressController),
          8.verticalSpace,
          CustomButton(
            text: Get.context!.appWords.save,
            onTap: () {
              if (addressController.text.isEmpty) {
                Get.back();
                return;
              }
              setAddress();
            },
          ),
        ],
      ),
    );
  }
}
