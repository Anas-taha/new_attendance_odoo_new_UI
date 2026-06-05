import 'package:hr_app_odoo/models/hr_payslip.dart';

abstract class PayslipRepository {
  Future<List<HrPayslip>> getPayslips();

  Future<bool> getPayslipLine();
}
