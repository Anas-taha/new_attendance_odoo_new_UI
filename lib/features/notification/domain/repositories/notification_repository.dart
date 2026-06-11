import 'package:hr_app_odoo/models/notifications_model.dart';

abstract class NotificationRepository {
  Future<NotificationsModel> getNotifications();

  // Future<List<String>> getReadNotifications();

  // Future<List<String>> getUnreadNotifications();
}
