import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hr_app_odoo/custom_widgets/custom_text/custom_text.dart';

class HolidayColoredStateCardWidget extends StatelessWidget {
  const HolidayColoredStateCardWidget({
    super.key,
    required this.title,
    required this.stateColor,
    required this.cardColor,
  });

  final String title;
  final Color stateColor;
  final Color cardColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13),
      height: 32.h,
      decoration: BoxDecoration(
        color: cardColor,
        border: Border.all(color: stateColor),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: CustomText(
          text: title,
          fontSize: 14.w,
          fontWeight: FontWeight.w400,
          color: stateColor,
        ),
      ),
    );
  }
}
