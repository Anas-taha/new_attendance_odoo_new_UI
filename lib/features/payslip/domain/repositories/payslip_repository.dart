import 'package:hr_app_odoo/models/hr_payslip.dart';
import 'package:hr_app_odoo/models/salary_model.dart';

abstract class PayslipRepository {
  Future<SalaryModel> getPayslips();

  Future<bool> getPayslipLine();
}
