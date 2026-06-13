import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/get_rx.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:hr_app_odoo/features/holidays/data/repositories/holiday_repo_impl.dart';
import 'package:hr_app_odoo/features/holidays/domain/repositories/holidays_repository.dart';
import 'package:hr_app_odoo/models/holiday_model.dart';
import 'package:hr_app_odoo/services/extension.dart';
import 'package:hr_app_odoo/theme/app_theme.dart';
import 'package:hr_app_odoo/custom_widgets/custom_calender/custom_calender.dart';
import 'package:hr_app_odoo/custom_widgets/custom_dialog/custom_dialog.dart';
import 'package:table_calendar/table_calendar.dart';

enum HolidayStateEnum { all, approved, rejected, pending, cancelled, draft }

class HolidaysController extends GetxController {
  HolidaysController({HolidaysRepository? holidaysRepository})
    : _profileRepository = holidaysRepository ?? HolidayRepositoryImpl();

  final HolidaysRepository _profileRepository;

  Rx<bool> loading = Rx<bool>(false);
  HolidaysModel holidays = HolidaysModel();
  List<Leaves> leaves = [];
  Rx<HolidayStateEnum> selectedHolidayState = HolidayStateEnum.all.obs;
  TextEditingController holidayTypeController = TextEditingController();
  TextEditingController holidayStartDateController = TextEditingController();
  TextEditingController holidayEndDateController = TextEditingController();
  TextEditingController holidayReasonController = TextEditingController();
  @override
  void onReady() {
    selectedHolidayState.value = HolidayStateEnum.all;
    holidayTypeController.text = '';
    holidayStartDateController.text = '';
    holidayEndDateController.text = '';
    holidayReasonController.text = '';
    getHolidays();
    super.onReady();
  }

  @override
  void onClose() {
    holidayTypeController.dispose();
    holidayStartDateController.dispose();
    holidayEndDateController.dispose();
    holidayReasonController.dispose();
    super.onClose();
  }

  // void init() {
  //   selectedHolidayState.value = HolidayStateEnum.all;
  //   holidayTypeController.text = '';
  //   holidayStartDateController.text = '';
  //   holidayEndDateController.text = '';
  //   holidayReasonController.text = '';
  // }

  void getHolidays() async {
    loading.value = true;
    final result = await _profileRepository.getHolidays();
    if (result != null) {
      holidays = result;
      leaves = result.leaves ?? [];
    }
    loading.value = false;
  }

  void changeHolidayState(HolidayStateEnum newState) {
    selectedHolidayState.value = newState;
    leaves =
        holidays.leaves
            ?.where(
              (leave) => leave.holidayStatus == newState.name.toLowerCase(),
            )
            .toList() ??
        [];
  }

  void selectHoolidayType(String type) {
    holidayTypeController.text = type;
  }

  void selectStartDate(String title) {
    CustomCalender.calenderDialog(
      contorller: holidayStartDateController,
      title: title,
    );
  }

  void selectEndDate(String title) {
    CustomCalender.calenderDialog(
      contorller: holidayEndDateController,
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
