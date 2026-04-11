import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/odoo_config.dart';
import '../models/hr_expense.dart';
import 'odoo_rpc_service.dart';

/// Service for handling expense management in Odoo
class ExpenseService {
  static ExpenseService? _instance;
  static ExpenseService get instance =>
      _instance ??= ExpenseService._internal();

  ExpenseService._internal();

  final OdooRPCService _odooService = OdooRPCService.instance;

  /// Get expense categories/products
  Future<List<Map<String, dynamic>>> getExpenseCategories() async {
    try {
      print('📂 Fetching expense categories...');

      final result = await _odooService.searchRead(
        model: 'product.product',
        domain: [
          ['can_be_expensed', '=', true],
        ],
        fields: ['id', 'name', 'standard_price', 'default_code', 'categ_id'],
        limit: 100,
      );

      if (result['success'] && result['data'] != null) {
        print('✅ Found ${result['data'].length} expense categories');
        return List<Map<String, dynamic>>.from(result['data']);
      }

      return [];
    } catch (e) {
      print('❌ Error fetching expense categories: $e');
      return [];
    }
  }

  /// Get employee expenses
  Future<List<HrExpense>> getEmployeeExpenses({
    required int employeeId,
    String? state,
    DateTime? startDate,
    DateTime? endDate,
    int limit = 50,
  }) async {
    try {
      print('💰 Fetching expenses for employee $employeeId...');

      final domain = <List<dynamic>>[
        ['employee_id', '=', employeeId],
      ];

      if (state != null) {
        domain.add(['state', '=', state]);
      }

      if (startDate != null) {
        domain.add(['date', '>=', _formatOdooDate(startDate)]);
      }

      if (endDate != null) {
        domain.add(['date', '<=', _formatOdooDate(endDate)]);
      }

      final result = await _odooService.searchRead(
        model: OdooConfig.hrExpenseModel,
        domain: domain,
        fields: [
          'id',
          'name',
          'employee_id',
          'product_id',
          'unit_amount',
          'total_amount',
          'tax_amount',
          'quantity',
          'date',
          'state',
          'payment_mode',
          'description',
          'reference',
          'analytic_distribution',
          'create_date',
          'write_date',
        ],
        limit: limit,
        order: 'date desc',
      );

      if (result['success'] && result['data'] != null) {
        final expenses = <HrExpense>[];
        for (final data in result['data']) {
          try {
            expenses.add(HrExpense.fromOdoo(data));
          } catch (e) {
            print('⚠️ Error parsing expense data: $e');
          }
        }
        print('✅ Found ${expenses.length} expenses');
        return expenses;
      }

      return [];
    } catch (e) {
      print('❌ Error fetching employee expenses: $e');
      return [];
    }
  }

  /// Create a new expense
  Future<Map<String, dynamic>> createExpense({
    required int employeeId,
    required String name,
    required double amount,
    required int productId,
    required DateTime date,
    String? description,
    String? reference,
    String paymentMode = 'own_account',
    double quantity = 1.0,
    File? receipt,
  }) async {
    try {
      print('📝 Creating expense for employee $employeeId...');

      final values = {
        'employee_id': employeeId,
        'name': name,
        'unit_amount': amount,
        'quantity': quantity,
        'product_id': productId,
        'date': _formatOdooDate(date),
        'payment_mode': paymentMode,
      };

      if (description != null && description.isNotEmpty) {
        values['description'] = description;
      }

      if (reference != null && reference.isNotEmpty) {
        values['reference'] = reference;
      }

      print('🔍 Expense data: $values');

      final result = await _odooService.create(
        model: 'hr.expense',
        values: values,
      );

      if (result['success']) {
        final expenseId = result['data'];
        print('✅ Expense created successfully: $expenseId');

        // Upload receipt if provided
        if (receipt != null) {
          await _uploadReceipt(expenseId: expenseId, file: receipt);
        }

        return {
          'success': true,
          'expense_id': expenseId,
          'message': 'Expense created successfully',
        };
      }

      print('❌ Failed to create expense: ${result['error']}');
      return {
        'success': false,
        'error': result['error'] ?? 'Failed to create expense',
      };
    } catch (e) {
      print('❌ Error creating expense: $e');
      return {'success': false, 'error': 'Exception: $e'};
    }
  }

  /// Upload receipt attachment to expense
  Future<Map<String, dynamic>> _uploadReceipt({
    required int expenseId,
    required File file,
  }) async {
    try {
      print('📎 Uploading receipt for expense $expenseId...');

      final bytes = await file.readAsBytes();
      final base64Data = base64Encode(bytes);
      final fileName = file.path.split('/').last;

      final result = await _odooService.create(
        model: 'ir.attachment',
        values: {
          'name': fileName,
          'type': 'binary',
          'datas': base64Data,
          'res_model': 'hr.expense',
          'res_id': expenseId,
          'mimetype': _getMimeType(fileName),
        },
      );

      if (result['success']) {
        print('✅ Receipt uploaded successfully');
        return {'success': true, 'attachment_id': result['data']};
      }

      return {
        'success': false,
        'error': result['error'] ?? 'Failed to upload receipt',
      };
    } catch (e) {
      print('❌ Error uploading receipt: $e');
      return {'success': false, 'error': 'Exception: $e'};
    }
  }

  /// Update an expense
  Future<Map<String, dynamic>> updateExpense({
    required int expenseId,
    String? name,
    double? amount,
    int? productId,
    DateTime? date,
    String? description,
    String? reference,
  }) async {
    try {
      print('✏️ Updating expense $expenseId...');

      final values = <String, dynamic>{};

      if (name != null) values['name'] = name;
      if (amount != null) values['unit_amount'] = amount;
      if (productId != null) values['product_id'] = productId;
      if (date != null) values['date'] = _formatOdooDate(date);
      if (description != null) values['description'] = description;
      if (reference != null) values['reference'] = reference;

      final result = await _odooService.write(
        model: 'hr.expense',
        recordId: expenseId,
        values: values,
      );

      if (result['success']) {
        print('✅ Expense updated successfully');
        return {'success': true, 'message': 'Expense updated successfully'};
      }

      return {
        'success': false,
        'error': result['error'] ?? 'Failed to update expense',
      };
    } catch (e) {
      print('❌ Error updating expense: $e');
      return {'success': false, 'error': 'Exception: $e'};
    }
  }

  /// Delete an expense
  Future<Map<String, dynamic>> deleteExpense({required int expenseId}) async {
    try {
      print('🗑️ Deleting expense $expenseId...');

      final result = await _odooService.delete(
        model: 'hr.expense',
        recordId: expenseId,
      );

      if (result['success']) {
        print('✅ Expense deleted successfully');
        return {'success': true, 'message': 'Expense deleted successfully'};
      }

      return {
        'success': false,
        'error': result['error'] ?? 'Failed to delete expense',
      };
    } catch (e) {
      print('❌ Error deleting expense: $e');
      return {'success': false, 'error': 'Exception: $e'};
    }
  }

  /// Submit expense for approval
  Future<Map<String, dynamic>> submitExpense({required int expenseId}) async {
    try {
      print('📤 Submitting expense $expenseId for approval...');

      final result = await _odooService.executeRPC(
        model: 'hr.expense',
        method: 'action_submit_expenses',
        args: [
          [expenseId],
        ],
      );

      if (result['success']) {
        print('✅ Expense submitted successfully');
        return {'success': true, 'message': 'Expense submitted for approval'};
      }

      return {
        'success': false,
        'error': result['error'] ?? 'Failed to submit expense',
      };
    } catch (e) {
      print('❌ Error submitting expense: $e');
      return {'success': false, 'error': 'Exception: $e'};
    }
  }

  /// Create expense sheet/report
  Future<Map<String, dynamic>> createExpenseSheet({
    required int employeeId,
    required List<int> expenseIds,
    String? name,
  }) async {
    try {
      print('📋 Creating expense sheet...');

      final sheetName =
          name ??
          'Expense Report ${DateTime.now().toIso8601String().split('T')[0]}';

      final result = await _odooService.create(
        model: 'hr.expense.sheet',
        values: {
          'name': sheetName,
          'employee_id': employeeId,
          'expense_line_ids': [
            [6, 0, expenseIds],
          ], // Many2many set command
        },
      );

      if (result['success']) {
        print('✅ Expense sheet created: ${result['data']}');
        return {
          'success': true,
          'sheet_id': result['data'],
          'message': 'Expense sheet created successfully',
        };
      }

      return {
        'success': false,
        'error': result['error'] ?? 'Failed to create expense sheet',
      };
    } catch (e) {
      print('❌ Error creating expense sheet: $e');
      return {'success': false, 'error': 'Exception: $e'};
    }
  }

  /// Get expense sheets for employee
  Future<List<Map<String, dynamic>>> getExpenseSheets({
    required int employeeId,
    String? state,
    int limit = 50,
  }) async {
    try {
      print('📋 Fetching expense sheets for employee $employeeId...');

      final domain = <List<dynamic>>[
        ['employee_id', '=', employeeId],
      ];

      if (state != null) {
        domain.add(['state', '=', state]);
      }

      final result = await _odooService.searchRead(
        model: OdooConfig.hrExpenseSheetModel,
        domain: domain,
        fields: [
          'id',
          'name',
          'employee_id',
          'state',
          'total_amount',
          'expense_line_ids',
          'create_date',
          'write_date',
        ],
        limit: limit,
        order: 'create_date desc',
      );

      if (result['success'] && result['data'] != null) {
        print('✅ Found ${result['data'].length} expense sheets');
        return List<Map<String, dynamic>>.from(result['data']);
      }

      return [];
    } catch (e) {
      print('❌ Error fetching expense sheets: $e');
      return [];
    }
  }

  /// Get expense statistics for an employee
  Future<Map<String, dynamic>> getExpenseStatistics({
    required int employeeId,
    int? year,
    int? month,
  }) async {
    try {
      print('📊 Fetching expense statistics for employee $employeeId...');

      final now = DateTime.now();
      final targetYear = year ?? now.year;
      final targetMonth = month ?? now.month;

      // Get all expenses for the period
      final startDate = DateTime(targetYear, targetMonth, 1);
      final endDate = DateTime(targetYear, targetMonth + 1, 0);

      final expenses = await getEmployeeExpenses(
        employeeId: employeeId,
        startDate: startDate,
        endDate: endDate,
        limit: 200,
      );

      // Calculate statistics
      double totalAmount = 0;
      double approvedAmount = 0;
      double pendingAmount = 0;
      double refusedAmount = 0;
      int totalCount = expenses.length;
      int approvedCount = 0;
      int pendingCount = 0;
      int refusedCount = 0;

      final byCategory = <String, double>{};

      for (final expense in expenses) {
        final amount = expense.total ?? 0;
        totalAmount += amount;

        // Group by category
        final category = expense.category ?? 'Other';
        byCategory[category] = (byCategory[category] ?? 0) + amount;

        switch (expense.state) {
          case 'approved':
          case 'done':
            approvedAmount += amount;
            approvedCount++;
            break;
          case 'reported':
          case 'submit':
            pendingAmount += amount;
            pendingCount++;
            break;
          case 'refused':
            refusedAmount += amount;
            refusedCount++;
            break;
          default:
            pendingAmount += amount;
            pendingCount++;
        }
      }

      return {
        'success': true,
        'period': '${targetYear}-${targetMonth.toString().padLeft(2, '0')}',
        'total_amount': totalAmount,
        'approved_amount': approvedAmount,
        'pending_amount': pendingAmount,
        'refused_amount': refusedAmount,
        'total_count': totalCount,
        'approved_count': approvedCount,
        'pending_count': pendingCount,
        'refused_count': refusedCount,
        'by_category': byCategory,
      };
    } catch (e) {
      print('❌ Error fetching expense statistics: $e');
      return {'success': false, 'error': 'Exception: $e'};
    }
  }

  /// Get all expenses (for managers)
  Future<List<HrExpense>> getAllExpenses({
    String? state,
    DateTime? startDate,
    DateTime? endDate,
    int limit = 100,
  }) async {
    try {
      print('📋 Fetching all expenses...');

      final domain = <List<dynamic>>[];

      if (state != null) {
        domain.add(['state', '=', state]);
      }

      if (startDate != null) {
        domain.add(['date', '>=', _formatOdooDate(startDate)]);
      }

      if (endDate != null) {
        domain.add(['date', '<=', _formatOdooDate(endDate)]);
      }

      final result = await _odooService.searchRead(
        model: OdooConfig.hrExpenseModel,
        domain: domain,
        fields: [
          'id',
          'name',
          'employee_id',
          'product_id',
          'unit_amount',
          'total_amount',
          'tax_amount',
          'quantity',
          'date',
          'state',
          'payment_mode',
          'description',
          'reference',
          'create_date',
          'write_date',
        ],
        limit: limit,
        order: 'date desc',
      );

      if (result['success'] && result['data'] != null) {
        final expenses = <HrExpense>[];
        for (final data in result['data']) {
          try {
            expenses.add(HrExpense.fromOdoo(data));
          } catch (e) {
            print('⚠️ Error parsing expense data: $e');
          }
        }
        print('✅ Found ${expenses.length} expenses');
        return expenses;
      }

      return [];
    } catch (e) {
      print('❌ Error fetching all expenses: $e');
      return [];
    }
  }

  /// Format date for Odoo (YYYY-MM-DD)
  String _formatOdooDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  /// Get MIME type from file extension
  String _getMimeType(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'pdf':
        return 'application/pdf';
      case 'doc':
        return 'application/msword';
      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      default:
        return 'application/octet-stream';
    }
  }
}
