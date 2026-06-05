import 'package:hr_app_odoo/features/payslip/domain/repositories/payslip_repository.dart';
import 'package:hr_app_odoo/models/hr_payslip.dart';
import 'package:hr_app_odoo/services/simple_hr_service.dart';

class PayslipRepositoryImpl implements PayslipRepository {
  PayslipRepositoryImpl({SimpleHrService? hrService})
    : _hrService = hrService ?? SimpleHrService();

  final SimpleHrService _hrService;

  @override
  Future<List<HrPayslip>> getPayslips() => _hrService.getPayslip();

  @override
  Future<bool> getPayslipLine() => _hrService.getPayslipLine();
}
