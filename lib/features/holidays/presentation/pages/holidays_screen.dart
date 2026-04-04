import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hr_app_odoo/app/app_route.dart';
import 'package:hr_app_odoo/features/holidays/presentation/controller/holidays_controller.dart';
import 'package:hr_app_odoo/features/holidays/presentation/widgets/HolidayColoredStateCardWidget.dart';
import 'package:hr_app_odoo/features/holidays/presentation/widgets/holiday_detail_widget.dart';
import 'package:hr_app_odoo/features/holidays/presentation/widgets/holiday_select_state_card_widget.dart';
import 'package:hr_app_odoo/theme/app_theme.dart';
import 'package:hr_app_odoo/widgets/custom_button/custom_button.dart';
import 'package:hr_app_odoo/widgets/custom_screen/custom_screen.dart';
import 'package:hr_app_odoo/widgets/custom_text/custom_text.dart';
import 'package:hr_app_odoo/widgets/custom_text_field/custom_text_field.dart';

class HolidaysScreen extends StatefulWidget {
  const HolidaysScreen({super.key});

  @override
  State<HolidaysScreen> createState() => _HolidaysScreenState();
}

class _HolidaysScreenState extends State<HolidaysScreen> {
  final controller = Get.find<HolidaysController>();
  @override
  Widget build(BuildContext context) {
    return CustomScreen(
      floatingActionButton: CustomButton(
        text: 'طلب اجازه',
        onTap: () {
          Get.toNamed(AppRoutes.requestHoliday);
        },
      ),
      appBarTitle: 'الاجازات',

      body: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  controller: TextEditingController(),
                  enabled: false,
                  hintText: 'نوع الاجازة',
                ),
              ),
              7.horizontalSpace,
              Expanded(
                child: CustomTextField(
                  controller: TextEditingController(),
                  enabled: false,
                  usePrefixCalender: true,
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
                HolidaySelectStateCardWidget(state: HolidayStateEnum.accepted),
                6.horizontalSpace,
                HolidaySelectStateCardWidget(state: HolidayStateEnum.pending),
                6.horizontalSpace,
                HolidaySelectStateCardWidget(state: HolidayStateEnum.rejected),
              ],
            ),
          ),
          16.verticalSpace,
          Expanded(
            child: ListView.separated(
              itemBuilder: (context, index) {
                return HolidayDetailWidget(
                  state: controller.selectedHolidayState.value,
                );
              },
              separatorBuilder: (context, index) => 16.verticalSpace,
              itemCount: 2,
            ),
          ),
        ],
      ),
    );
  }
}
