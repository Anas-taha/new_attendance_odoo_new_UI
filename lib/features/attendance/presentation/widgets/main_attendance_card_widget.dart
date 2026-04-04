import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hr_app_odoo/features/attendance/presentation/controller/attendance_controller.dart';
import 'package:hr_app_odoo/features/attendance/presentation/widgets/quick_state_widget.dart';
import 'package:hr_app_odoo/features/attendance/presentation/widgets/time_box_widget.dart';
import 'package:hr_app_odoo/generated/l10n/app_localizations.dart';

class MainAttendanceCardWidget extends StatelessWidget {
  MainAttendanceCardWidget({super.key});
  final controller = Get.find<AttendanceController>();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: controller.isCheckedIn
                      ? const LinearGradient(
                          colors: [Colors.green, Colors.greenAccent],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : const LinearGradient(
                          colors: [Color(0xFF6B46C1), Color(0xFF9F7AEA)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  controller.isCheckedIn ? Icons.work : Icons.access_time,
                  size: 24,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      controller.isCheckedIn
                          ? AppLocalizations.of(context)!.currentlyWorking
                          : AppLocalizations.of(context)!.registerAttendance,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                    Text(
                      controller.isCheckedIn
                          ? AppLocalizations.of(
                              context,
                            )!.checkedInSinceUseLogout(controller.checkInTime)
                          : AppLocalizations.of(context)!.notCheckedInUseLogin,
                      style: TextStyle(
                        fontSize: 14,
                        color: controller.isCheckedIn
                            ? Colors.green[600]
                            : Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Quick Stats
          Row(
            children: [
              Expanded(
                child: QuickStateWidget(
                  icon: Icons.timer,
                  title: AppLocalizations.of(context)!.today,
                  value: controller.totalWorkedHours.value,
                  color: const Color(0xFF667eea),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: QuickStateWidget(
                  icon: Icons.schedule,
                  title: AppLocalizations.of(context)!.records,
                  value: '${controller.todayRecords.length}',
                  color: const Color(0xFF764ba2),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Session Timer (only show when checked in)
          if (controller.isCheckedIn) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6B46C1), Color(0xFF9F7AEA)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    AppLocalizations.of(context)!.currentSession,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TimeBoxWidget(
                        time:
                            '${(controller.seconds ~/ 3600).toString().padLeft(2, '0')}',
                      ),
                      const Text(
                        ' : ',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TimeBoxWidget(
                        time:
                            '${((controller.seconds % 3600) ~/ 60).toString().padLeft(2, '0')}',
                      ),
                      const Text(
                        ' : ',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TimeBoxWidget(
                        time:
                            '${(controller.seconds % 60).toString().padLeft(2, '0')}',
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(
                      context,
                    )!.startedAt(controller.checkInTime),
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Register Attendance Section
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                controller.isCheckedIn
                    ? AppLocalizations.of(context)!.endYourShift
                    : AppLocalizations.of(context)!.startYourShift,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3748),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                controller.isCheckedIn
                    ? AppLocalizations.of(context)!.checkedInClickLogout
                    : AppLocalizations.of(context)!.notCheckedInClickLogin,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: controller.handleCheckInOut,
                      icon: Icon(
                        controller.isCheckedIn ? Icons.logout : Icons.login,
                      ),
                      label: Text(
                        controller.isCheckedIn
                            ? AppLocalizations.of(context)!.logOut
                            : AppLocalizations.of(context)!.logIn,
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: controller.isCheckedIn
                            ? Colors.red[600]
                            : Colors.green[600],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          Navigator.pushNamed(context, '/attendance-report'),
                      icon: const Icon(Icons.analytics),
                      label: Text(AppLocalizations.of(context)!.viewReports),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF6B46C1),
                        side: const BorderSide(color: Color(0xFF6B46C1)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
