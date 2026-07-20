import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hr_core/src/custom_widgets/custom_container/custom_container.dart';
import 'package:hr_core/src/custom_widgets/custom_image/custom_image.dart';
import 'package:hr_core/src/custom_widgets/custom_text/custom_text.dart';
import 'package:hr_core/src/theme/app_theme.dart';

class FeatureCardWidget extends StatelessWidget {
  const FeatureCardWidget({
    super.key,
    required this.image,
    required this.title,
    this.onTap,
  });

  final String image;
  final String title;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final brand = Theme.of(context).colorScheme.secondary;

    return GestureDetector(
      onTap: onTap,
      child: CustomContainer(
        verticalPadding: 12.h,
        horizontalPadding: 10.w,
        color: AppColors.appFAFAFABackGround2,
        borderColor: AppColors.appE5E5E5Border,
        child: Row(
          children: [
            Container(
              width: 34.w,
              height: 34.w,
              padding: EdgeInsets.all(7.w),
              decoration: BoxDecoration(
                color: brand.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: CustomImage(image: image),
            ),
            8.horizontalSpace,
            Expanded(
              child: CustomText(
                overflow: TextOverflow.ellipsis,
                text: title,
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 18.sp,
              color: brand.withValues(alpha: 0.7),
            ),
          ],
        ),
      ),
    );
  }
}
