import 'package:get/get.dart';
import 'package:hr_core/src/features/home/presentation/controllers/home_controller.dart';
import 'package:hr_core/src/features/notification/presentation/controllers/notification_controller.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => HomeController());
    Get.lazyPut(() => NotificationController());
  }
}
