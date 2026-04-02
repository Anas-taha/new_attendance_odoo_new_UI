import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hr_app_odoo/theme/app_theme.dart';
import 'package:hr_app_odoo/widgets/custom_image/custom_image.dart';
import 'package:hr_app_odoo/widgets/custom_text/custom_text.dart';

class CustomTextValueAndImage extends StatelessWidget {
  const CustomTextValueAndImage({
    super.key,
    required this.text,
    this.textColor,
    this.textSize,
    this.value,
    this.image,
    this.valueColor,
    this.valueSize,
    this.imageSize,
    this.imageColor,
    this.checkValueIsEmpty = false,
    this.crossAxisAlignment = CrossAxisAlignment.center,
  });

  final String text;
  final Color? textColor;
  final double? textSize;
  final String? value;
  final Color? valueColor;
  final double? valueSize;
  final String? image;
  final double? imageSize;
  final Color? imageColor;
  final CrossAxisAlignment crossAxisAlignment;
  final bool checkValueIsEmpty;

  @override
  Widget build(BuildContext context) {
    if (checkValueIsEmpty &&
        (value == null || value == '' || value == 'null')) {
      return const SizedBox.shrink();
    }
    return Row(
      crossAxisAlignment: crossAxisAlignment,
      children: [
        image != null
            ? CustomImage(
                image: image ?? '',
                width: imageSize ?? 14,
                height: imageSize ?? 14,
                color: imageColor,
              )
            : SizedBox.shrink(),
        image != null ? 4.horizontalSpace : SizedBox.shrink(),

        CustomText(
          text: value != null ? text : "$text : ",
          color: textColor ?? AppColors.app1A1A1AText1,
          fontSize: textSize ?? 16,
        ),
        value == null && value != ''
            ? const SizedBox.shrink()
            : Flexible(
                child: CustomText(
                  // overflow: TextOverflow.fade,
                  text: value!,
                  color: imageColor ?? valueColor ?? AppColors.app1A1A1AText1,
                  fontSize: valueSize ?? 16.w,
                ),
              ),
      ],
    );
  }
}
