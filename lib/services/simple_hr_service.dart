import 'dart:developer';

import 'package:get/get.dart';
import 'package:hr_app_odoo/app/app_route.dart';
import 'package:hr_app_odoo/services/odoo_rpc_service.dart';
import 'package:hr_app_odoo/models/hr_employee.dart';
import 'package:hr_app_odoo/models/hr_leave.dart';
import 'package:hr_app_odoo/models/hr_contract.dart';
import 'package:hr_app_odoo/models/hr_payslip.dart';
import 'package:hr_app_odoo/models/hr_attendance.dart';

class SimpleHrService {
  final OdooRPCService _odooService = OdooRPCService.instance;

  // SimpleHrService(this._odooService=OdooRPCService.instance);

  /// Get all employees
  Future<List<HrEmployee>> getEmployeeProfile() async {
    try {
      final result = await _odooService.searchRead(
        model: 'hr.employee',
        fields: [
          "name",
          "job_title",
          "department_id",
          "work_email",
          "work_phone",
          "barcode",
          "image_1920",
          "attendance_state",
          "last_attendance_id",
          "work_location_id",
        ],
        limit: 1,
      );
      log(name: 'SimpleHrService', 'getEmployees result: $result');
      if (result['success']) {
        final data = result['data'] as List<dynamic>;
        return data.map((item) => HrEmployee.fromOdoo(item)).toList();
      }
      return [];
    } catch (e) {
      print('❌ Error getting employees: $e');
      return [];
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
        return data.map((item) => HrEmployee.fromOdoo(item)).toList();
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

  /// Get employee payslips
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

  /// Create a new leave request
  Future<bool> createLeave(Map<String, dynamic> leaveData) async {
    try {
      final result = await _odooService.create(
        model: 'hr.leave',
        values: leaveData,
      );

      return result['success'] ?? false;
    } catch (e) {
      print('❌ Error creating leave: $e');
      return false;
    }
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
  Future<bool> getPayslip() async {
    try {
      final result = await _odooService.searchRead(
        model: 'hr.payslip',
        fields: [
          "number",
          "name",
          "date_from",
          "date_to",
          "state",
          "net_wage",
          "basic_wage",
          "struct_id",
        ],
        order: "date_from desc",
        limit: 12,
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
