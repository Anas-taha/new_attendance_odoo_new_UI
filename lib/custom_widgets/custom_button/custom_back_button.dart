import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:hr_app_odoo/app/app_locale.dart';
import 'package:hr_app_odoo/theme/app_theme.dart';

class CustomBackButton extends StatelessWidget {
  const CustomBackButton({super.key, this.color = AppColors.app1A1A1AText1});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        Get.back();
      },
      icon: Icon(size: 20, Icons.arrow_back_ios, color: color),
    );
  }
}
