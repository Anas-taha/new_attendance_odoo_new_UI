import 'dart:developer';

import 'package:get/get.dart';
import 'package:hr_app_odoo/features/notification/data/repositories/notification_repository_impl.dart';
import 'package:hr_app_odoo/features/notification/domain/repositories/notification_repository.dart';

enum NotifiState { all, readed, unReaded }

class NotificationController extends GetxController {
  NotificationController({NotificationRepository? notificationRepository})
    : _notificationRepository =
          notificationRepository ?? NotificationRepositoryImpl();

  final NotificationRepository _notificationRepository;

  Rx<NotifiState> selectedNotifiState = Rx<NotifiState>(NotifiState.all);
  RxList<String> notificationList = RxList<String>([]);

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
        getReadedNotification();
      case NotifiState.unReaded:
        getUnReadedNotification();
    }
  }

  Future<void> getReadedNotification() async {
    notificationList.value = await _notificationRepository
        .getReadNotifications();
  }

  Future<void> getUnReadedNotification() async {
    notificationList.value = await _notificationRepository
        .getUnreadNotifications();
  }

  Future<void> getAllNotification() async {
    notificationList.value = await _notificationRepository
        .getAllNotifications();
  }
}
