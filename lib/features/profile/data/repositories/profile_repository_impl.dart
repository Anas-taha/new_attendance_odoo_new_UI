import 'package:hr_app_odoo/features/profile/domain/repositories/profile_repository.dart';
import 'package:hr_app_odoo/models/hr_employee.dart';
import 'package:hr_app_odoo/services/simple_hr_service.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl({SimpleHrService? hrService})
    : _hrService = hrService ?? SimpleHrService();

  final SimpleHrService _hrService;

  @override
  Future<HrEmployee?> getProfileData() async {
    final result = await _hrService.getProfile();
    if (result.isEmpty) {
      return null;
    }
    return result.first;
  }
}
