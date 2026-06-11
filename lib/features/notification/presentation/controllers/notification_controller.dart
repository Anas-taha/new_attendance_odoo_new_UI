import 'dart:developer';

import 'package:get/get.dart';
import 'package:hr_app_odoo/features/notification/data/repositories/notification_repository_impl.dart';
import 'package:hr_app_odoo/features/notification/domain/repositories/notification_repository.dart';
import 'package:hr_app_odoo/models/notifications_model.dart';

enum NotifiState { all, readed, unReaded }

class NotificationController extends GetxController {
  NotificationController({NotificationRepository? notificationRepository})
    : _notificationRepository =
          notificationRepository ?? NotificationRepositoryImpl();

  final NotificationRepository _notificationRepository;
RxBool isLoading = false.obs;
  Rx<NotifiState> selectedNotifiState = Rx<NotifiState>(NotifiState.all);
 NotificationsModel notificationList = NotificationsModel();

  @override
  void onReady() {
    super.onReady();
    log(name: 'NotificationControllerState', 'onReady');
    getAllNotification();
    selectedNotifiState.value = NotifiState.all;
  }

  @override
  void onClose() {
    super.onClose();
    log(name: 'NotificationControllerState', 'onClose');
  }

  void changeNotifiState(NotifiState state) {
    selectedNotifiState.value = state;
    switch (state) {
      case NotifiState.all:
        getAllNotification();
      case NotifiState.readed:
        getAllNotification();

      // getReadedNotification();
      case NotifiState.unReaded:
        getAllNotification();
      // getUnReadedNotification();
    }
  }

  // Future<void> getReadedNotification() async {
  //   notificationList.value = await _notificationRepository
  //       .getReadNotifications();
  // }

  // Future<void> getUnReadedNotification() async {
  //   notificationList.value = await _notificationRepository
  //       .getUnreadNotifications();
  // }

  Future<void> getAllNotification() async {
    isLoading.value = true;
    notificationList = await _notificationRepository.getNotifications();
    update();
    isLoading.value = false;
  }
}
