import 'package:hr_app_odoo/models/check_in_model.dart';
import 'package:hr_app_odoo/models/hr_employee.dart';

abstract class HomeRepository {
  Future<CheckInModel> getAttendanceCheck({
    required double latitude,
    required double longitude,
    required String address,
  });
  Future<HrEmployee?> getCurrentEmployee();

  Future<Map<String, dynamic>> getTodayAttendanceSummary();

  Future<bool> checkIn();

  Future<bool> checkOut();

  Future<void> logout();
}
