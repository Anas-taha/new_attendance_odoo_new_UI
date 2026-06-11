import 'package:hr_app_odoo/features/notification/domain/repositories/notification_repository.dart';
import 'package:hr_app_odoo/models/notifications_model.dart';
import 'package:hr_app_odoo/services/simple_hr_service.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  NotificationRepositoryImpl({SimpleHrService? hrService})
    : _hrService = hrService ?? SimpleHrService();
 final SimpleHrService _hrService;
  @override
  Future<NotificationsModel> getNotifications() async =>
     _hrService.getNotifications();

  // @override
  // Future<List<String>> getReadNotifications() async =>
  //     _notifications.where((item) => item.contains('readed')).toList();

  // @override
  // Future<List<String>> getUnreadNotifications() async =>
  //     _notifications.where((item) => item.contains('unReaded')).toList();
}
