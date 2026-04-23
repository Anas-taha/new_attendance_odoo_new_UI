import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hr_app_odoo/services/extension.dart';
import 'package:hr_app_odoo/app/app_image.dart';
import 'package:hr_app_odoo/app/app_route.dart';
import 'package:hr_app_odoo/features/notification/presentation/pages/notification_screen.dart';
import 'package:hr_app_odoo/generated/l10n/app_localizations.dart';
import 'package:hr_app_odoo/main.dart';
import 'package:hr_app_odoo/theme/app_theme.dart';
import 'package:hr_app_odoo/custom_widgets/custom_image/custom_image.dart';
import 'package:hr_app_odoo/custom_widgets/custom_text/custom_text.dart';

class GreetingWidget extends StatelessWidget {
  const GreetingWidget({super.key, required this.employeeName});

  final String employeeName;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            CustomText(
              text: context.appWords.welcome,
              color: AppColors.appA0A0A0Text2,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
            CustomText(
              text: employeeName ?? '',
              color: AppColors.appPrimaryColor,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ],
        ),
        const Spacer(),
        InkWell(
          onTap: () {
            Get.toNamed(AppRoutes.notifications);
          },
          child: Container(
            height: 24.h,
            width: 30.w,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: CustomImage(
              fit: BoxFit.contain,
              image: AppImage.notificationIcon,
            ),
          ),
        ),
      ],
    );
  }
}
