import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hr_app_odoo/features/attendance/presentation/controller/attendance_controller.dart';
import 'package:hr_app_odoo/theme/app_theme.dart';
import 'package:hr_app_odoo/custom_widgets/custom_text/custom_text.dart';

class AttendanceInfoDateCardWidget extends StatelessWidget {
  AttendanceInfoDateCardWidget({
    super.key,
    required this.state,
    required this.value,
    required this.date,
  });
  AttendanceStateEnum state;
  String? value;
  String? date;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 4),
      height: 42.h,
      padding: EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: backgroundColor(),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: borderColor(), width: 1),
      ),
      child: Row(
        children: [
          CustomText(
            text: date ?? '',
            fontSize: 13.w,
            fontWeight: FontWeight.w500,
            color: AppColors.app1A1A1AText1,
          ),
          22.horizontalSpace,
          CustomText(
            text: value ?? '',
            color: textColor(),
            fontSize: 13.w,
            fontWeight: FontWeight.w500,
          ),
        ],
      ),
    );
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
