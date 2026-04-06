import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:hr_app_odoo/theme/app_theme.dart';

class CustomBackButton extends StatefulWidget {
  const CustomBackButton({super.key, this.color = AppColors.app1A1A1AText1});
  final Color color;

  @override
  State<CustomBackButton> createState() => _CustomBackButtonState();
}

class _CustomBackButtonState extends State<CustomBackButton> {
  @override
  Widget build(BuildContext context) {
    String languageCode = Get.locale!.languageCode;
    log(name: 'wcdwecewc', languageCode);
    return IconButton(
      onPressed: () => Get.back(),
      icon: Icon(
        size: 20,
        languageCode == 'ar' ? Icons.arrow_back_ios : Icons.arrow_forward_ios,
        color: widget.color,
      ),
    );
  }
}
