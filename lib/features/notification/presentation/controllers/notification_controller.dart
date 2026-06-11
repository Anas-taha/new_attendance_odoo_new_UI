import 'dart:developer';

import 'package:get/get.dart';
import 'package:hr_app_odoo/features/notification/data/repositories/notification_repository_impl.dart';
import 'package:hr_app_odoo/features/notification/domain/repositories/notification_repository.dart';
import 'package:hr_app_odoo/models/notification_model.dart';

enum NotifiState { all, read, unread }

class NotificationController extends GetxController {
  NotificationController({NotificationRepository? notificationRepository})
    : _notificationRepository =
          notificationRepository ?? NotificationRepositoryImpl();

  final NotificationRepository _notificationRepository;

  NotifiState selectedNotifiState = NotifiState.all;
  NotificationModel? notificationsModel;

  List<Notifications> notifications = [];
  List<Notifications> allNotifications = [];
  // List<Notifications> readNotifications = [];
  // List<Notifications> unreadNotifications = [];

  RxBool isLoading = false.obs;

  @override
  void onReady() {
    super.onReady();
    log(name: 'NotificationControllerState', 'onReady');
    getNotification();
    selectedNotifiState = NotifiState.all;
    update();
  }

  @override
  void onClose() {
    super.onClose();
    log(name: 'NotificationControllerState', 'onClose');
  }

  void changeNotifiState(NotifiState state) {
    selectedNotifiState = state;
    update();
    switch (state) {
      case NotifiState.all:
        notifications = allNotifications;
      // getNotification();
      case NotifiState.read:
        notifications = allNotifications
            .where((n) => n.state == 'read')
            .toList();
      // getNotification();
      // getReadedNotification();
      case NotifiState.unread:
        notifications = allNotifications
            .where((n) => n.state == 'unread')
            .toList();
      // getNotification();
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

  Future<void> getNotification() async {
    notificationsModel = await _notificationRepository.getNotification();
    allNotifications = notificationsModel?.notifications ?? [];
    log(
      name: 'NotificationControllerState',
      'getNotification: ${notificationsModel?.notifications?[0].title}',
    );
    notifications = allNotifications;
    update();
  }
}
