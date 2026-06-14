import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hr_app_odoo/app/app_route.dart';
import 'package:hr_app_odoo/custom_widgets/custom_drop_down/custom_drop_down.dart';
import 'package:hr_app_odoo/custom_widgets/custom_no_data/custom_no_data.dart';
import 'package:hr_app_odoo/features/holidays/presentation/controller/holidays_controller.dart';
import 'package:hr_app_odoo/features/holidays/presentation/widgets/HolidayColoredStateCardWidget.dart';
import 'package:hr_app_odoo/features/holidays/presentation/widgets/holiday_detail_widget.dart';
import 'package:hr_app_odoo/features/holidays/presentation/widgets/holiday_select_state_card_widget.dart';
import 'package:hr_app_odoo/features/notification/presentation/widgets/no_notif_widget.dart';
import 'package:hr_app_odoo/services/extension.dart';
import 'package:hr_app_odoo/theme/app_theme.dart';
import 'package:hr_app_odoo/custom_widgets/custom_button/custom_button.dart';
import 'package:hr_app_odoo/custom_widgets/custom_screen/custom_screen.dart';
import 'package:hr_app_odoo/custom_widgets/custom_text/custom_text.dart';
import 'package:hr_app_odoo/custom_widgets/custom_text_field/custom_text_field.dart';

class HolidaysScreen extends StatelessWidget {
  const HolidaysScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HolidaysController>(
      builder: (controller) {
        return CustomScreen(
          floatingActionButton: Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: CustomButton(
              text: context.appWords.leaveRequest,
              onTap: () {
                Get.toNamed(AppRoutes.requestHoliday);
              },
            ),
          ),
          appBarTitle: context.appWords.holidays,

          body: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: CustomDropDown(
                      hintText: context.appWords.leaveType,
                      itemList: ['1', '2', '3'],
                      onSelect: (type) {
                        controller.selectHoolidayType(type);
                      },
                    ),
                  ),
                  7.horizontalSpace,
                  Expanded(
                    child: GestureDetector(
                      onTap: () => controller.selectStartDate(
                        context.appWords.startDate,
                      ),
                      child: CustomTextField(
                        controller: controller.holidayStartDateController,
                        enabled: false,
                        usePrefixCalender: true,
                        useSuffixArrow: true,
                        hintText: context.appWords.startDate,
                      ),
                    ),
                  ),
                ],
              ),
              16.verticalSpace,
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    HolidaySelectStateCardWidget(state: HolidayStateEnum.all),
                    6.horizontalSpace,
                    HolidaySelectStateCardWidget(
                      state: HolidayStateEnum.approved,
                    ),
                    6.horizontalSpace,
                    HolidaySelectStateCardWidget(
                      state: HolidayStateEnum.pending,
                    ),
                    6.horizontalSpace,
                    HolidaySelectStateCardWidget(
                      state: HolidayStateEnum.rejected,
                    ),
                    6.horizontalSpace,
                    HolidaySelectStateCardWidget(
                      state: HolidayStateEnum.cancelled,
                    ),
                    6.horizontalSpace,
                    HolidaySelectStateCardWidget(state: HolidayStateEnum.draft),
                  ],
                ),
              ),
              16.verticalSpace,
              controller.leaves.isEmpty
                  ? CustomNoDataWidget()
                  : Expanded(
                      child: ListView.separated(
                        itemBuilder: (context, index) {
                          return HolidayDetailWidget(
                            state: controller.selectedHolidayState.value,
                            leave: controller.leaves[index],
                          );
                        },
                        separatorBuilder: (context, index) => 16.verticalSpace,
                        itemCount: 1,
                      ),
                    ),
            ],
          ),
        );
      },
    );
  }
}
