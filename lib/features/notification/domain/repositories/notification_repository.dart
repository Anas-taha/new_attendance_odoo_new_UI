import 'package:hr_app_odoo/models/notification_model.dart';

abstract class NotificationRepository {
  Future<NotificationModel> getNotification();

  Future<List<Notifications>> getReadNotifications();

  Future<List<Notifications>> getUnreadNotifications();
}
