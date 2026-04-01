import 'package:get/get.dart';
import 'package:hr_app_odoo/screens/home/home_data.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => HomeController());
  }
}
