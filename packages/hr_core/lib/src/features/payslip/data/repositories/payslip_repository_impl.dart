import 'package:hr_core/src/features/payslip/domain/repositories/payslip_repository.dart';
import 'package:hr_core/src/models/hr_payslip.dart';
import 'package:hr_core/src/models/salary_model.dart';
import 'package:hr_core/src/services/simple_hr_service.dart';

class PayslipRepositoryImpl implements PayslipRepository {
  PayslipRepositoryImpl({SimpleHrService? hrService})
    : _hrService = hrService ?? SimpleHrService();

  final SimpleHrService _hrService;

  @override
  Future<SalaryModel> getPayslips() => _hrService.getPayslip();

  @override
  Future<bool> getPayslipLine() => _hrService.getPayslipLine();
}
