import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hr_core/src/theme/app_theme.dart';
import 'package:hr_core/src/custom_widgets/custom_text/custom_text.dart';

class HolidayLeaveTypeChipWidget extends StatelessWidget {
  const HolidayLeaveTypeChipWidget({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 13),
        height: 32.h,
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.appE1CDE4CardBG
              : AppColors.appFAFAFABackGround2,
          border: Border.all(
            color: isSelected
                ? AppColors.app670379Sedondary2
                : AppColors.appE5E5E5Border,
          ),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Center(
          child: CustomText(
            text: label,
            fontSize: 12.w,
            fontWeight: FontWeight.w400,
            color: isSelected
                ? AppColors.app670379Sedondary2
                : AppColors.appA0A0A0Text2,
          ),
        ),
      ),
    );
  }
}
