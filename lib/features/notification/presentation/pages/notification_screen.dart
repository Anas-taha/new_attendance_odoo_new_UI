import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/instance_manager.dart';
import 'package:hr_app_odoo/custom_widgets/custom_screen/custom_screen.dart';
import 'package:hr_app_odoo/services/extension.dart';
import 'package:hr_app_odoo/features/notification/presentation/controller/notifi_controller.dart';
import 'package:hr_app_odoo/features/notification/presentation/widgets/no_notif_widget.dart';
import 'package:hr_app_odoo/features/notification/presentation/widgets/notif_card_widget.dart';
import 'package:hr_app_odoo/features/notification/presentation/widgets/notif_state_widget.dart';
import 'package:hr_app_odoo/theme/app_theme.dart';
import 'package:hr_app_odoo/custom_widgets/custom_appbar/custom_appbar.dart';
import 'package:skeletonizer/skeletonizer.dart';

class NotificationScreen extends StatelessWidget {
  NotificationScreen({super.key});

   

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
          body: Padding(
            padding: EdgeInsetsGeometry.symmetric(horizontal: 20),
            child: Column(
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
                      child: NotificationStateWidget(
                        state: NotifiState.unReaded,
                      ),
                    ),
                    8.horizontalSpace,
                    Expanded(
                      child: NotificationStateWidget(state: NotifiState.readed),
                    ),
                  ],
                ),
                16.verticalSpace,
                Obx(() {
                  if (controller
                      .notificationList
                     
                      .notifications!
                      .isEmpty) {
                    return NoNotificationWidget();
                  }
                  final notifList = controller.notificationList;
                  return Expanded(
                    child: ListView.separated(
                      itemCount: notifList.notifications!.length,
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      physics: const BouncingScrollPhysics(),
                      separatorBuilder: (context, index) => 16.verticalSpace,
                      itemBuilder: (context, index) {
                        return Skeletonizer(
                          enabled: false,
                          child: NotificationCardWidget(
                            title: notifList.notifications?[index].title ?? '',
                            date: 'منذ يومين',
                          ),
                        );
                      },
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }
}
