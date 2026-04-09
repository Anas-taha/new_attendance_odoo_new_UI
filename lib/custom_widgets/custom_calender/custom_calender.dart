import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hr_app_odoo/custom_widgets/custom_Item/custom_item.dart';
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
            CustomItem.customDivider(),
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

                selectedDayPredicate: (day) {
                  if (contorller.text.isNotEmpty) {
                    final selectedDate = DateFormat(
                      'd/M/yyyy',
                    ).parse(contorller.text);
                    return isSameDay(day, selectedDate);
                  }
                  return false;
                },

                onDaySelected: (selectedDay, focusedDay) {
                  contorller.text =
                      '${selectedDay.day}/${selectedDay.month}/${selectedDay.year}';
                  Get.back();
                },

                calendarStyle: CalendarStyle(
                  selectedDecoration: const BoxDecoration(
                    color: AppColors.appPrimaryColor,
                    shape: BoxShape.circle,
                  ),

                  todayDecoration: contorller.text.isEmpty
                      ? const BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        )
                      : const BoxDecoration(color: Colors.transparent),

                  todayTextStyle: TextStyle(
                    color: contorller.text.isEmpty
                        ? Colors.white
                        : Colors.black,
                  ),
                ),

                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextStyle: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.app1A1A1AText1,
                  ),
                  leftChevronIcon: Icon(
                    Icons.chevron_left,
                    size: 30,
                    color: AppColors.appPrimaryColor,
                  ),
                  rightChevronIcon: Icon(
                    Icons.chevron_right,
                    size: 30,
                    color: AppColors.appPrimaryColor,
                  ),
                ),
              ),
            ),
            CustomItem.customDivider(),
            CustomItem.customDivider(horizontalPadding: 30),
            CustomItem.customDivider(horizontalPadding: 50),
          ],
        ),
      ),
    );
  }
}
