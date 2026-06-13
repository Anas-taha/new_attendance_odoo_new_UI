import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hr_app_odoo/features/attendance/presentation/controllers/attendance_controller.dart';
import 'package:hr_app_odoo/services/extension.dart';
import 'package:hr_app_odoo/features/attendance/presentation/widgets/attendance_info_card_widget.dart';
import 'package:hr_app_odoo/features/attendance/presentation/widgets/weak_info_widget.dart';
import 'package:hr_app_odoo/theme/app_theme.dart';
import 'package:hr_app_odoo/custom_widgets/custom_screen/custom_screen.dart';
import 'package:hr_app_odoo/custom_widgets/custom_text/custom_text.dart';
import 'package:hr_app_odoo/custom_widgets/custom_text_field/custom_text_field.dart';

class AttendanceScreen extends StatelessWidget {
  const AttendanceScreen({super.key});

  // @override
  @override
  Widget build(BuildContext context) {
    return GetBuilder<AttendanceController>(
      builder: (controller) {
        return CustomScreen(
          loading: controller.isLoading,
          appBarTitle: context.appWords.attendanceAndLeaves,
          body: Column(
            children: [
              // CustomText(text: controller.weekInfo.length.toString()),
              GestureDetector(
                onTap: () => controller.selectDate(),
                child: CustomTextField(
                  hintText: context.appWords.selectDate,
                  controller: controller.dateController,
                  enabled: false,
                  usePrefixCalender: true,
                  useSuffixArrow: true,
                ),
              ),
              16.verticalSpace,
              Row(
                children: [
                  AttendanceInfoCardWidget(
                    value: controller.attendanceTotals.earlyLeaves.toString(),
                    state: AttendanceStateEnum.leaveEarly,
                  ),
                  10.horizontalSpace,
                  AttendanceInfoCardWidget(
                    value: controller.attendanceTotals.absences.toString(),
                    state: AttendanceStateEnum.absences,
                  ),
                  10.horizontalSpace,
                  AttendanceInfoCardWidget(
                    value: controller.attendanceTotals.holidays.toString(),
                    state: AttendanceStateEnum.holidays,
                  ),
                  10.horizontalSpace,
                  AttendanceInfoCardWidget(
                    value: controller.attendanceTotals.lates.toString(),
                    state: AttendanceStateEnum.lateArrival,
                  ),
                ],
              ),
              16.verticalSpace,
              // GetBuilder(
              //   builder: (con) {
              //     return Expanded(
              //       child: ListView.separated(
              //         itemCount: 5,
              //         itemBuilder: (context, index) {
              //           {
              //             return WeakInfoWidget(index: index);
              //           }
              //         },
              //         separatorBuilder: (context, index) => 8.verticalSpace,
              //       ),
              //     );
              //   },
              // ),
              Expanded(
                child: ListView.separated(
                  itemCount: controller.weekInfo.length,
                  itemBuilder: (context, index) {
                    {
                      log(name: 'AttendanceScreen_ListView', 'index: $index');
                      return WeakInfoWidget(index: index);
                    }
                  },
                  separatorBuilder: (context, index) => 8.verticalSpace,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
