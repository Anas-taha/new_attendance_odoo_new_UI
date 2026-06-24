import 'package:hr_app_odoo/models/attendance_model.dart';

abstract class AttendanceRepository {
  Future<AttendanceSummaryModel> getAttendanceSummary({
    String? dateFrom,
    String? dateTo,
  });

  // Future<HrEmployee?> getCurrentEmployee();

  // Future<Map<String, dynamic>> getTodayAttendanceSummary({int? employeeId});

  // Future<bool> checkIn({int? employeeId});

  // Future<bool> checkOut({int? employeeId});
}
