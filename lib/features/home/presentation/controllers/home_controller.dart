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
import 'package:hr_app_odoo/services/face_attendance_service.dart';
import 'package:hr_app_odoo/services/local_storage_service.dart';
import 'package:hr_app_odoo/services/location_service.dart';
import 'package:hr_app_odoo/services/odoo_rpc_service.dart';

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
    FaceAttendanceService? faceAttendanceService,
  }) : _homeRepository = homeRepository ?? HomeRepositoryImpl(),
       _notificationRepository =
           notificationRepository ?? NotificationRepositoryImpl(),
       _locationService = locationService ?? LocationService(),
       _faceService = faceAttendanceService ?? FaceAttendanceService.instance;
  TextEditingController addressController = TextEditingController();
  RxInt seconds = 0.obs;
  RxBool isCheckedIn = false.obs;
  final checkInDateTime = Rxn<DateTime>();
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
  final FaceAttendanceService _faceService;
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
    _initializeAttendance();
  }

  Future<void> _initializeAttendance() async {
    await _ensureEmployeeId();
    await loadEmployeeData();
    await loadTodayAttendance();
  }

  Future<void> _ensureEmployeeId() async {
    if (OdooRPCService.instance.currentEmployeeId != null) {
      return;
    }

    final employee = await _homeRepository.getCurrentEmployee();
    if (employee?.profile?.id != null) {
      OdooRPCService.instance.setCurrentEmployeeId(employee!.profile!.id!);
    }
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
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (checkInDateTime.value != null) {
        elapsed.value = DateTime.now().difference(checkInDateTime.value!);
      }
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

  Duration _parseHms(String value) {
    final parts = value.split(':');
    if (parts.length != 3) {
      return Duration.zero;
    }

    final hours = int.tryParse(parts[0]) ?? 0;
    final minutes = int.tryParse(parts[1]) ?? 0;
    final seconds = int.tryParse(parts[2]) ?? 0;
    return Duration(hours: hours, minutes: minutes, seconds: seconds);
  }

  String _formatHms(Duration duration) {
    final totalSeconds = duration.inSeconds;
    final hours = (totalSeconds ~/ 3600).toString().padLeft(2, '0');
    final minutes = ((totalSeconds % 3600) ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  String get formattedTime {
    final workedToday = _parseHms(totalToday.value);
    final sessionElapsed =
        isCheckedIn.value ? elapsed.value : Duration.zero;
    return _formatHms(workedToday + sessionElapsed);
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
      checkInDateTime.value = summary['current_check_in'] is DateTime
          ? summary['current_check_in'] as DateTime
          : null;

      if (checkInDateTime.value != null) {
        final nowCheckIn = checkInDateTime.value!;
        checkInTime.value =
            '${nowCheckIn.hour.toString().padLeft(2, '0')}:${nowCheckIn.minute.toString().padLeft(2, '0')}:${nowCheckIn.second.toString().padLeft(2, '0')}';
      } else {
        checkInTime.value = '--:--:--';
      }

      if (isCheckedIn.value && checkInDateTime.value != null) {
        startTimer();
        _syncSessionTimer();
      } else {
        stopTimer();
        _syncSessionTimer();
      }
    } catch (e, stackTrace) {
      log(
        'Error loading attendance data: $e',
        name: 'HomeController',
        stackTrace: stackTrace,
      );
    }
  }

  void _syncSessionTimer() {
    if (isCheckedIn.value && checkInDateTime.value != null) {
      elapsed.value = DateTime.now().difference(checkInDateTime.value!);
      if (!isRunning.value) {
        _startTimer();
      }
      return;
    }

    _stopTimer();
    elapsed.value = Duration.zero;
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

  Future<void> handleFaceAttendance() async {
    if (isLoading.value) {
      return;
    }

    isLoading.value = true;
    try {
      await _ensureEmployeeId();

      final status = await _faceService.getCurrentAttendanceStatus();
      final currentlyCheckedIn = status['is_checked_in'] == true;

      final imageData = await _faceService.pickImageFromGallery();
      if (imageData['success'] != true) {
        _showAttendanceMessage(
          imageData['error']?.toString() ??
              Get.context!.appWords.couldNotSelectImage,
          isError: true,
        );
        return;
      }

      final latitude = (imageData['latitude'] as num?)?.toDouble();
      final longitude = (imageData['longitude'] as num?)?.toDouble();
      final base64Image = imageData['image'] as String?;

      if (base64Image == null || base64Image.isEmpty) {
        _showAttendanceMessage(
          Get.context!.appWords.faceImageNotSelected,
          isError: true,
        );
        return;
      }

      final resolvedAddress = (imageData['address'] as String?)?.trim();
      if (resolvedAddress != null && resolvedAddress.isNotEmpty) {
        address.value = resolvedAddress;
        addressController.text = resolvedAddress;
        await LocalStorageService().saveAddress(resolvedAddress);
      } else if (address.value.isEmpty) {
        await resolveLocationAndAddress(forceRefresh: true);
      }

      if (latitude != null && longitude != null) {
        position = Position(
          latitude: latitude,
          longitude: longitude,
          timestamp: DateTime.now(),
          accuracy: 0,
          altitude: 0,
          altitudeAccuracy: 0,
          heading: 0,
          headingAccuracy: 0,
          speed: 0,
          speedAccuracy: 0,
        );
      }

      final result = await _faceService.submitFaceAttendanceWithFallback(
        base64Image: base64Image,
        latitude: latitude ?? position.latitude,
        longitude: longitude ?? position.longitude,
        address: address.value.isNotEmpty ? address.value : resolvedAddress,
      );

      log('Attendance API result: $result', name: 'HomeController');

      if (result['success'] == true) {
        await loadTodayAttendance();

        final l10n = Get.context!.appWords;
        final action = result['action']?.toString() ?? '';
        final message =
            result['message']?.toString() ??
            (action == 'check_out' || currentlyCheckedIn
                ? l10n.checkoutCompletedSuccess
                : l10n.checkinCompletedSuccess);

        _showAttendanceMessage(message, isError: false);
        return;
      }

      _showAttendanceMessage(
        result['error']?.toString() ??
            Get.context!.appWords.attendanceActionFailed,
        isError: true,
      );
    } catch (e, stackTrace) {
      log(
        'Attendance error: $e',
        name: 'HomeController',
        stackTrace: stackTrace,
      );
      _showAttendanceMessage(
        Get.context!.appWords.errorGeneric(e.toString()),
        isError: true,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void _showAttendanceMessage(String message, {required bool isError}) {
    final context = Get.context;
    if (context == null) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
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
