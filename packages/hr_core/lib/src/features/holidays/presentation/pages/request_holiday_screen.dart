import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hr_core/src/custom_widgets/custom_button/custom_button.dart';
import 'package:hr_core/src/custom_widgets/custom_drop_down/custom_drop_down.dart';
import 'package:hr_core/src/custom_widgets/custom_screen/custom_screen.dart';
import 'package:hr_core/src/custom_widgets/custom_text/custom_text.dart';
import 'package:hr_core/src/custom_widgets/custom_text_field/custom_text_field.dart';
import 'package:hr_core/src/features/holidays/presentation/controller/holidays_controller.dart';
import 'package:hr_core/src/services/extension.dart';
import 'package:hr_core/src/theme/app_theme.dart';

class RequestHolidayScreen extends StatelessWidget {
  const RequestHolidayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HolidaysController>(
      builder: (controller) {
        return CustomScreen(
          loading: controller.loading,
          floatingActionButton: Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: CustomButton(
              text: context.appWords.send,
              onTap: controller.submitLeaveRequest,
            ),
          ),
          appBarTitle: context.appWords.leaveRequest,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomText(
                text: context.appWords.leaveType,
                fontSize: 14.w,
                fontWeight: FontWeight.w500,
                color: AppColors.app1A1A1AText1,
              ),
              8.verticalSpace,
              CustomDropDown(
                hintText: context.appWords.leaveType,
                itemList: controller.leaveTypeOptions,
                onSelect: controller.selectRequestLeaveType,
              ),
              16.verticalSpace,
              GestureDetector(
                onTap: () =>
                    controller.selectRequestStartDate(context.appWords.startDate),
                child: CustomTextField(
                  hintText: context.appWords.startDate,
                  hintLocationTop: true,
                  controller: controller.requestStartDateController,
                  enabled: false,
                  usePrefixCalender: true,
                  useSuffixArrow: true,
                ),
              ),
              16.verticalSpace,
              GestureDetector(
                onTap: () =>
                    controller.selectRequestEndDate(context.appWords.endDate),
                child: CustomTextField(
                  hintText: context.appWords.endDate,
                  hintLocationTop: true,
                  controller: controller.requestEndDateController,
                  enabled: false,
                  usePrefixCalender: true,
                  useSuffixArrow: true,
                ),
              ),
              16.verticalSpace,
              CustomTextField(
                controller: controller.requestReasonController,
                maxLines: 2,
                hintLocationTop: true,
                hintText: context.appWords.leaveReason,
              ),
            ],
          ),
        );
      },
    );
  }
}
