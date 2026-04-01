import 'dart:async';

import 'package:flutter/material.dart';

import '../../app/locale_scope.dart';
import '../../generated/l10n/app_localizations.dart';
import '../../models/hr_attendance.dart';
import '../../models/hr_employee.dart';
import '../../models/hr_expense.dart';
import '../../services/hr_service.dart';
import '../../services/local_storage_service.dart';
import '../../services/odoo_rpc_service.dart';
import '../auth/login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  Timer? _timer;
  int _seconds = 0;
  bool _isCheckedIn = false;
  String _checkInTime = "--:--:--";
  String _checkOutTime = "--:--:--";
  String _totalToday = "00:00:00";
  String _beforeTime = "00:00";
  DateTime? _checkInDateTime;
  
  final HrService _hrService = HrService();
  final OdooRPCService _odooService = OdooRPCService.instance;
  HrEmployee? _currentEmployee;
  List<HrAttendance> _todayAttendance = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadEmployeeData();
    _loadTodayAttendance();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopTimer();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // Refresh attendance data when app becomes visible
      _loadTodayAttendance();
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted && _isCheckedIn && _checkInDateTime != null) {
        setState(() {
          final now = DateTime.now();
          final duration = now.difference(_checkInDateTime!);
          _seconds = duration.inSeconds;
        });
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
    setState(() {
      _seconds = 0;
    });
  }

  /// Load current employee data from Odoo
  Future<void> _loadEmployeeData() async {
    try {
      final employee = await _hrService.getCurrentEmployee();
      if (mounted) {
        setState(() {
          _currentEmployee = employee;
        });
      }
    } catch (e) {
      print('Error loading employee data: $e');
    }
  }

  /// Load today's attendance data from Odoo
  Future<void> _loadTodayAttendance() async {
    try {
      final summary = await _hrService.getTodayAttendanceSummary();
      if (mounted) {
        setState(() {
          _totalToday = summary['total_worked_hours'] ?? '00:00:00';
          _isCheckedIn = summary['is_checked_in'] ?? false;
          _todayAttendance = summary['today_records'] ?? [];
          
          // Set check-in time if available
          if (summary['current_check_in'] != null) {
            final checkInTime = summary['current_check_in'] as DateTime;
            _checkInDateTime = checkInTime;
            _checkInTime = '${checkInTime.hour.toString().padLeft(2, '0')}:${checkInTime.minute.toString().padLeft(2, '0')}:${checkInTime.second.toString().padLeft(2, '0')}';
          } else {
            _checkInDateTime = null;
          }
        });
        
        // Start or stop timer based on check-in status
        if (_isCheckedIn && _checkInDateTime != null) {
          _startTimer();
        } else {
          _stopTimer();
        }
      }
    } catch (e) {
      print('Error loading attendance data: $e');
    }
  }

  /// Get appropriate greeting based on time of day
  String _getGreeting(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final hour = DateTime.now().hour;
    final now = DateTime.now();
    final weekday = now.weekday;

    String timeGreeting;
    if (hour >= 5 && hour < 12) {
      timeGreeting = l10n.goodMorning;
    } else if (hour >= 12 && hour < 17) {
      timeGreeting = l10n.goodAfternoon;
    } else if (hour >= 17 && hour < 22) {
      timeGreeting = l10n.goodEvening;
    } else {
      timeGreeting = l10n.goodNight;
    }

    String dayName;
    switch (weekday) {
      case 1:
        dayName = l10n.monday;
        break;
      case 2:
        dayName = l10n.tuesday;
        break;
      case 3:
        dayName = l10n.wednesday;
        break;
      case 4:
        dayName = l10n.thursday;
        break;
      case 5:
        dayName = l10n.friday;
        break;
      case 6:
        dayName = l10n.saturday;
        break;
      case 7:
        dayName = l10n.sunday;
        break;
      default:
        dayName = '';
    }

    return l10n.greetingHappyDay(timeGreeting, dayName);
  }

  /// Get current time as formatted string
  String _getCurrentTime() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }



  /// Handle logout
  Future<void> _handleLogout() async {
    try {
      final l10n = AppLocalizations.of(context)!;
      final shouldLogout = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(l10n.logout),
            content: Text(l10n.logoutConfirm),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(l10n.cancel),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(l10n.logout),
              ),
            ],
          );
        },
      );

      if (shouldLogout == true) {
        // Clear all data
        final storage = LocalStorageService();
        await storage.clearAllData();
        
        // Clear Odoo service state
        _odooService.logout();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.loggedOutSuccess),
              backgroundColor: Colors.green,
            ),
          );
          
          // Navigate to login screen
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.logoutError(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Handle check in/out with Odoo
  Future<void> _handleCheckInOut() async {
    try {
      bool success;
      if (_isCheckedIn) {
        // Check out
        success = await _hrService.checkOut();
        if (success) {
          setState(() {
            _isCheckedIn = false;
            _checkOutTime = '${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}:${DateTime.now().second.toString().padLeft(2, '0')}';
            _checkInDateTime = null;
          });
          _stopTimer();
          // Reload attendance data
          _loadTodayAttendance();
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.successCheckedOut),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        // Check in
        success = await _hrService.checkIn();
        if (success) {
          final now = DateTime.now();
          setState(() {
            _isCheckedIn = true;
            _checkInDateTime = now;
            _checkInTime = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
            _checkOutTime = '--:--:--';
            _seconds = 0;
          });
          _startTimer();
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.successCheckedIn),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
      
      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.failedUpdateAttendance),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.errorGeneric(e.toString())),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.hrDashboard),
        backgroundColor: const Color(0xFF6B46C1),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          // User info and logout button
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'logout') {
                _handleLogout();
              } else if (value == 'lang_en' || value == 'lang_ar') {
                final code = value == 'lang_en' ? 'en' : 'ar';
                await LocaleScope.of(context).setLocale(code);
              }
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem<String>(
                value: 'user',
                enabled: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _currentEmployee?.name ?? AppLocalizations.of(context)!.employee,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                    Text(
                      _currentEmployee?.workEmail ?? AppLocalizations.of(context)!.noEmail,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF718096),
                      ),
                    ),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem<String>(
                value: 'lang_en',
                child: Row(
                  children: [
                    const Icon(Icons.language),
                    const SizedBox(width: 8),
                    Text(AppLocalizations.of(context)!.english),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'lang_ar',
                child: Row(
                  children: [
                    const Icon(Icons.language),
                    const SizedBox(width: 8),
                    Text(AppLocalizations.of(context)!.arabic),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem<String>(
                value: 'logout',
                child: Row(
                  children: [
                    const Icon(Icons.logout, color: Colors.red),
                    const SizedBox(width: 8),
                    Text(AppLocalizations.of(context)!.logout),
                  ],
                ),
              ),
            ],
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.white,
                    child: Text(
                      (_currentEmployee?.name ?? 'E').substring(0, 1).toUpperCase(),
                      style: const TextStyle(
                        color: Color(0xFF6B46C1),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_drop_down, color: Colors.white),
                ],
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [


              // Greeting Section
              Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: const Color(0xFF6B46C1),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Icon(
                      Icons.person,
                      size: 30,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${_getGreeting(context)}, ${_currentEmployee?.name ?? AppLocalizations.of(context)!.employee}',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          AppLocalizations.of(context)!.welcomeBackDashboard,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          AppLocalizations.of(context)!.currentTime(_getCurrentTime()),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Attendance Summary Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  children: [
                    // Header with navigation
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF6B46C1), Color(0xFF9F7AEA)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.access_time,
                            size: 24,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppLocalizations.of(context)!.registerAttendance,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2D3748),
                                ),
                              ),
                              Text(
                                _isCheckedIn ? AppLocalizations.of(context)!.currentlyWorking : AppLocalizations.of(context)!.notCheckedIn,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: _isCheckedIn ? Colors.green[600] : Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pushNamed(
                            context, 
                            '/attendance',
                            arguments: {
                              'isCheckedIn': _isCheckedIn,
                              'checkInDateTime': _checkInDateTime,
                              'checkInTime': _checkInTime,
                              'totalWorkedHours': _totalToday,
                            },
                          ),
                          icon: const Icon(Icons.arrow_forward_ios, color: Color(0xFF6B46C1)),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Quick Stats
                    Row(
                      children: [
                        Expanded(
                          child: _buildQuickStat(
                            icon: Icons.timer,
                            title: AppLocalizations.of(context)!.today,
                            value: _totalToday,
                            color: const Color(0xFF667eea),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildQuickStat(
                            icon: Icons.schedule,
                            title: AppLocalizations.of(context)!.thisWeek,
                            value: _beforeTime, // Reusing for weekly hours
                            color: const Color(0xFF764ba2),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Session Timer (only show when checked in)
                    if (_isCheckedIn) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF6B46C1), Color(0xFF9F7AEA)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Text(
                              AppLocalizations.of(context)!.currentSession,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildTimeBox('${(_seconds ~/ 3600).toString().padLeft(2, '0')}'),
                                const Text(' : ', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                                _buildTimeBox('${((_seconds % 3600) ~/ 60).toString().padLeft(2, '0')}'),
                                const Text(' : ', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                                _buildTimeBox('${(_seconds % 60).toString().padLeft(2, '0')}'),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              AppLocalizations.of(context)!.startedAt(_checkInTime),
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Register Attendance Section
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.registerAttendance,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D3748),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => Navigator.pushNamed(context, '/face-attendance'),
                            icon: Icon(_isCheckedIn ? Icons.logout : Icons.login),
                            label: Text(_isCheckedIn ? AppLocalizations.of(context)!.checkOutFace : AppLocalizations.of(context)!.checkInFace),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isCheckedIn ? Colors.red[600] : Colors.green[600],
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => Navigator.pushNamed(
                              context, 
                              '/attendance',
                              arguments: {
                                'isCheckedIn': _isCheckedIn,
                                'checkInDateTime': _checkInDateTime,
                                'checkInTime': _checkInTime,
                                'totalWorkedHours': _totalToday,
                              },
                            ),
                            icon: const Icon(Icons.visibility),
                            label: Text(AppLocalizations.of(context)!.viewDetails),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF6B46C1),
                              side: const BorderSide(color: Color(0xFF6B46C1)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // What do you need section
              Text(
                AppLocalizations.of(context)!.whatDoYouNeed,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),

              const SizedBox(height: 20),

              // Feature Cards Grid
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 3,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.2,
                children: [
                  _buildFeatureCard(
                    icon: Icons.work,
                    title: AppLocalizations.of(context)!.contracts,
                    color: Colors.orange[600]!,
                    onTap: () {
                      Navigator.pushNamed(context, '/contracts');
                    },
                  ),
                  _buildFeatureCard(
                    icon: Icons.payment,
                    title: AppLocalizations.of(context)!.payslip,
                    color: Colors.green[600]!,
                    onTap: () {
                      Navigator.pushNamed(context, '/payslips');
                    },
                  ),
                  _buildFeatureCard(
                    icon: Icons.receipt_long,
                    title: AppLocalizations.of(context)!.expenses,
                    color: Colors.red,
                    onTap: () {
                      Navigator.pushNamed(context, '/expenses');
                    },
                  ),
                  _buildFeatureCard(
                    icon: Icons.access_time,
                    title: AppLocalizations.of(context)!.attendance,
                    color: Colors.grey[700]!,
                    onTap: () {
                      Navigator.pushNamed(
                        context, 
                        '/attendance',
                        arguments: {
                          'isCheckedIn': _isCheckedIn,
                          'checkInDateTime': _checkInDateTime,
                          'checkInTime': _checkInTime,
                          'totalWorkedHours': _totalToday,
                        },
                      );
                    },
                  ),
                  _buildFeatureCard(
                    icon: Icons.beach_access,
                    title: 'Time Off',
                    color: Colors.blue[600]!,
                    onTap: () {
                      Navigator.pushNamed(context, '/team-off');
                    },
                  ),
                  _buildFeatureCard(
                    icon: Icons.calendar_today,
                    title: 'Working Schedule',
                    color: Colors.red[600]!,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeBox(String time) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          time,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF6B46C1),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickStat({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required Color color,
    VoidCallback? onTap,
  }) {
    Widget cardContent = Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey[200]!,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: cardContent,
      );
    }
    
    return cardContent;
  }
} 