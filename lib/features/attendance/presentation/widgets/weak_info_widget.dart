import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hr_app_odoo/features/attendance/presentation/controller/attendance_controller.dart';
import 'package:hr_app_odoo/features/attendance/presentation/widgets/attendance_info_date_card_widget.dart';
import 'package:hr_app_odoo/features/attendance/presentation/widgets/attendance_info_mini_card_widget.dart';
import 'package:hr_app_odoo/theme/app_theme.dart';
import 'package:hr_app_odoo/custom_widgets/custom_text/custom_text.dart';

class WeakInfoWidget extends StatelessWidget {
  WeakInfoWidget({super.key, required this.index});
  final controller = Get.find<AttendanceController>();
  int index;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        controller.selectWeekCard(index);
      },
      child: Obx(() {
        bool isSelected = controller.selectedWeekCard.value == index;
        WeekInfoModel weekInfo = controller.weekInfo.value[index];
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: EdgeInsets.only(top: 8, bottom: 4, left: 8, right: 8),
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.appFAFAFABackGround2,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.appFFFFFFBackGround1,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    _weekNumberAndDate(isSelected: isSelected),
                    16.horizontalSpace,
                    _miniCardsInfo(isSelected: isSelected),
                    // isSelected ? SizedBox.shrink() : Spacer(),
                    isSelected
                        ? SizedBox.shrink()
                        : Icon(
                            Icons.keyboard_arrow_down_sharp,
                            color: AppColors.appA0A0A0Text2,
                            size: 30,
                          ),
                  ],
                ),
              ),
              2.verticalSpace,
              AnimatedCrossFade(
                firstCurve: Curves.easeInOut,
                secondCurve: Curves.easeInOut,
                crossFadeState: isSelected
                    ? CrossFadeState.showFirst
                    : CrossFadeState.showSecond,
                firstChild: Column(
                  children: List.generate(
                    2,
                    (index) => AttendanceInfoDateCardWidget(
                      state: AttendanceStateEnum.holidays,
                      date: '2023-01-01',
                      value: '3 أيام (اجازه مرضية)',
                    ),
                  ),
                ),
                secondChild: SizedBox.shrink(),
                duration: const Duration(milliseconds: 300),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _miniCardsInfo extends StatelessWidget {
  const _miniCardsInfo({super.key, required this.isSelected});

  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: AnimatedCrossFade(
        duration: const Duration(milliseconds: 300),
        firstCurve: Curves.easeInOut,
        secondCurve: Curves.easeInOut,
        crossFadeState: isSelected
            ? CrossFadeState.showFirst
            : CrossFadeState.showSecond,
        firstChild: Row(
          children: [
            AttendanceInfoMiniCardWidget(
              isSelected: isSelected,
              value: 2.toString(),
              state: AttendanceStateEnum.leaveEarly,
            ),
            6.horizontalSpace,
            AttendanceInfoMiniCardWidget(
              isSelected: isSelected,
              value: 14.toString(),
              state: AttendanceStateEnum.absences,
            ),
            6.horizontalSpace,
            AttendanceInfoMiniCardWidget(
              isSelected: isSelected,
              value: 7.toString(),
              state: AttendanceStateEnum.holidays,
            ),
            6.horizontalSpace,
            AttendanceInfoMiniCardWidget(
              isSelected: isSelected,
              value: 0.toString(),
              state: AttendanceStateEnum.lateArrival,
            ),
          ],
        ),
        secondChild: CustomText(
          text: '(01 مايو - 07 مايو )',
          fontSize: 12.w,
          fontWeight: FontWeight.w500,
          color: AppColors.appA0A0A0Text2,
        ),
      ),
    );
  }
}

class _weekNumberAndDate extends StatelessWidget {
  const _weekNumberAndDate({super.key, required this.isSelected});

  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return AnimatedCrossFade(
      duration: const Duration(milliseconds: 300),
      firstCurve: Curves.easeInOut,
      secondCurve: Curves.easeInOut,
      crossFadeState: isSelected
          ? CrossFadeState.showFirst
          : CrossFadeState.showSecond,
      firstChild: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            text: '',
            fontSize: 14.w,
            fontWeight: FontWeight.w400,
            color: AppColors.appPrimaryColor,
          ),
          CustomText(
            text: '(01 مايو - 07 مايو )',
            fontSize: 12.w,
            fontWeight: FontWeight.w500,
            color: AppColors.appA0A0A0Text2,
          ),
        ],
      ),
      secondChild: CustomText(
        text: 'الاسبوع الاول',
        fontSize: 14.w,
        fontWeight: FontWeight.w400,
        color: AppColors.appPrimaryColor,
      ),
    );
  }
}
