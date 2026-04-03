import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/instance_manager.dart';
import 'package:hr_app_odoo/features/notification/presentation/controller/notifi_controller.dart';
import 'package:hr_app_odoo/features/notification/presentation/widgets/no_notif_widget.dart';
import 'package:hr_app_odoo/features/notification/presentation/widgets/notif_card_widget.dart';
import 'package:hr_app_odoo/features/notification/presentation/widgets/notif_state_widget.dart';
import 'package:hr_app_odoo/theme/app_theme.dart';
import 'package:hr_app_odoo/widgets/custom_appbar/custom_appbar.dart';

class NotificationScreen extends StatelessWidget {
  NotificationScreen({super.key});
  final notifController = Get.put(NotificationController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appFFFFFFBackGround1,
      appBar: CustomAppBar(title: 'الاشعارات', onBackTap: () => Get.back()),
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
                  child: NotificationStateWidget(state: NotifiState.unReaded),
                ),
                8.horizontalSpace,
                Expanded(
                  child: NotificationStateWidget(state: NotifiState.readed),
                ),
              ],
            ),
            8.verticalSpace,
            Obx(() {
              if (notifController.notificationList.value.isEmpty) {
                return NoNotificationWidget();
              }
              final notifList = notifController.notificationList.value;
              return Expanded(
                child: ListView.separated(
                  itemCount: notifList.length,
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  separatorBuilder: (context, index) => 13.verticalSpace,
                  itemBuilder: (context, index) {
                    return NotificationCardWidget(
                      title: notifList[index],
                      date: 'منذ يومين',
                    );
                  },
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
