import 'package:hr_core/src/models/notification_model.dart';

abstract class NotificationRepository {
  Future<NotificationModel> getNotification();

  Future<List<Notifications>> getReadNotifications();

  Future<List<Notifications>> getUnreadNotifications();
}
