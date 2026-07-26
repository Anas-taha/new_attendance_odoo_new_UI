import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hr_core/src/services/extension.dart';
import 'package:hr_core/src/custom_widgets/custom_Item/custom_item.dart';
import 'package:hr_core/src/custom_widgets/custom_text/custom_text.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class CustomCalender {
  static void calenderDialog({
    required TextEditingController contorller,
    String? title,
    void Function(DateTime selectedDay)? onDateSelected,
  }) {
    final context = Get.context!;
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final secondary = theme.colorScheme.secondary;
    final hasSelectedDate = contorller.text.isNotEmpty;

    showDialog(
      fullscreenDialog: false,
      useSafeArea: true,
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            16.verticalSpace,
            CustomText(
              text: title ?? context.appWords.selectDate,
              fontSize: 18.w,
              fontWeight: FontWeight.w700,
              color: primary,
            ),
            8.verticalSpace,
            CustomItem.customDivider(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TableCalendar(
                firstDay: DateTime(2020),
                lastDay: DateTime(2030),
                focusedDay: hasSelectedDate
                    ? DateFormat('d/M/yyyy').parse(contorller.text)
                    : DateTime.now(),
                locale: Get.locale!.languageCode,
                calendarFormat: CalendarFormat.month,
                selectedDayPredicate: (day) {
                  if (hasSelectedDate) {
                    final selectedDate =
                        DateFormat('d/M/yyyy').parse(contorller.text);
                    return isSameDay(day, selectedDate);
                  }
                  return false;
                },
                onDaySelected: (selectedDay, focusedDay) {
                  contorller.text =
                      '${selectedDay.day}/${selectedDay.month}/${selectedDay.year}';
                  Get.back();
                  onDateSelected?.call(selectedDay);
                },
                calendarStyle: CalendarStyle(
                  selectedDecoration: BoxDecoration(
                    color: secondary,
                    shape: BoxShape.circle,
                  ),
                  todayDecoration: hasSelectedDate
                      ? const BoxDecoration(color: Colors.transparent)
                      : BoxDecoration(
                          color: primary.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: primary.withValues(alpha: 0.45),
                          ),
                        ),
                  todayTextStyle: TextStyle(
                    color: hasSelectedDate ? primary : primary,
                    fontWeight: FontWeight.w600,
                  ),
                  selectedTextStyle: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                headerStyle: HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextStyle: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: primary,
                  ),
                  leftChevronIcon: Icon(
                    Icons.chevron_left,
                    size: 30,
                    color: primary,
                  ),
                  rightChevronIcon: Icon(
                    Icons.chevron_right,
                    size: 30,
                    color: primary,
                  ),
                ),
              ),
            ),
            CustomItem.customDivider(),
            16.verticalSpace,
          ],
        ),
      ),
    );
  }
}
