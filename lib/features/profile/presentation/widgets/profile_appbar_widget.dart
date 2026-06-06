import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hr_app_odoo/app/app_image.dart';
import 'package:hr_app_odoo/app/app_route.dart';
import 'package:hr_app_odoo/custom_widgets/custom_button/custom_back_button.dart';
import 'package:hr_app_odoo/custom_widgets/custom_image/custom_image.dart';
import 'package:hr_app_odoo/theme/app_theme.dart';

class ProfileAppBar extends StatelessWidget {
  const ProfileAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          CustomBackButton(color: AppColors.appFAFAFABackGround2),
          Spacer(),
          InkWell(
            onTap: () {
              Get.offAllNamed(AppRoutes.home);
            },
            child: Container(
              height: 24.h,
              width: 24.w,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: CustomImage(
                fit: BoxFit.contain,
                image: AppImage.home,
                color: AppColors.appFAFAFABackGround2,
              ),
            ),
          ),
          InkWell(
            onTap: () {
              Get.toNamed(AppRoutes.notifications);
            },
            child: Container(
              height: 24.h,
              width: 30.w,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: CustomImage(
                color: AppColors.appFAFAFABackGround2,
                fit: BoxFit.contain,
                image: AppImage.notificationIcon,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
