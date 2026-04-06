import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hr_app_odoo/features/notification/presentation/controller/notifi_controller.dart';
import 'package:hr_app_odoo/theme/app_theme.dart';
import 'package:hr_app_odoo/custom_widgets/custom_text/custom_text.dart';

class NotificationStateWidget extends StatelessWidget {
  NotificationStateWidget({super.key, required this.state});
  NotifiState state;
  final notifController = Get.find<NotificationController>();
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        notifController.changeNotifiState(state);
      },
      child: Obx(() {
        bool isSelected = notifController.selectedNotifiState.value == state;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.all(8),
          // transform: Matrix4.identity()..scale(isSelected ? 1.05 : 1.0),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.appE1CDE4CardBG
                : AppColors.appFAFAFABackGround2,
            borderRadius: BorderRadius.circular(5),
            border: Border.all(
              color: isSelected
                  ? AppColors.app670379Sedondary2
                  : AppColors.appE5E5E5Border,
              // width: isSelected ? 2 : 1,
            ),
          ),
          child: CustomText(
            textAlign: TextAlign.center,
            text: stateTitle(state),
            color: isSelected
                ? AppColors.app670379Sedondary2
                : AppColors.appA0A0A0Text2,
            fontSize: 14.w,
            fontWeight: FontWeight.w500,
          ),
        );
      }),
    );
  }
}

String stateTitle(NotifiState state) {
  switch (state) {
    case NotifiState.all:
      return 'الكل';
    case NotifiState.readed:
      return 'مقروءة';
    case NotifiState.unReaded:
      return 'غير مقروءة';
  }
}
