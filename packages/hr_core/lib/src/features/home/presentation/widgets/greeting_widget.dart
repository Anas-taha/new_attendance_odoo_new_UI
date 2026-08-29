import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hr_core/src/app/app_image.dart';
import 'package:hr_core/src/app/app_route.dart';
import 'package:hr_core/src/config/odoo_config.dart';
import 'package:hr_core/src/custom_widgets/custom_image/custom_image.dart';
import 'package:hr_core/src/custom_widgets/custom_text/custom_text.dart';
import 'package:hr_core/src/features/home/presentation/controllers/home_controller.dart';
import 'package:hr_core/src/services/extension.dart';
import 'package:hr_core/src/theme/app_theme.dart';

class GreetingWidget extends StatelessWidget {
  const GreetingWidget({
    super.key,
    required this.employeeName,
    this.unreadCount = 0,
  });

  final String employeeName;
  final int unreadCount;

  String get _initials {
    final parts = employeeName
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    String initialOf(String value) =>
        value.isEmpty ? '' : value.substring(0, 1).toUpperCase();
    if (parts.length == 1) {
      final word = parts.first;
      return word.length >= 2
          ? word.substring(0, 2).toUpperCase()
          : initialOf(word);
    }
    return '${initialOf(parts.first)}${initialOf(parts.last)}';
  }

  @override
  Widget build(BuildContext context) {
    final brand = Theme.of(context).colorScheme.secondary;
    final logoPath = OdooConfig.logoAssetPath;
    final headerImagePath = OdooConfig.headerImageAssetPath;
    final hasHeaderImage =
        headerImagePath != null && headerImagePath.isNotEmpty;

    return Column(
      children: [
        Row(
          children: [
           
           
              _BrandAssetImage(path: headerImagePath ?? logoPath!, brand: brand),
          
            if (!hasHeaderImage)
             ... [
              SizedBox(width: 8.w),
               CustomText(
                text: OdooConfig.appName,
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.primary,
              ),],
            const Spacer(),
            _AvatarChip(initials: _initials, brand: brand),
            10.horizontalSpace,
            _NotificationBell(unreadCount: unreadCount, brand: brand),
          ],
        ),
        10.verticalSpace,
        Container(
          height: 2.h,
          width: double.infinity,
          decoration: BoxDecoration(
            color: brand.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(2.r),
          ),
        ),
        12.verticalSpace,
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomText(
                text: context.appWords.welcome,
                color: AppColors.appA0A0A0Text2,
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
              ),
              CustomText(
                text: employeeName,
                color: Theme.of(context).colorScheme.primary,
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BrandAssetImage extends StatelessWidget {
  const _BrandAssetImage({
    required this.path,
    required this.brand,
  });

  final String path;
  final Color brand;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8.r),
      child: Image.asset(
        path,
        height: 40.h,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => Icon(
          Icons.business,
          size: 24.sp,
          color: brand,
        ),
      ),
    );
  }
}

class _AvatarChip extends StatelessWidget {
  const _AvatarChip({required this.initials, required this.brand});

  final String initials;
  final Color brand;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36.h,
      width: 36.w,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: brand.withValues(alpha: 0.12),
        shape: BoxShape.circle,
        border: Border.all(color: brand.withValues(alpha: 0.35)),
      ),
      child: CustomText(
        text: initials,
        fontSize: 12.sp,
        fontWeight: FontWeight.w700,
        color: brand,
      ),
    );
  }
}

class _NotificationBell extends StatelessWidget {
  const _NotificationBell({
    required this.unreadCount,
    required this.brand,
  });

  final int unreadCount;
  final Color brand;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        await Get.toNamed(AppRoutes.notifications);
        if (Get.isRegistered<HomeController>()) {
          await Get.find<HomeController>().loadRecentNotifications();
        }
      },
      borderRadius: BorderRadius.circular(20.r),
      child: SizedBox(
        height: 36.h,
        width: 36.w,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Center(
              child: CustomImage(
                fit: BoxFit.contain,
                image: AppImage.notificationIcon,
                height: 22.h,
                width: 22.w,
              ),
            ),
            if (unreadCount > 0)
              PositionedDirectional(
                top: 0,
                end: 0,
                child: Container(
                  constraints: BoxConstraints(minWidth: 16.w),
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  decoration: BoxDecoration(
                    color: brand,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Text(
                    unreadCount > 9 ? '9+' : '$unreadCount',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 9.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
