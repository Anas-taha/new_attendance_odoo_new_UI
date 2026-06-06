import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/get_rx.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:hr_app_odoo/services/extension.dart';
import 'package:hr_app_odoo/theme/app_theme.dart';
import 'package:hr_app_odoo/custom_widgets/custom_calender/custom_calender.dart';
import 'package:hr_app_odoo/custom_widgets/custom_dialog/custom_dialog.dart';
import 'package:table_calendar/table_calendar.dart';

enum HolidayStateEnum { all, accepted, rejected, pending }

class HolidaysController extends GetxController {
  Rx<HolidayStateEnum> selectedHolidayState = HolidayStateEnum.all.obs;
  TextEditingController holidayTypeController = TextEditingController();
  TextEditingController holidayStartDateController = TextEditingController();
  TextEditingController holidayEndDateController = TextEditingController();
  TextEditingController holidayReasonController = TextEditingController();

  void init() {
    selectedHolidayState.value = HolidayStateEnum.all;
    holidayTypeController.text = '';
    holidayStartDateController.text = '';
    holidayEndDateController.text = '';
    holidayReasonController.text = '';
  }

  void changeHolidayState(HolidayStateEnum newState) =>
      selectedHolidayState.value = newState;
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
        return AppColors.appE5E5E5Border;
      case HolidayStateEnum.pending:
        return AppColors.appF59E0BWorning;
      case HolidayStateEnum.accepted:
        return AppColors.app4CAF50Success;
      case HolidayStateEnum.rejected:
        return AppColors.appF44336Error;
    }
  }

  Color holidaySwitchCardColor(HolidayStateEnum state) {
    switch (state) {
      case HolidayStateEnum.all:
        return Colors.transparent;
      case HolidayStateEnum.pending:
        return AppColors.appF9E8CACardBG6;
      case HolidayStateEnum.accepted:
        return AppColors.appEEF7EECardBG3;
      case HolidayStateEnum.rejected:
        return AppColors.appF9E8E6CardBG6;
    }
  }

  String holidaySwitchTitle(HolidayStateEnum state) {
    switch (state) {
      case HolidayStateEnum.all:
        return Get.context!.appWords.allStatuses;
      case HolidayStateEnum.pending:
        return Get.context!.appWords.pending;
      case HolidayStateEnum.accepted:
        return Get.context!.appWords.approved;
      case HolidayStateEnum.rejected:
        return Get.context!.appWords.rejected;
    }
  }
}
