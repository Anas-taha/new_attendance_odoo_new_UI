import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hr_app_odoo/app/app_image.dart';
import 'package:hr_app_odoo/theme/app_theme.dart';
import 'package:hr_app_odoo/widgets/custom_container/custom_container.dart';
import 'package:hr_app_odoo/widgets/custom_image/custom_image.dart';
import 'package:hr_app_odoo/widgets/custom_text/custom_text.dart';

class NotificationCardWidget extends StatelessWidget {
  NotificationCardWidget({
    super.key,
    required this.title,
    this.onTap,
    this.date,
  });

  String title;
  String? date;
  VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: CustomContainer(
        usedefaultSahdow: true,
        verticalPadding: 8,
        borderRadius: 5,
        color: AppColors.appFAFAFABackGround2,
        borderColor: AppColors.appE5E5E5Border,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              width: 32,
              height: 32,
              padding: EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.appE1CDE4CardBG,
                shape: BoxShape.circle,
              ),
              child: CustomImage(image: AppImage.notifications),
            ),
            8.horizontalSpace,
            CustomText(
              text: title,
              fontSize: 13.w,
              fontWeight: FontWeight.w600,
            ),
            const Spacer(),
            CustomText(
              text: date ?? '',
              color: AppColors.app9F9F9FText4,
              fontSize: 11.w,
              fontWeight: FontWeight.w600,
            ),
          ],
        ),
      ),
    );
  }
}
