import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hr_core/src/app/app_image.dart';
import 'package:hr_core/src/app/app_route.dart';
import 'package:hr_core/src/custom_widgets/custom_screen/custom_screen.dart';
import 'package:hr_core/src/custom_widgets/custom_text/custom_text.dart';
import 'package:hr_core/src/features/home/presentation/controllers/home_controller.dart';
import 'package:hr_core/src/features/home/presentation/widgets/attendance_widget.dart';
import 'package:hr_core/src/features/home/presentation/widgets/feature_card_widget.dart';
import 'package:hr_core/src/features/home/presentation/widgets/greeting_widget.dart';
import 'package:hr_core/src/features/home/presentation/widgets/quick_state_widget.dart';
import 'package:hr_core/src/features/notification/presentation/widgets/no_notif_widget.dart';
import 'package:hr_core/src/features/notification/presentation/widgets/notif_card_widget.dart';
import 'package:hr_core/src/services/extension.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      builder: (controller) {
        final brand = Theme.of(context).colorScheme.secondary;
        final primary = Theme.of(context).colorScheme.primary;

        return CustomScreen(
          loading: controller.isLoading,
          body: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Obx(
                    () => GreetingWidget(
                      employeeName: controller.userName.value,
                      unreadCount: controller.recentNotifications
                          .where((n) => n.state == 'unread')
                          .length,
                    ),
                  ),
                  14.verticalSpace,
                  Obx(
                    () => Row(
                      children: [
                        Expanded(
                          child: QuickStateWidget(
                            icon: Icons.timer_outlined,
                            title: context.appWords.today,
                            value: controller.totalToday.value,
                            color: brand,
                          ),
                        ),
                        10.horizontalSpace,
                        Expanded(
                          child: QuickStateWidget(
                            icon: Icons.calendar_view_week_outlined,
                            title: context.appWords.thisWeek,
                            value: controller.beforeTime.value,
                            color: primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  14.verticalSpace,
                  const AttendanceWidget(),
                  16.verticalSpace,
                  Row(
                    children: [
                      Expanded(
                        child: FeatureCardWidget(
                          image: AppImage.attendance,
                          title: context.appWords.attendanceAndLeaves,
                          onTap: () => Get.toNamed(AppRoutes.attendance),
                        ),
                      ),
                      10.horizontalSpace,
                      Expanded(
                        child: FeatureCardWidget(
                          image: AppImage.holiday,
                          title: context.appWords.holidays,
                          onTap: () => Get.toNamed(AppRoutes.holidays),
                        ),
                      ),
                    ],
                  ),
                  12.verticalSpace,
                  Row(
                    children: [
                      Expanded(
                        child: FeatureCardWidget(
                          image: AppImage.money,
                          title: context.appWords.salary,
                          onTap: () => Get.toNamed(AppRoutes.payslips),
                        ),
                      ),
                      10.horizontalSpace,
                      Expanded(
                        child: FeatureCardWidget(
                          image: AppImage.person,
                          title: context.appWords.profile,
                          onTap: () => Get.toNamed(AppRoutes.profile),
                        ),
                      ),
                    ],
                  ),
                  16.verticalSpace,
                  CustomText(
                    text: context.appWords.lastNotifications,
                    fontWeight: FontWeight.w600,
                  ),
                  12.verticalSpace,
                  Obx(() {
                    final notifications = controller.recentNotifications;
                    if (notifications.isEmpty) {
                      return Center(child: NoNotificationWidget(height: 30));
                    }
                    return Column(
                      children: [
                        for (var index = 0;
                            index < notifications.length;
                            index++) ...[
                          if (index > 0) 13.verticalSpace,
                          NotificationCardWidget(
                            title: notifications[index].title ?? '',
                            date: notifications[index].date?.getDateOnly(
                                  fallback: context.appWords
                                      .notificationsRelativeTwoDaysAgo,
                                ) ??
                                '',
                            state: notifications[index].state,
                          ),
                        ],
                      ],
                    );
                  }),
                  16.verticalSpace,
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
