import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:hr_app_odoo/screens/home/home_data.dart';
import 'package:hr_app_odoo/screens/home/widgets/greeting_widget.dart';

import '../../app/locale_scope.dart';
import '../../generated/l10n/app_localizations.dart';
import '../../models/hr_attendance.dart';
import '../../models/hr_employee.dart';
import '../../models/hr_expense.dart';
import '../../services/hr_service.dart';
import '../../services/local_storage_service.dart';
import '../../services/odoo_rpc_service.dart';
import '../login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  final homeController = Get.find<HomeController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    homeController.loadEmployeeData();
    homeController.loadTodayAttendance();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    homeController.stopTimer();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // Refresh attendance data when app becomes visible
      homeController.loadTodayAttendance();
    }
  }

  /// Load current employee data from Odoo

  /// Load today's attendance data from Odoo

  /// Get appropriate greeting based on time of day

  /// Get current time as formatted string

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // appBar: _homeAppBar(context),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting Section
              GreetingWidget(),
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

                    // Row(
                    //   children: [
                    //     Container(
                    //       padding: const EdgeInsets.all(12),
                    //       decoration: BoxDecoration(
                    //         gradient: const LinearGradient(
                    //           colors: [Color(0xFF6B46C1), Color(0xFF9F7AEA)],
                    //           begin: Alignment.topLeft,
                    //           end: Alignment.bottomRight,
                    //         ),
                    //         borderRadius: BorderRadius.circular(12),
                    //       ),
                    //       child: const Icon(
                    //         Icons.access_time,
                    //         size: 24,
                    //         color: Colors.white,
                    //       ),
                    //     ),
                    //     const SizedBox(width: 16),
                    //     Expanded(
                    //       child: Column(
                    //         crossAxisAlignment: CrossAxisAlignment.start,
                    //         children: [
                    //           Text(
                    //             AppLocalizations.of(
                    //               context,
                    //             )!.registerAttendance,
                    //             style: TextStyle(
                    //               fontSize: 18,
                    //               fontWeight: FontWeight.bold,
                    //               color: Color(0xFF2D3748),
                    //             ),
                    //           ),
                    //           Text(
                    //             homeController.isCheckedIn.value
                    //                 ? AppLocalizations.of(
                    //                     context,
                    //                   )!.currentlyWorking
                    //                 : AppLocalizations.of(
                    //                     context,
                    //                   )!.notCheckedIn,
                    //             style: TextStyle(
                    //               fontSize: 14,
                    //               color: homeController.isCheckedIn.value
                    //                   ? Colors.green[600]
                    //                   : Colors.grey[600],
                    //               fontWeight: FontWeight.w500,
                    //             ),
                    //           ),
                    //         ],
                    //       ),
                    //     ),
                    //     IconButton(
                    //       onPressed: () => Navigator.pushNamed(
                    //         context,
                    //         '/attendance',
                    //         arguments: {
                    //           'isCheckedIn': homeController.isCheckedIn.value,
                    //           'checkInDateTime':
                    //               homeController.checkInDateTime.value,
                    //           'checkInTime': homeController.checkInTime.value,
                    //           'totalWorkedHours':
                    //               homeController.totalToday.value,
                    //         },
                    //       ),
                    //       icon: const Icon(
                    //         Icons.arrow_forward_ios,
                    //         color: Color(0xFF6B46C1),
                    //       ),
                    //     ),
                    //   ],
                    // ),
                    const SizedBox(height: 20),

                    // Quick Stats
                    Row(
                      children: [
                        Expanded(
                          child: _buildQuickStat(
                            icon: Icons.timer,
                            title: AppLocalizations.of(context)!.today,
                            value: homeController.totalToday.value,
                            color: const Color(0xFF667eea),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildQuickStat(
                            icon: Icons.schedule,
                            title: AppLocalizations.of(context)!.thisWeek,
                            value: homeController
                                .beforeTime
                                .value, // Reusing for weekly hours
                            color: const Color(0xFF764ba2),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Session Timer (only show when checked in)
                    if (homeController.isCheckedIn.value) ...[
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
                                _buildTimeBox(
                                  '${(homeController.seconds.value ~/ 3600).toString().padLeft(2, '0')}',
                                ),
                                const Text(
                                  ' : ',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                _buildTimeBox(
                                  '${((homeController.seconds.value % 3600) ~/ 60).toString().padLeft(2, '0')}',
                                ),
                                const Text(
                                  ' : ',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                _buildTimeBox(
                                  '${(homeController.seconds.value % 60).toString().padLeft(2, '0')}',
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              AppLocalizations.of(
                                context,
                              )!.startedAt(homeController.checkInTime.value),
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
                                onPressed: () => Navigator.pushNamed(
                                  context,
                                  '/face-attendance',
                                ),
                                icon: Icon(
                                  homeController.isCheckedIn.value
                                      ? Icons.logout
                                      : Icons.login,
                                ),
                                label: Text(
                                  homeController.isCheckedIn.value
                                      ? AppLocalizations.of(
                                          context,
                                        )!.checkOutFace
                                      : AppLocalizations.of(
                                          context,
                                        )!.checkInFace,
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      homeController.isCheckedIn.value
                                      ? Colors.red[600]
                                      : Colors.green[600],
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
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
                                    'isCheckedIn':
                                        homeController.isCheckedIn.value,
                                    'checkInDateTime':
                                        homeController.checkInDateTime.value,
                                    'checkInTime':
                                        homeController.checkInTime.value,
                                    'totalWorkedHours':
                                        homeController.totalToday.value,
                                  },
                                ),
                                icon: const Icon(Icons.visibility),
                                label: Text(
                                  AppLocalizations.of(context)!.viewDetails,
                                ),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFF6B46C1),
                                  side: const BorderSide(
                                    color: Color(0xFF6B46C1),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
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
                          'isCheckedIn': homeController.isCheckedIn.value,
                          'checkInDateTime':
                              homeController.checkInDateTime.value,
                          'checkInTime': homeController.checkInTime.value,
                          'totalWorkedHours': homeController.totalToday.value,
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

  AppBar _homeAppBar(BuildContext context) {
    return AppBar(
      title: Text(AppLocalizations.of(context)!.hrDashboard),
      backgroundColor: Colors.red,
      foregroundColor: Colors.white,
      elevation: 0,
      actions: [
        // User info and logout button
        PopupMenuButton<String>(
          onSelected: (value) async {
            if (value == 'logout') {
              await homeController.handleLogout();
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
                    homeController.currentEmployee.value?.name ??
                        AppLocalizations.of(context)!.employee,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3748),
                    ),
                  ),
                  Text(
                    homeController.currentEmployee.value?.workEmail ??
                        AppLocalizations.of(context)!.noEmail,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF718096),
                    ),
                  ),
                ],
              ),
            ),
            // const PopupMenuDivider(),
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
                    (homeController.currentEmployee.value?.name ?? 'E')
                        .substring(0, 1)
                        .toUpperCase(),
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
            child: Icon(icon, color: color, size: 24),
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
      return GestureDetector(onTap: onTap, child: cardContent);
    }

    return cardContent;
  }
}
