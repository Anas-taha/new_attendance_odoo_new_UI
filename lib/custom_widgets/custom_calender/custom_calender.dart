import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hr_app_odoo/custom_widgets/customItem/custom_item.dart';
import 'package:hr_app_odoo/theme/app_theme.dart';
import 'package:hr_app_odoo/custom_widgets/custom_text/custom_text.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class CustomCalender {
  static void calenderDialog({
    required TextEditingController contorller,
    String? title,
  }) {
    showDialog(
      fullscreenDialog: false,
      useSafeArea: true,
      context: Get.context!,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            16.verticalSpace,
            CustomText(text: title ?? '', fontSize: 18.w),
            8.verticalSpace,
            CustomItem.CustomDivider(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TableCalendar(
                firstDay: DateTime(2020),
                lastDay: DateTime(2030),
                focusedDay: contorller.text.isNotEmpty
                    ? DateFormat('d/M/yyyy').parse(contorller.text)
                    : DateTime.now(),
                locale: 'ar',
                calendarFormat: CalendarFormat.month,

                onDaySelected: (selectedDay, focusedDay) {
                  contorller.text =
                      '${selectedDay.day}/${selectedDay.month}/${selectedDay.year}';
                  Get.back();
                },
                calendarStyle: const CalendarStyle(
                  // defaultDecoration: BoxDecoration(
                  //   color: AppColors.appFFFFFFBackGround1,
                  // ),
                  // todayDecoration: BoxDecoration(
                  //   color: AppColors.appPrimaryColor,
                  //   shape: BoxShape.circle,
                  // ),
                  selectedDecoration: BoxDecoration(
                    color: AppColors.app670379Sedondary2,
                    shape: BoxShape.circle,
                  ),
                ),
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
