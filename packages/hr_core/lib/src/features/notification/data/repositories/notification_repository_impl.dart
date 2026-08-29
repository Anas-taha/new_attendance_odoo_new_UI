import 'package:hr_core/src/features/notification/domain/repositories/notification_repository.dart';
import 'package:hr_core/src/models/notification_model.dart';
import 'package:hr_core/src/services/simple_hr_service.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  NotificationRepositoryImpl({SimpleHrService? hrService})
    : _hrService = hrService ?? SimpleHrService();
  final SimpleHrService _hrService;

  @override
  Future<NotificationModel> getNotification({String? state}) async {
    final result = await _hrService.getNotification(state: state);
    if (result.status == 'success') {
      return result;
    }
    return NotificationModel();
  }

  @override
  Future<List<Notifications>> getReadNotifications() async {
    final model = await getNotification(state: 'read');
    return model.notifications ?? [];
  }

  @override
  Future<List<Notifications>> getUnreadNotifications() async {
    final model = await getNotification(state: 'unread');
    return model.notifications ?? [];
  }

  @override
  Future<NotificationModel> markAsRead({int? id, List<int>? ids}) {
    return _hrService.markNotificationsRead(id: id, ids: ids);
  }

  @override
  Future<NotificationModel> markAllAsRead({List<int>? ids}) {
    return _hrService.markAllNotificationsRead(ids: ids);
  }
}
