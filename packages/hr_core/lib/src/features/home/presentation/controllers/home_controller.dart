import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:hr_core/src/custom_widgets/custom_button/custom_button.dart';
import 'package:hr_core/src/custom_widgets/custom_dialog/custom_dialog.dart';
import 'package:hr_core/src/custom_widgets/custom_text/custom_text.dart';
import 'package:hr_core/src/custom_widgets/custom_text_field/custom_text_field.dart';
import 'package:hr_core/src/features/home/data/repositories/home_repository_impl.dart';
import 'package:hr_core/src/features/notification/data/repositories/notification_repository_impl.dart';
import 'package:hr_core/src/features/notification/domain/repositories/notification_repository.dart';
import 'package:hr_core/src/models/notification_model.dart';
import 'package:hr_core/src/features/home/domain/repositories/home_repository.dart';
import 'package:hr_core/generated/l10n/app_localizations.dart';
import 'package:hr_core/src/models/check_in_model.dart';
import 'package:hr_core/src/models/hr_attendance.dart';
import 'package:hr_core/src/models/hr_employee.dart';
import 'package:hr_core/src/services/extension.dart';
import 'package:hr_core/src/services/face_attendance_service.dart';
import 'package:hr_core/src/services/local_storage_service.dart';
import 'package:hr_core/src/services/location_service.dart';
import 'package:hr_core/src/services/odoo_rpc_service.dart';

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
    await loadEmployeeData();
    await loadTodayAttendance();
  }

  Future<void> _ensureEmployeeId() async {
    if (OdooRPCService.instance.currentEmployeeId != null) {
      return;
    }

    final profileId = currentEmployee.value?.profile?.id;
    if (profileId != null) {
      OdooRPCService.instance.setCurrentEmployeeId(profileId);
      return;
    }

    final employee = await _homeRepository.getProfile();
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
    _stopTimer();
    _timer?.cancel();
    timer?.cancel();
    addressController.dispose();
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

  bool _isToday(DateTime dateTime) {
    final now = DateTime.now();
    return dateTime.year == now.year &&
        dateTime.month == now.month &&
        dateTime.day == now.day;
  }

  void _addToTotalToday(Duration duration) {
    if (duration <= Duration.zero) {
      return;
    }
    totalToday.value = _formatHms(_parseHms(totalToday.value) + duration);
  }

  Duration? _durationBetweenAttendanceTimes(
    String? checkInRaw,
    String? checkOutRaw,
  ) {
    final checkIn = _parseOdooDateTime(checkInRaw);
    if (checkIn == null) {
      return null;
    }
    final checkOut = _parseOdooDateTime(checkOutRaw) ?? DateTime.now();
    final duration = checkOut.difference(checkIn);
    if (duration.isNegative) {
      return null;
    }
    return duration;
  }

  void _mergeCheckoutSessionIntoTotal({
    String? checkInRaw,
    String? checkOutRaw,
  }) {
    final fromModel = _durationBetweenAttendanceTimes(checkInRaw, checkOutRaw);
    if (fromModel != null && _isToday(_parseOdooDateTime(checkInRaw)!)) {
      _addToTotalToday(fromModel);
      return;
    }

    if (checkInDateTime.value != null && _isToday(checkInDateTime.value!)) {
      final session = elapsed.value > Duration.zero
          ? elapsed.value
          : DateTime.now().difference(checkInDateTime.value!);
      _addToTotalToday(session);
    }
  }

  void _syncTotalTodayFromRecords(List<HrAttendance> records) {
    if (records.isEmpty) {
      return;
    }
    final calculated = HrAttendance.calculateTotalWorkedHours(records);
    if (calculated != '00:00:00') {
      totalToday.value = calculated;
    }
  }

  void _syncTotalTodayFromProfile(Profile? profile) {
    if (profile == null) {
      return;
    }

    final last = profile.lastAttendance;
    if (last?.checkIn == null) {
      return;
    }

    final checkIn = _parseOdooDateTime(last!.checkIn);
    if (checkIn == null || !_isToday(checkIn)) {
      return;
    }

    final duration = _durationBetweenAttendanceTimes(last.checkIn, last.checkOut);
    if (duration == null || duration <= Duration.zero) {
      return;
    }

    final current = _parseHms(totalToday.value);
    if (current >= duration) {
      return;
    }
    totalToday.value = _formatHms(duration);
  }

  /// Parses Odoo datetimes like `2026-06-18 05:50:09` or ISO-8601.
  DateTime? _parseOdooDateTime(dynamic raw) {
    if (raw == null) {
      return null;
    }
    if (raw is DateTime) {
      return raw.toLocal();
    }
    if (raw is! String) {
      return null;
    }

    final value = raw.trim();
    if (value.isEmpty) {
      return null;
    }

    final normalized = value.contains('T') ? value : value.replaceFirst(' ', 'T');
    final parsed =
        DateTime.tryParse(normalized) ?? DateTime.tryParse('${normalized}Z');
    return parsed?.toLocal();
  }

  void _syncSessionTimer() {
    if (isCheckedIn.value && checkInDateTime.value != null) {
      elapsed.value = DateTime.now().difference(checkInDateTime.value!);
      _startTimer();
      return;
    }

    _stopTimer();
    elapsed.value = Duration.zero;
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

  Future<void> loadEmployeeData() async {
    try {
      final employee = await _homeRepository.getProfile();
      if (employee?.profile != null) {
        currentEmployee.value = employee;
        _applyProfileAttendance(employee!.profile);
        if (!isCheckedIn.value) {
          _syncTotalTodayFromProfile(employee.profile);
        }
        if (employee.profile!.id != null) {
          OdooRPCService.instance.setCurrentEmployeeId(employee.profile!.id!);
        }
        _syncSessionTimer();
      }
    } catch (e, stackTrace) {
      log(
        'Error loading profile: $e',
        name: 'HomeController',
        stackTrace: stackTrace,
      );
    }
  }

  String getCurrentTime() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }

  Future<void> loadTodayAttendance() async {
    try {
      final summary = await _homeRepository.getTodayAttendanceSummary();
      final records =
          (summary['today_records'] as List<HrAttendance>?) ?? <HrAttendance>[];
      todayAttendance.value = records;

      _syncTotalTodayFromRecords(records);

      final summaryTotal =
          (summary['total_worked_hours'] as String?) ?? '00:00:00';
      if (totalToday.value == '00:00:00' && summaryTotal != '00:00:00') {
        totalToday.value = summaryTotal;
      }

      if (totalToday.value == '00:00:00') {
        _syncTotalTodayFromProfile(currentEmployee.value?.profile);
      }

      final summaryCheckedIn = (summary['is_checked_in'] as bool?) ?? false;
      final summaryCheckIn = _parseOdooDateTime(summary['current_check_in']);

      if (summaryCheckedIn && summaryCheckIn != null) {
        isCheckedIn.value = true;
        checkInDateTime.value = summaryCheckIn;
      } else if (!summaryCheckedIn && !_isProfileCheckedIn()) {
        isCheckedIn.value = false;
        checkInDateTime.value = null;
      } else if (_isProfileCheckedIn()) {
        _applyProfileAttendance(currentEmployee.value?.profile);
      }

      _updateCheckInTimeLabel();
      _syncSessionTimer();
    } catch (e, stackTrace) {
      log(
        'Error loading attendance data: $e',
        name: 'HomeController',
        stackTrace: stackTrace,
      );
      if (_isProfileCheckedIn()) {
        _applyProfileAttendance(currentEmployee.value?.profile);
        _syncSessionTimer();
      } else {
        _syncTotalTodayFromProfile(currentEmployee.value?.profile);
      }
    }
  }

  bool _isProfileCheckedIn() {
    final state =
        currentEmployee.value?.profile?.attendanceState?.toLowerCase();
    return state == 'checked_in';
  }

  void _applyProfileAttendance(Profile? profile) {
    if (profile == null) {
      return;
    }

    final state = profile.attendanceState?.toLowerCase();
    final last = profile.lastAttendance;
    final checkedIn =
        state == 'checked_in' ||
        (last?.checkOut == null && (last?.checkIn?.isNotEmpty ?? false));

    if (checkedIn && last?.checkIn != null) {
      isCheckedIn.value = true;
      checkInDateTime.value = _parseOdooDateTime(last!.checkIn);
      _updateCheckInTimeLabel();
      return;
    }

    if (state == 'checked_out' || last?.checkOut != null) {
      isCheckedIn.value = false;
      checkInDateTime.value = null;
      checkInTime.value = '--:--:--';
      _syncTotalTodayFromProfile(profile);
    }
  }

  void _updateCheckInTimeLabel() {
    if (checkInDateTime.value != null) {
      final t = checkInDateTime.value!;
      checkInTime.value =
          '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}:${t.second.toString().padLeft(2, '0')}';
      return;
    }
    checkInTime.value = '--:--:--';
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
        _mergeCheckoutSessionIntoTotal();
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

  Future<void> handleAttendance() async {
    if (isLoading.value) {
      return;
    }

    isLoading.value = true;
    try {
      await _ensureEmployeeId();

      if (address.value.isEmpty) {
        await resolveLocationAndAddress(forceRefresh: true);
      }
      if (address.value.isEmpty) {
        _showAttendanceMessage(
          Get.context!.appWords.enterYourAddress,
          isError: true,
        );
        return;
      }

      final wasCheckedIn = isCheckedIn.value;

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
      }

      final lat = latitude ?? position.latitude;
      final lon = longitude ?? position.longitude;
      final addr = address.value.isNotEmpty ? address.value : resolvedAddress ?? '';

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

      Map<String, dynamic> result =
          await _faceService.submitFaceAttendanceWithFallback(
        base64Image: base64Image,
        latitude: lat,
        longitude: lon,
        address: addr,
      );

      if (result['success'] != true &&
          result['use_attendance_check_fallback'] == true) {
        log(
          '↪️ Falling back to POST /mobile/attendance/check',
          name: 'HomeController',
        );
        result = await _submitAttendanceCheck(
          latitude: lat,
          longitude: lon,
          address: addr,
          wasCheckedIn: wasCheckedIn,
        );
      }

      log('Attendance API result: $result', name: 'HomeController');

      if (result['success'] == true) {
        _syncCheckedInFromAttendanceResult(
          result,
          wasCheckedIn: wasCheckedIn,
        );

        await loadEmployeeData();
        await loadTodayAttendance();

        // Server summary can lag; keep UI aligned with the last action.
        _syncCheckedInFromAttendanceResult(
          result,
          wasCheckedIn: wasCheckedIn,
        );

        _showAttendanceMessage(
          _attendanceSuccessMessage(result),
          isError: false,
        );
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

  /// Postman: POST /mobile/attendance/check
  Future<Map<String, dynamic>> _submitAttendanceCheck({
    required double latitude,
    required double longitude,
    required String address,
    required bool wasCheckedIn,
  }) async {
    final checkResult = await _homeRepository.getAttendanceCheck(
      latitude: latitude,
      longitude: longitude,
      address: address,
    );

    if (checkResult.status == 'success') {
      return {
        'success': true,
        'action': checkResult.action ??
            (wasCheckedIn ? 'check_out' : 'check_in'),
        'message': null,
        'check_in': checkResult.checkIn,
        'check_out': checkResult.checkOut,
      };
    }

    return {
      'success': false,
      'error': checkResult.status ?? 'Attendance check failed',
    };
  }

  void _applyCheckInModel(CheckInModel model) {
    final action = model.action?.toLowerCase();
    final state = model.attendanceState?.toLowerCase();
    final checkedOut = action == 'check_out' || state == 'checked_out';

    if (checkedOut) {
      _mergeCheckoutSessionIntoTotal(
        checkInRaw: model.checkIn,
        checkOutRaw: model.checkOut,
      );
      isCheckedIn.value = false;
      checkInDateTime.value = null;
      checkInTime.value = '--:--:--';
      _syncSessionTimer();
      return;
    }

    isCheckedIn.value =
        action == 'check_in' ||
        state == 'checked_in' ||
        (model.checkOut == null && model.checkIn != null);

    final parsedCheckIn = _parseOdooDateTime(model.checkIn);
    if (parsedCheckIn != null) {
      checkInDateTime.value = parsedCheckIn;
      _updateCheckInTimeLabel();
    } else if (!isCheckedIn.value) {
      checkInDateTime.value = null;
      checkInTime.value = '--:--:--';
    }

    _syncSessionTimer();
  }

  /// Keeps [isCheckedIn] in sync after attendance API success.
  ///
  /// [loadTodayAttendance] can briefly return stale data and reset the flag;
  /// the last action from the API is applied again here so the home button
  /// label updates immediately.
  void _syncCheckedInFromAttendanceResult(
    Map<String, dynamic> result, {
    required bool wasCheckedIn,
  }) {
    final action = result['action']?.toString().toLowerCase() ?? '';

    if (action == 'check_out') {
      _mergeCheckoutSessionIntoTotal(
        checkInRaw: result['check_in']?.toString(),
        checkOutRaw: result['check_out']?.toString(),
      );
      isCheckedIn.value = false;
      checkInDateTime.value = null;
      checkInTime.value = '--:--:--';
      _syncSessionTimer();
      return;
    }

    if (action == 'check_in') {
      isCheckedIn.value = true;
      final parsedCheckIn = _parseOdooDateTime(result['check_in']);
      checkInDateTime.value = parsedCheckIn ?? DateTime.now();
      _updateCheckInTimeLabel();
      _syncSessionTimer();
      return;
    }

    // Face controller may return action=unknown; toggle from UI state.
    isCheckedIn.value = !wasCheckedIn;
    if (isCheckedIn.value) {
      final parsedCheckIn = _parseOdooDateTime(result['check_in']);
      checkInDateTime.value = parsedCheckIn ?? DateTime.now();
      _updateCheckInTimeLabel();
    } else {
      _mergeCheckoutSessionIntoTotal(
        checkInRaw: result['check_in']?.toString(),
        checkOutRaw: result['check_out']?.toString(),
      );
      checkInDateTime.value = null;
      checkInTime.value = '--:--:--';
    }
    _syncSessionTimer();
  }

  String _attendanceSuccessMessage(Map<String, dynamic> result) {
    final l10n = Get.context!.appWords;
    final serverMessage = result['message']?.toString().trim();
    if (serverMessage != null && serverMessage.isNotEmpty) {
      return serverMessage;
    }

    final action = result['action']?.toString().toLowerCase() ?? '';
    if (action == 'check_out') {
      return l10n.checkoutCompletedSuccess;
    }
    if (action == 'check_in') {
      return l10n.checkinCompletedSuccess;
    }

    return isCheckedIn.value
        ? l10n.checkinCompletedSuccess
        : l10n.checkoutCompletedSuccess;
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
