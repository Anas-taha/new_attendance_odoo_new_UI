import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/odoo_config.dart';
import '../models/hr_attendance.dart';
import 'odoo_rpc_service.dart';

/// Service for handling attendance reports from Odoo
/// Integrates with the attendance_location module endpoints
class AttendanceReportService {
  static AttendanceReportService? _instance;
  static AttendanceReportService get instance =>
      _instance ??= AttendanceReportService._internal();

  AttendanceReportService._internal();

  final OdooRPCService _odooService = OdooRPCService.instance;

  /// Fetch attendance report data from Odoo
  /// Uses the /attendance_location/objects endpoint
  Future<Map<String, dynamic>> getAttendanceReport({
    int? employeeId,
    DateTime? startDate,
    DateTime? endDate,
    int limit = 50,
  }) async {
    try {
      print('📊 Fetching attendance report...');

      // Build domain filters
      final domain = <List<dynamic>>[];

      if (employeeId != null) {
        domain.add(['employee_id', '=', employeeId]);
      }

      if (startDate != null) {
        final utcStart = startDate.toUtc();
        domain.add(['check_in', '>=', _formatOdooDateTime(utcStart)]);
      }

      if (endDate != null) {
        final utcEnd = endDate.toUtc();
        domain.add(['check_in', '<=', _formatOdooDateTime(utcEnd)]);
      }

      final result = await _odooService.searchRead(
        model: 'hr.attendance',
        domain: domain,
        fields: [
          'id',
          'employee_id',
          'check_in',
          'check_out',
          'worked_hours',
          'in_latitude',
          'in_longitude',
          'out_latitude',
          'out_longitude',
          'in_address',
          'out_address',
          'create_date',
          'write_date',
        ],
        limit: limit,
        order: 'check_in desc',
      );

      if (result['success'] && result['data'] != null) {
        final records = result['data'] as List;
        print('✅ Found ${records.length} attendance records');

        // Calculate statistics
        final stats = _calculateStatistics(records);

        return {
          'success': true,
          'records': records,
          'statistics': stats,
          'count': records.length,
        };
      }

      return {
        'success': false,
        'error': result['error'] ?? 'Failed to fetch attendance report',
      };
    } catch (e) {
      print('❌ Error fetching attendance report: $e');
      return {
        'success': false,
        'error': 'Exception: $e',
      };
    }
  }

  /// Fetch attendance records with location data
  Future<List<Map<String, dynamic>>> getAttendanceWithLocation({
    int? employeeId,
    int limit = 50,
  }) async {
    try {
      final domain = <List<dynamic>>[];

      if (employeeId != null) {
        domain.add(['employee_id', '=', employeeId]);
      }

      // Only get records with location data
      domain.add(['in_latitude', '!=', false]);
      domain.add(['in_longitude', '!=', false]);

      final result = await _odooService.searchRead(
        model: 'hr.attendance',
        domain: domain,
        fields: [
          'id',
          'employee_id',
          'check_in',
          'check_out',
          'worked_hours',
          'in_latitude',
          'in_longitude',
          'out_latitude',
          'out_longitude',
          'in_address',
          'out_address',
        ],
        limit: limit,
        order: 'check_in desc',
      );

      if (result['success'] && result['data'] != null) {
        return List<Map<String, dynamic>>.from(result['data']);
      }

      return [];
    } catch (e) {
      print('❌ Error fetching attendance with location: $e');
      return [];
    }
  }

  /// Get daily attendance summary
  Future<Map<String, dynamic>> getDailySummary({
    required int employeeId,
    required DateTime date,
  }) async {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final result = await getAttendanceReport(
        employeeId: employeeId,
        startDate: startOfDay,
        endDate: endOfDay,
      );

      if (result['success']) {
        final records = result['records'] as List;
        
        // Calculate total worked hours for the day
        double totalWorkedHours = 0;
        int completedSessions = 0;
        int activeSessions = 0;

        for (final record in records) {
          final workedHours = record['worked_hours'];
          if (workedHours != null && workedHours != false) {
            totalWorkedHours += (workedHours as num).toDouble();
            completedSessions++;
          } else {
            activeSessions++;
          }
        }

        return {
          'success': true,
          'date': date.toIso8601String(),
          'total_worked_hours': totalWorkedHours,
          'completed_sessions': completedSessions,
          'active_sessions': activeSessions,
          'total_records': records.length,
          'records': records,
        };
      }

      return result;
    } catch (e) {
      print('❌ Error getting daily summary: $e');
      return {
        'success': false,
        'error': 'Exception: $e',
      };
    }
  }

  /// Get weekly attendance summary
  Future<Map<String, dynamic>> getWeeklySummary({
    required int employeeId,
    DateTime? weekStart,
  }) async {
    try {
      final now = weekStart ?? DateTime.now();
      final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      final endOfWeek = startOfWeek.add(const Duration(days: 7));

      final result = await getAttendanceReport(
        employeeId: employeeId,
        startDate: startOfWeek,
        endDate: endOfWeek,
        limit: 100,
      );

      if (result['success']) {
        final records = result['records'] as List;
        
        // Group records by day
        final dailyBreakdown = <String, Map<String, dynamic>>{};
        double totalWeeklyHours = 0;

        for (final record in records) {
          final checkIn = DateTime.parse(record['check_in']);
          final dayKey = '${checkIn.year}-${checkIn.month.toString().padLeft(2, '0')}-${checkIn.day.toString().padLeft(2, '0')}';
          
          if (!dailyBreakdown.containsKey(dayKey)) {
            dailyBreakdown[dayKey] = {
              'date': dayKey,
              'total_hours': 0.0,
              'sessions': 0,
            };
          }

          final workedHours = record['worked_hours'];
          if (workedHours != null && workedHours != false) {
            dailyBreakdown[dayKey]!['total_hours'] += (workedHours as num).toDouble();
            totalWeeklyHours += (workedHours as num).toDouble();
          }
          dailyBreakdown[dayKey]!['sessions'] += 1;
        }

        return {
          'success': true,
          'week_start': startOfWeek.toIso8601String(),
          'week_end': endOfWeek.toIso8601String(),
          'total_weekly_hours': totalWeeklyHours,
          'daily_breakdown': dailyBreakdown,
          'total_records': records.length,
          'records': records,
        };
      }

      return result;
    } catch (e) {
      print('❌ Error getting weekly summary: $e');
      return {
        'success': false,
        'error': 'Exception: $e',
      };
    }
  }

  /// Get monthly attendance summary
  Future<Map<String, dynamic>> getMonthlySummary({
    required int employeeId,
    int? year,
    int? month,
  }) async {
    try {
      final now = DateTime.now();
      final targetYear = year ?? now.year;
      final targetMonth = month ?? now.month;

      final startOfMonth = DateTime(targetYear, targetMonth, 1);
      final endOfMonth = DateTime(targetYear, targetMonth + 1, 1);

      final result = await getAttendanceReport(
        employeeId: employeeId,
        startDate: startOfMonth,
        endDate: endOfMonth,
        limit: 200,
      );

      if (result['success']) {
        final records = result['records'] as List;
        
        double totalMonthlyHours = 0;
        int workingDays = 0;
        final uniqueDays = <String>{};

        for (final record in records) {
          final checkIn = DateTime.parse(record['check_in']);
          final dayKey = '${checkIn.year}-${checkIn.month}-${checkIn.day}';
          uniqueDays.add(dayKey);

          final workedHours = record['worked_hours'];
          if (workedHours != null && workedHours != false) {
            totalMonthlyHours += (workedHours as num).toDouble();
          }
        }

        workingDays = uniqueDays.length;
        final averageDailyHours = workingDays > 0 ? totalMonthlyHours / workingDays : 0.0;

        return {
          'success': true,
          'month': targetMonth,
          'year': targetYear,
          'month_start': startOfMonth.toIso8601String(),
          'month_end': endOfMonth.toIso8601String(),
          'total_monthly_hours': totalMonthlyHours,
          'working_days': workingDays,
          'average_daily_hours': averageDailyHours,
          'total_records': records.length,
          'records': records,
        };
      }

      return result;
    } catch (e) {
      print('❌ Error getting monthly summary: $e');
      return {
        'success': false,
        'error': 'Exception: $e',
      };
    }
  }

  /// Calculate statistics from attendance records
  Map<String, dynamic> _calculateStatistics(List<dynamic> records) {
    if (records.isEmpty) {
      return {
        'total_hours': 0.0,
        'average_hours': 0.0,
        'total_sessions': 0,
        'completed_sessions': 0,
        'active_sessions': 0,
        'on_time_count': 0,
        'late_count': 0,
        'early_checkout_count': 0,
        'records_with_location': 0,
      };
    }

    double totalHours = 0;
    int completedSessions = 0;
    int activeSessions = 0;
    int onTimeCount = 0;
    int lateCount = 0;
    int earlyCheckoutCount = 0;
    int recordsWithLocation = 0;

    const workStartHour = 9; // 9 AM is considered on-time
    const workEndHour = 17; // 5 PM is expected checkout

    for (final record in records) {
      // Count worked hours
      final workedHours = record['worked_hours'];
      if (workedHours != null && workedHours != false) {
        totalHours += (workedHours as num).toDouble();
        completedSessions++;

        // Check for early checkout
        if (record['check_out'] != null && record['check_out'] != false) {
          final checkOut = DateTime.parse(record['check_out']);
          if (checkOut.hour < workEndHour) {
            earlyCheckoutCount++;
          }
        }
      } else {
        activeSessions++;
      }

      // Check in time analysis
      if (record['check_in'] != null) {
        final checkIn = DateTime.parse(record['check_in']);
        if (checkIn.hour <= workStartHour) {
          onTimeCount++;
        } else {
          lateCount++;
        }
      }

      // Check for location data
      if (record['in_latitude'] != null && 
          record['in_latitude'] != false &&
          record['in_longitude'] != null && 
          record['in_longitude'] != false) {
        recordsWithLocation++;
      }
    }

    final totalSessions = records.length;
    final averageHours = completedSessions > 0 ? totalHours / completedSessions : 0.0;

    return {
      'total_hours': totalHours,
      'average_hours': averageHours,
      'total_sessions': totalSessions,
      'completed_sessions': completedSessions,
      'active_sessions': activeSessions,
      'on_time_count': onTimeCount,
      'late_count': lateCount,
      'early_checkout_count': earlyCheckoutCount,
      'records_with_location': recordsWithLocation,
      'on_time_percentage': totalSessions > 0 ? (onTimeCount / totalSessions * 100).toStringAsFixed(1) : '0.0',
    };
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

  /// Export attendance report to JSON
  String exportToJson(Map<String, dynamic> reportData) {
    return json.encode(reportData);
  }

  /// Get attendance trends (for charts)
  Future<Map<String, dynamic>> getAttendanceTrends({
    required int employeeId,
    int daysBack = 30,
  }) async {
    try {
      final endDate = DateTime.now();
      final startDate = endDate.subtract(Duration(days: daysBack));

      final result = await getAttendanceReport(
        employeeId: employeeId,
        startDate: startDate,
        endDate: endDate,
        limit: 200,
      );

      if (result['success']) {
        final records = result['records'] as List;
        
        // Create daily trends
        final dailyTrends = <String, double>{};
        
        for (final record in records) {
          final checkIn = DateTime.parse(record['check_in']);
          final dayKey = '${checkIn.month}/${checkIn.day}';
          
          final workedHours = record['worked_hours'];
          if (workedHours != null && workedHours != false) {
            dailyTrends[dayKey] = (dailyTrends[dayKey] ?? 0) + (workedHours as num).toDouble();
          }
        }

        return {
          'success': true,
          'daily_trends': dailyTrends,
          'period_start': startDate.toIso8601String(),
          'period_end': endDate.toIso8601String(),
        };
      }

      return result;
    } catch (e) {
      print('❌ Error getting attendance trends: $e');
      return {
        'success': false,
        'error': 'Exception: $e',
      };
    }
  }
}

