import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/get_rx.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:hr_app_odoo/theme/app_theme.dart';
import 'package:hr_app_odoo/widgets/custom_dialog/customDialog.dart';
import 'package:table_calendar/table_calendar.dart';

enum HolidayStateEnum { all, accepted, rejected, pending }

class HolidaysController extends GetxController {
  Rx<HolidayStateEnum> selectedHolidayState = HolidayStateEnum.all.obs;
  TextEditingController holidayTypeController = TextEditingController();
  TextEditingController holidayStartDateController = TextEditingController();
  TextEditingController holidayEndDateController = TextEditingController();
  TextEditingController holidayReasonController = TextEditingController();
  void changeHolidayState(HolidayStateEnum newState) =>
      selectedHolidayState.value = newState;

  void selectStartDate() {
    showDialog(
      context: Get.context!,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: TableCalendar(
            firstDay: DateTime(2020),
            lastDay: DateTime(2030),
            focusedDay: DateTime.now(),
            locale: 'ar',
            calendarFormat: CalendarFormat.month,
            onDaySelected: (selectedDay, focusedDay) {
              holidayStartDateController.text =
                  '${selectedDay.day}/${selectedDay.month}/${selectedDay.year}';
              Get.back();
            },
            calendarStyle: const CalendarStyle(
              todayDecoration: BoxDecoration(
                color: AppColors.appPrimaryColor,
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: AppColors.app670379Sedondary2,
                shape: BoxShape.circle,
              ),
            ),
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
            ),
          ),
        ),
      ),
    );
  }

  void selectEndDate() {
    log(name: 'fvids', 'fvdfvfdv');
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
