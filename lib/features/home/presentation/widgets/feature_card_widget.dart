import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hr_app_odoo/theme/app_theme.dart';
import 'package:hr_app_odoo/custom_widgets/custom_container/custom_container.dart';
import 'package:hr_app_odoo/custom_widgets/custom_image/custom_image.dart';
import 'package:hr_app_odoo/custom_widgets/custom_text/custom_text.dart';

class FeatureCardWidget extends StatelessWidget {
  FeatureCardWidget({
    super.key,
    required this.image,
    required this.title,
    this.onTap,
  });
  String image;
  String title;

  VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: CustomContainer(
        verticalPadding: 8,
        color: AppColors.appFAFAFABackGround2,
        borderColor: AppColors.appE5E5E5Border,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              width: 32,
              height: 32,
              padding: EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: AppColors.appE1CDE4CardBG,
                shape: BoxShape.circle,
                // borderRadius: BorderRadius.circular(25),
              ),
              child: CustomImage(image: image),
            ),
            8.horizontalSpace,
            CustomText(
              text: title,
              fontSize: 13.w,
              fontWeight: FontWeight.w600,
            ),
          ],
        ),
      ),
    );
  }
}
