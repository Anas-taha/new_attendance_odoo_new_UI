import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:hr_app_odoo/theme/app_theme.dart';

class CustomItem {
  static Widget customDivider({
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

  static Widget customLoading({required RxBool loading}) {
    return Obx(() {
      if (loading.value) {
        return Container(
          height: double.infinity,
          width: double.infinity,
          color: AppColors.app9F9F9FText4.withValues(alpha: 0.1),
          child: Center(child: CircularProgressIndicator()),
        );
      } else {
        return SizedBox();
      }
    });
  }
}
