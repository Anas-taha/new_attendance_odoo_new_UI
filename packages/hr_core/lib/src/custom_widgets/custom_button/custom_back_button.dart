import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hr_core/src/theme/app_theme.dart';

class CustomBackButton extends StatelessWidget {
  const CustomBackButton({
    super.key,
    this.color = AppColors.app1A1A1AText1,
    this.onTap,
  });
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap ?? () => Get.back(),
      icon: Icon(size: 20, Icons.arrow_back_ios, color: color),
    );
  }
}
