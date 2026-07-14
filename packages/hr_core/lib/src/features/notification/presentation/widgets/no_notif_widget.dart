import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hr_core/src/services/extension.dart';
import 'package:hr_core/src/app/app_image.dart';
import 'package:hr_core/src/theme/app_theme.dart';
import 'package:hr_core/src/custom_widgets/custom_image/custom_image.dart';
import 'package:hr_core/src/custom_widgets/custom_text/custom_text.dart';

class NoNotificationWidget extends StatelessWidget {
  NoNotificationWidget({super.key, this.height});
  double? height;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: height ?? 100.h),
        CustomImage(image: AppImage.notification),
        CustomText(text: context.appWords.noNotification, color: AppColors.app212529Text5),
        4.verticalSpace,
        CustomText(
          text: context.appWords.noNotificationDescription,
          fontSize: 14.w,
          fontWeight: FontWeight.w400,
          color: AppColors.app6C757DText5,
        ),
      ],
    );
  }
}
