import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/instance_manager.dart';
import 'package:hr_core/src/custom_widgets/custom_screen/custom_screen.dart';
import 'package:hr_core/src/services/extension.dart';
import 'package:hr_core/src/features/notification/presentation/controller/notifi_controller.dart';
import 'package:hr_core/src/features/notification/presentation/widgets/no_notif_widget.dart';
import 'package:hr_core/src/features/notification/presentation/widgets/notif_card_widget.dart';
import 'package:hr_core/src/features/notification/presentation/widgets/notif_state_widget.dart';
import 'package:hr_core/src/theme/app_theme.dart';
import 'package:hr_core/src/custom_widgets/custom_appbar/custom_appbar.dart';
import 'package:skeletonizer/skeletonizer.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  // @override
  @override
  Widget build(BuildContext context) {
    return GetBuilder<NotificationController>(
      builder: (controller) {
        return CustomScreen(
          loading: controller.isLoading,
          appBar: CustomAppBar(
            title: context.appWords.notifications,
            onBackTap: () => Get.back(),
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
              (controller.notifications.isEmpty)
                  ? NoNotificationWidget()
                  : Expanded(
                      child: ListView.separated(
                        itemCount: controller.notifications.length,
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        physics: const BouncingScrollPhysics(),
                        separatorBuilder: (context, index) => 16.verticalSpace,
                        itemBuilder: (context, index) {
                          return Skeletonizer(
                            enabled: false,
                            child: NotificationCardWidget(
                              state: controller.notifications[index].state,
                              title:
                                  controller.notifications[index].title ?? '',
                              date:
                                  controller.notifications[index].date
                                      ?.getDateOnly(
                                        fallback: context
                                            .appWords
                                            .notificationsRelativeTwoDaysAgo,
                                      ) ??
                                  context.appWords.notificationsRelativeTwoDaysAgo,
                            ),
                          );
                        },
                      ),
                    ),
              // if (controller.notificationList.value.isEmpty) {
              //   return NoNotificationWidget();
              // }
              // final notifList = controller.notificationList.value;
              // return Expanded(
              //   child: ListView.separated(
              //     itemCount: notifList.length,
              //     padding: EdgeInsets.zero,
              //     shrinkWrap: true,
              //     physics: const BouncingScrollPhysics(),
              //     separatorBuilder: (context, index) => 16.verticalSpace,
              //     itemBuilder: (context, index) {
              //       return Skeletonizer(
              //         enabled: false,
              //         child: NotificationCardWidget(
              //           title: notifList[index].title ?? '',
              //           date: notifList[index].date ?? 'منذ يومين',
              //         ),
              //       );
              //     },
              //   ),
              // );
            ],
          ),
        );
      },
    );
  }
}
