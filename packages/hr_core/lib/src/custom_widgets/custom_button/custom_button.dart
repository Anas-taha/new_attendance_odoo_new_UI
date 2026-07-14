import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hr_core/src/theme/app_theme.dart';
import 'package:hr_core/src/custom_widgets/custom_text/custom_text.dart';

class CustomButton extends StatelessWidget {
  CustomButton({
    super.key,
    required this.text,
    required this.onTap,
    this.color,
    this.height,
  });
  double? height;
  Color? color;
  String text;
  Color? textColor;
  double? textSize;
  Function() onTap;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: height ?? 48.h,
        decoration: BoxDecoration(
          color: color ?? Theme.of(context).colorScheme.secondary,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: CustomText(
            text: text,
            color: textColor ?? AppColors.appFFFFFFBackGround1,
            fontSize: textSize ?? 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
