import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hr_app_odoo/app/locale_scope.dart';
import 'package:hr_app_odoo/features/home/presentation/controllers/home_controller.dart';
import 'package:hr_app_odoo/features/home/presentation/widgets/attendance_widget.dart';
import 'package:hr_app_odoo/generated/l10n/app_localizations.dart';
import 'package:hr_app_odoo/features/home/presentation/widgets/greeting_widget.dart';
import 'package:hr_app_odoo/screens/login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  final homeController = Get.find<HomeController>();
  late final Worker _uiEventWorker;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _uiEventWorker = ever<HomeUiEvent?>(
      homeController.uiEvent,
      _handleControllerUiEvent,
    );
    homeController.loadEmployeeData();
    homeController.loadTodayAttendance();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _uiEventWorker.dispose();
    homeController.stopTimer();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      homeController.loadTodayAttendance();
    }
  }

  Future<void> _handleControllerUiEvent(HomeUiEvent? event) async {
    if (event == null || !mounted) {
      return;
    }

    final l10n = AppLocalizations.of(context)!;
    if (event is ShowLogoutConfirmationEvent) {
      final shouldLogout = await showDialog<bool>(
        context: context,
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            title: Text(l10n.logout),
            content: Text(l10n.logoutConfirm),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: Text(l10n.cancel),
              ),
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: Text(l10n.logout),
              ),
            ],
          );
        },
      );

      if (shouldLogout == true) {
        await homeController.confirmLogout();
      }
      return;
    }

    if (event is HomeSuccessMessageEvent) {
      final message = _resolveMessage(l10n, event.messageKey);
      Get.snackbar(
        'Success',
        message,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      return;
    }

    if (event is HomeErrorMessageEvent) {
      final message = _resolveMessage(
        l10n,
        event.messageKey,
        errorDetail: event.errorDetail,
      );
      Get.snackbar(
        'Failed',
        message,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
      return;
    }

    if (event is LogoutSuccessEvent) {
      Get.offAll(() => const LoginScreen());
    }
  }

  String _resolveMessage(
    AppLocalizations l10n,
    String messageKey, {
    String? errorDetail,
  }) {
    switch (messageKey) {
      case 'successCheckedIn':
        return l10n.successCheckedIn;
      case 'successCheckedOut':
        return l10n.successCheckedOut;
      case 'failedUpdateAttendance':
        return l10n.failedUpdateAttendance;
      case 'loggedOutSuccess':
        return l10n.loggedOutSuccess;
      case 'logoutError':
        return l10n.logoutError(errorDetail ?? '');
      case 'errorGeneric':
        return l10n.errorGeneric(errorDetail ?? '');
      default:
        return errorDetail ?? messageKey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        backgroundColor: Colors.white,

        // appBar: AppBar(
        //   title: const Text('HR Dashboard'),
        //   backgroundColor: const Color(0xFF6B46C1),
        //   foregroundColor: Colors.white,
        //   elevation: 0,
        //   actions: [
        //     // User info and logout button
        //     PopupMenuButton<String>(
        //       onSelected: (value) {
        //         // if (value == 'logout') {
        //         //   _handleLogout();
        //         // }
        //       },
        //       itemBuilder: (BuildContext context) => [
        //         PopupMenuItem<String>(
        //           value: 'user',
        //           enabled: false,
        //           child: Column(
        //             crossAxisAlignment: CrossAxisAlignment.start,
        //             children: [
        //               Text(
        //                 homeController.currentEmployee.value?.name ??
        //                     'Employee',
        //                 style: const TextStyle(
        //                   fontWeight: FontWeight.bold,
        //                   color: Color(0xFF2D3748),
        //                 ),
        //               ),
        //               Text(
        //                 homeController.currentEmployee.value?.workEmail ??
        //                     'No email',
        //                 style: const TextStyle(
        //                   fontSize: 12,
        //                   color: Color(0xFF718096),
        //                 ),
        //               ),
        //             ],
        //           ),
        //         ),
        //         const PopupMenuDivider(),
        //         const PopupMenuItem<String>(
        //           value: 'logout',
        //           child: Row(
        //             children: [
        //               Icon(Icons.logout, color: Colors.red),
        //               SizedBox(width: 8),
        //               Text('Logout'),
        //             ],
        //           ),
        //         ),
        //       ],
        //       child: Container(
        //         padding: const EdgeInsets.symmetric(
        //           horizontal: 12,
        //           vertical: 8,
        //         ),
        //         child: Row(
        //           mainAxisSize: MainAxisSize.min,
        //           children: [
        //             CircleAvatar(
        //               radius: 16,
        //               backgroundColor: Colors.white,
        //               child: Text(
        //                 (homeController.currentEmployee.value?.name ?? 'E')
        //                     .substring(0, 1)
        //                     .toUpperCase(),
        //                 style: const TextStyle(
        //                   color: Color(0xFF6B46C1),
        //                   fontWeight: FontWeight.bold,
        //                 ),
        //               ),
        //             ),
        //             const SizedBox(width: 8),
        //             const Icon(Icons.arrow_drop_down, color: Colors.white),
        //           ],
        //         ),
        //       ),
        //     ),
        //   ],
        // ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GreetingWidget(
                  employeeName:
                      homeController.currentEmployee.value?.name ??
                      AppLocalizations.of(context)!.employee,
                ),
                16.verticalSpace,
                AttendanceWidget(),
                const SizedBox(height: 32),
                Text(
                  AppLocalizations.of(context)!.whatDoYouNeed,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 20),
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
                      onTap: () => Navigator.pushNamed(context, '/contracts'),
                    ),
                    _buildFeatureCard(
                      icon: Icons.payment,
                      title: AppLocalizations.of(context)!.payslip,
                      color: Colors.green[600]!,
                      onTap: () => Navigator.pushNamed(context, '/payslips'),
                    ),
                    _buildFeatureCard(
                      icon: Icons.receipt_long,
                      title: AppLocalizations.of(context)!.expenses,
                      color: Colors.red,
                      onTap: () => Navigator.pushNamed(context, '/expenses'),
                    ),
                    _buildFeatureCard(
                      icon: Icons.access_time_rounded,
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
                      onTap: () => Navigator.pushNamed(context, '/team-off'),
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
        PopupMenuButton<String>(
          onSelected: (value) async {
            if (value == 'logout') {
              homeController.requestLogout();
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

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required Color color,
    VoidCallback? onTap,
  }) {
    final cardContent = Container(
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
