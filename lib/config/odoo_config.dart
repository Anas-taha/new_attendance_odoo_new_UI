import 'package:hr_app_odoo/config/tenant_config.dart';

class OdooConfig {
  static String get baseUrl => TenantConfig.odooBaseUrl;
  static String get database => TenantConfig.odooDatabase;
  static const String apiVersion = '1.0';
  static String token = '';
  // API endpoints
  static const String xmlRpcEndpoint = '/xmlrpc/2/';
  static const String commonEndpoint = '/xmlrpc/2/common';
  static const String objectEndpoint = '/xmlrpc/2/object';

  // Authentication timeout
  static const int connectionTimeout = 30000; // 30 seconds
  static const int readTimeout = 30000; // 30 seconds
  static const int writeTimeout = 30000; // 30 seconds for write operations

  // Default page size for records
  static const int defaultPageSize = 20;

  // HR Models
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
  // Hr Model
  static const String methodSearchRead = "search_read";
  static const String methodcreate = 'create';

  /// Root server URL without the `/mobile/` API prefix.
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

  /// POST {{base_url}}/mobile/jsonrpc (no double slash).
  static String get jsonRpcUrl => '${baseUrl}jsonrpc';

  /// POST {{base_url}}/mobile/{path}
  static String mobileEndpoint(String path) {
    final normalized = path.startsWith('/') ? path.substring(1) : path;
    return '$baseUrl$normalized';
  }

  /// POST {{base_url}}/{path} — e.g. /submit_face, /face_attendance
  static String rootEndpoint(String path) {
    final normalized = path.startsWith('/') ? path.substring(1) : path;
    return '$serverRootUrl/$normalized';
  }

  /// GET/POST {{server_root}}/api/v1/{path}
  static String apiV1Endpoint(String path) {
    final normalized = path.startsWith('/') ? path.substring(1) : path;
    return '$serverRootUrl/api/v1/$normalized';
  }

  /// Get the full URL for a specific endpoint
  static String getEndpointUrl(String endpoint) {
    return '$baseUrl$endpoint';
  }

  /// Get common endpoint URL
  static String get commonUrl => getEndpointUrl(commonEndpoint);

  /// Get object endpoint URL
  static String get objectUrl => getEndpointUrl(objectEndpoint);
}
