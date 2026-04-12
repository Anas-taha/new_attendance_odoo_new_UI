import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hr_app_odoo/app/app_image.dart';
import 'package:hr_app_odoo/theme/app_theme.dart';
import 'package:hr_app_odoo/custom_widgets/custom_image/custom_image.dart';
import 'package:hr_app_odoo/custom_widgets/custom_text/custom_text.dart';

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
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hintLocationTop == true)
          CustomText(
            text: hintText ?? '',
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: AppColors.app1A1A1AText1,
          ),
        8.verticalSpace,
        TextFormField(
          controller: controller,
          enabled: enabled,
          maxLines: maxLines,
          decoration: InputDecoration(
            filled: true,
            hint: CustomText(
              text: hintLocationTop ? '' : hintText ?? '',
              color: AppColors.appA0A0A0Text2,
              fontSize: 14.w,
              fontWeight: FontWeight.w500,
            ),
            fillColor: AppColors.appFAFAFABackGround2,
            prefixIcon: usePrefixCalender
                ? Container(
                    padding: EdgeInsets.all(10),
                    child: CustomImage(image: AppImage.calender),
                  )
                : prefixIcon,
            border: _borderStyle(),
            suffixIcon: useSuffixArrow
                ? Icon(
                    Icons.keyboard_arrow_down_sharp,
                    color: AppColors.appA0A0A0Text2,
                    size: 30,
                  )
                : suffixIcon,
          ),
        ),
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
