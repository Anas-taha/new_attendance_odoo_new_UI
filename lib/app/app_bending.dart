import 'package:get/get.dart';
import 'package:hr_app_odoo/features/home/presentation/controllers/home_controller.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => HomeController());
  }
}
