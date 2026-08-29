import 'dart:developer';

import 'package:get/get.dart';
import 'package:hr_core/src/app/app_route.dart';
import 'package:hr_core/src/features/home/presentation/controllers/home_controller.dart';
import 'package:hr_core/src/features/notification/data/repositories/notification_repository_impl.dart';
import 'package:hr_core/src/features/notification/domain/repositories/notification_repository.dart';
import 'package:hr_core/src/models/notification_model.dart';

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
  int unreadCount = 0;

  RxBool isLoading = false.obs;

  @override
  void onReady() {
    super.onReady();
    selectedNotifiState = NotifiState.all;
    getNotification();
  }

  void changeNotifiState(NotifiState state) {
    selectedNotifiState = state;
    _applyFilter();
    update();
  }

  void _applyFilter() {
    switch (selectedNotifiState) {
      case NotifiState.all:
        notifications = List<Notifications>.from(allNotifications);
      case NotifiState.read:
        notifications = allNotifications
            .where((n) => n.state == 'read')
            .toList();
      case NotifiState.unread:
        notifications = allNotifications
            .where((n) => n.state == 'unread')
            .toList();
    }
  }

  Future<void> getNotification() async {
    isLoading.value = true;
    try {
      notificationsModel = await _notificationRepository.getNotification();
      allNotifications = notificationsModel?.notifications ?? [];
      unreadCount = notificationsModel?.unreadCount?.toInt() ??
          allNotifications.where((n) => n.state == 'unread').length;
      _applyFilter();
      update();
    } catch (e, stackTrace) {
      log(
        'getNotification failed: $e',
        name: 'NotificationController',
        stackTrace: stackTrace,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> onNotificationTap(Notifications item) async {
    final id = item.id?.toInt();
    if (id == null) {
      return;
    }

    if (item.state == 'unread') {
      isLoading.value = true;
      try {
        final result = await _notificationRepository.markAsRead(id: id);
        if (result.status == 'success') {
          final updated = (result.notifications != null &&
                  result.notifications!.isNotEmpty)
              ? result.notifications!.first
              : null;
          _replaceLocalNotification(
            id,
            updated ?? item.copyWith(state: 'read'),
          );
          unreadCount = result.unreadCount?.toInt() ??
              allNotifications.where((n) => n.state == 'unread').length;
          _applyFilter();
          update();
          await _syncHomeUnreadCount(unreadCount);
        }
      } finally {
        isLoading.value = false;
      }
    }

    if (item.leaveId != null) {
      Get.toNamed(AppRoutes.holidays);
    }
  }

  Future<void> markAllAsReadAndLeave() async {
    final hasUnread = allNotifications.any((n) => n.state == 'unread');
    if (hasUnread) {
      isLoading.value = true;
      try {
        final result = await _notificationRepository.markAllAsRead();
        if (result.status == 'success') {
          allNotifications = allNotifications
              .map((n) => n.state == 'unread' ? n.copyWith(state: 'read') : n)
              .toList();
          unreadCount = result.unreadCount?.toInt() ?? 0;
          _applyFilter();
          update();
        }
      } finally {
        isLoading.value = false;
      }
    }
    await _syncHomeUnreadCount(0);
  }

  void _replaceLocalNotification(int id, Notifications updated) {
    allNotifications = allNotifications
        .map((n) => n.id?.toInt() == id ? updated : n)
        .toList();
  }

  Future<void> _syncHomeUnreadCount(int count) async {
    if (!Get.isRegistered<HomeController>()) {
      return;
    }
    final home = Get.find<HomeController>();
    home.unreadNotificationCount.value = count;
    await home.loadRecentNotifications();
  }
}
