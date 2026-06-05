import 'package:hr_app_odoo/features/attendance/data/model/attendance_model.dart';
import 'package:hr_app_odoo/models/hr_employee.dart';

abstract class AttendanceRepository {
  Future<List<AttendanceModel>> getAllAttendance();

  Future<HrEmployee?> getCurrentEmployee();

  Future<Map<String, dynamic>> getTodayAttendanceSummary({int? employeeId});

  Future<bool> checkIn({int? employeeId});

  Future<bool> checkOut({int? employeeId});
}
