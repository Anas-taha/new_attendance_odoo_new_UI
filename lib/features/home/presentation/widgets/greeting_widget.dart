import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hr_app_odoo/app/app_image.dart';
import 'package:hr_app_odoo/generated/l10n/app_localizations.dart';
import 'package:hr_app_odoo/theme/app_theme.dart';
import 'package:hr_app_odoo/widgets/custom_image/custom_image.dart';
import 'package:hr_app_odoo/widgets/custom_text/custom_text.dart';

class GreetingWidget extends StatelessWidget {
  const GreetingWidget({super.key, required this.employeeName});

  final String employeeName;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Row(
          children: [
            InkWell(
              onTap: () {},
              child: Container(
                height: 24.h,
                width: 24.w,
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: CustomImage(fit: BoxFit.contain, image: AppImage.home),
              ),
            ),
            InkWell(
              onTap: () {},
              child: Container(
                height: 24.h,
                width: 30.w,
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: CustomImage(
                  fit: BoxFit.contain,
                  image: AppImage.notifications,
                ),
              ),
            ),
          ],
        ),
        const Spacer(),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            CustomText(
              text: 'مرحباً بك',
              color: AppColors.appA0A0A0Text2,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
            CustomText(
              text: employeeName ?? '',
              color: AppColors.primaryColor,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ],
        ),
      ],
    );
  }
}
