import 'package:hr_app_odoo/features/notification/domain/repositories/notification_repository.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  static const List<String> _notifications = <String>[
    ' readed notification 1',
    ' readed notification 2',
    'unReaded notification 1',
    'unReaded notification 2',
    'unReaded notification 3',
  ];

  @override
  Future<List<String>> getAllNotifications() async =>
      List<String>.from(_notifications);

  @override
  Future<List<String>> getReadNotifications() async =>
      _notifications.where((item) => item.contains('readed')).toList();

  @override
  Future<List<String>> getUnreadNotifications() async =>
      _notifications.where((item) => item.contains('unReaded')).toList();
}
