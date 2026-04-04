import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hr_app_odoo/features/attendance/presentation/controller/attendance_controller.dart';
import 'package:hr_app_odoo/generated/l10n/app_localizations.dart';
 
class EmployeeCardWidget extends StatelessWidget {
    EmployeeCardWidget({super.key});
final controller = Get.find<AttendanceController>();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFF6B46C1),
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Icon(Icons.person, size: 30, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  controller.currentEmployee?.name ??
                      AppLocalizations.of(context)!.employee,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3748),
                  ),
                ),
                if (controller.currentEmployee?.jobTitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    controller.currentEmployee!.jobTitle!,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
                const SizedBox(height: 4),
                Text(
                  AppLocalizations.of(context)!.idLabel(
                    controller.currentEmployee?.id.toString() ??
                        AppLocalizations.of(context)!.na,
                  ),
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}