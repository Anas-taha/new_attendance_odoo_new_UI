import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:hr_app_odoo/app/app_image.dart';
import 'package:hr_app_odoo/custom_widgets/custom_image/custom_image.dart';
import 'package:hr_app_odoo/custom_widgets/custom_text/custom_text.dart';
import 'package:hr_app_odoo/features/profile/presentation/widgets/change_lang_widget.dart';
import 'package:hr_app_odoo/theme/app_theme.dart';

class ProfileController extends GetxController {
  void openChangeLanguageDialog() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(13),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            10.verticalSpace,
            CustomText(
              text: 'اللغه',
              fontSize: 16.w,
              fontWeight: FontWeight.w700,
              color: AppColors.appPrimaryColor,
            ),
            24.verticalSpace,
            ChangeLangWidget(lang: 'ar'),
            ChangeLangWidget(lang: 'en'),
            const SizedBox(height: 10),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }
}
