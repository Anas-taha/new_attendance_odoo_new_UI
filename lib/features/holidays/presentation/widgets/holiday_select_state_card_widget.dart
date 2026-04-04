import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hr_app_odoo/features/holidays/presentation/controller/holidays_controller.dart';
import 'package:hr_app_odoo/theme/app_theme.dart';
import 'package:hr_app_odoo/widgets/custom_text/custom_text.dart';

class HolidaySelectStateCardWidget extends StatelessWidget {
  HolidaySelectStateCardWidget({super.key, required this.state});
  final controller = Get.find<HolidaysController>();
  HolidayStateEnum state;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        controller.changeHolidayState(state);
      },
      child: Obx(() {
        bool isSelected = controller.selectedHolidayState.value == state;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          padding: EdgeInsets.symmetric(horizontal: 13),
          height: 32.h,
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.appE1CDE4CardBG
                : AppColors.appFAFAFABackGround2,
            border: Border.all(
              color: isSelected
                  ? AppColors.app670379Sedondary2
                  : AppColors.appE5E5E5Border,
            ),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Center(
            child: CustomText(
              text: controller.holidaySwitchTitle(state),
              fontSize: 14.w,
              fontWeight: FontWeight.w400,
              color: isSelected
                  ? AppColors.app670379Sedondary2
                  : AppColors.appA0A0A0Text2,
            ),
          ),
        );
      }),
    );
  }
}
