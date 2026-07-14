import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hr_core/src/app/app_image.dart';
import 'package:hr_core/src/theme/app_theme.dart';
import 'package:hr_core/src/custom_widgets/custom_image/custom_image.dart';
import 'package:hr_core/src/custom_widgets/custom_text/custom_text.dart';

class CustomTextField extends StatelessWidget {
  CustomTextField({
    super.key,
    required this.controller,
    this.enabled = true,
    this.prefixIcon,
    this.usePrefixCalender = false,
    this.hintText,
    this.suffixIcon,
    this.useSuffixArrow = false,
    this.maxLines,
    this.hintLocationTop = false,
    this.hintFontWeight,
    this.obscureText = false,
    this.height,
    this.fontSize,
  });

  TextEditingController controller;
  bool enabled;
  Widget? prefixIcon;
  Widget? suffixIcon;
  bool usePrefixCalender;
  bool useSuffixArrow;
  String? hintText;
  int? maxLines;
  bool hintLocationTop;
  FontWeight? hintFontWeight;
  bool obscureText;
  final double? height;
  final double? fontSize;

  double get _fontSize => fontSize ?? 12.w;

  @override
  Widget build(BuildContext context) {
    final field = SizedBox(
      height: height,
      child: TextFormField(
        controller: controller,
        enabled: enabled,
        maxLines: obscureText ? 1 : maxLines,
        obscureText: obscureText,
        style: TextStyle(
          fontSize: _fontSize,
          fontWeight: FontWeight.w500,
          color: AppColors.app1A1A1AText1,
        ),
        decoration: InputDecoration(
          filled: true,
          isDense: height != null,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 10.w,
            vertical: height != null ? 0 : 14,
          ),
          hint: Text(
            hintLocationTop ? '' : hintText ?? '',
            style: TextStyle(
              fontSize: _fontSize,
              fontWeight: FontWeight.w500,
              color: AppColors.appA0A0A0Text2,
            ),
          ),
          fillColor: AppColors.appFAFAFABackGround2,
          prefixIcon: usePrefixCalender
              ? Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.w),
                  child: CustomImage(
                    image: AppImage.calender,
                    height: 18.h,
                    width: 18.w,
                  ),
                )
              : prefixIcon,
          prefixIconConstraints: BoxConstraints(
            minWidth: usePrefixCalender ? 36.w : 0,
            minHeight: height ?? 48.h,
          ),
          border: _borderStyle(),
          enabledBorder: _borderStyle(),
          focusedBorder: _borderStyle(),
          disabledBorder: _borderStyle(),
          suffixIcon: useSuffixArrow
              ? Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: AppColors.appA0A0A0Text2,
                  size: 22,
                )
              : suffixIcon,
        ),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hintLocationTop)
          CustomText(
            text: hintText ?? '',
            fontSize: 14,
            fontWeight: hintFontWeight ?? FontWeight.w500,
            color: AppColors.app1A1A1AText1,
          ),
        if (hintLocationTop) 8.verticalSpace,
        field,
      ],
    );
  }
  OutlineInputBorder _borderStyle() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(10)),
      borderSide: BorderSide(color: AppColors.appE5E5E5Border),
    );
  }
}
