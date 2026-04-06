import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hr_app_odoo/custom_widgets/custom_text/custom_text.dart';
import 'package:hr_app_odoo/theme/app_theme.dart';

class ProfileItemInfoWidget extends StatelessWidget {
  ProfileItemInfoWidget({super.key, required this.title, required this.value});
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: EdgeInsetsDirectional.only(end: 8),
            child: CustomText(
              text: title,
              fontSize: 16.w,
              fontWeight: FontWeight.w400,
              color: AppColors.appA0A0A0Text2,
            ),
          ),

          Flexible(
            child: CustomText(
              overflow: TextOverflow.clip,
              text: value,
              fontSize: 16.w,
              fontWeight: FontWeight.w400,
              color: AppColors.appPrimaryColor,
            ),
          ),
        ],
      ),
    );
  }
}
