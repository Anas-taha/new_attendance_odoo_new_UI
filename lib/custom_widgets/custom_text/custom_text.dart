import 'package:flutter/material.dart';
import 'package:hr_app_odoo/theme/app_theme.dart';

class CustomText extends StatelessWidget {
  CustomText({
    super.key,
    required this.text,
    this.color,
    this.fontSize,
    this.fontWeight,
    this.bold = false,
    this.overflow,
    this.textAlign,
  });
  String text;
  Color? color;
  double? fontSize;
  FontWeight? fontWeight;
  bool bold;
  TextAlign? textAlign;
  TextOverflow? overflow;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      style: TextStyle(
        color: color ?? AppColors.app1A1A1AText1,
        fontSize: bold ? 20 : fontSize ?? 16,
        fontWeight: bold ? FontWeight.bold : fontWeight ?? FontWeight.w500,
        overflow: overflow,
      ),
    );
  }
}
