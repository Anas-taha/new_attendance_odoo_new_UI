import 'package:flutter/material.dart';
import 'package:hr_app_odoo/theme/app_theme.dart';

class CustomContainer extends StatelessWidget {
  CustomContainer({
    super.key,
    required this.child,
    this.color,
    this.borderRadius,
    this.borderColor,
    this.horizontalPadding,
    this.verticalPadding,
    this.usedefaultSahdow = false,
    this.boxShadow,
  });
  Widget child;
  Color? color;
  double? borderRadius;
  Color? borderColor;
  double? horizontalPadding;
  double? verticalPadding;
  bool? usedefaultSahdow;
  BoxShadow? boxShadow;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding ?? 8,
        vertical: verticalPadding ?? 0,
      ),
      decoration: BoxDecoration(
        color: color ?? AppColors.appE1CDE4CardBG,
        borderRadius: BorderRadius.circular(borderRadius ?? 10),
        border: Border.all(color: borderColor ?? Colors.transparent),
        boxShadow: boxShadow != null
            ? [boxShadow!]
            : usedefaultSahdow == true
            ? [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.4),
                  blurRadius: 4,
                  offset: const Offset(0, 0),
                ),
              ]
            : [],
      ),
      child: child,
    );
  }
}
