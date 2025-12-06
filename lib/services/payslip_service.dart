import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/odoo_config.dart';
import '../models/hr_payslip.dart';
import 'odoo_rpc_service.dart';

/// Service for handling payslip management in Odoo
class PayslipService {
  static PayslipService? _instance;
  static PayslipService get instance => _instance ??= PayslipService._internal();

  PayslipService._internal();

  final OdooRPCService _odooService = OdooRPCService.instance;

  /// Get employee payslips
  Future<List<HrPayslip>> getEmployeePayslips({
    required int employeeId,
    String? state,
    int? year,
    int? month,
    int limit = 50,
  }) async {
    try {
      print('💵 Fetching payslips for employee $employeeId...');

      final domain = <List<dynamic>>[
        ['employee_id', '=', employeeId]
      ];

      if (state != null) {
        domain.add(['state', '=', state]);
      }

      if (year != null) {
        final startDate = DateTime(year, month ?? 1, 1);
        final endDate = month != null 
            ? DateTime(year, month + 1, 0)
            : DateTime(year + 1, 1, 0);
        domain.add(['date_from', '>=', _formatOdooDate(startDate)]);
        domain.add(['date_to', '<=', _formatOdooDate(endDate)]);
      }

      final result = await _odooService.searchRead(
        model: 'hr.payslip',
        domain: domain,
        fields: [
          'id',
          'name',
          'number',
          'employee_id',
          'contract_id',
          'struct_id',
          'date_from',
          'date_to',
          'date',
          'state',
          'company_id',
          'basic_wage',
          'gross_wage',
          'net_wage',
          'create_date',
          'write_date',
        ],
        limit: limit,
        order: 'date_from desc',
      );

      if (result['success'] && result['data'] != null) {
        final payslips = <HrPayslip>[];
        for (final data in result['data']) {
          try {
            payslips.add(HrPayslip.fromOdoo(data));
          } catch (e) {
            print('⚠️ Error parsing payslip data: $e');
          }
        }
        print('✅ Found ${payslips.length} payslips');
        return payslips;
      }

      return [];
    } catch (e) {
      print('❌ Error fetching employee payslips: $e');
      return [];
    }
  }

  /// Get payslip details with lines
  Future<Map<String, dynamic>> getPayslipDetails({required int payslipId}) async {
    try {
      print('📋 Fetching payslip details for $payslipId...');

      // Get the main payslip
      final payslipResult = await _odooService.searchRead(
        model: 'hr.payslip',
        domain: [
          ['id', '=', payslipId]
        ],
        fields: [
          'id',
          'name',
          'number',
          'employee_id',
          'contract_id',
          'struct_id',
          'date_from',
          'date_to',
          'date',
          'state',
          'company_id',
          'basic_wage',
          'gross_wage',
          'net_wage',
          'line_ids',
          'worked_days_line_ids',
          'input_line_ids',
        ],
        limit: 1,
      );

      if (!payslipResult['success'] || payslipResult['data']?.isEmpty == true) {
        return {
          'success': false,
          'error': 'Payslip not found',
        };
      }

      final payslip = payslipResult['data'][0];

      // Get payslip lines
      final linesResult = await _odooService.searchRead(
        model: 'hr.payslip.line',
        domain: [
          ['slip_id', '=', payslipId]
        ],
        fields: [
          'id',
          'name',
          'code',
          'category_id',
          'sequence',
          'quantity',
          'rate',
          'amount',
          'total',
        ],
        order: 'sequence asc',
      );

      // Get worked days
      final workedDaysResult = await _odooService.searchRead(
        model: 'hr.payslip.worked_days',
        domain: [
          ['payslip_id', '=', payslipId]
        ],
        fields: [
          'id',
          'name',
          'code',
          'number_of_days',
          'number_of_hours',
          'amount',
        ],
      );

      return {
        'success': true,
        'payslip': payslip,
        'lines': linesResult['success'] ? linesResult['data'] : [],
        'worked_days': workedDaysResult['success'] ? workedDaysResult['data'] : [],
      };
    } catch (e) {
      print('❌ Error fetching payslip details: $e');
      return {
        'success': false,
        'error': 'Exception: $e',
      };
    }
  }

  /// Get all payslips (for managers)
  Future<List<HrPayslip>> getAllPayslips({
    String? state,
    DateTime? startDate,
    DateTime? endDate,
    int limit = 100,
  }) async {
    try {
      print('📋 Fetching all payslips...');

      final domain = <List<dynamic>>[];

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
        model: 'hr.payslip',
        domain: domain,
        fields: [
          'id',
          'name',
          'number',
          'employee_id',
          'contract_id',
          'date_from',
          'date_to',
          'date',
          'state',
          'basic_wage',
          'gross_wage',
          'net_wage',
          'create_date',
          'write_date',
        ],
        limit: limit,
        order: 'date_from desc',
      );

      if (result['success'] && result['data'] != null) {
        final payslips = <HrPayslip>[];
        for (final data in result['data']) {
          try {
            payslips.add(HrPayslip.fromOdoo(data));
          } catch (e) {
            print('⚠️ Error parsing payslip data: $e');
          }
        }
        print('✅ Found ${payslips.length} payslips');
        return payslips;
      }

      return [];
    } catch (e) {
      print('❌ Error fetching all payslips: $e');
      return [];
    }
  }

  /// Get payslip statistics for an employee
  Future<Map<String, dynamic>> getPayslipStatistics({
    required int employeeId,
    int? year,
  }) async {
    try {
      print('📊 Fetching payslip statistics for employee $employeeId...');

      final targetYear = year ?? DateTime.now().year;
      
      final payslips = await getEmployeePayslips(
        employeeId: employeeId,
        year: targetYear,
        limit: 200,
      );

      double totalGross = 0;
      double totalNet = 0;
      double totalDeductions = 0;
      int paidCount = 0;
      int draftCount = 0;
      int verifyCount = 0;
      double highestNet = 0;
      double lowestNet = double.infinity;

      final monthlyBreakdown = <int, Map<String, double>>{};

      for (final payslip in payslips) {
        final gross = payslip.grossWage ?? 0;
        final net = payslip.netWage ?? 0;
        
        totalGross += gross;
        totalNet += net;
        totalDeductions += (gross - net);

        if (net > highestNet) highestNet = net;
        if (net < lowestNet && net > 0) lowestNet = net;

        // Count by state
        switch (payslip.state) {
          case 'done':
            paidCount++;
            break;
          case 'verify':
            verifyCount++;
            break;
          case 'draft':
            draftCount++;
            break;
        }

        // Monthly breakdown
        if (payslip.dateFrom != null) {
          final month = payslip.dateFrom!.month;
          monthlyBreakdown[month] ??= {'gross': 0, 'net': 0, 'deductions': 0};
          monthlyBreakdown[month]!['gross'] = (monthlyBreakdown[month]!['gross'] ?? 0) + gross;
          monthlyBreakdown[month]!['net'] = (monthlyBreakdown[month]!['net'] ?? 0) + net;
          monthlyBreakdown[month]!['deductions'] = (monthlyBreakdown[month]!['deductions'] ?? 0) + (gross - net);
        }
      }

      final averageNet = payslips.isNotEmpty ? totalNet / payslips.length : 0.0;

      return {
        'success': true,
        'year': targetYear,
        'total_payslips': payslips.length,
        'total_gross': totalGross,
        'total_net': totalNet,
        'total_deductions': totalDeductions,
        'average_net': averageNet,
        'highest_net': highestNet == 0 ? 0 : highestNet,
        'lowest_net': lowestNet == double.infinity ? 0 : lowestNet,
        'paid_count': paidCount,
        'draft_count': draftCount,
        'verify_count': verifyCount,
        'monthly_breakdown': monthlyBreakdown,
      };
    } catch (e) {
      print('❌ Error fetching payslip statistics: $e');
      return {
        'success': false,
        'error': 'Exception: $e',
      };
    }
  }

  /// Get payslip by period
  Future<HrPayslip?> getPayslipByPeriod({
    required int employeeId,
    required int year,
    required int month,
  }) async {
    try {
      final startDate = DateTime(year, month, 1);
      final endDate = DateTime(year, month + 1, 0);

      final domain = <List<dynamic>>[
        ['employee_id', '=', employeeId],
        ['date_from', '>=', _formatOdooDate(startDate)],
        ['date_from', '<=', _formatOdooDate(endDate)],
      ];

      final result = await _odooService.searchRead(
        model: 'hr.payslip',
        domain: domain,
        fields: [
          'id',
          'name',
          'number',
          'employee_id',
          'contract_id',
          'date_from',
          'date_to',
          'date',
          'state',
          'basic_wage',
          'gross_wage',
          'net_wage',
        ],
        limit: 1,
      );

      if (result['success'] && result['data']?.isNotEmpty == true) {
        return HrPayslip.fromOdoo(result['data'][0]);
      }

      return null;
    } catch (e) {
      print('❌ Error fetching payslip by period: $e');
      return null;
    }
  }

  /// Get salary structure types
  Future<List<Map<String, dynamic>>> getSalaryStructures() async {
    try {
      print('🏗️ Fetching salary structures...');

      final result = await _odooService.searchRead(
        model: 'hr.payroll.structure',
        domain: [],
        fields: [
          'id',
          'name',
          'code',
          'type_id',
          'country_id',
        ],
        limit: 50,
      );

      if (result['success'] && result['data'] != null) {
        return List<Map<String, dynamic>>.from(result['data']);
      }

      return [];
    } catch (e) {
      print('❌ Error fetching salary structures: $e');
      return [];
    }
  }

  /// Compute payslip (recalculate)
  Future<Map<String, dynamic>> computePayslip({required int payslipId}) async {
    try {
      print('🔄 Computing payslip $payslipId...');

      final result = await _odooService.executeRPC(
        model: 'hr.payslip',
        method: 'compute_sheet',
        args: [
          [payslipId]
        ],
      );

      if (result['success']) {
        print('✅ Payslip computed successfully');
        return {
          'success': true,
          'message': 'Payslip computed successfully',
        };
      }

      return {
        'success': false,
        'error': result['error'] ?? 'Failed to compute payslip',
      };
    } catch (e) {
      print('❌ Error computing payslip: $e');
      return {
        'success': false,
        'error': 'Exception: $e',
      };
    }
  }

  /// Confirm/validate payslip
  Future<Map<String, dynamic>> confirmPayslip({required int payslipId}) async {
    try {
      print('✅ Confirming payslip $payslipId...');

      final result = await _odooService.executeRPC(
        model: 'hr.payslip',
        method: 'action_payslip_done',
        args: [
          [payslipId]
        ],
      );

      if (result['success']) {
        print('✅ Payslip confirmed successfully');
        return {
          'success': true,
          'message': 'Payslip confirmed successfully',
        };
      }

      return {
        'success': false,
        'error': result['error'] ?? 'Failed to confirm payslip',
      };
    } catch (e) {
      print('❌ Error confirming payslip: $e');
      return {
        'success': false,
        'error': 'Exception: $e',
      };
    }
  }

  /// Get payroll summary for a period
  Future<Map<String, dynamic>> getPayrollSummary({
    required int year,
    required int month,
  }) async {
    try {
      print('📊 Fetching payroll summary for $year-$month...');

      final startDate = DateTime(year, month, 1);
      final endDate = DateTime(year, month + 1, 0);

      final result = await _odooService.searchRead(
        model: 'hr.payslip',
        domain: [
          ['date_from', '>=', _formatOdooDate(startDate)],
          ['date_from', '<=', _formatOdooDate(endDate)],
        ],
        fields: [
          'id',
          'employee_id',
          'state',
          'basic_wage',
          'gross_wage',
          'net_wage',
        ],
        limit: 500,
      );

      if (result['success'] && result['data'] != null) {
        final payslips = result['data'] as List;
        
        double totalGross = 0;
        double totalNet = 0;
        int totalEmployees = 0;
        int paidCount = 0;
        int pendingCount = 0;
        final employeeIds = <int>{};

        for (final payslip in payslips) {
          totalGross += (payslip['gross_wage'] ?? 0).toDouble();
          totalNet += (payslip['net_wage'] ?? 0).toDouble();
          
          final empId = payslip['employee_id']?[0];
          if (empId != null) employeeIds.add(empId);

          if (payslip['state'] == 'done') {
            paidCount++;
          } else {
            pendingCount++;
          }
        }

        totalEmployees = employeeIds.length;

        return {
          'success': true,
          'period': '$year-${month.toString().padLeft(2, '0')}',
          'total_payslips': payslips.length,
          'total_employees': totalEmployees,
          'total_gross': totalGross,
          'total_net': totalNet,
          'total_deductions': totalGross - totalNet,
          'paid_count': paidCount,
          'pending_count': pendingCount,
          'average_per_employee': totalEmployees > 0 ? totalNet / totalEmployees : 0,
        };
      }

      return {
        'success': false,
        'error': result['error'] ?? 'Failed to get payroll summary',
      };
    } catch (e) {
      print('❌ Error fetching payroll summary: $e');
      return {
        'success': false,
        'error': 'Exception: $e',
      };
    }
  }

  /// Download payslip PDF
  Future<Map<String, dynamic>> downloadPayslipPdf({required int payslipId}) async {
    try {
      print('📥 Getting payslip PDF for $payslipId...');

      // Get the report action
      final result = await _odooService.executeRPC(
        model: 'ir.actions.report',
        method: 'render_qweb_pdf',
        args: [
          ['hr.report_payslip'],
          [payslipId]
        ],
      );

      if (result['success'] && result['data'] != null) {
        // The result should contain the PDF data
        return {
          'success': true,
          'pdf_data': result['data'],
          'message': 'PDF generated successfully',
        };
      }

      return {
        'success': false,
        'error': 'Failed to generate PDF',
      };
    } catch (e) {
      print('❌ Error downloading payslip PDF: $e');
      return {
        'success': false,
        'error': 'Exception: $e',
      };
    }
  }

  /// Format date for Odoo (YYYY-MM-DD)
  String _formatOdooDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }
}

