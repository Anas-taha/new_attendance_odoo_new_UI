# دليل التحويل من JSON-RPC إلى REST API

## هل يمكن التحويل بسهولة؟

**نعم، يمكن التحويل!** لكن يحتاج:
1. **تغيير في Odoo Server** (إضافة REST API endpoints)
2. **تغيير في Flutter App** (تعديل Service layer)

## الاستراتيجية الموصى بها

### ✅ أفضل طريقة: Abstraction Layer (طبقة تجريد)

إنشاء **interface** يخفي تفاصيل التنفيذ:

```
┌─────────────────┐
│  UI Layer       │  ← لا يتغير
├─────────────────┤
│  Service Layer  │  ← يتغير فقط هنا
│  (Abstraction)  │
├─────────────────┤
│  API Client     │  ← يتغير هنا
│  (RPC or REST)  │
└─────────────────┘
```

## التصميم الحالي

### المشكلة الحالية:
```dart
// الكود الحالي مرتبط بـ JSON-RPC مباشرة
class OdooRPCService {
  Future<Map<String, dynamic>> executeRPC({...}) {
    // JSON-RPC implementation
  }
}
```

### الحل: Interface Pattern

#### 1. إنشاء Interface
```dart
// lib/services/api_client_interface.dart
abstract class OdooApiClient {
  Future<Map<String, dynamic>> authenticate({
    required String username,
    required String password,
    String? database,
  });
  
  Future<Map<String, dynamic>> searchRead({
    required String model,
    List<List<dynamic>>? domain,
    List<String>? fields,
    int? limit,
    int? offset,
    String? order,
  });
  
  Future<Map<String, dynamic>> create({
    required String model,
    required Map<String, dynamic> values,
  });
  
  // ... باقي الدوال
}
```

#### 2. Implementation للـ JSON-RPC (الحالي)
```dart
// lib/services/odoo_rpc_client.dart
class OdooRpcClient implements OdooApiClient {
  @override
  Future<Map<String, dynamic>> searchRead({...}) {
    // JSON-RPC implementation
  }
}
```

#### 3. Implementation للـ REST API (المستقبلي)
```dart
// lib/services/odoo_rest_client.dart
class OdooRestClient implements OdooApiClient {
  @override
  Future<Map<String, dynamic>> searchRead({...}) {
    // REST API implementation
    // GET /api/hr/employees?domain=...
  }
}
```

#### 4. Service Layer يستخدم Interface
```dart
// lib/services/hr_service.dart
class HrService {
  final OdooApiClient _apiClient;
  
  HrService({OdooApiClient? apiClient}) 
    : _apiClient = apiClient ?? OdooRpcClient.instance;
  
  Future<List<Employee>> getEmployees() async {
    final result = await _apiClient.searchRead(
      model: 'hr.employee',
      // ...
    );
    // ...
  }
}
```

## مثال التحويل

### JSON-RPC (الحالي)
```dart
POST /jsonrpc
{
  "jsonrpc": "2.0",
  "method": "call",
  "params": {
    "service": "object",
    "method": "execute_kw",
    "args": [
      "database",
      userId,
      password,
      "hr.employee",
      "search_read",
      [[], ["name", "email"], 0, 20]
    ]
  }
}
```

### REST API (المستقبلي)
```dart
GET /api/v1/hr/employees?fields=name,email&limit=20
Headers: Authorization: Bearer token123
```

## خطوات التحويل

### المرحلة 1: إعداد Odoo Server
```python
# في Odoo، إضافة REST API endpoints
from odoo import http
from odoo.http import request

class HrEmployeeAPI(http.Controller):
    @http.route('/api/v1/hr/employees', auth='user', methods=['GET'])
    def get_employees(self, **kwargs):
        # REST API implementation
        pass
```

### المرحلة 2: تحديث Flutter App

#### أ) إنشاء REST Client
```dart
class OdooRestClient implements OdooApiClient {
  final Dio dio;
  String? _accessToken;
  
  OdooRestClient() : dio = Dio() {
    dio.options.baseUrl = OdooConfig.baseUrl;
    dio.interceptors.add(AuthInterceptor());
  }
  
  @override
  Future<Map<String, dynamic>> searchRead({
    required String model,
    List<List<dynamic>>? domain,
    List<String>? fields,
    int? limit,
    int? offset,
    String? order,
  }) async {
    final response = await dio.get(
      '/api/v1/$model',
      queryParameters: {
        'fields': fields?.join(','),
        'limit': limit,
        'offset': offset,
        'order': order,
      },
    );
    return {'success': true, 'data': response.data};
  }
}
```

#### ب) تبديل Implementation
```dart
// في OdooConfig أو Environment
enum ApiType { jsonRpc, rest }

class ApiFactory {
  static OdooApiClient createClient(ApiType type) {
    switch (type) {
      case ApiType.jsonRpc:
        return OdooRpcClient.instance;
      case ApiType.rest:
        return OdooRestClient();
    }
  }
}

// في main.dart أو config
final apiClient = ApiFactory.createClient(
  ApiType.rest, // أو jsonRpc
);
```

## الفروقات الرئيسية

| الميزة | JSON-RPC | REST API |
|--------|----------|----------|
| **Endpoint** | `/jsonrpc` (واحد) | `/api/v1/model` (متعدد) |
| **HTTP Method** | POST فقط | GET, POST, PUT, DELETE |
| **Authentication** | في body | في headers (Bearer token) |
| **Request Format** | JSON-RPC 2.0 | JSON عادي |
| **Response Format** | `{result: [...]}` | `[{...}, {...}]` |
| **Error Handling** | `{error: {...}}` | HTTP status codes |

## الخطة الموصى بها

### ✅ الخطوة 1: إنشاء Interface (الآن)
- إنشاء `OdooApiClient` interface
- Refactor الكود الحالي لاستخدام interface

### ✅ الخطوة 2: إعداد Odoo Server (لاحقاً)
- إضافة REST API endpoints في Odoo
- إعداد authentication (JWT/Bearer token)

### ✅ الخطوة 3: إنشاء REST Client (لاحقاً)
- إنشاء `OdooRestClient` implementation
- اختبار REST API

### ✅ الخطوة 4: التبديل (لاحقاً)
- تغيير `ApiFactory` لاستخدام REST
- اختبار شامل

## مثال كامل: Interface Pattern

```dart
// 1. Interface
abstract class OdooApiClient {
  Future<Map<String, dynamic>> authenticate({...});
  Future<Map<String, dynamic>> searchRead({...});
  Future<Map<String, dynamic>> create({...});
}

// 2. JSON-RPC Implementation
class OdooRpcClient implements OdooApiClient {
  // Current implementation
}

// 3. REST Implementation
class OdooRestClient implements OdooApiClient {
  // Future REST implementation
}

// 4. Factory
class ApiFactory {
  static OdooApiClient create() {
    // يمكن التبديل بسهولة
    return OdooRpcClient.instance; // أو OdooRestClient()
  }
}

// 5. Service Layer
class HrService {
  final OdooApiClient _client = ApiFactory.create();
  // باقي الكود لا يتغير!
}
```

## الخلاصة

✅ **Dio vs HTTP:** لا فرق في النتيجة، لكن Dio أفضل للمستقبل

✅ **JSON-RPC → REST:** ممكن بسهولة مع Interface Pattern

✅ **الخطوة التالية:** إنشاء Interface الآن للتحضير للمستقبل
