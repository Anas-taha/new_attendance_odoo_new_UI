import 'dart:developer';

import 'package:get/get.dart';

enum NotifiState { all, readed, unReaded }

class NotificationController extends GetxController {
  Rx<NotifiState> selectedNotifiState = Rx<NotifiState>(NotifiState.all);
  RxList<String> notificationList = RxList<String>([]);

  void init() {
    selectedNotifiState.value = NotifiState.all;
    notificationList.value = [];
  }

  void changeNotifiState(NotifiState state) {
    selectedNotifiState.value = state;
    getAllNotification();
    log(name: 'aksdcu', selectedNotifiState.value.toString());
  }

  void getReadedNotification() {
    notificationList.value = [
      ' readed notification 1',
      ' readed notification 2',
    ];
  }

  void getUnReadedNotification() {
    notificationList.value = [
      'unReaded notification 1',
      'unReaded notification 2',
      'unReaded notification 3',
    ];
  }

  void getAllNotification() {
    notificationList.value = [
      ' readed notification 1',
      ' readed notification 2',
      'unReaded notification 1',
      'unReaded notification 2',
      'unReaded notification 3',
      ' readed notification 1',
      ' readed notification 2',
      'unReaded notification 1',
      'unReaded notification 2',
      'unReaded notification 3',
      ' readed notification 1',
      ' readed notification 2',
      'unReaded notification 1',
      'unReaded notification 2',
      'unReaded notification 3',
      ' readed notification 1',
      ' readed notification 2',
      'unReaded notification 1',
      'unReaded notification 2',
      'unReaded notification 3',
      ' readed notification 1',
      ' readed notification 2',
      'unReaded notification 1',
      'unReaded notification 2',
      'unReaded notification 3',
      ' readed notification 1',
      ' readed notification 2',
      'unReaded notification 1',
      'unReaded notification 2',
      'unReaded notification 3',
      ' readed notification 1',
      ' readed notification 2',
      'unReaded notification 1',
      'unReaded notification 2',
      'unReaded notification 3',
      ' readed notification 1',
      ' readed notification 2',
      'unReaded notification 1',
      'unReaded notification 2',
      'unReaded notification 3',
      ' readed notification 1',
      ' readed notification 2',
      'unReaded notification 1',
      'unReaded notification 2',
      'unReaded notification 3',
      ' readed notification 1',
      ' readed notification 2',
      'unReaded notification 1',
      'unReaded notification 2',
      'unReaded notification 3',
    ];
  }
}
