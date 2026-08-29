import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hr_core/src/custom_widgets/custom_appbar/custom_appbar.dart';
import 'package:hr_core/src/custom_widgets/custom_screen/custom_screen.dart';
import 'package:hr_core/src/features/notification/presentation/controller/notifi_controller.dart';
import 'package:hr_core/src/features/notification/presentation/widgets/no_notif_widget.dart';
import 'package:hr_core/src/features/notification/presentation/widgets/notif_card_widget.dart';
import 'package:hr_core/src/features/notification/presentation/widgets/notif_state_widget.dart';
import 'package:hr_core/src/services/extension.dart';
import 'package:skeletonizer/skeletonizer.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  bool _allowPop = false;

  Future<void> _onBack(NotificationController controller) async {
    if (_allowPop) {
      return;
    }
    await controller.markAllAsReadAndLeave();
    if (!mounted) {
      return;
    }
    setState(() => _allowPop = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Get.back();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<NotificationController>(
      builder: (controller) {
        return PopScope(
          canPop: _allowPop,
          onPopInvokedWithResult: (didPop, _) async {
            if (didPop) {
              return;
            }
            await _onBack(controller);
          },
          child: CustomScreen(
            loading: controller.isLoading,
            appBar: CustomAppBar(
              title: context.appWords.notifications,
              onBackTap: () => _onBack(controller),
              showNotivication: false,
            ),
            body: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                16.verticalSpace,
                Row(
                  children: [
                    Expanded(
                      child: NotificationStateWidget(state: NotifiState.all),
                    ),
                    8.horizontalSpace,
                    Expanded(
                      child: NotificationStateWidget(state: NotifiState.unread),
                    ),
                    8.horizontalSpace,
                    Expanded(
                      child: NotificationStateWidget(state: NotifiState.read),
                    ),
                  ],
                ),
                16.verticalSpace,
                Expanded(
                  child: controller.notifications.isEmpty
                      ? Center(child: NoNotificationWidget())
                      : ListView.separated(
                          itemCount: controller.notifications.length,
                          padding: EdgeInsets.zero,
                          physics: const BouncingScrollPhysics(),
                          separatorBuilder: (context, index) =>
                              16.verticalSpace,
                          itemBuilder: (context, index) {
                            final item = controller.notifications[index];
                            return Skeletonizer(
                              enabled: false,
                              child: NotificationCardWidget(
                                state: item.state,
                                title: item.title ?? '',
                                date: item.date?.getDateOnly(
                                      fallback: context.appWords
                                          .notificationsRelativeTwoDaysAgo,
                                    ) ??
                                    context.appWords
                                        .notificationsRelativeTwoDaysAgo,
                                onTap: () => controller.onNotificationTap(item),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
