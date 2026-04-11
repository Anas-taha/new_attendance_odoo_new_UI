import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hr_app_odoo/app/app_image.dart';
import 'package:hr_app_odoo/app/app_route.dart';
import 'package:hr_app_odoo/custom_widgets/custom_button/custom_back_button.dart';
import 'package:hr_app_odoo/features/home/presentation/pages/home_screen.dart';
import 'package:hr_app_odoo/theme/app_theme.dart';
import 'package:hr_app_odoo/custom_widgets/custom_image/custom_image.dart';
import 'package:hr_app_odoo/custom_widgets/custom_text/custom_text.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({
    super.key,
    required this.title,
    this.onBackTap,
    this.onHomeTap,
    this.onNotificationTap,
    this.showNotivication = true,
  });

  final String title;
  final VoidCallback? onBackTap;
  final VoidCallback? onHomeTap;
  final VoidCallback? onNotificationTap;
  final bool showNotivication;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 1,
      shadowColor: AppColors.app1A1A1AText1.withValues(alpha: 0.5),
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          CustomBackButton(),
          CustomText(
            text: title,
            fontSize: 17.w,
            fontWeight: FontWeight.w700,
            color: AppColors.appPrimaryColor,
          ),
          8.horizontalSpace,
          const Spacer(),

          // _buildIconButton(image: AppImage.notifications),
          // 4.horizontalSpace,
          (showNotivication)
              ? _buildIconButton(
                  height: 30,
                  image: AppImage.notificationIcon,
                  onTap: () => Get.toNamed(AppRoutes.notifications),
                )
              : SizedBox.shrink(),
          5.horizontalSpace,
          _buildIconButton(
            image: AppImage.home,
            onTap: () => Get.offAllNamed(AppRoutes.home),
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton({
    required String image,
    VoidCallback? onTap,
    double height = 24,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: height.h,
        width: 30.w,
        // padding: const EdgeInsets.all(4),
        child: CustomImage(fit: BoxFit.contain, image: image),
      ),
    );
  }
}
