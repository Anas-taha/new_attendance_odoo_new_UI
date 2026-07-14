import 'package:hr_core/src/models/hr_employee.dart';

abstract class ProfileRepository {
  Future<HrEmployee?> getProfileData();
}
