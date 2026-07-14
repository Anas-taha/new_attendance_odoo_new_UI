import 'package:hr_core/src/features/notification/domain/repositories/notification_repository.dart';
import 'package:hr_core/src/models/notification_model.dart';
import 'package:hr_core/src/services/simple_hr_service.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  NotificationRepositoryImpl({SimpleHrService? hrService})
    : _hrService = hrService ?? SimpleHrService();
  final SimpleHrService _hrService;

  // static const List<String> _notifications = <String>[
  //   ' readed notification 1',
  //   ' readed notification 2',
  //   'unReaded notification 1',
  //   'unReaded notification 2',
  //   'unReaded notification 3',
  // ];

  @override
  Future<NotificationModel> getNotification() async {
    final result = await _hrService.getNotification();
    if (result.status == 'success') {
      return result;
    }
    return NotificationModel();
  }

  @override
  Future<List<Notifications>> getReadNotifications() async {
    final model = await getNotification();
    return model.notifications?.where((n) => n.state == 'read').toList() ?? [];
  }

  @override
  Future<List<Notifications>> getUnreadNotifications() async {
    final model = await getNotification();
    return model.notifications?.where((n) => n.state == 'unread').toList() ?? [];
  }
}
