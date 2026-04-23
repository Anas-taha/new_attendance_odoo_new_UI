import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hr_app_odoo/app/app_image.dart';
import 'package:hr_app_odoo/app/app_locale.dart';
import 'package:hr_app_odoo/custom_widgets/custom_image/custom_image.dart';
import 'package:hr_app_odoo/custom_widgets/custom_text/custom_text.dart';
import 'package:hr_app_odoo/theme/app_theme.dart';

class ChangeLangWidget extends StatelessWidget {
  const ChangeLangWidget({super.key, required this.lang});
  final String lang;

  @override
  Widget build(BuildContext context) {
    bool isSelected = lang == Get.locale!.languageCode;
    return GestureDetector(
      onTap: () {
        Get.find<AppLocaleController>().changeLang(lang);
        // Get.updateLocale(Locale(lang));
        Get.back();
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 16),
        padding: EdgeInsets.symmetric(horizontal: 9, vertical: 13),
        decoration: BoxDecoration(
          color: AppColors.appF9F9F9Text7,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(3),
              height: 19.h,
              width: 19.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? AppColors.app8A3159Sedondary4
                      : AppColors.app6C757DText5,
                  width: 1,
                ),
              ),
              child: Container(
                padding: EdgeInsets.all(3),
                height: 19.h,
                width: 19.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected
                      ? AppColors.app8A3159Sedondary4
                      : AppColors.appFFFFFFBackGround1,
                ),
              ),
            ),
            12.horizontalSpace,
            CustomImage(
              image: lang == 'ar' ? AppImage.arabic : AppImage.english,
            ),
            8.horizontalSpace,
            CustomText(
              text: lang == 'ar' ? 'اللغه العربية' : 'English',
              fontSize: 14.w,
              color: AppColors.app6C757DText5,
            ),
          ],
        ),
      ),
    );
  }
}
