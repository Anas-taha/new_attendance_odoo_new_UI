import 'package:flutter/material.dart';
import 'package:hr_app_odoo/generated/l10n/app_localizations.dart';
import 'package:hr_app_odoo/models/hr_attendance.dart';
import 'package:intl/intl.dart';

class AttendanceRecordCardWidget extends StatelessWidget {
  AttendanceRecordCardWidget({
    super.key,
    required this.record,
    required this.index,
  });
  HrAttendance record;
  int index;

  @override
  Widget build(BuildContext context) {
    final isCurrentSession = record.isCheckedIn;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCurrentSession
            ? const Color(0xFF48BB78).withOpacity(0.1)
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCurrentSession ? const Color(0xFF48BB78) : Colors.grey[200]!,
          width: isCurrentSession ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isCurrentSession
                  ? const Color(0xFF48BB78)
                  : Colors.grey[400],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isCurrentSession ? Icons.play_arrow : Icons.stop,
              color: Colors.white,
              size: 20,
            ),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      isCurrentSession
                          ? AppLocalizations.of(context)!.activeSession
                          : AppLocalizations.of(context)!.completedSession,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isCurrentSession
                            ? const Color(0xFF48BB78)
                            : Colors.grey[700],
                      ),
                    ),
                    const Spacer(),
                    if (isCurrentSession)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF48BB78),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          AppLocalizations.of(context)!.live,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 8),

                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${AppLocalizations.of(context)!.checkIn} ',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          DateFormat('HH:mm:ss').format(record.checkIn),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2D3748),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(width: 24),

                    if (record.checkOut != null) ...[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.checkOut,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            DateFormat('HH:mm:ss').format(record.checkOut!),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2D3748),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(width: 24),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.duration,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            record.getFormattedWorkedHours(),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF667eea),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
