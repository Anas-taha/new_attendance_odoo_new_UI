import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hr_core/src/app/app_route.dart';
import 'package:hr_core/src/custom_widgets/custom_button/custom_button.dart';
import 'package:hr_core/src/custom_widgets/custom_text/custom_text.dart';
import 'package:hr_core/src/services/odoo_rpc_service.dart';

class CustomDialog {
  static bool _loginAgainShowing = false;

  static Future dialog({
    required Widget child,
    bool barrierDismissible = true,
  }) {
    return showDialog(
      context: Get.context!,
      barrierDismissible: barrierDismissible,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              content: child,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            );
          },
        );
      },
    );
  }

  /// Clears stored token/credentials then sends the user to a fresh login form.
  static Future<void> loginAgainDialog(String? message) async {
    if (_loginAgainShowing) {
      return;
    }
    _loginAgainShowing = true;

    try {
      await OdooRPCService.instance.invalidateLocalAuth(keepSavedEmail: true);

      if (Get.context == null) {
        Get.offAllNamed(AppRoutes.login);
        return;
      }

      await dialog(
        barrierDismissible: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomText(text: message ?? ''),
             CustomText(
              text: 'Your session has expired. Please log in again.',
            ),
            CustomButton(
              text: 'Login Again',
              onTap: () {
                Get.back();
                Get.offAllNamed(AppRoutes.login);
              },
            ),
          ],
        ),
      );
    } finally {
      _loginAgainShowing = false;
    }
  }
}
