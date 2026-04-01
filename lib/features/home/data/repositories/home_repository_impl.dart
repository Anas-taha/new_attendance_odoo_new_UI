import 'package:hr_app_odoo/features/home/domain/repositories/home_repository.dart';
import 'package:hr_app_odoo/models/hr_employee.dart';
import 'package:hr_app_odoo/services/hr_service.dart';
import 'package:hr_app_odoo/services/local_storage_service.dart';
import 'package:hr_app_odoo/services/odoo_rpc_service.dart';

class HomeRepositoryImpl implements HomeRepository {
  HomeRepositoryImpl({
    HrService? hrService,
    LocalStorageService? localStorageService,
    OdooRPCService? odooRpcService,
  }) : _hrService = hrService ?? HrService(),
       _localStorageService = localStorageService ?? LocalStorageService(),
       _odooRpcService = odooRpcService ?? OdooRPCService.instance;

  final HrService _hrService;
  final LocalStorageService _localStorageService;
  final OdooRPCService _odooRpcService;

  @override
  Future<HrEmployee?> getCurrentEmployee() => _hrService.getCurrentEmployee();

  @override
  Future<Map<String, dynamic>> getTodayAttendanceSummary() =>
      _hrService.getTodayAttendanceSummary();

  @override
  Future<bool> checkIn() => _hrService.checkIn();

  @override
  Future<bool> checkOut() => _hrService.checkOut();

  @override
  Future<void> logout() async {
    await _localStorageService.clearAllData();
    _odooRpcService.logout();
  }
}
