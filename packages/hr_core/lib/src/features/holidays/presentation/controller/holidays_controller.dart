import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hr_core/src/custom_widgets/custom_calender/custom_calender.dart';
import 'package:hr_core/src/features/holidays/data/repositories/holiday_repo_impl.dart';
import 'package:hr_core/src/features/holidays/domain/repositories/holidays_repository.dart';
import 'package:hr_core/src/models/holiday_model.dart';
import 'package:hr_core/src/services/extension.dart';
import 'package:hr_core/src/services/simple_hr_service.dart';
import 'package:hr_core/src/theme/app_theme.dart';
enum HolidayStateEnum { all, approved, rejected, pending, cancelled, draft }

class LeaveTypeFilter {
  const LeaveTypeFilter({required this.id, required this.label});

  final int? id;
  final String label;
}

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
  final RxList<Leaves> leaves = RxList<Leaves>();
  List<Map<String, dynamic>> leaveTypes = [];
  List<LeaveTypeFilter> leaveTypeFilters = [];
  final Map<String, int> _leaveTypeLabelToId = {};
  final Map<String, Set<int>> _leaveTypeNameToIds = {};
  List<String> _leaveTypeLabels = [];
  Rxn<int> selectedFilterLeaveTypeId = Rxn<int>();
  Rx<HolidayStateEnum> selectedHolidayState = HolidayStateEnum.all.obs;
  List<Leaves> _leavesByType = [];
  int? selectedRequestLeaveTypeId;
  TextEditingController filterStartDateController = TextEditingController();
  TextEditingController requestStartDateController = TextEditingController();
  TextEditingController requestEndDateController = TextEditingController();
  TextEditingController requestReasonController = TextEditingController();

  List<String> get leaveTypeOptions => _leaveTypeLabels;

  @override
  void onReady() {
    selectedFilterLeaveTypeId.value = null;
    selectedHolidayState.value = HolidayStateEnum.all;
    filterStartDateController.text = '';
    resetRequestForm();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initialize();
    });
    super.onReady();
  }

  Future<void> _initialize() async {
    await loadLeaveTypes();
    await getHolidays();
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
    _leaveTypeNameToIds.clear();
    _leaveTypeLabels = [];

    final seenIds = <int>{};

    for (final type in types) {
      final id = type['id'] as int?;
      final name = type['name']?.toString().trim() ?? '';
      if (id == null || name.isEmpty || seenIds.contains(id)) {
        continue;
      }
      seenIds.add(id);
      leaveTypes.add(type);
      _leaveTypeNameToIds.putIfAbsent(name, () => {}).add(id);
    }

    for (final entry in _leaveTypeNameToIds.entries) {
      _leaveTypeLabels.add(entry.key);
      _leaveTypeLabelToId[entry.key] = entry.value.first;
    }

    final allLabel = Get.context?.appWords.all ?? 'All';
    leaveTypeFilters = [
      LeaveTypeFilter(id: null, label: allLabel),
      ..._leaveTypeNameToIds.entries.map(
        (entry) => LeaveTypeFilter(
          id: entry.value.first,
          label: entry.key,
        ),
      ),
    ];

    update();
  }

  void _applyStatusFilter() {
    if (selectedHolidayState.value == HolidayStateEnum.all) {
      leaves.assignAll(_leavesByType);
      return;
    }

    leaves.assignAll(
      _leavesByType.where(
        (leave) => holidayStateFromLeave(leave) == selectedHolidayState.value,
      ),
    );
  }

  void changeHolidayState(HolidayStateEnum newState) {
    selectedHolidayState.value = newState;
    _applyStatusFilter();
  }

  void _applyLeavesFilter() {
    final allLeaves = holidays.leaves ?? [];
    final typeId = selectedFilterLeaveTypeId.value;
    if (typeId == null) {
      leaves.assignAll(allLeaves);
    } else {
      final matchingIds = _matchingTypeIds(typeId);
      leaves.assignAll(
        allLeaves.where((leave) => matchingIds.contains(leave.leaveTypeId)),
      );
    }
    _leavesByType = List<Leaves>.from(leaves);
    _applyStatusFilter();
  }

  Set<int> _matchingTypeIds(int typeId) {
    return _leaveTypeNameToIds.values.firstWhere(
      (ids) => ids.contains(typeId),
      orElse: () => {typeId},
    );
  }

  Future<void> _loadLeavesForFilter() async {
    final typeId = selectedFilterLeaveTypeId.value;
    final statusIds = typeId == null ? null : _matchingTypeIds(typeId).toList();

    loading.value = true;

    final apiLeaves = await _profileRepository.searchLeaves(
      holidayStatusIds: statusIds,
    );

    if (apiLeaves != null) {
      if (typeId == null) {
        holidays = HolidaysModel(
          status: 'success',
          count: apiLeaves.length,
          leaves: apiLeaves,
        );
      }
      _leavesByType = apiLeaves;
      _applyStatusFilter();
    } else if (typeId == null) {
      final result = await _profileRepository.getHolidays();
      if (result != null) {
        holidays = result;
        _leavesByType = result.leaves ?? [];
        _applyStatusFilter();
      }
    } else {
      _applyLeavesFilter();
    }

    loading.value = false;
  }

  void changeLeaveTypeFilter(int? leaveTypeId) {
    selectedFilterLeaveTypeId.value = leaveTypeId;
    selectedHolidayState.value = HolidayStateEnum.all;
    _loadLeavesForFilter();
  }

  HolidayStateEnum holidayStateFromLeave(Leaves leave) {
    switch (leave.holidayStatus?.toLowerCase()) {
      case 'approved':
      case 'validate':
        return HolidayStateEnum.approved;
      case 'rejected':
      case 'refuse':
        return HolidayStateEnum.rejected;
      case 'pending':
      case 'confirm':
        return HolidayStateEnum.pending;
      case 'cancelled':
      case 'cancel':
        return HolidayStateEnum.cancelled;
      case 'draft':
        return HolidayStateEnum.draft;
      default:
        return HolidayStateEnum.pending;
    }
  }

  Future<void> getHolidays() async {
    await _loadLeavesForFilter();
  }

  void selectFilterLeaveType(String label) {
    selectedFilterLeaveTypeId.value = _leaveTypeLabelToId[label];
    _loadLeavesForFilter();
  }

  void selectRequestLeaveType(String label) {
    selectedRequestLeaveTypeId = _leaveTypeLabelToId[label];
  }

  Future<void> submitLeaveRequest() async {
    final l10n = Get.context!.appWords;
    if (selectedRequestLeaveTypeId == null) {
      Get.snackbar(l10n.leaveRequest, l10n.leaveType);
      return;
    }
    if (requestStartDateController.text.isEmpty ||
        requestEndDateController.text.isEmpty) {
      Get.snackbar(l10n.leaveRequest, l10n.selectDate);
      return;
    }

    loading.value = true;

    final result = await _simpleHrService.createLeave({
      'holiday_status_id': selectedRequestLeaveTypeId,
      'request_date_from': requestStartDateController.text,
      'request_date_to': requestEndDateController.text,
      'name': requestReasonController.text.trim().isEmpty
          ? l10n.leaveRequest
          : requestReasonController.text.trim(),
    });

    loading.value = false;

    if (result['success'] == true) {
      resetRequestForm();
      await getHolidays();
      Get.back();
      return;
    }

    Get.snackbar(
      l10n.leaveRequest,
      _leaveSubmitErrorMessage(l10n, result['error']?.toString()),
    );
  }

  String _leaveSubmitErrorMessage(dynamic l10n, String? error) {
    if (error == null || error.isEmpty) {
      return l10n.failedToCreateLeaveRequest;
    }

    final normalized = error.toLowerCase();
    if (normalized.contains('network is unreachable') ||
        normalized.contains('socketexception') ||
        normalized.contains('failed host lookup') ||
        normalized.contains('connection timed out') ||
        normalized.contains('connection refused')) {
      return l10n.networkUnavailable;
    }

    if (normalized.contains('not authenticated')) {
      return l10n.authFailed;
    }

    return l10n.connectionError(error);
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
        return AppColors.primary;
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
        return AppColors.primary;
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
