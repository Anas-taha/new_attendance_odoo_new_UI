import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hr_app_odoo/features/attendance/presentation/controller/attendance_controller.dart';
import 'package:hr_app_odoo/features/attendance/presentation/widgets/attendance_record_card_widget.dart';
import 'package:hr_app_odoo/generated/l10n/app_localizations.dart';

class TodayRecordWidget extends StatelessWidget {
  TodayRecordWidget({super.key});
  final controller = Get.find<AttendanceController>();

  @override
  Widget build(BuildContext context) {
    if (controller.todayRecords.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            Icon(Icons.access_time, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.noAttendanceToday,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)!.checkInToStart,
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF764ba2).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.history,
                color: Color(0xFF764ba2),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              AppLocalizations.of(context)!.todayRecords,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3748),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: controller.todayRecords.length,
          itemBuilder: (context, index) {
            final record = controller.todayRecords[index];
            return AttendanceRecordCardWidget(index: index, record: record);
          },
        ),
      ],
    );
  }
}
