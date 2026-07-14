import 'package:hr_core/src/models/hr_payslip.dart';
import 'package:hr_core/src/models/salary_model.dart';

abstract class PayslipRepository {
  Future<SalaryModel> getPayslips();

  Future<bool> getPayslipLine();
}
