import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hr_app_odoo/features/holidays/presentation/controller/holidays_controller.dart';
import 'package:hr_app_odoo/theme/app_theme.dart';
import 'package:hr_app_odoo/widgets/custom_text/custom_text.dart';

class HolidayColoredStateCardWidget extends StatelessWidget {
  HolidayColoredStateCardWidget({super.key, required this.state});
  final controller = Get.find<HolidaysController>();
  HolidayStateEnum state;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 13),
      height: 32.h,
      decoration: BoxDecoration(
        color: controller.holidaySwitchCardColor(state),
        border: Border.all(color: controller.holidayStateColor(state)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: CustomText(
          text: controller.holidaySwitchTitle(state),
          fontSize: 14.w,
          fontWeight: FontWeight.w400,
          color: controller.holidayStateColor(state),
        ),
      ),
    );
  }
}
