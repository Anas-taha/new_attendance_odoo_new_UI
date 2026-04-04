import 'package:flutter/material.dart';
import 'package:hr_app_odoo/app/app_image.dart';
import 'package:hr_app_odoo/theme/app_theme.dart';
import 'package:hr_app_odoo/widgets/custom_image/custom_image.dart';

class CustomTextField extends StatelessWidget {
  CustomTextField({
    super.key,
    required this.controller,
    this.onTap,
    this.enabled = true,
  });
  TextEditingController controller;
  Function()? onTap;
  bool enabled;
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onTap: () {
        if (!enabled) onTap!();
      },
      enabled: enabled,
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.appFAFAFABackGround2,
        prefixIcon: Container(
          padding: EdgeInsets.all(10),
          child: CustomImage(image: AppImage.calender),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          borderSide: BorderSide(color: AppColors.appE5E5E5Border),
        ),
        suffixIcon: Icon(
          Icons.keyboard_arrow_down_sharp,
          color: AppColors.appA0A0A0Text2,
          size: 30,
        ),
      ),
    );
  }
}
