import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hr_app_odoo/features/attendance/presentation/controller/attendance_controller.dart';
import 'package:hr_app_odoo/services/extension.dart';
import 'package:hr_app_odoo/theme/app_theme.dart';
import 'package:hr_app_odoo/custom_widgets/custom_text/custom_text.dart';

class AttendanceInfoMiniCardWidget extends StatelessWidget {
  AttendanceInfoMiniCardWidget({
    super.key,
    required this.state,
    required this.value,
    required this.isSelected,
  });
  bool isSelected;
  AttendanceStateEnum state;
  String? value;
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: isSelected ? 45.h : 0,
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: backgroundColor(),
          borderRadius: BorderRadius.circular(5),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              5.verticalSpace,
              CustomText(
                text: value ?? '0',
                fontSize: 13.w,
                fontWeight: FontWeight.w500,
                color: AppColors.app1A1A1AText1,
              ),
              3.verticalSpace,
              CustomText(
                overflow: TextOverflow.ellipsis,
                text: text(),
                color: AppColors.app1A1A1AText1,
                fontSize: 10.w,
                fontWeight: FontWeight.w400,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String text() {
    switch (state) {
      case AttendanceStateEnum.leaveEarly:
        return Get.context!.appWords.departure;
      case AttendanceStateEnum.absences:
        return Get.context!.appWords.absence;
      case AttendanceStateEnum.holidays:
        return Get.context!.appWords.leaves;
      case AttendanceStateEnum.lateArrival:
        return Get.context!.appWords.late;
    }
  }

  Color backgroundColor() {
    switch (state) {
      case AttendanceStateEnum.leaveEarly:
        return AppColors.appF0E6F2CardBG6;
      case AttendanceStateEnum.absences:
        return AppColors.appDEDBFFCardBG6;
      case AttendanceStateEnum.holidays:
        return AppColors.appFFDFAACardBG6;
      case AttendanceStateEnum.lateArrival:
        return AppColors.appFDD0CDCardBG6;
    }
  }
}
