import 'package:flutter/material.dart';
import 'package:get/get_rx/get_rx.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:hr_app_odoo/theme/app_theme.dart';

enum HolidayStateEnum { all, accepted, rejected, pending }

class HolidaysController extends GetxController {
  Rx<HolidayStateEnum> selectedHolidayState = HolidayStateEnum.all.obs;

  void changeHolidayState(HolidayStateEnum newState) =>
      selectedHolidayState.value = newState;

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
