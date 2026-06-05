abstract class NotificationRepository {
  Future<List<String>> getAllNotifications();

  Future<List<String>> getReadNotifications();

  Future<List<String>> getUnreadNotifications();
}
