import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hr_app_odoo/features/attendance/presentation/controller/attendance_controller.dart';
import 'package:hr_app_odoo/generated/l10n/app_localizations.dart';

class StstusIndicatorWidget extends StatelessWidget {
    StstusIndicatorWidget({super.key});
  final controller = Get.find<AttendanceController>();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: controller.isCheckedIn ? Colors.green[50] : Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: controller.isCheckedIn ? Colors.green[200]! : Colors.blue[200]!,
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: controller.isCheckedIn ? Colors.green[100] : Colors.blue[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              controller.isCheckedIn ? Icons.work : Icons.schedule,
              color: controller.isCheckedIn ? Colors.green[700] : Colors.blue[700],
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  controller.isCheckedIn
                      ? '🟢 ${AppLocalizations.of(context)!.currentlyWorkingStatus}'
                      : '🔵 ${AppLocalizations.of(context)!.readyToStart}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: controller.isCheckedIn ? Colors.green[700] : Colors.blue[700],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  controller.isCheckedIn
                      ? AppLocalizations.of(context)!.checkedInActive
                      : AppLocalizations.of(context)!.notCheckedInReady,
                  style: TextStyle(
                    fontSize: 14,
                    color: controller.isCheckedIn ? Colors.green[600] : Colors.blue[600],
                  ),
                ),
                if (controller.isCheckedIn && controller.checkInTime != '--:--:--') ...[
                  const SizedBox(height: 4),
                  Text(
                    AppLocalizations.of(context)!.startedAtLabel(controller.checkInTime),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
