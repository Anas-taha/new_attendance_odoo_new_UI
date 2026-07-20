import 'package:flutter/material.dart';
import 'package:hr_core/src/config/tenant_config.dart';

class OdooConfig {
  OdooConfig._();

  static TenantConfig? _config;

  static void init(TenantConfig config) {
    _config = config;
  }

  static void _ensureInitialized() {
    if (_config == null) {
      throw StateError(
        'OdooConfig.init(TenantConfig) must be called before using OdooConfig.',
      );
    }
  }

  static TenantConfig get tenant {
    _ensureInitialized();
    return _config!;
  }

  static String get appName => tenant.appName;

  static Color get primaryColor => tenant.primaryColor;

  static Color get secondaryColor => tenant.secondaryColor;

  static String? get logoAssetPath => tenant.logoAssetPath;

  static String get baseUrl {
    _ensureInitialized();
    return _config!.odooBaseUrl;
  }

  static String get database {
    _ensureInitialized();
    return _config!.odooDatabase;
  }

  static const String apiVersion = '1.0';
  static String token = '';

  static const String xmlRpcEndpoint = '/xmlrpc/2/';
  static const String commonEndpoint = '/xmlrpc/2/common';
  static const String objectEndpoint = '/xmlrpc/2/object';

  static const int connectionTimeout = 30000;
  static const int readTimeout = 30000;
  static const int writeTimeout = 30000;

  static const int defaultPageSize = 20;

  static const String hrEmployeeModel = 'hr.employee';
  static const String hrAttendanceModel = 'hr.attendance';
  static const String hrExpenseModel = 'hr.expense';
  static const String hrExpenseSheetModel = 'hr.expense.sheet';
  static const String hrContractModel = 'hr.contract';
  static const String hrPayslipModel = 'hr.payslip';
  static const String hrLeaveModel = 'hr.leave';
  static const String hrExpenseCategoryModel = 'hr.expense.category';
  static const String hrWorkScheduleModel = 'hr.work.schedule';
  static const String hrProductProductModel = 'product.product';
  static const String methodSearchRead = 'search_read';
  static const String methodcreate = 'create';

  static String get serverRootUrl {
    var url = baseUrl;
    if (url.endsWith('/mobile/')) {
      return url.substring(0, url.length - '/mobile/'.length);
    }
    if (url.endsWith('/mobile')) {
      return url.substring(0, url.length - '/mobile'.length);
    }
    if (url.endsWith('/')) {
      return url.substring(0, url.length - 1);
    }
    return url;
  }

  static String get jsonRpcUrl => '${baseUrl}jsonrpc';

  static String mobileEndpoint(String path) {
    final normalized = path.startsWith('/') ? path.substring(1) : path;
    return '$baseUrl$normalized';
  }

  static String rootEndpoint(String path) {
    final normalized = path.startsWith('/') ? path.substring(1) : path;
    return '$serverRootUrl/$normalized';
  }

  static String apiV1Endpoint(String path) {
    final normalized = path.startsWith('/') ? path.substring(1) : path;
    return '$serverRootUrl/api/v1/$normalized';
  }

  static String getEndpointUrl(String endpoint) {
    return '$baseUrl$endpoint';
  }

  static String get commonUrl => getEndpointUrl(commonEndpoint);

  static String get objectUrl => getEndpointUrl(objectEndpoint);
}
