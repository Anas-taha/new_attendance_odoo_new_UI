import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/odoo_config.dart';
import '../models/hr_leave.dart';
import 'odoo_rpc_service.dart';

/// Service for handling leave/time-off requests in Odoo
class LeaveService {
  static LeaveService? _instance;
  static LeaveService get instance => _instance ??= LeaveService._internal();

  LeaveService._internal();

  final OdooRPCService _odooService = OdooRPCService.instance;

  /// Get all leave types available in the system
  Future<List<Map<String, dynamic>>> getLeaveTypes() async {
    try {
      print('📋 Fetching leave types...');

      final result = await _odooService.searchRead(
        model: 'hr.leave.type',
        domain: [
          ['active', '=', true]
        ],
        fields: [
          'id',
          'name',
          'requires_allocation',
          'request_unit',
          'create_uid',
          'color',
        ],
        limit: 50,
      );

      if (result['success'] && result['data'] != null) {
        print('✅ Found ${result['data'].length} leave types');
        return List<Map<String, dynamic>>.from(result['data']);
      }

      return [];
    } catch (e) {
      print('❌ Error fetching leave types: $e');
      return [];
    }
  }

  /// Get employee leave balance/allocation
  Future<Map<String, dynamic>> getLeaveBalance({required int employeeId}) async {
    try {
      print('💰 Fetching leave balance for employee $employeeId...');

      final result = await _odooService.searchRead(
        model: 'hr.leave.allocation',
        domain: [
          ['employee_id', '=', employeeId],
          ['state', '=', 'validate'],
        ],
        fields: [
          'id',
          'name',
          'employee_id',
          'holiday_status_id',
          'number_of_days',
          'number_of_days_display',
          'state',
        ],
        limit: 100,
      );

      if (result['success'] && result['data'] != null) {
        final allocations = result['data'] as List;
        
        // Group allocations by leave type
        final balanceByType = <String, double>{};
        for (final allocation in allocations) {
          final leaveType = allocation['holiday_status_id']?[1] ?? 'Unknown';
          final days = (allocation['number_of_days'] ?? 0).toDouble();
          balanceByType[leaveType] = (balanceByType[leaveType] ?? 0) + days;
        }

        return {
          'success': true,
          'allocations': allocations,
          'balance_by_type': balanceByType,
          'total_allocated': balanceByType.values.fold(0.0, (a, b) => a + b),
        };
      }

      return {
        'success': false,
        'error': result['error'] ?? 'Failed to fetch leave balance',
      };
    } catch (e) {
      print('❌ Error fetching leave balance: $e');
      return {
        'success': false,
        'error': 'Exception: $e',
      };
    }
  }

  /// Get employee leave requests
  Future<List<HrLeave>> getEmployeeLeaves({
    required int employeeId,
    String? state,
    DateTime? startDate,
    DateTime? endDate,
    int limit = 50,
  }) async {
    try {
      print('🏖️ Fetching leaves for employee $employeeId...');

      final domain = <List<dynamic>>[
        ['employee_id', '=', employeeId]
      ];

      if (state != null) {
        domain.add(['state', '=', state]);
      }

      if (startDate != null) {
        domain.add(['date_from', '>=', _formatOdooDate(startDate)]);
      }

      if (endDate != null) {
        domain.add(['date_to', '<=', _formatOdooDate(endDate)]);
      }

      final result = await _odooService.searchRead(
        model: 'hr.leave',
        domain: domain,
        fields: [
          'id',
          'name',
          'employee_id',
          'holiday_status_id',
          'date_from',
          'date_to',
          'number_of_days',
          'state',
          'notes',
          'create_date',
          'write_date',
        ],
        limit: limit,
        order: 'date_from desc',
      );

      if (result['success'] && result['data'] != null) {
        final leaves = <HrLeave>[];
        for (final data in result['data']) {
          try {
            leaves.add(HrLeave.fromOdoo(data));
          } catch (e) {
            print('⚠️ Error parsing leave data: $e');
          }
        }
        print('✅ Found ${leaves.length} leave requests');
        return leaves;
      }

      return [];
    } catch (e) {
      print('❌ Error fetching employee leaves: $e');
      return [];
    }
  }

  /// Get all team leaves (for managers)
  Future<List<HrLeave>> getTeamLeaves({
    List<int>? employeeIds,
    String? state,
    DateTime? startDate,
    DateTime? endDate,
    int limit = 100,
  }) async {
    try {
      print('👥 Fetching team leaves...');

      final domain = <List<dynamic>>[];

      if (employeeIds != null && employeeIds.isNotEmpty) {
        domain.add(['employee_id', 'in', employeeIds]);
      }

      if (state != null) {
        domain.add(['state', '=', state]);
      }

      if (startDate != null) {
        domain.add(['date_from', '>=', _formatOdooDate(startDate)]);
      }

      if (endDate != null) {
        domain.add(['date_to', '<=', _formatOdooDate(endDate)]);
      }

      final result = await _odooService.searchRead(
        model: 'hr.leave',
        domain: domain,
        fields: [
          'id',
          'name',
          'employee_id',
          'holiday_status_id',
          'date_from',
          'date_to',
          'number_of_days',
          'state',
          'notes',
          'create_date',
          'write_date',
        ],
        limit: limit,
        order: 'date_from desc',
      );

      if (result['success'] && result['data'] != null) {
        final leaves = <HrLeave>[];
        for (final data in result['data']) {
          try {
            leaves.add(HrLeave.fromOdoo(data));
          } catch (e) {
            print('⚠️ Error parsing leave data: $e');
          }
        }
        print('✅ Found ${leaves.length} team leave requests');
        return leaves;
      }

      return [];
    } catch (e) {
      print('❌ Error fetching team leaves: $e');
      return [];
    }
  }

  /// Create a new leave request
  Future<Map<String, dynamic>> createLeaveRequest({
    required int employeeId,
    required int leaveTypeId,
    required DateTime dateFrom,
    required DateTime dateTo,
    String? description,
  }) async {
    try {
      print('📝 Creating leave request for employee $employeeId...');

      // Calculate number of days
      final numberOfDays = dateTo.difference(dateFrom).inDays + 1;

      final values = {
        'employee_id': employeeId,
        'holiday_status_id': leaveTypeId,
        'date_from': _formatOdooDateTime(dateFrom),
        'date_to': _formatOdooDateTime(dateTo),
        'number_of_days': numberOfDays,
        'name': description ?? 'Leave Request',
        'request_date_from': _formatOdooDate(dateFrom),
        'request_date_to': _formatOdooDate(dateTo),
      };

      print('🔍 Leave request data: $values');

      final result = await _odooService.create(
        model: 'hr.leave',
        values: values,
      );

      if (result['success']) {
        print('✅ Leave request created successfully: ${result['data']}');
        return {
          'success': true,
          'leave_id': result['data'],
          'message': 'Leave request created successfully',
        };
      }

      print('❌ Failed to create leave request: ${result['error']}');
      return {
        'success': false,
        'error': result['error'] ?? 'Failed to create leave request',
      };
    } catch (e) {
      print('❌ Error creating leave request: $e');
      return {
        'success': false,
        'error': 'Exception: $e',
      };
    }
  }

  /// Update a leave request
  Future<Map<String, dynamic>> updateLeaveRequest({
    required int leaveId,
    DateTime? dateFrom,
    DateTime? dateTo,
    String? description,
  }) async {
    try {
      print('✏️ Updating leave request $leaveId...');

      final values = <String, dynamic>{};

      if (dateFrom != null) {
        values['date_from'] = _formatOdooDateTime(dateFrom);
        values['request_date_from'] = _formatOdooDate(dateFrom);
      }

      if (dateTo != null) {
        values['date_to'] = _formatOdooDateTime(dateTo);
        values['request_date_to'] = _formatOdooDate(dateTo);
      }

      if (description != null) {
        values['name'] = description;
      }

      // Recalculate days if dates changed
      if (dateFrom != null && dateTo != null) {
        values['number_of_days'] = dateTo.difference(dateFrom).inDays + 1;
      }

      final result = await _odooService.write(
        model: 'hr.leave',
        recordId: leaveId,
        values: values,
      );

      if (result['success']) {
        print('✅ Leave request updated successfully');
        return {
          'success': true,
          'message': 'Leave request updated successfully',
        };
      }

      return {
        'success': false,
        'error': result['error'] ?? 'Failed to update leave request',
      };
    } catch (e) {
      print('❌ Error updating leave request: $e');
      return {
        'success': false,
        'error': 'Exception: $e',
      };
    }
  }

  /// Cancel a leave request
  Future<Map<String, dynamic>> cancelLeaveRequest({required int leaveId}) async {
    try {
      print('❌ Cancelling leave request $leaveId...');

      // Try to call the action_refuse method first
      final result = await _odooService.executeRPC(
        model: 'hr.leave',
        method: 'action_refuse',
        args: [
          [leaveId]
        ],
      );

      if (result['success']) {
        print('✅ Leave request cancelled successfully');
        return {
          'success': true,
          'message': 'Leave request cancelled successfully',
        };
      }

      // Fallback: update state directly
      final updateResult = await _odooService.write(
        model: 'hr.leave',
        recordId: leaveId,
        values: {'state': 'refuse'},
      );

      if (updateResult['success']) {
        return {
          'success': true,
          'message': 'Leave request cancelled successfully',
        };
      }

      return {
        'success': false,
        'error': result['error'] ?? 'Failed to cancel leave request',
      };
    } catch (e) {
      print('❌ Error cancelling leave request: $e');
      return {
        'success': false,
        'error': 'Exception: $e',
      };
    }
  }

  /// Approve a leave request (for managers)
  Future<Map<String, dynamic>> approveLeaveRequest({required int leaveId}) async {
    try {
      print('✅ Approving leave request $leaveId...');

      final result = await _odooService.executeRPC(
        model: 'hr.leave',
        method: 'action_approve',
        args: [
          [leaveId]
        ],
      );

      if (result['success']) {
        print('✅ Leave request approved successfully');
        return {
          'success': true,
          'message': 'Leave request approved successfully',
        };
      }

      return {
        'success': false,
        'error': result['error'] ?? 'Failed to approve leave request',
      };
    } catch (e) {
      print('❌ Error approving leave request: $e');
      return {
        'success': false,
        'error': 'Exception: $e',
      };
    }
  }

  /// Get leave statistics for an employee
  Future<Map<String, dynamic>> getLeaveStatistics({required int employeeId}) async {
    try {
      print('📊 Fetching leave statistics for employee $employeeId...');

      final leaves = await getEmployeeLeaves(employeeId: employeeId, limit: 200);
      final balance = await getLeaveBalance(employeeId: employeeId);

      int totalRequests = leaves.length;
      int approved = 0;
      int pending = 0;
      int refused = 0;
      double totalDaysTaken = 0;

      for (final leave in leaves) {
        switch (leave.state) {
          case 'validate':
            approved++;
            totalDaysTaken += leave.numberOfDays ?? 0;
            break;
          case 'confirm':
            pending++;
            break;
          case 'refuse':
            refused++;
            break;
        }
      }

      return {
        'success': true,
        'total_requests': totalRequests,
        'approved': approved,
        'pending': pending,
        'refused': refused,
        'total_days_taken': totalDaysTaken,
        'balance': balance['success'] ? balance['balance_by_type'] : {},
        'total_allocated': balance['success'] ? balance['total_allocated'] : 0,
      };
    } catch (e) {
      print('❌ Error fetching leave statistics: $e');
      return {
        'success': false,
        'error': 'Exception: $e',
      };
    }
  }

  /// Check for date conflicts with existing leaves
  Future<Map<String, dynamic>> checkDateConflict({
    required int employeeId,
    required DateTime dateFrom,
    required DateTime dateTo,
    int? excludeLeaveId,
  }) async {
    try {
      print('🔍 Checking for date conflicts...');

      final domain = <List<dynamic>>[
        ['employee_id', '=', employeeId],
        ['state', 'not in', ['refuse', 'cancel']],
        ['date_from', '<=', _formatOdooDate(dateTo)],
        ['date_to', '>=', _formatOdooDate(dateFrom)],
      ];

      if (excludeLeaveId != null) {
        domain.add(['id', '!=', excludeLeaveId]);
      }

      final result = await _odooService.searchRead(
        model: 'hr.leave',
        domain: domain,
        fields: ['id', 'name', 'date_from', 'date_to', 'state'],
        limit: 10,
      );

      if (result['success'] && result['data'] != null) {
        final conflicts = result['data'] as List;
        
        if (conflicts.isNotEmpty) {
          return {
            'success': true,
            'has_conflict': true,
            'conflicting_leaves': conflicts,
            'message': 'Date conflict detected with existing leave requests',
          };
        }

        return {
          'success': true,
          'has_conflict': false,
          'message': 'No conflicts found',
        };
      }

      return {
        'success': false,
        'error': result['error'] ?? 'Failed to check date conflicts',
      };
    } catch (e) {
      print('❌ Error checking date conflict: $e');
      return {
        'success': false,
        'error': 'Exception: $e',
      };
    }
  }

  /// Get upcoming leaves for calendar view
  Future<List<Map<String, dynamic>>> getUpcomingLeaves({
    int? employeeId,
    int daysAhead = 30,
  }) async {
    try {
      final now = DateTime.now();
      final endDate = now.add(Duration(days: daysAhead));

      final domain = <List<dynamic>>[
        ['date_from', '>=', _formatOdooDate(now)],
        ['date_from', '<=', _formatOdooDate(endDate)],
        ['state', 'in', ['confirm', 'validate']],
      ];

      if (employeeId != null) {
        domain.add(['employee_id', '=', employeeId]);
      }

      final result = await _odooService.searchRead(
        model: 'hr.leave',
        domain: domain,
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
        limit: 100,
        order: 'date_from asc',
      );

      if (result['success'] && result['data'] != null) {
        return List<Map<String, dynamic>>.from(result['data']);
      }

      return [];
    } catch (e) {
      print('❌ Error fetching upcoming leaves: $e');
      return [];
    }
  }

  /// Format date for Odoo (YYYY-MM-DD)
  String _formatOdooDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  /// Format datetime for Odoo (YYYY-MM-DD HH:MM:SS)
  String _formatOdooDateTime(DateTime dateTime) {
    return '${dateTime.year.toString().padLeft(4, '0')}-'
        '${dateTime.month.toString().padLeft(2, '0')}-'
        '${dateTime.day.toString().padLeft(2, '0')} '
        '${dateTime.hour.toString().padLeft(2, '0')}:'
        '${dateTime.minute.toString().padLeft(2, '0')}:'
        '${dateTime.second.toString().padLeft(2, '0')}';
  }
}

