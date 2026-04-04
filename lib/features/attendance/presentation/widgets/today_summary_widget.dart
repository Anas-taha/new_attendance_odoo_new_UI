import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hr_app_odoo/features/attendance/presentation/controller/attendance_controller.dart';
import 'package:hr_app_odoo/features/attendance/presentation/widgets/quick_state_widget.dart';
import 'package:hr_app_odoo/generated/l10n/app_localizations.dart';
 
class TodaySummaryWidget extends StatelessWidget {
    TodaySummaryWidget({super.key});
  final controller = Get.find<AttendanceController>();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF667eea).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.today,
                  color: Color(0xFF667eea),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                AppLocalizations.of(context)!.todaySummary,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3748),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: QuickStateWidget(
                  icon: Icons.access_time,
                  title: AppLocalizations.of(context)!.totalWorked,
                  value: controller.totalWorkedHours.value,
                  color: const Color(0xFF667eea),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: QuickStateWidget(
                  icon: Icons.list_alt,
                  title: AppLocalizations.of(context)!.records,
                  value: '${controller.todayRecords.length}',
                  color: const Color(0xFF764ba2),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}