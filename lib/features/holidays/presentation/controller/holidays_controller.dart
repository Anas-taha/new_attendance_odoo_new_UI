import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/get_rx.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
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

  void selectStartDate() {
    CustomCalender.calenderDialog(
      contorller: holidayStartDateController,
      title: 'تاريخ البداية',
    );
  }

  void selectEndDate() {
    CustomCalender.calenderDialog(
      contorller: holidayEndDateController,
      title: 'تاريخ النهاية',
    );
  }

  Color holidayStateColor(HolidayStateEnum state) {
    switch (state) {
      case HolidayStateEnum.all:
        return Colors.transparent;
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
        return 'كل الحالات';
      case HolidayStateEnum.pending:
        return 'قيد المعالجة';
      case HolidayStateEnum.accepted:
        return 'تم الموافقه';
      case HolidayStateEnum.rejected:
        return 'مرفوضة';
    }
  }
}
