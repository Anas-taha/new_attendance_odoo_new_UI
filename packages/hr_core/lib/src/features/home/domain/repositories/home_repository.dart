import 'package:hr_core/src/models/check_in_model.dart';
import 'package:hr_core/src/models/hr_employee.dart';

abstract class HomeRepository {
  Future<CheckInModel> getAttendanceCheck({
    required double latitude,
    required double longitude,
    required String address,
  });
  Future<HrEmployee?> getCurrentEmployee();

  Future<HrEmployee?> getProfile();

  Future<Map<String, dynamic>> getTodayAttendanceSummary();

  Future<bool> checkIn();

  Future<bool> checkOut();

  Future<void> logout();
}
