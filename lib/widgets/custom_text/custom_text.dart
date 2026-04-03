import 'package:flutter/material.dart';
import 'package:hr_app_odoo/theme/app_theme.dart';

class CustomText extends StatelessWidget {
  CustomText({
    super.key,
    required this.text,
    this.color,
    this.fontSize,
    this.fontWeight,
    this.isBold = false,
    this.overflow,
    this.textAlign,
  });
  String text;
  Color? color;
  double? fontSize;
  FontWeight? fontWeight;
  bool isBold;
  TextAlign? textAlign;
  TextOverflow? overflow;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      style: TextStyle(
        color: color ?? AppColors.app1A1A1AText1,
        fontSize: isBold ? 20 : fontSize ?? 16,
        fontWeight: isBold ? FontWeight.bold : fontWeight ?? FontWeight.w500,
        overflow: overflow,
      ),
    );
  }
}
