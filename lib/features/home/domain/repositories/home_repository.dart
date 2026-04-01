import 'package:hr_app_odoo/models/hr_employee.dart';

abstract class HomeRepository {
  Future<HrEmployee?> getCurrentEmployee();

  Future<Map<String, dynamic>> getTodayAttendanceSummary();

  Future<bool> checkIn();

  Future<bool> checkOut();

  Future<void> logout();
}
