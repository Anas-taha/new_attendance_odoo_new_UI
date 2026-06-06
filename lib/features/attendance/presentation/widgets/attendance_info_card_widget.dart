import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hr_app_odoo/services/extension.dart';
import 'package:hr_app_odoo/features/attendance/presentation/controller/attendance_controller.dart';
import 'package:hr_app_odoo/theme/app_theme.dart';
import 'package:hr_app_odoo/custom_widgets/custom_text/custom_text.dart';

class AttendanceInfoCardWidget extends StatelessWidget {
  AttendanceInfoCardWidget({
    super.key,
    required this.state,
    required this.value,
  });
  AttendanceStateEnum state;
  String? value;
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 64.h,
        decoration: BoxDecoration(
          color: backgroundColor(),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor(), width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomText(
                  text: value ?? '0',
                  fontWeight: FontWeight.w700,
                  color: textColor(),
                ),
                2.horizontalSpace,
                CustomText(
                  text: Get.context!.appWords.days,
                  fontSize: 10.w,
                  color: AppColors.appA0A0A0Text2,
                  fontWeight: FontWeight.w500,
                ),
              ],
            ),
            8.verticalSpace,
            CustomText(
              text: text(),
              color: AppColors.appPrimaryColor,
              fontSize: 14.w,
              fontWeight: FontWeight.w400,
            ),
          ],
        ),
      ),
    );
  }

  String text() {
    switch (state) {
      case AttendanceStateEnum.leaveEarly:
        return Get.context!.appWords.leaveEarly;
      case AttendanceStateEnum.absences:
        return Get.context!.appWords.absences;
      case AttendanceStateEnum.holidays:
        return Get.context!.appWords.holidays;
      case AttendanceStateEnum.lateArrival:
        return Get.context!.appWords.lateArrival;
    }
  }

  Color textColor() {
    switch (state) {
      case AttendanceStateEnum.leaveEarly:
        return AppColors.appPrimaryColor;
      case AttendanceStateEnum.absences:
        return AppColors.app796DFFText6;
      case AttendanceStateEnum.holidays:
        return AppColors.appF59E0BWorning;
      case AttendanceStateEnum.lateArrival:
        return AppColors.appF44336Error;
    }
  }

  Color backgroundColor() {
    switch (state) {
      case AttendanceStateEnum.leaveEarly:
        return AppColors.appF9F5FACardBG4;
      case AttendanceStateEnum.absences:
        return AppColors.appF5F8FFCardBG5;
      case AttendanceStateEnum.holidays:
        return AppColors.appFFF7F4CardBG6;
      case AttendanceStateEnum.lateArrival:
        return AppColors.appFFF7F5CardBG6;
    }
  }

  Color borderColor() {
    switch (state) {
      case AttendanceStateEnum.leaveEarly:
        return AppColors.app670379Sedondary2;
      case AttendanceStateEnum.absences:
        return AppColors.app6A5CFFBorder2;
      case AttendanceStateEnum.holidays:
        return AppColors.appF59E0BWorning;
      case AttendanceStateEnum.lateArrival:
        return AppColors.appF44336Error;
    }
  }
}
