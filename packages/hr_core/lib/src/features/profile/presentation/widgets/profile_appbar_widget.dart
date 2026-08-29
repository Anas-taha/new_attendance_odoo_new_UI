import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hr_core/src/app/app_image.dart';
import 'package:hr_core/src/app/app_route.dart';
import 'package:hr_core/src/custom_widgets/custom_button/custom_back_button.dart';
import 'package:hr_core/src/custom_widgets/custom_image/custom_image.dart';
import 'package:hr_core/src/features/home/presentation/controllers/home_controller.dart';
import 'package:hr_core/src/theme/app_theme.dart';

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
            onTap: () async {
              await Get.toNamed(AppRoutes.notifications);
              if (Get.isRegistered<HomeController>()) {
                await Get.find<HomeController>().loadRecentNotifications();
              }
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
