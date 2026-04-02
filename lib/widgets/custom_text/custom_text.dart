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
  });
  String text;
  Color? color;
  double? fontSize;
  FontWeight? fontWeight;
  bool isBold;
  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: color ?? AppColors.app1A1A1AText1,
        fontSize: isBold ? 20 : fontSize ?? 16,
        fontWeight: isBold ? FontWeight.bold : fontWeight ?? FontWeight.w500,
      ),
    );
  }
}
