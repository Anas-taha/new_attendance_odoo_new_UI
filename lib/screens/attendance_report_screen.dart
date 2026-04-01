import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../generated/l10n/app_localizations.dart';
import '../models/hr_attendance.dart';
import '../models/hr_employee.dart';
import '../services/attendance_report_service.dart';
import '../services/hr_service.dart';

class AttendanceReportScreen extends StatefulWidget {
  const AttendanceReportScreen({super.key});

  @override
  State<AttendanceReportScreen> createState() => _AttendanceReportScreenState();
}

class _AttendanceReportScreenState extends State<AttendanceReportScreen>
    with TickerProviderStateMixin {
  final HrService _hrService = HrService();
  final AttendanceReportService _reportService = AttendanceReportService.instance;
  
  HrEmployee? _currentEmployee;
  List<HrAttendance> _allRecords = [];
  Map<String, dynamic>? _statistics;
  Map<String, dynamic>? _weeklySummary;
  Map<String, dynamic>? _monthlySummary;
  bool _isLoading = true;
  String _selectedPeriod = 'this_week';
  String _selectedView = 'summary';
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late TabController _tabController;

  static const List<String> _periodKeys = [
    'today',
    'this_week',
    'this_month',
    'last_month',
    'custom_range',
  ];

  String _periodLabel(BuildContext context, String key) {
    final l10n = AppLocalizations.of(context)!;
    switch (key) {
      case 'today':
        return l10n.today;
      case 'this_week':
        return l10n.thisWeek;
      case 'this_month':
        return l10n.thisMonth;
      case 'last_month':
        return l10n.lastMonth;
      case 'custom_range':
        return l10n.customRange;
      default:
        return key;
    }
  }

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      _currentEmployee = await _hrService.getCurrentEmployee();
      if (_currentEmployee != null) {
        await Future.wait([
          _loadAttendanceRecords(),
          _loadWeeklySummary(),
          _loadMonthlySummary(),
        ]);
      }
    } catch (e) {
      print('Error loading data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
      _fadeController.forward();
      _slideController.forward();
    }
  }

  Future<void> _loadAttendanceRecords() async {
    try {
      final records = await _hrService.getEmployeeAttendance(
        employeeId: _currentEmployee!.id,
        limit: 100,
      );
      
      final reportData = await _reportService.getAttendanceReport(
        employeeId: _currentEmployee!.id,
        limit: 100,
      );
      
      setState(() {
        _allRecords = records;
        if (reportData['success'] == true) {
          _statistics = reportData['statistics'] as Map<String, dynamic>?;
        }
      });
    } catch (e) {
      print('Error loading attendance records: $e');
    }
  }

  Future<void> _loadWeeklySummary() async {
    try {
      final summary = await _reportService.getWeeklySummary(
        employeeId: _currentEmployee!.id,
      );
      setState(() {
        _weeklySummary = summary['success'] == true ? summary : null;
      });
    } catch (e) {
      print('Error loading weekly summary: $e');
    }
  }

  Future<void> _loadMonthlySummary() async {
    try {
      final summary = await _reportService.getMonthlySummary(
        employeeId: _currentEmployee!.id,
      );
      setState(() {
        _monthlySummary = summary['success'] == true ? summary : null;
      });
    } catch (e) {
      print('Error loading monthly summary: $e');
    }
  }

  List<HrAttendance> _getFilteredRecords() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    switch (_selectedPeriod) {
      case 'today':
        return _allRecords.where((record) {
          final recordDate = DateTime(record.createDate.year, record.createDate.month, record.createDate.day);
          return recordDate.isAtSameMomentAs(today);
        }).toList();

      case 'this_week':
        final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
        final endOfWeek = startOfWeek.add(const Duration(days: 7));
        return _allRecords.where((record) {
          return record.createDate.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
                 record.createDate.isBefore(endOfWeek);
        }).toList();

      case 'this_month':
        final startOfMonth = DateTime(now.year, now.month, 1);
        final endOfMonth = DateTime(now.year, now.month + 1, 1);
        return _allRecords.where((record) {
          return record.createDate.isAfter(startOfMonth.subtract(const Duration(days: 1))) &&
                 record.createDate.isBefore(endOfMonth);
        }).toList();

      case 'last_month':
        final startOfLastMonth = DateTime(now.year, now.month - 1, 1);
        final endOfLastMonth = DateTime(now.year, now.month, 1);
        return _allRecords.where((record) {
          return record.createDate.isAfter(startOfLastMonth.subtract(const Duration(days: 1))) &&
                 record.createDate.isBefore(endOfLastMonth);
        }).toList();

      default:
        return _allRecords;
    }
  }

  Map<String, dynamic> _calculateStats(List<HrAttendance> records) {
    if (records.isEmpty) {
      return {
        'total_hours': '00:00:00',
        'average_daily': '00:00:00',
        'total_sessions': 0,
        'on_time_count': 0,
        'late_count': 0,
        'early_leave_count': 0,
      };
    }

    int totalSeconds = 0;
    int totalSessions = 0;
    int onTimeCount = 0;
    int lateCount = 0;
    int earlyLeaveCount = 0;

    for (final record in records) {
      final duration = record.getWorkedDuration();
      if (duration != null) {
        totalSeconds += duration.inSeconds;
        totalSessions++;
      }

      // Simple logic for on-time/late (you can customize this)
      final checkInHour = record.checkIn.hour;
      if (checkInHour <= 9) {
        onTimeCount++;
      } else if (checkInHour <= 10) {
        lateCount++;
      } else {
        earlyLeaveCount++;
      }
    }

    final totalHours = totalSeconds ~/ 3600;
    final totalMinutes = (totalSeconds % 3600) ~/ 60;
    final totalSecs = totalSeconds % 60;
    
    final avgSeconds = totalSessions > 0 ? totalSeconds ~/ totalSessions : 0;
    final avgHours = avgSeconds ~/ 3600;
    final avgMinutes = (avgSeconds % 3600) ~/ 60;
    final avgSecs = avgSeconds % 60;

    return {
      'total_hours': '${totalHours.toString().padLeft(2, '0')}:${totalMinutes.toString().padLeft(2, '0')}:${totalSecs.toString().padLeft(2, '0')}',
      'average_daily': '${avgHours.toString().padLeft(2, '0')}:${avgMinutes.toString().padLeft(2, '0')}:${avgSecs.toString().padLeft(2, '0')}',
      'total_sessions': totalSessions,
      'on_time_count': onTimeCount,
      'late_count': lateCount,
      'early_leave_count': earlyLeaveCount,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF667eea),
              Color(0xFF764ba2),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Custom App Bar
              _buildAppBar(),
              
              // Tab Bar
              _buildTabBar(),
              
              // Content
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : TabBarView(
                          controller: _tabController,
                          children: [
                            _buildSummaryView(),
                            _buildRecordsView(),
                            _buildAnalyticsView(),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.attendanceReport,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (_currentEmployee != null)
                  Text(
                    _currentEmployee!.name,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
              ],
            ),
          ),
          IconButton(
            onPressed: _loadData,
            icon: const Icon(Icons.refresh, color: Colors.white),
          ),
          IconButton(
            onPressed: () => _showExportOptions(),
            icon: const Icon(Icons.download, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white.withOpacity(0.2),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white.withOpacity(0.6),
        labelStyle: const TextStyle(fontWeight: FontWeight.bold),
        tabs: [
          Tab(text: AppLocalizations.of(context)!.summary),
          Tab(text: AppLocalizations.of(context)!.records),
          Tab(text: AppLocalizations.of(context)!.analytics),
        ],
      ),
    );
  }

  Widget _buildSummaryView() {
    final filteredRecords = _getFilteredRecords();
    final stats = _calculateStats(filteredRecords);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Period Selector
          _buildPeriodSelector(),
          
          const SizedBox(height: 24),
          
          // Quick Stats
          _buildQuickStats(context, stats),
          
          const SizedBox(height: 24),
          
          // Weekly Overview
          if (_weeklySummary != null) _buildWeeklyOverview(),
          
          const SizedBox(height: 24),
          
          // Monthly Overview
          if (_monthlySummary != null) _buildMonthlyOverview(),
        ],
      ),
    );
  }

  Widget _buildRecordsView() {
    final filteredRecords = _getFilteredRecords();
    
    return Column(
      children: [
        // Period Selector
        Padding(
          padding: const EdgeInsets.all(20),
          child: _buildPeriodSelector(),
        ),
        
        // Records List
        Expanded(
          child: _buildRecordsList(context, filteredRecords),
        ),
      ],
    );
  }

  Widget _buildAnalyticsView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Attendance Trends Chart Placeholder
          _buildAttendanceTrends(),
          
          const SizedBox(height: 24),
          
          // Punctuality Analysis
          _buildPunctualityAnalysis(),
          
          const SizedBox(height: 24),
          
          // Location Analysis (if available)
          _buildLocationAnalysis(),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF667eea).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.calendar_today,
                  color: Color(0xFF667eea),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                AppLocalizations.of(context)!.selectPeriod,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D3748),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _periodKeys.map((key) {
              final isSelected = _selectedPeriod == key;
              return ChoiceChip(
                label: Text(_periodLabel(context, key)),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      _selectedPeriod = key;
                    });
                  }
                },
                selectedColor: const Color(0xFF667eea),
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey[700],
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(BuildContext context, Map<String, dynamic> stats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF764ba2).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.analytics,
                color: Color(0xFF764ba2),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              AppLocalizations.of(context)!.quickStatistics,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3748),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.2,
          children: [
            _buildStatCard(
              context: context,
              icon: Icons.access_time,
              title: AppLocalizations.of(context)!.totalHours,
              value: stats['total_hours'],
              color: const Color(0xFF667eea),
            ),
            _buildStatCard(
              context: context,
              icon: Icons.timer,
              title: AppLocalizations.of(context)!.dailyAverage,
              value: stats['average_daily'],
              color: const Color(0xFF764ba2),
            ),
            _buildStatCard(
              context: context,
              icon: Icons.list_alt,
              title: AppLocalizations.of(context)!.sessions,
              value: '${stats['total_sessions']}',
              color: const Color(0xFF48BB78),
            ),
            _buildStatCard(
              context: context,
              icon: Icons.check_circle,
              title: AppLocalizations.of(context)!.onTime,
              value: '${stats['on_time_count']}',
              color: const Color(0xFF38A169),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWeeklyOverview() {
    final weeklyHours = _weeklySummary?['total_weekly_hours'] ?? 0.0;
    final dailyBreakdown = _weeklySummary?['daily_breakdown'] as Map<String, dynamic>?;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF667eea).withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF667eea).withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.calendar_view_week, color: Color(0xFF667eea)),
              const SizedBox(width: 12),
              Text(
                AppLocalizations.of(context)!.weeklyOverview,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3748),
                ),
              ),
              const Spacer(),
              Text(
                '${weeklyHours.toStringAsFixed(1)}h',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF667eea),
                ),
              ),
            ],
          ),
          
          if (dailyBreakdown != null && dailyBreakdown.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            ...dailyBreakdown.entries.map((entry) {
              final dayData = entry.value as Map<String, dynamic>;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      entry.key,
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    Text(
                      '${(dayData['total_hours'] as double).toStringAsFixed(1)}h',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildMonthlyOverview() {
    final monthlyHours = _monthlySummary?['total_monthly_hours'] ?? 0.0;
    final workingDays = _monthlySummary?['working_days'] ?? 0;
    final avgDaily = _monthlySummary?['average_daily_hours'] ?? 0.0;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF764ba2).withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF764ba2).withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.calendar_month, color: Color(0xFF764ba2)),
              const SizedBox(width: 12),
              Text(
                AppLocalizations.of(context)!.monthlyOverview,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3748),
                ),
              ),
              const Spacer(),
              Text(
                '${monthlyHours.toStringAsFixed(1)}h',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF764ba2),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: _buildMiniStat(
                  context,
                  AppLocalizations.of(context)!.workingDays,
                  '$workingDays',
                  Icons.calendar_today,
                ),
              ),
              Expanded(
                child: _buildMiniStat(
                  context,
                  AppLocalizations.of(context)!.avgDaily,
                  '${avgDaily.toStringAsFixed(1)}h',
                  Icons.trending_up,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(BuildContext context, String title, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRecordsList(BuildContext context, List<HrAttendance> records) {
    if (records.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.analytics,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.noAttendanceRecords,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)!.tryDifferentPeriod,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: records.length,
      itemBuilder: (context, index) {
        final record = records[index];
        return _buildRecordCard(context, record, index);
      },
    );
  }

  Widget _buildRecordCard(BuildContext context, HrAttendance record, int index) {
    final isCurrentSession = record.isCheckedIn;
    final workedHours = record.getFormattedWorkedHours();
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCurrentSession ? const Color(0xFF48BB78).withOpacity(0.1) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCurrentSession ? const Color(0xFF48BB78) : Colors.grey[200]!,
          width: isCurrentSession ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isCurrentSession 
                      ? const Color(0xFF48BB78) 
                      : Colors.grey[400],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  isCurrentSession ? Icons.play_arrow : Icons.stop,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              
              const SizedBox(width: 16),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          isCurrentSession ? AppLocalizations.of(context)!.activeSession : AppLocalizations.of(context)!.completedSession,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isCurrentSession 
                                ? const Color(0xFF48BB78) 
                                : Colors.grey[700],
                          ),
                        ),
                        const Spacer(),
                        if (isCurrentSession)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF48BB78),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              AppLocalizations.of(context)!.live,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    
                    const SizedBox(height: 8),
                    
                    Text(
                      DateFormat('EEEE, MMMM dd, yyyy', Localizations.localeOf(context).toString()).format(record.createDate),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: _buildTimeInfo(
                  context: context,
                  title: AppLocalizations.of(context)!.checkIn,
                  time: DateFormat('HH:mm:ss').format(record.checkIn),
                  icon: Icons.login,
                  color: Colors.green[600]!,
                ),
              ),
              
              if (record.checkOut != null) ...[
                Expanded(
                  child: _buildTimeInfo(
                    context: context,
                    title: AppLocalizations.of(context)!.checkOut,
                    time: DateFormat('HH:mm:ss').format(record.checkOut!),
                    icon: Icons.logout,
                    color: Colors.red[600]!,
                  ),
                ),
                
                Expanded(
                  child: _buildTimeInfo(
                    context: context,
                    title: AppLocalizations.of(context)!.duration,
                    time: workedHours,
                    icon: Icons.timer,
                    color: const Color(0xFF667eea),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeInfo({
    required BuildContext context,
    required String title,
    required String time,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          time,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildAttendanceTrends() {
    final stats = _statistics;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.trending_up, color: Color(0xFF667eea)),
              const SizedBox(width: 12),
              Text(
                AppLocalizations.of(context)!.attendanceTrends,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3748),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          if (stats != null) ...[
            _buildTrendItem(
              context,
              AppLocalizations.of(context)!.totalHoursLabel,
              '${(stats['total_hours'] as num?)?.toStringAsFixed(1) ?? '0.0'}h',
              const Color(0xFF667eea),
              0.8,
            ),
            const SizedBox(height: 12),
            _buildTrendItem(
              context,
              AppLocalizations.of(context)!.onTimeRate,
              '${stats['on_time_percentage'] ?? '0.0'}%',
              const Color(0xFF48BB78),
              double.tryParse(stats['on_time_percentage']?.toString() ?? '0') ?? 0.0 / 100,
            ),
            const SizedBox(height: 12),
            _buildTrendItem(
              context,
              AppLocalizations.of(context)!.sessionsWithLocation,
              '${stats['records_with_location'] ?? 0}',
              const Color(0xFF764ba2),
              0.6,
            ),
          ] else
            Center(
              child: Text(
                AppLocalizations.of(context)!.loadingTrends,
                style: const TextStyle(color: Colors.grey),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTrendItem(BuildContext context, String label, String value, Color color, double progress) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: TextStyle(color: Colors.grey[700])),
            Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            backgroundColor: color.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 6,
          ),
        ),
      ],
    );
  }

  Widget _buildPunctualityAnalysis() {
    final filteredRecords = _getFilteredRecords();
    final stats = _calculateStats(filteredRecords);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF48BB78).withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF48BB78).withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.alarm_on, color: Color(0xFF48BB78)),
              const SizedBox(width: 12),
              Text(
                AppLocalizations.of(context)!.punctualityAnalysis,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3748),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: _buildPunctualityItem(
                  AppLocalizations.of(context)!.onTime,
                  stats['on_time_count'],
                  Colors.green,
                  Icons.check_circle,
                ),
              ),
              Expanded(
                child: _buildPunctualityItem(
                  AppLocalizations.of(context)!.late,
                  stats['late_count'],
                  Colors.orange,
                  Icons.warning,
                ),
              ),
              Expanded(
                child: _buildPunctualityItem(
                  AppLocalizations.of(context)!.earlyLeave,
                  stats['early_leave_count'],
                  Colors.red,
                  Icons.exit_to_app,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPunctualityItem(String label, int count, Color color, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(
          '$count',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildLocationAnalysis() {
    final locationCount = _statistics?['records_with_location'] ?? 0;
    final totalRecords = _statistics?['total_sessions'] ?? 0;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF764ba2).withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF764ba2).withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.location_on, color: Color(0xFF764ba2)),
              const SizedBox(width: 12),
              Text(
                AppLocalizations.of(context)!.locationTracking,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3748),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  Text(
                    '$locationCount',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF764ba2),
                    ),
                  ),
                  Text(
                    AppLocalizations.of(context)!.withLocation,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
              Column(
                children: [
                  Text(
                    '${totalRecords - locationCount}',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[400],
                    ),
                  ),
                  Text(
                    AppLocalizations.of(context)!.withoutLocation,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showExportOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.exportReport,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.table_chart, color: Color(0xFF667eea)),
              title: Text(AppLocalizations.of(context)!.exportAsCsv),
              subtitle: Text(AppLocalizations.of(context)!.exportCsvSubtitle),
              onTap: () {
                Navigator.pop(context);
                _exportReport(context, 'csv');
              },
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
              title: Text(AppLocalizations.of(context)!.exportAsPdf),
              subtitle: Text(AppLocalizations.of(context)!.exportPdfSubtitle),
              onTap: () {
                Navigator.pop(context);
                _exportReport(context, 'pdf');
              },
            ),
            ListTile(
              leading: const Icon(Icons.code, color: Colors.orange),
              title: Text(AppLocalizations.of(context)!.exportAsJson),
              subtitle: Text(AppLocalizations.of(context)!.exportJsonSubtitle),
              onTap: () {
                Navigator.pop(context);
                _exportReport(context, 'json');
              },
            ),
          ],
        ),
      ),
    );
  }

  void _exportReport(BuildContext context, String format) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.exportingAs(format)),
        backgroundColor: const Color(0xFF667eea),
      ),
    );
  }
}
