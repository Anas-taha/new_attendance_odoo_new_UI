import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hr_app_odoo/app/app_image.dart';
import 'package:hr_app_odoo/app/app_route.dart';
import 'package:hr_app_odoo/app/locale_scope.dart';
import 'package:hr_app_odoo/features/home/presentation/controllers/home_controller.dart';
import 'package:hr_app_odoo/features/home/presentation/widgets/attendance_widget.dart';
import 'package:hr_app_odoo/features/home/presentation/widgets/feature_card_widget.dart';
import 'package:hr_app_odoo/features/notification/presentation/widgets/no_notif_widget.dart';
import 'package:hr_app_odoo/features/notification/presentation/widgets/notif_card_widget.dart';
import 'package:hr_app_odoo/generated/l10n/app_localizations.dart';
import 'package:hr_app_odoo/features/home/presentation/widgets/greeting_widget.dart';
import 'package:hr_app_odoo/screens/login_screen.dart';
import 'package:hr_app_odoo/custom_widgets/custom_screen/custom_screen.dart';
import 'package:hr_app_odoo/custom_widgets/custom_text/custom_text.dart';

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
    // WidgetsBinding.instance.addObserver(this);
    // _uiEventWorker = ever<HomeUiEvent?>(
    //   homeController.uiEvent,
    //   _handleControllerUiEvent,
    // );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      homeController.initData();
    });
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
    homeController.loadTodayAttendance();
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {}
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
      () => CustomScreen(
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GreetingWidget(
                employeeName:
                    // homeController.currentEmployee.value?.name
                    homeController.userName.value,
              ),
              16.verticalSpace,
              AttendanceWidget(),
              16.verticalSpace,

              Row(
                children: [
                  Expanded(
                    child: FeatureCardWidget(
                      image: AppImage.attendance,
                      title: 'الحضور والانصراف',
                      onTap: () {
                        Get.toNamed(AppRoutes.attendance);
                        // Navigator.pushNamed(
                        //   context,
                        //   '/attendance',
                        //   arguments: {
                        //     'isCheckedIn': homeController.isCheckedIn.value,
                        //     'checkInDateTime':
                        //         homeController.checkInDateTime.value,
                        //     'checkInTime': homeController.checkInTime.value,
                        //     'totalWorkedHours': homeController.totalToday.value,
                        //   },
                        // );
                      },
                    ),
                  ),
                  10.horizontalSpace,
                  Expanded(
                    child: FeatureCardWidget(
                      image: AppImage.holiday,
                      title: 'الاجازات',
                      onTap: () => Get.toNamed(AppRoutes.holidays),
                      // onTap: () => Navigator.pushNamed(context, '/team-off'),
                    ),
                  ),
                ],
              ),
              20.verticalSpace,
              Row(
                children: [
                  Expanded(
                    child: FeatureCardWidget(
                      image: AppImage.money,
                      // title: AppLocalizations.of(context)!.payslip,
                      title: "الرواتب",

                      onTap: () => Get.toNamed(AppRoutes.payslips),
                    ),
                  ),
                  10.horizontalSpace,
                  Expanded(
                    child: FeatureCardWidget(
                      image: AppImage.person,
                      title: 'الصفحه الشخصية',
                      onTap: () => Get.toNamed(AppRoutes.profile),
                    ),
                  ),
                ],
              ),
              16.verticalSpace,
              CustomText(
                text: 'اخر اشعارات الشركة',
                fontWeight: FontWeight.w600,
              ),
              16.verticalSpace,

              Obx(() {
                if (homeController.lastNotivication.value.isEmpty) {
                  return Center(child: NoNotificationWidget(height: 30));
                }
                return Expanded(
                  child: ListView.separated(
                    itemCount: 1,
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    physics: const BouncingScrollPhysics(),
                    separatorBuilder: (context, index) => 13.verticalSpace,
                    itemBuilder: (context, index) {
                      return NotificationCardWidget(
                        title: 'تم الموافقة على طلب الإجازة',
                        date: 'منذ يومين',
                      );
                    },
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
