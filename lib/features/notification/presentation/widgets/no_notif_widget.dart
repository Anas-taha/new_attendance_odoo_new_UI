import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hr_app_odoo/app/app_image.dart';
import 'package:hr_app_odoo/theme/app_theme.dart';
import 'package:hr_app_odoo/widgets/custom_image/custom_image.dart';
import 'package:hr_app_odoo/widgets/custom_text/custom_text.dart';

class NoNotificationWidget extends StatelessWidget {
  const NoNotificationWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 100.h),
        CustomImage(image: AppImage.notification),
        CustomText(text: 'لا يوجد إشعارات', color: AppColors.app212529Text5),
        4.verticalSpace,
        CustomText(
          text: 'سنخبرك عندما يكون هناك شيء لتحديثك.',
          fontSize: 14.w,
          fontWeight: FontWeight.w400,
          color: AppColors.app6C757DText5,
        ),
      ],
    );
  }
}
