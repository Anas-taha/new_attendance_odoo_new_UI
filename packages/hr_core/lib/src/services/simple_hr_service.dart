import 'dart:developer';

import 'package:hr_core/src/models/attendance_model.dart';
import 'package:hr_core/src/models/check_in_model.dart';
import 'package:hr_core/src/models/holiday_model.dart';
import 'package:hr_core/src/models/notification_model.dart';
import 'package:hr_core/src/models/salary_model.dart';
import 'package:hr_core/src/services/odoo_rpc_service.dart';
import 'package:hr_core/src/models/hr_employee.dart';
import 'package:hr_core/src/models/hr_leave.dart';
import 'package:hr_core/src/models/hr_contract.dart';
import 'package:hr_core/src/models/hr_payslip.dart';
import 'package:hr_core/src/models/hr_attendance.dart';

class SimpleHrService {
  final OdooRPCService _odooService = OdooRPCService.instance;

  // SimpleHrService(this._odooService=OdooRPCService.instance);

  /// Get all employees
  Future<HrEmployee> getProfile() async {
    try {
      final result = await _odooService.callOdooApi(
        apiUrl: 'profile',
        // final result = await _odooService.searchRead(
      );
      log(name: 'SimpleHrService', 'getEmployees result: $result');
      if (result['status'] == 'success') {
        return HrEmployee.fromJson(result);
      }
      return HrEmployee();
    } catch (e) {
      // await CustomDialog.loginAgainDialog(e.toString());
      print('❌ Error getting employees: $e');
      // Get.back();
      return HrEmployee();
    }
  }

  /// Upload profile photo + auto face-enrol via POST /mobile/profile/photo.
  ///
  /// [imageBase64] may be raw base64 or a `data:image/jpeg;base64,...` URI.
  /// Returns a structured map — does NOT show UI dialogs so the caller can
  /// force retake on `no_face_detected`.
  Future<Map<String, dynamic>> uploadProfilePhoto({
    required String imageBase64,
  }) async {
    return _odooService.uploadProfilePhoto(imageBase64: imageBase64);
  }

  Future<SalaryModel> getPayslip() async {
    try {
      final result = await _odooService.callOdooApi(
        apiUrl: 'payslips',
        date_from: null,
        date_to: null,
      );
      if (result['status'] == 'success') {
        SalaryModel ddd = SalaryModel.fromJson(result);
        log(name: 'asokdjnbvksjdbngv', "${ddd.status}");
        return SalaryModel.fromJson(result);
      }
      return SalaryModel();
    } catch (e) {
      print('❌ Error getting salary: $e');
      return SalaryModel();
    }
  }

  Future<NotificationModel> getNotification({String? state}) async {
    try {
      final result = await _odooService.callOdooApi(
        apiUrl: 'notifications',
        state: state,
      );
      if (result is Map && result['status'] == 'success') {
        return NotificationModel.fromJson(Map<String, dynamic>.from(result));
      }
      return NotificationModel();
    } catch (e) {
      print('❌ Error getting notifications: $e');
      return NotificationModel();
    }
  }

  /// POST /mobile/notifications/read — mark one or many as read.
  Future<NotificationModel> markNotificationsRead({
    int? id,
    List<int>? ids,
  }) async {
    try {
      final result = await _odooService.callOdooApi(
        apiUrl: 'notifications/read',
        id: id,
        ids: ids,
      );
      if (result is Map && result['status'] == 'success') {
        return NotificationModel.fromJson(Map<String, dynamic>.from(result));
      }
      return NotificationModel(status: 'error');
    } catch (e) {
      print('❌ Error marking notifications read: $e');
      return NotificationModel(status: 'error');
    }
  }

  /// POST /mobile/notifications/mark_read — mark all unread (or given ids).
  Future<NotificationModel> markAllNotificationsRead({List<int>? ids}) async {
    try {
      final result = await _odooService.callOdooApi(
        apiUrl: 'notifications/mark_read',
        ids: ids,
      );
      if (result is Map && result['status'] == 'success') {
        return NotificationModel.fromJson(Map<String, dynamic>.from(result));
      }
      return NotificationModel(status: 'error');
    } catch (e) {
      print('❌ Error mark_read notifications: $e');
      return NotificationModel(status: 'error');
    }
  }

  Future<AttendanceSummaryModel> getAttendanceSummary() async {
    try {
      final result = await _odooService.callOdooApi(
        apiUrl: 'attendance/summary',
        state: null,
      );
      if (result['status'] == 'success') {
        return AttendanceSummaryModel.fromJson(result);
      }
      return AttendanceSummaryModel();
    } catch (e) {
      print('❌ Error getting attendance summary: $e');
      return AttendanceSummaryModel();
    }
  }

  Future<CheckInModel> getAttendanceCheck({
    double? latitude,
    double? longitude,
    String? address,
  }) async {
    try {
      if (latitude == null || longitude == null || address == null) {
        return CheckInModel(status: 'Please enter valid location data');
      }
      final result = await _odooService.callOdooApi(
        apiUrl: 'attendance/check',
        latitude: latitude,
        longitude: longitude,
        address: address,
      );
      log(name: 'SimpleHrService', 'attendance/check response: $result');
      if (result is Map<String, dynamic> && result['status'] == 'success') {
        return CheckInModel.fromJson(result);
      }
      if (result is Map) {
        final message = result['message']?.toString();
        if (message != null && message.isNotEmpty) {
          log(
            name: 'SimpleHrService',
            'attendance/check failed: $message',
          );
          return CheckInModel(status: message);
        }
      }
      return CheckInModel(
        status: result is Map ? result['status']?.toString() : 'error',
      );
    } catch (e, stackTrace) {
      log(
        'Error attendance/check: $e',
        name: 'SimpleHrService',
        stackTrace: stackTrace,
      );
      return CheckInModel(status: 'error');
    }
  }

  static const _leaveSearchReadFields = [
    'name',
    'holiday_status_id',
    'date_from',
    'date_to',
    'number_of_days',
    'state',
  ];

  /// Postman: hr.leave — search_read via /mobile/jsonrpc
  Future<List<Leaves>?> searchLeavesFromApi({List<int>? holidayStatusIds}) async {
    try {
      final domain = <List<dynamic>>[];
      if (holidayStatusIds != null && holidayStatusIds.isNotEmpty) {
        if (holidayStatusIds.length == 1) {
          domain.add(['holiday_status_id', '=', holidayStatusIds.first]);
        } else {
          domain.add(['holiday_status_id', 'in', holidayStatusIds]);
        }
      }

      final result = await _odooService.searchRead(
        model: 'hr.leave',
        fields: _leaveSearchReadFields,
        domain: domain,
        limit: 100,
      );

      if (result['success'] != true || result['data'] == null) {
        return null;
      }

      final data = result['data'] as List<dynamic>;
      return data
          .map((item) => Leaves.fromSearchRead(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('❌ Error search_read hr.leave: $e');
      return null;
    }
  }

  Future<HolidaysModel> getHolidays() async {
    try {
      final result = await _odooService.callOdooApi(
        apiUrl: 'leaves',
        date_from: null,
        leave_type_id: 1,
      );
      if (result['status'] == 'success') {
        return HolidaysModel.fromJson(result);
      }
      return HolidaysModel();
    } catch (e) {
      print('❌ Error getting holidays: $e');
      return HolidaysModel();
    }
  }

  Future<List<HrEmployee>> getEmployees() async {
    try {
      final result = await _odooService.searchRead(
        model: 'hr.employee',
        fields: [
          'id',
          'name',
          'work_email',
          'work_phone',
          'job_title',
          'department_id',
          'work_location_id',
        ],
        domain: [],
        limit: 100,
      );
      log(name: 'SimpleHrService', 'getEmployees result: $result');
      if (result['success']) {
        final data = result['data'] as List<dynamic>;
        return data.map((item) => HrEmployee.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      print('❌ Error getting employees: $e');
      return [];
    }
  }

  /// Get employee contracts
  Future<List<HrContract>> getEmployeeContracts() async {
    try {
      final result = await _odooService.searchRead(
        model: 'hr.contract',
        fields: [
          'id',
          'name',
          'employee_id',
          'date_start',
          'date_end',
          'state',
          'wage',
        ],
        domain: [],
        limit: 100,
      );

      if (result['success']) {
        final data = result['data'] as List<dynamic>;
        return data.map((item) => HrContract.fromOdoo(item)).toList();
      }
      return [];
    } catch (e) {
      print('❌ Error getting contracts: $e');
      return [];
    }
  }

  /// Get employee leaves
  Future<List<HrLeave>> getLeaves() async {
    try {
      final result = await _odooService.searchRead(
        model: 'hr.leave',
        fields: [
          'id',
          'name',
          'employee_id',
          'holiday_status_id',
          'date_from',
          'date_to',
          'number_of_days',
          'state',
        ],
        domain: [],
        limit: 100,
      );

      if (result['success']) {
        final data = result['data'] as List<dynamic>;
        return data.map((item) => HrLeave.fromOdoo(item)).toList();
      }
      return [];
    } catch (e) {
      print('❌ Error getting leaves: $e');
      return [];
    }
  }

  /// Get holiday status types
  Future<List<Map<String, dynamic>>> getHolidayStatusTypes() async {
    try {
      final result = await _odooService.searchRead(
        model: 'hr.leave.type',
        fields: ['id', 'name'],
        domain: [],
        limit: 100,
      );

      if (result['success']) {
        final data = result['data'] as List<dynamic>;
        return data.map((item) => item as Map<String, dynamic>).toList();
      }
      return [];
    } catch (e) {
      print('❌ Error getting holiday status types: $e');
      return [];
    }
  }

  /// Create a new leave request (Postman: hr.leave — create via jsonrpc).
  Future<Map<String, dynamic>> createLeave(Map<String, dynamic> leaveData) async {
    try {
      final payload = Map<String, dynamic>.from(leaveData);
      if (payload['request_date_from'] != null) {
        payload['request_date_from'] =
            _normalizeLeaveDate(payload['request_date_from'].toString());
      }
      if (payload['request_date_to'] != null) {
        payload['request_date_to'] =
            _normalizeLeaveDate(payload['request_date_to'].toString());
      }

      final result = await _odooService.create(
        model: 'hr.leave',
        values: payload,
      );

      if (result['success'] == true) {
        return {'success': true, 'id': result['data']};
      }

      return {
        'success': false,
        'error': result['error']?.toString() ?? 'Create failed',
      };
    } catch (e) {
      print('❌ Error creating leave: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  String _normalizeLeaveDate(String raw) {
    final value = raw.trim();
    if (value.isEmpty) {
      return value;
    }

    if (RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(value)) {
      return value;
    }

    final parts = value.split('/');
    if (parts.length == 3) {
      final day = int.tryParse(parts[0]);
      final month = int.tryParse(parts[1]);
      final year = int.tryParse(parts[2]);
      if (day != null && month != null && year != null) {
        return '${year.toString().padLeft(4, '0')}-'
            '${month.toString().padLeft(2, '0')}-'
            '${day.toString().padLeft(2, '0')}';
      }
    }

    final parsed = DateTime.tryParse(value.replaceFirst(' ', 'T'));
    if (parsed != null) {
      return '${parsed.year.toString().padLeft(4, '0')}-'
          '${parsed.month.toString().padLeft(2, '0')}-'
          '${parsed.day.toString().padLeft(2, '0')}';
    }

    return value;
  }

  /// Update a leave request
  Future<bool> updateLeave(int leaveId, Map<String, dynamic> values) async {
    try {
      final result = await _odooService.write(
        model: 'hr.leave',
        recordId: leaveId,
        values: values,
      );

      return result['success'] ?? false;
    } catch (e) {
      print('❌ Error updating leave: $e');
      return false;
    }
  }

  /// Force refresh data
  Future<void> forceRefresh() async {
    // Simple service doesn't need refresh logic
    print('✅ Force refresh called (no-op in simple service)');
  }

  /// Create leave from HrLeave object
  Future<bool> createLeaveFromObject(HrLeave leave) async {
    try {
      final leaveData = leave.toOdoo();
      final result = await _odooService.create(
        model: 'hr.leave',
        values: leaveData,
      );

      return result['success'] ?? false;
    } catch (e) {
      print('❌ Error creating leave from object: $e');
      return false;
    }
  }

  /// Update leave from HrLeave object
  Future<bool> updateLeaveFromObject(HrLeave leave) async {
    try {
      final leaveData = leave.toOdoo();
      final result = await _odooService.write(
        model: 'hr.leave',
        recordId: leave.id,
        values: leaveData,
      );

      return result['success'] ?? false;
    } catch (e) {
      print('❌ Error updating leave from object: $e');
      return false;
    }
  }

  /// get Salary --------------------------------------------------------
  Future<List<HrPayslip>> getEmployeePayslips() async {
    try {
      final result = await _odooService.searchRead(
        model: 'hr.payslip',
        fields: [
          'id',
          'name',
          'employee_id',
          'state',
          'date_from',
          'date_to',
          'basic_wage',
          'gross_wage',
          'net_wage',
        ],
        domain: [],
        limit: 100,
      );

      if (result['success']) {
        final data = result['data'] as List<dynamic>;
        return data.map((item) => HrPayslip.fromOdoo(item)).toList();
      }
      return [];
    } catch (e) {
      print('❌ Error getting payslips: $e');
      return [];
    }
  }

  Future<bool> getPayslipLine() async {
    try {
      final result = await _odooService.searchRead(
        model: 'hr.payslip.line',
        listInsideArgs: ["slip_id", "=", 1],
        fields: [
          "name",
          "code",
          "category_id",
          "quantity",
          "rate",
          "amount",
          "total",
        ],
      );
      if (result['success']) {
        return true;
        // final data = result['data'] as List<dynamic>;
        // return data.map((item) => HrSalaryModel.fromOdoo(item)).toList();
      }
      return false;
    } catch (e) {
      print('❌ Error getting salary: $e');
      return false;
    }
  }
}
