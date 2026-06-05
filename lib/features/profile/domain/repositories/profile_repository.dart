import 'package:hr_app_odoo/models/hr_employee.dart';

abstract class ProfileRepository {
  Future<HrEmployee?> getProfileData();
}
