import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hr_app_odoo/app/app_route.dart';
import 'package:hr_app_odoo/custom_widgets/custom_button/custom_button.dart';
import 'package:hr_app_odoo/custom_widgets/custom_text/custom_text.dart';

class CustomDialog {
  static Future dialog({
    required Widget child,
    bool barrierDismissible = false,
  }) {
    return showDialog(
      barrierDismissible: barrierDismissible,
      context: Get.context!,
      builder: (_) {
        return child;
      },
    );
  }

  static Future loginAgainDialog(String? message) async {
    await dialog(
      child: Column(
        children: [
          CustomText(text: message ?? ''),
          CustomText(text: 'Your session has expired. Please log in again.'),
          CustomButton(
            text: 'Login Again',
            onTap: () {
              Get.offAll(AppRoutes.login);
            },
          ),
        ],
      ),
    );
  }
}
