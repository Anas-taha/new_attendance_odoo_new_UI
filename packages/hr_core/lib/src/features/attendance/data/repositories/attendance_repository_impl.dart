import 'package:hr_core/src/features/attendance/data/model/attendance_model.dart';
import 'package:hr_core/src/features/attendance/domain/repositories/attendance_repository.dart';
import 'package:hr_core/src/models/attendance_model.dart';
import 'package:hr_core/src/models/hr_employee.dart';
import 'package:hr_core/src/services/attendance_report_service.dart';
import 'package:hr_core/src/services/hr_service.dart';

class AttendanceRepositoryImpl implements AttendanceRepository {
  AttendanceRepositoryImpl({
    HrService? hrService,
    AttendanceReportService? attendanceReportService,
  }) : _attendanceReportService =
           attendanceReportService ?? AttendanceReportService.instance;

  final AttendanceReportService _attendanceReportService;

  @override
  Future<AttendanceSummaryModel> getAttendanceSummary({
    String? dateFrom,
    String? dateTo,
  }) async =>
      await _attendanceReportService.getAttendanceSummary(
        dateFrom: dateFrom,
        dateTo: dateTo,
      );

  // @override
  // Future<List<AttendanceModel>> getAllAttendance() =>
  //     _attendanceReportService.getAllAttendance();

  // @override
  // Future<HrEmployee?> getCurrentEmployee() => _hrService.getCurrentEmployee();

  // @override
  // Future<Map<String, dynamic>> getTodayAttendanceSummary({int? employeeId}) =>
  //     _hrService.getTodayAttendanceSummary(employeeId: employeeId);

  // @override
  // Future<bool> checkIn({int? employeeId}) =>
  //     _hrService.checkIn(employeeId: employeeId);

  // @override
  // Future<bool> checkOut({int? employeeId}) =>
  //     _hrService.checkOut(employeeId: employeeId);
}
