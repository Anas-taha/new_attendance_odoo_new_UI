import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hr_core/src/custom_widgets/custom_container/custom_container.dart';

class TimeBoxWidget extends StatelessWidget {
  const TimeBoxWidget({super.key, required this.time});

  final String time;

  @override
  Widget build(BuildContext context) {
    final brand = Theme.of(context).colorScheme.secondary;
    return CustomContainer(
      color: brand.withValues(alpha: 0.08),
      borderColor: brand.withValues(alpha: 0.2),
      horizontalPadding: 10.w,
      verticalPadding: 8.h,
      child: Center(
        child: Text(
          time,
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: brand,
          ),
        ),
      ),
    );
  }
}
