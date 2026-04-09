import 'package:flutter/material.dart';
import 'package:hr_app_odoo/theme/app_theme.dart';

class CustomItem {
  static Widget CustomDivider({
    Color? color,
    double? thickness,
    double? horizontalPadding,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding ?? 16),
      child: Divider(
        thickness: thickness ?? 1,
        color: color ?? AppColors.app1A1A1AText1,
      ),
    );
  }
}
