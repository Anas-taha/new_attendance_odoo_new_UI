import 'package:hr_core/src/models/notification_model.dart';

abstract class NotificationRepository {
  Future<NotificationModel> getNotification({String? state});

  Future<List<Notifications>> getReadNotifications();

  Future<List<Notifications>> getUnreadNotifications();

  Future<NotificationModel> markAsRead({int? id, List<int>? ids});

  Future<NotificationModel> markAllAsRead({List<int>? ids});
}
