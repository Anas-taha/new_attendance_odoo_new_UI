import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hr_app_odoo/app/app_route.dart';
import 'package:hr_app_odoo/custom_widgets/custom_drop_down/custom_drop_down.dart';
import 'package:hr_app_odoo/custom_widgets/custom_no_data/custom_no_data.dart';
import 'package:hr_app_odoo/features/holidays/presentation/controller/holidays_controller.dart';
import 'package:hr_app_odoo/features/holidays/presentation/widgets/holiday_detail_widget.dart';
import 'package:hr_app_odoo/features/holidays/presentation/widgets/holiday_leave_type_chip_widget.dart';
import 'package:hr_app_odoo/features/holidays/presentation/widgets/holiday_select_state_card_widget.dart';
import 'package:hr_app_odoo/services/extension.dart';
import 'package:hr_app_odoo/custom_widgets/custom_button/custom_button.dart';
import 'package:hr_app_odoo/custom_widgets/custom_screen/custom_screen.dart';
import 'package:hr_app_odoo/custom_widgets/custom_text_field/custom_text_field.dart';
import 'package:hr_app_odoo/theme/app_theme.dart';
import 'package:skeletonizer/skeletonizer.dart';

class HolidaysScreen extends StatelessWidget {
  const HolidaysScreen({super.key});

  static const _statusFilters = [
    HolidayStateEnum.all,
    HolidayStateEnum.approved,
    HolidayStateEnum.pending,
    HolidayStateEnum.rejected,
    HolidayStateEnum.cancelled,
    HolidayStateEnum.draft,
  ];

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HolidaysController>();

    return CustomScreen(
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: CustomButton(
          text: context.appWords.leaveRequest,
          onTap: () {
            controller.resetRequestForm();
            Get.toNamed(AppRoutes.requestHoliday);
          },
        ),
      ),
      appBarTitle: context.appWords.holidays,
      body: Column(
        children: [
          GetBuilder<HolidaysController>(
            builder: (c) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: CustomDropDown(
                      height: 46.h,
                      fontSize: 11.w,
                      hintText: context.appWords.leaveType,
                      itemList: c.leaveTypeOptions.isNotEmpty
                          ? c.leaveTypeOptions
                          : [context.appWords.leaveType],
                      onSelect: c.selectFilterLeaveType,
                    ),
                  ),
                  7.horizontalSpace,
                  Expanded(
                    child: GestureDetector(
                      onTap: () => c.selectFilterStartDate(
                        context.appWords.startDate,
                      ),
                      child: CustomTextField(
                        height: 46.h,
                        fontSize: 11.w,
                        controller: c.filterStartDateController,
                        enabled: false,
                        usePrefixCalender: true,
                        useSuffixArrow: true,
                        hintText: context.appWords.startDate,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          16.verticalSpace,
          GetBuilder<HolidaysController>(
            builder: (c) {
              return Obx(() {
                final selectedTypeId = c.selectedFilterLeaveTypeId.value;
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (var i = 0; i < c.leaveTypeFilters.length; i++) ...[
                        if (i > 0) 6.horizontalSpace,
                        HolidayLeaveTypeChipWidget(
                          label: c.leaveTypeFilters[i].label,
                          isSelected:
                              selectedTypeId == c.leaveTypeFilters[i].id,
                          onTap: () => c.changeLeaveTypeFilter(
                            c.leaveTypeFilters[i].id,
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              });
            },
          ),
          10.verticalSpace,
          Obx(() {
            final selectedState = controller.selectedHolidayState.value;
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (var i = 0; i < _statusFilters.length; i++) ...[
                    if (i > 0) 6.horizontalSpace,
                    HolidaySelectStateCardWidget(
                      title: controller.holidaySwitchTitle(_statusFilters[i]),
                      isSelected: selectedState == _statusFilters[i],
                      onTap: () =>
                          controller.changeHolidayState(_statusFilters[i]),
                    ),
                  ],
                ],
              ),
            );
          }),
          16.verticalSpace,
          Obx(() {
            if (controller.loading.value) {
              return Expanded(
                child: Skeletonizer(
                  enabled: true,
                  child: ListView.separated(
                    itemCount: 4,
                    separatorBuilder: (context, index) => 16.verticalSpace,
                    itemBuilder: (context, index) => _HolidaySkeletonTile(),
                  ),
                ),
              );
            }

            if (controller.leaves.isEmpty) {
              return Expanded(child: CustomNoDataWidget());
            }

            return Expanded(
              child: ListView.separated(
                itemCount: controller.leaves.length,
                separatorBuilder: (context, index) => 16.verticalSpace,
                itemBuilder: (context, index) {
                  final leave = controller.leaves[index];
                  final state = controller.holidayStateFromLeave(leave);
                  return HolidayDetailWidget(
                    key: ValueKey(leave.id ?? index),
                    state: state,
                    leave: leave,
                    stateTitle: controller.holidaySwitchTitle(state),
                    stateColor: controller.holidayStateColor(state),
                    cardColor: controller.holidaySwitchCardColor(state),
                  );
                },
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _HolidaySkeletonTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 96.h,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: AppColors.appFAFAFABackGround2,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Bone.text(words: 3),
          12.verticalSpace,
          Bone.text(words: 8),
        ],
      ),
    );
  }
}
