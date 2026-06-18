import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hr_app_odoo/custom_widgets/custom_calender/custom_calender.dart';
import 'package:hr_app_odoo/features/holidays/data/repositories/holiday_repo_impl.dart';
import 'package:hr_app_odoo/features/holidays/domain/repositories/holidays_repository.dart';
import 'package:hr_app_odoo/models/holiday_model.dart';
import 'package:hr_app_odoo/services/extension.dart';
import 'package:hr_app_odoo/services/simple_hr_service.dart';
import 'package:hr_app_odoo/theme/app_theme.dart';
enum HolidayStateEnum { all, approved, rejected, pending, cancelled, draft }

class HolidaysController extends GetxController {
  HolidaysController({
    HolidaysRepository? holidaysRepository,
    SimpleHrService? simpleHrService,
  }) : _profileRepository = holidaysRepository ?? HolidayRepositoryImpl(),
       _simpleHrService = simpleHrService ?? SimpleHrService();

  final HolidaysRepository _profileRepository;
  final SimpleHrService _simpleHrService;

  RxBool loading = false.obs;
  HolidaysModel holidays = HolidaysModel();
  List<Leaves> leaves = [];
  List<Map<String, dynamic>> leaveTypes = [];
  final Map<String, int> _leaveTypeLabelToId = {};
  List<String> _leaveTypeLabels = [];
  Rx<HolidayStateEnum> selectedHolidayState = HolidayStateEnum.all.obs;
  TextEditingController filterStartDateController = TextEditingController();
  TextEditingController requestStartDateController = TextEditingController();
  TextEditingController requestEndDateController = TextEditingController();
  TextEditingController requestReasonController = TextEditingController();
  int? selectedFilterLeaveTypeId;
  int? selectedRequestLeaveTypeId;

  List<String> get leaveTypeOptions => _leaveTypeLabels;

  @override
  void onReady() {
    selectedHolidayState.value = HolidayStateEnum.all;
    filterStartDateController.text = '';
    resetRequestForm();
    loadLeaveTypes();
    getHolidays();
    super.onReady();
  }

  void resetRequestForm() {
    requestStartDateController.text = '';
    requestEndDateController.text = '';
    requestReasonController.text = '';
    selectedRequestLeaveTypeId = null;
  }

  @override
  void onClose() {
    filterStartDateController.dispose();
    requestStartDateController.dispose();
    requestEndDateController.dispose();
    requestReasonController.dispose();
    super.onClose();
  }

  // void init() {
  //   selectedHolidayState.value = HolidayStateEnum.all;
  //   holidayTypeController.text = '';
  //   holidayStartDateController.text = '';
  //   holidayEndDateController.text = '';
  //   holidayReasonController.text = '';
  // }

  Future<void> loadLeaveTypes() async {
    final types = await _simpleHrService.getHolidayStatusTypes();
    leaveTypes = [];
    _leaveTypeLabelToId.clear();
    _leaveTypeLabels = [];

    final seenIds = <int>{};
    final nameCounts = <String, int>{};

    for (final type in types) {
      final id = type['id'] as int?;
      final name = type['name']?.toString().trim() ?? '';
      if (id == null || name.isEmpty || seenIds.contains(id)) {
        continue;
      }
      seenIds.add(id);
      nameCounts[name] = (nameCounts[name] ?? 0) + 1;
      leaveTypes.add(type);
    }

    for (final type in leaveTypes) {
      final id = type['id'] as int;
      final name = type['name']!.toString().trim();
      final label = (nameCounts[name] ?? 0) > 1 ? '$name ($id)' : name;
      _leaveTypeLabels.add(label);
      _leaveTypeLabelToId[label] = id;
    }

    update();
  }

  Future<void> getHolidays() async {
    loading.value = true;
    update();
    final result = await _profileRepository.getHolidays();
    if (result != null) {
      holidays = result;
      leaves = result.leaves ?? [];
    }
    loading.value = false;
    update();
  }

  void changeHolidayState(HolidayStateEnum newState) {
    selectedHolidayState.value = newState;
    if (newState == HolidayStateEnum.all) {
      leaves = holidays.leaves ?? [];
    } else {
      leaves =
          holidays.leaves
              ?.where(
                (leave) => leave.holidayStatus == newState.name.toLowerCase(),
              )
              .toList() ??
          [];
    }
    update();
  }

  void selectFilterLeaveType(String label) {
    selectedFilterLeaveTypeId = _leaveTypeLabelToId[label];
  }

  void selectRequestLeaveType(String label) {
    selectedRequestLeaveTypeId = _leaveTypeLabelToId[label];
  }

  Future<void> submitLeaveRequest() async {
    final l10n = Get.context!.appWords;
    if (requestStartDateController.text.isEmpty ||
        requestEndDateController.text.isEmpty) {
      Get.snackbar(l10n.leaveRequest, l10n.selectDate);
      return;
    }

    loading.value = true;
    update();

    final leaveTypeId =
        selectedRequestLeaveTypeId ??
        (leaveTypes.isNotEmpty ? leaveTypes.first['id'] as int? : 1);

    final success = await _simpleHrService.createLeave({
      'holiday_status_id': leaveTypeId,
      'request_date_from': requestStartDateController.text,
      'request_date_to': requestEndDateController.text,
      'name': requestReasonController.text,
    });

    loading.value = false;
    update();

    if (success) {
      resetRequestForm();
      await getHolidays();
      Get.back();
      return;
    }

    Get.snackbar(l10n.leaveRequest, l10n.failedToCreateExpense);
  }

  void selectFilterStartDate(String title) {
    CustomCalender.calenderDialog(
      contorller: filterStartDateController,
      title: title,
    );
  }

  void selectRequestStartDate(String title) {
    CustomCalender.calenderDialog(
      contorller: requestStartDateController,
      title: title,
    );
  }

  void selectRequestEndDate(String title) {
    CustomCalender.calenderDialog(
      contorller: requestEndDateController,
      title: title,
    );
  }

  Color holidayStateColor(HolidayStateEnum state) {
    switch (state) {
      case HolidayStateEnum.all:
        return AppColors.app1A1A1AText1;
      case HolidayStateEnum.pending:
        return AppColors.appF59E0BWorning;
      case HolidayStateEnum.approved:
        return AppColors.app4CAF50Success;
      case HolidayStateEnum.rejected:
        return AppColors.appF44336Error;
      case HolidayStateEnum.cancelled:
        return AppColors.appC6B8FFSedondary3;
      case HolidayStateEnum.draft:
        return AppColors.primary500;
    }
  }

  Color holidaySwitchCardColor(HolidayStateEnum state) {
    switch (state) {
      case HolidayStateEnum.all:
        return Colors.transparent;
      case HolidayStateEnum.pending:
        return AppColors.appF9E8CACardBG6;
      case HolidayStateEnum.approved:
        return AppColors.appEEF7EECardBG3;
      case HolidayStateEnum.rejected:
        return AppColors.appF9E8E6CardBG6;
      case HolidayStateEnum.cancelled:
        return AppColors.appF9F5FACardBG4;
      case HolidayStateEnum.draft:
        return AppColors.primary100;
    }
  }

  String holidaySwitchTitle(HolidayStateEnum state) {
    switch (state) {
      case HolidayStateEnum.all:
        return Get.context!.appWords.allStatuses;
      case HolidayStateEnum.pending:
        return Get.context!.appWords.pending;
      case HolidayStateEnum.approved:
        return Get.context!.appWords.approved;
      case HolidayStateEnum.rejected:
        return Get.context!.appWords.rejected;
      case HolidayStateEnum.cancelled:
        return Get.context!.appWords.cancelled;
      case HolidayStateEnum.draft:
        return Get.context!.appWords.draft;
    }
  }
}
