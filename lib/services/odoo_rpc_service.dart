import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hr_app_odoo/app/app_route.dart';
import 'package:hr_app_odoo/custom_widgets/custom_button/custom_button.dart';
import 'package:hr_app_odoo/custom_widgets/custom_dialog/custom_dialog.dart';
import 'package:hr_app_odoo/custom_widgets/custom_text/custom_text.dart';
import 'package:hr_app_odoo/models/hr_login.dart';
import 'package:http/http.dart' as http;
import '../config/odoo_config.dart';

class OdooRPCService {
  static OdooRPCService? _instance;
  static OdooRPCService get instance =>
      _instance ??= OdooRPCService._internal();

  OdooRPCService._internal();

  String? _sessionId;
  int? _userId;
  String? _database;
  String? _webSessionId; // For web API calls
  String? _username; // Store username for web session auth
  String? _password; // Store password for web session auth
  String? _mobileToken; // Store mobile token for Odoo.sh

  // Getter for authentication status
  bool get isAuthenticated => _sessionId != null && _userId != null;

  // Getter for current user ID
  int? get currentUserId {
    print('🔍 Getting current user ID: $_userId');
    return _userId;
  }

  // Getter for current database
  String? get currentDatabase => _database;

  // Getter for current password
  String? get currentPassword => _password;

  // Employee ID for the current user
  int? _currentEmployeeId;

  // Getter for current employee ID
  int? get currentEmployeeId => _currentEmployeeId;

  // Setter for current employee ID
  void setCurrentEmployeeId(int employeeId) {
    _currentEmployeeId = employeeId;
    print('✅ Current employee ID set to: $employeeId');
  }

  // Clear current employee ID
  void clearCurrentEmployeeId() {
    _currentEmployeeId = null;
    print('✅ Current employee ID cleared');
  }

  // Debug method to show current state
  void debugState() {
    print('🔍 Debug - OdooRPCService State:');
    print('   _userId: $_userId');
    print('   _currentEmployeeId: $_currentEmployeeId');
    print('   _sessionId: $_sessionId');
    print('   _database: $_database');
    print('   isAuthenticated: $isAuthenticated');
  }

  /// Authenticate with Odoo.sh using web session
  Future<HrLogin> authenticate({
    required String username,
    required String password,
    String? database,
  }) async {
    try {
      // Store credentials for web session authentication
      _username = username;
      _password = password;
      _database = database ?? OdooConfig.database;

      // First, get a web session for Odoo.sh compatibility
      await _getWebSession();

      // Then authenticate using web session
      final sessionUrl = Uri.parse(
        '${OdooConfig.baseUrl}web/session/authenticate',
      );

      final response = await http
          .post(
            sessionUrl,
            headers: {
              'Content-Type': 'application/json',
              'User-Agent': 'HR App Flutter Odoo.sh',
              'Accept': 'application/json',
              'Cookie': 'session_id=$_webSessionId',
            },
            body: json.encode({
              'jsonrpc': '2.0',
              'method': 'call',
              'params': {
                'db': _database,
                'login': username,
                'password': password,
              },
            }),
          )
          .timeout(Duration(milliseconds: OdooConfig.connectionTimeout));

      print('Response api: ${OdooConfig.baseUrl}web/session/authenticate');
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        try {
          final jsonResponse = json.decode(response.body);

          if (jsonResponse['error'] != null) {
            return HrLogin(
              success: false,
              error:
                  jsonResponse['error']['data']['message'] ??
                  'Authentication failed',
            );
            // return {
            //   'success': false,
            //   'error':
            //       jsonResponse['error']['data']['message'] ??
            //       'Authentication failed',
            // };
          }

          // Check if authentication was successful
          if (jsonResponse['result'] == null ||
              jsonResponse['result']['uid'] == null) {
            return HrLogin(
              success: false,
              error: 'Username or password is wrong',
            );
            // return {'success': false, 'error': 'Username or password is wrong'};
          }

          // Extract user ID from Odoo.sh web session response
          _userId = jsonResponse['result']['uid'] ?? 1;
          _sessionId = 'session_${DateTime.now().millisecondsSinceEpoch}';
          _mobileToken = jsonResponse['result']['mobile_token'] ?? '';
          OdooConfig.token = jsonResponse['result']['mobile_token'] ?? '';
          log(
            name: " OdooConfig_token",
            "Received mobile token: ${OdooConfig.token}",
          );
          print('✅ Odoo.sh web session authenticated successfully');

          return HrLogin(
            success: true,
            userId: _userId,
            sessionId: _sessionId,
            database: _database,
            userName: jsonResponse['result']['name'] ?? '',
            message: 'Authentication successful',
            mobileToken: _mobileToken,
          );

          // return {
          //   'success': true,
          //   'userId': _userId,
          //   'sessionId': _sessionId,
          //   'database': _database,
          //   'userName': jsonResponse['result']['name'] ?? '',
          //   'message': 'Authentication successful',
          // };
        } catch (e) {
          return HrLogin(success: false, error: 'Failed to parse response: $e');
          // return {'success': false, 'error': 'Failed to parse response: $e'};
        }
      } else {
        return HrLogin(
          success: false,
          error: 'HTTP Error: ${response.statusCode} - ${response.body}',
        );
        // return {
        //   'success': false,
        //   'error': 'HTTP Error: ${response.statusCode} - ${response.body}',
        // };
      }
    } catch (e) {
      print('Authentication error: $e');
      return HrLogin(success: false, error: e.toString());
      // return {'success': false, 'error': e.toString()};
    }
  }

  /// Execute RPC method on Odoo using standard JSON-RPC
  Future<Map<String, dynamic>> executeRPC({
    required String model,
    required String method,
    List<dynamic>? args,
    Map<String, dynamic>? kwargs,
  }) async {
    if (!isAuthenticated) {
      throw Exception('Not authenticated. Please login first.');
    }

    try {
      final url = Uri.parse('${OdooConfig.baseUrl}/jsonrpc');

      final response = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'User-Agent': 'HR App Flutter Odoo.sh',
              'Accept': 'application/json',
              'X-Requested-With': 'XMLHttpRequest',
            },
            body: json.encode({
              'jsonrpc': '2.0',
              'method': 'call',
              'params': {
                'service': 'object',
                'method': 'execute_kw',
                'args': [
                  _database,
                  _userId,
                  _password,
                  model,
                  method,
                  args ?? [],
                  kwargs ?? {},
                ],
              },
            }),
          )
          .timeout(Duration(milliseconds: OdooConfig.readTimeout));

      if (response.statusCode == 200) {
        try {
          final jsonResponse = json.decode(response.body);

          if (jsonResponse['error'] != null) {
            return {
              'success': false,
              'error': jsonResponse['error']['data']['message'] ?? 'RPC failed',
            };
          }

          return {'success': true, 'data': jsonResponse['result'] ?? []};
        } catch (e) {
          return {
            'success': false,
            'error': 'Failed to parse JSON response: $e',
          };
        }
      } else {
        return {
          'success': false,
          'error': 'HTTP Error: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Search and read records from Odoo using standard JSON-RPC
  Future<Map<String, dynamic>> searchRead({
    required String model,
    List<List<dynamic>>? domain,
    List<String>? fields,
    int? limit,
    int? offset,
    String? order,
  }) async {
    if (!isAuthenticated) {
      throw Exception('Not authenticated. Please login first.');
    }

    try {
      // For Odoo.sh, we need to use the standard JSON-RPC endpoint with proper session context
      final url = Uri.parse('${OdooConfig.baseUrl}jsonrpc');
      log(
        name: 'OdooRPCServiceData',
        'database: $_database,token: $_mobileToken, model: $model, fields: $fields,limit: $limit',
      );
      final response = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'User-Agent': 'HR App Flutter Odoo.sh',
              'Accept': 'application/json',
              'X-Requested-With': 'XMLHttpRequest',
            },
            body: json.encode({
              'jsonrpc': '2.0',
              'method': 'call',
              'params': {
                'service': 'object',
                'method': 'execute_kw',
                'args': [
                  _database,
                  1,
                  OdooConfig.token,
                  model,
                  "search_read",
                  [[]],
                  {
                    "fields": fields ?? [],
                    "limit": limit ?? OdooConfig.defaultPageSize,
                  },
                ],

                // [
                //   _database,
                //   _mobileToken,
                //   model,
                //   1,
                //   "search_read",
                //   [[]],
                //   {
                //     "fields": fields ?? [],
                //     "order": order ?? "",
                //     "limit": limit ?? OdooConfig.defaultPageSize,
                //   },
                // ],
              },
            }),
          )
          .timeout(Duration(milliseconds: OdooConfig.readTimeout));

      print('🔍 Odoo.sh searchRead response status: ${response.statusCode}');
      print('🔍 Odoo.sh searchRead response body: ${response.body}');

      if (response.statusCode == 200) {
        try {
          final jsonResponse = json.decode(response.body);

          if (jsonResponse['error'] != null) {
            if (jsonResponse['error']['data']['message'] ==
                    'Invalid mobile session' ||
                jsonResponse['error']['message'] == 'Odoo Server Error') {
              log(
                name: 'OdooRPCService',
                'Session expired or invalid. Redirecting to login.',
              );
              Get.offNamed(AppRoutes.login);
              // await CustomDialog.loginAgainDialog(
              //   jsonResponse['error']['data']['message'],
              // );
            }
            return {
              'success': false,
              'error':
                  jsonResponse['error']['data']['message'] ?? 'Search failed',
            };
          }

          return {'success': true, 'data': jsonResponse['result'] ?? []};
        } catch (e) {
          return {
            'success': false,
            'error': 'Failed to parse JSON response: $e',
          };
        }
      } else {
        return {
          'success': false,
          'error': 'HTTP Error: ${response.statusCode} - ${response.body}',
        };
      }
    } catch (e) {
      print('🔍 Odoo.sh searchRead error: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Create a new record in Odoo
  Future<Map<String, dynamic>> create({
    required String model,
    required Map<String, dynamic> values,
  }) async {
    if (!isAuthenticated) {
      throw Exception('Not authenticated. Please login first.');
    }

    try {
      // For Odoo.sh, we need to use the standard JSON-RPC endpoint with proper session context
      final url = Uri.parse('${OdooConfig.baseUrl}/jsonrpc');

      final response = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'User-Agent': 'HR App Flutter Odoo.sh',
              'Accept': 'application/json',
              'X-Requested-With': 'XMLHttpRequest',
            },
            body: json.encode({
              'jsonrpc': '2.0',
              'method': 'call',
              'params': {
                'service': 'object',
                'method': 'execute_kw',
                'args': [
                  _database,
                  _userId,
                  _password,
                  model,
                  'create',
                  [values],
                  {},
                ],
              },
            }),
          )
          .timeout(Duration(milliseconds: OdooConfig.writeTimeout));

      print('🔍 Odoo.sh create response status: ${response.statusCode}');
      print('🔍 Odoo.sh create response body: ${response.body}');

      if (response.statusCode == 200) {
        try {
          final jsonResponse = json.decode(response.body);

          if (jsonResponse['error'] != null) {
            return {
              'success': false,
              'error':
                  jsonResponse['error']['data']['message'] ?? 'Create failed',
            };
          }

          return {'success': true, 'data': jsonResponse['result'] ?? []};
        } catch (e) {
          return {
            'success': false,
            'error': 'Failed to parse JSON response: $e',
          };
        }
      } else {
        return {
          'success': false,
          'error': 'HTTP Error: ${response.statusCode} - ${response.body}',
        };
      }
    } catch (e) {
      print('🔍 Odoo.sh create error: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Create a new record in Odoo using sudo (admin privileges)
  Future<Map<String, dynamic>> createWithSudo({
    required String model,
    required Map<String, dynamic> values,
  }) async {
    if (!isAuthenticated) {
      throw Exception('Not authenticated. Please login first.');
    }

    try {
      // Try multiple approaches for Odoo.sh compatibility

      // Approach 1: Try with standard JSON-RPC and sudo context
      final url = Uri.parse('${OdooConfig.baseUrl}/jsonrpc');

      final requestBody = {
        'jsonrpc': '2.0',
        'method': 'call',
        'params': {
          'service': 'object',
          'method': 'execute_kw',
          'args': [
            _database,
            _userId,
            _password,
            model,
            'create',
            [values],
            {
              'context': {'sudo': true, 'force_sudo': true},
            },
          ],
        },
      };

      print('🔍 Odoo.sh Web Session Request Details:');
      print('🔍 URL: $url');
      print('🔍 Database: $_database');
      print('🔍 User ID: $_userId');
      print('🔍 Session ID: $_sessionId');
      print('🔍 Model: $model');
      print('🔍 Values: $values');
      print('🔍 Full Request Body: ${json.encode(requestBody)}');

      final response = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'User-Agent': 'HR App Flutter Odoo.sh',
              'Accept': 'application/json',
              'Cookie': 'session_id=$_webSessionId', // Use web session cookie
            },
            body: json.encode(requestBody),
          )
          .timeout(Duration(milliseconds: OdooConfig.readTimeout));

      print(
        '🔍 Odoo.sh createWithSudo response status: ${response.statusCode}',
      );
      print('🔍 Odoo.sh createWithSudo response body: ${response.body}');

      if (response.statusCode == 200) {
        try {
          final jsonResponse = json.decode(response.body);

          if (jsonResponse['error'] != null) {
            print(
              '❌ Odoo.sh web session approach 1 failed: ${jsonResponse['error']}',
            );

            // Approach 2: Try Odoo.sh specific context
            print('🔄 Trying approach 2: Odoo.sh specific context...');
            final odooShResult = await _tryOdooShSpecificContext(model, values);
            if (odooShResult['success']) return odooShResult;

            // Approach 3: Try without sudo context but with admin user
            print('🔄 Trying approach 3: Direct admin access...');
            return await _tryDirectAdminAccess(model, values);
          }

          return {'success': true, 'data': jsonResponse['result'] ?? []};
        } catch (e) {
          print('❌ Failed to parse JSON response: $e');
          return {
            'success': false,
            'error': 'Failed to parse JSON response: $e',
          };
        }
      } else {
        return {
          'success': false,
          'error': 'HTTP Error: ${response.statusCode} - ${response.body}',
        };
      }
    } catch (e) {
      print('🔍 Odoo.sh createWithSudo error: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Try Odoo.sh specific context approach
  Future<Map<String, dynamic>> _tryOdooShSpecificContext(
    String model,
    Map<String, dynamic> values,
  ) async {
    try {
      print('🔍 Trying Odoo.sh specific context approach...');
      final url = Uri.parse('${OdooConfig.baseUrl}/jsonrpc');

      final response = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'User-Agent': 'HR App Flutter Odoo.sh',
              'Accept': 'application/json',
              'X-Requested-With': 'XMLHttpRequest',
            },
            body: json.encode({
              'jsonrpc': '2.0',
              'method': 'call',
              'params': {
                'service': 'object',
                'method': 'execute_kw',
                'args': [
                  _database,
                  _userId,
                  _password,
                  model,
                  'create',
                  [values],
                  {
                    'context': {'sudo': true},
                  },
                ],
              },
            }),
          )
          .timeout(Duration(milliseconds: OdooConfig.writeTimeout));

      print(
        '🔍 Odoo.sh specific context response status: ${response.statusCode}',
      );
      print('🔍 Odoo.sh specific context response body: ${response.body}');

      if (response.statusCode == 200) {
        try {
          final jsonResponse = json.decode(response.body);

          if (jsonResponse['error'] != null) {
            return {
              'success': false,
              'error':
                  jsonResponse['error']['data']['message'] ??
                  'Odoo.sh specific context failed',
            };
          }

          return {'success': true, 'data': jsonResponse['result'] ?? []};
        } catch (e) {
          return {
            'success': false,
            'error': 'Failed to parse JSON response: $e',
          };
        }
      } else {
        return {
          'success': false,
          'error': 'HTTP Error: ${response.statusCode} - ${response.body}',
        };
      }
    } catch (e) {
      print('🔍 Odoo.sh specific context error: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Try direct admin access without sudo context
  Future<Map<String, dynamic>> _tryDirectAdminAccess(
    String model,
    Map<String, dynamic> values,
  ) async {
    try {
      final url = Uri.parse('${OdooConfig.baseUrl}/jsonrpc');

      final response = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'User-Agent': 'HR App Flutter Odoo.sh',
              'Accept': 'application/json',
              'X-Requested-With': 'XMLHttpRequest',
            },
            body: json.encode({
              'jsonrpc': '2.0',
              'method': 'call',
              'params': {
                'service': 'object',
                'method': 'execute_kw',
                'args': [
                  _database,
                  _userId,
                  _password,
                  model,
                  'create',
                  [values],
                  {}, // No special context
                ],
              },
            }),
          )
          .timeout(Duration(milliseconds: OdooConfig.writeTimeout));

      print(
        '🔍 Odoo.sh direct admin access response status: ${response.statusCode}',
      );
      print('🔍 Odoo.sh direct admin access response body: ${response.body}');

      if (response.statusCode == 200) {
        try {
          final jsonResponse = json.decode(response.body);

          if (jsonResponse['error'] != null) {
            return {
              'success': false,
              'error':
                  jsonResponse['error']['data']['message'] ??
                  'Direct admin access failed',
            };
          }

          return {'success': true, 'data': jsonResponse['result'] ?? []};
        } catch (e) {
          return {
            'success': false,
            'error': 'Failed to parse JSON response: $e',
          };
        }
      } else {
        return {
          'success': false,
          'error': 'HTTP Error: ${response.statusCode} - ${response.body}',
        };
      }
    } catch (e) {
      print('🔍 Odoo.sh direct admin access error: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Update an existing record in Odoo
  Future<Map<String, dynamic>> write({
    required String model,
    required int recordId,
    required Map<String, dynamic> values,
  }) async {
    return await executeRPC(
      model: model,
      method: 'write',
      args: [
        [recordId],
        values,
      ],
    );
  }

  /// Delete a record from Odoo
  Future<Map<String, dynamic>> delete({
    required String model,
    required int recordId,
  }) async {
    return await executeRPC(
      model: model,
      method: 'unlink',
      args: [
        [recordId],
      ],
    );
  }

  /// Get current user information
  Future<Map<String, dynamic>> getCurrentUser() async {
    if (!isAuthenticated) {
      throw Exception('Not authenticated');
    }

    return await searchRead(
      model: 'res.users',
      domain: [
        ['id', '=', _userId],
      ],
      fields: ['id', 'name', 'login', 'email', 'image_128'],
    );
  }

  /// Logout and clear session
  void logout() {
    _sessionId = null;
    _userId = null;
    _database = null;
    _webSessionId = null;
    _username = null;
    _password = null;
    clearCurrentEmployeeId();
  }

  /// Clear current session data (for logout or session termination)
  void clearSession() {
    _sessionId = null;
    _userId = null;
    _database = null;
    _webSessionId = null;
    _username = null;
    _password = null;
    clearCurrentEmployeeId();
    print('✅ Session data cleared completely');
  }

  /// Get a web session for API calls
  Future<void> _getWebSession() async {
    try {
      // First, get the session cookie by visiting the web interface
      final webUrl = Uri.parse('${OdooConfig.baseUrl}/web');
      final webResponse = await http.get(
        webUrl,
        headers: {'User-Agent': 'HR App Flutter Odoo.sh'},
      );

      if (webResponse.statusCode == 200) {
        // Extract session ID from cookies or response
        final cookies = webResponse.headers['set-cookie'];
        if (cookies != null) {
          // Look for session_id in cookies
          final sessionMatch = RegExp(
            r'session_id=([^;]+)',
          ).firstMatch(cookies);
          if (sessionMatch != null) {
            _webSessionId = sessionMatch.group(1);
            print('🔐 Web session ID obtained: $_webSessionId');
          }
        }

        // If no session ID in cookies, try to get it from the response
        if (_webSessionId == null) {
          final body = webResponse.body;
          final sessionMatch = RegExp(
            r'"session_id":\s*"([^"]+)"',
          ).firstMatch(body);
          if (sessionMatch != null) {
            _webSessionId = sessionMatch.group(1);
            print('🔐 Web session ID extracted from response: $_webSessionId');
          }
        }
      }

      // Now authenticate the web session
      if (_webSessionId != null) {
        await _authenticateWebSession();
      }
    } catch (e) {
      print('⚠️ Warning: Could not get web session: $e');
    }
  }

  /// Authenticate the web session with user credentials
  Future<void> _authenticateWebSession() async {
    try {
      // Use the web session/authenticate endpoint
      final authUrl = Uri.parse(
        '${OdooConfig.baseUrl}/web/session/authenticate',
      );

      final response = await http.post(
        authUrl,
        headers: {
          'Content-Type': 'application/json',
          'User-Agent': 'HR App Flutter Odoo.sh',
          'Accept': 'application/json',
          'Cookie': 'session_id=$_webSessionId',
        },
        body: json.encode({
          'jsonrpc': '2.0',
          'method': 'call',
          'params': {
            'db': _database,
            'login': _username,
            'password': _password,
          },
        }),
      );

      print(
        '🔐 Web session authentication response status: ${response.statusCode}',
      );
      print('🔐 Web session authentication response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['error'] == null) {
          print('✅ Web session authenticated successfully');
        } else {
          print(
            '❌ Web session authentication failed: ${jsonResponse['error']}',
          );
        }
      }
    } catch (e) {
      print('⚠️ Warning: Could not authenticate web session: $e');
    }
  }

  /// Test connection to Odoo.sh server
  Future<Map<String, dynamic>> testConnection() async {
    try {
      final url = Uri.parse('${OdooConfig.baseUrl}/web');

      final response = await http
          .get(url, headers: {'User-Agent': 'HR App Flutter Odoo.sh'})
          .timeout(Duration(milliseconds: 10000));

      return {
        'success': response.statusCode == 200,
        'statusCode': response.statusCode,
        'message': response.statusCode == 200
            ? 'Odoo.sh server is reachable'
            : 'Odoo.sh server returned ${response.statusCode}',
      };
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Print user permissions and access details
  Future<void> printUserPermissions() async {
    if (!isAuthenticated) {
      print('❌ Not authenticated. Please login first.');
      return;
    }

    print('\n🔐 === USER PERMISSIONS REPORT ===');
    print('👤 User ID: $_userId');
    print('🌐 Database: $_database');
    print('🔑 Web Session ID: $_webSessionId');
    print('📅 Session Time: ${DateTime.now()}');
    print('');

    try {
      // Test basic model access
      final modelsToTest = [
        'res.users',
        'res.partner',
        'hr.employee',
        'hr.expense',
        'hr.expense.category',
        'ir.model',
        'ir.model.fields',
        'note.note',
        'mail.thread',
        'res.company',
      ];

      print('🔍 Testing model access...');
      for (final model in modelsToTest) {
        try {
          final result = await searchRead(
            model: model,
            domain: [],
            fields: ['id'],
            limit: 1,
          );

          if (result['success']) {
            print('✅ $model: ACCESSIBLE');
            if (result['data'] != null && result['data'].isNotEmpty) {
              print('   📊 Records found: ${result['data'].length}');
            }
          } else {
            print('❌ $model: ${result['error']}');
          }
        } catch (e) {
          print('❌ $model: ERROR - $e');
        }
      }

      print('');
      print('🔍 Testing create permissions...');
      final createTestModels = ['res.partner', 'note.note', 'mail.thread'];

      for (final model in createTestModels) {
        try {
          final testData = {
            'name':
                'Test Permission Check - ${DateTime.now().millisecondsSinceEpoch}',
          };

          final result = await create(model: model, values: testData);

          if (result['success']) {
            print('✅ $model: CREATE ALLOWED');
            print('   🆔 Created ID: ${result['data']}');
          } else {
            print('❌ $model: CREATE DENIED - ${result['error']}');
          }
        } catch (e) {
          print('❌ $model: CREATE ERROR - $e');
        }
      }

      print('');
      print('🔍 Testing sudo permissions...');
      try {
        final sudoResult = await createWithSudo(
          model: 'res.partner',
          values: {
            'name': 'Sudo Test - ${DateTime.now().millisecondsSinceEpoch}',
            'is_company': false,
          },
        );

        if (sudoResult['success']) {
          print('✅ Sudo access: WORKING');
          print('   🆔 Created ID: ${sudoResult['data']}');
        } else {
          print('❌ Sudo access: FAILED - ${sudoResult['error']}');
        }
      } catch (e) {
        print('❌ Sudo access: ERROR - $e');
      }

      print('');
      print('🔍 Testing user context...');
      try {
        final userResult = await searchRead(
          model: 'res.users',
          domain: [
            ['id', '=', _userId],
          ],
          fields: ['id', 'name', 'login', 'groups_id', 'is_admin', 'is_system'],
          limit: 1,
        );

        if (userResult['success'] &&
            userResult['data'] != null &&
            userResult['data'].isNotEmpty) {
          final user = userResult['data'][0];
          print('👤 User Name: ${user['name']}');
          print('📧 Login: ${user['login']}');
          print('🔑 Is Admin: ${user['is_admin']}');
          print('⚙️ Is System: ${user['is_system']}');
          print('👥 Groups: ${user['groups_id']}');
        } else {
          print('❌ Could not fetch user details: ${userResult['error']}');
        }
      } catch (e) {
        print('❌ User context error: $e');
      }

      print('');
      print('🔍 Testing database info...');
      try {
        final dbResult = await searchRead(
          model: 'ir.module.module',
          domain: [
            ['state', '=', 'installed'],
          ],
          fields: ['name', 'state'],
          limit: 5,
        );

        if (dbResult['success']) {
          print('📦 Installed modules: ${dbResult['data']?.length ?? 0}');
          if (dbResult['data'] != null) {
            for (final module in dbResult['data'].take(3)) {
              print('   📋 ${module['name']} (${module['state']})');
            }
          }
        } else {
          print('❌ Could not fetch modules: ${dbResult['error']}');
        }
      } catch (e) {
        print('❌ Database info error: $e');
      }

      print('');
      print('🔐 === END PERMISSIONS REPORT ===');
      print('');
    } catch (e) {
      print('❌ Error generating permissions report: $e');
    }
  }

  /// Track successful login time
  Future<void> trackLoginTime() async {
    if (!isAuthenticated || _userId == null) {
      print('❌ Cannot track login time: not authenticated or no user ID');
      return;
    }

    try {
      print('📅 Tracking login time for user $_userId');

      // Format datetime for Odoo (YYYY-MM-DD HH:MM:SS)
      final now = DateTime.now();
      final formattedDateTime =
          '${now.year.toString().padLeft(4, '0')}-'
          '${now.month.toString().padLeft(2, '0')}-'
          '${now.day.toString().padLeft(2, '0')} '
          '${now.hour.toString().padLeft(2, '0')}:'
          '${now.minute.toString().padLeft(2, '0')}:'
          '${now.second.toString().padLeft(2, '0')}';

      // Update user's login date and last activity
      final result = await write(
        model: 'res.users',
        recordId: _userId!,
        values: {
          'login_date': formattedDateTime,
          'last_activity': formattedDateTime,
        },
      );

      if (result['success']) {
        print('✅ Login time tracked successfully');
      } else {
        print('❌ Failed to track login time: ${result['error']}');
      }
    } catch (e) {
      print('❌ Error tracking login time: $e');
    }
  }

  /// Get current session information
  Future<Map<String, dynamic>> getSessionInfo() async {
    if (!isAuthenticated || _userId == null) {
      return {'success': false, 'error': 'Not authenticated or no user ID'};
    }

    try {
      print('🔍 Getting session info for user $_userId');

      // Get user session details
      final result = await searchRead(
        model: 'res.users',
        domain: [
          ['id', '=', _userId],
        ],
        fields: [
          'id',
          'name',
          'login',
          'login_date',
          'last_activity',
          'active',
        ],
        limit: 1,
      );

      if (result['success'] &&
          result['data'] != null &&
          result['data'].isNotEmpty) {
        final user = result['data'][0];
        final loginDate = user['login_date'];
        final lastActivity = user['last_activity'];

        // Calculate session duration
        Duration? sessionDuration;
        DateTime? loginTime;

        if (loginDate != null) {
          try {
            loginTime = DateTime.parse(loginDate);
            final now = DateTime.now();
            sessionDuration = now.difference(loginTime);
          } catch (e) {
            print('❌ Error parsing login date: $e');
          }
        }

        // Check if session is active (within last 24 hours)
        final isActive =
            lastActivity != null &&
            DateTime.now().difference(DateTime.parse(lastActivity)).inHours <
                24;

        return {
          'success': true,
          'data': {
            'user_id': _userId,
            'user_name': user['name'],
            'login': user['login'],
            'login_time': loginTime?.toIso8601String(),
            'last_activity': lastActivity,
            'session_duration': sessionDuration?.toString(),
            'is_active': isActive,
            'web_session_id': _webSessionId,
            'database': _database,
          },
        };
      } else {
        return {'success': false, 'error': 'Could not fetch user session info'};
      }
    } catch (e) {
      print('❌ Error getting session info: $e');
      return {'success': false, 'error': 'Exception: $e'};
    }
  }

  /// Terminate current session
  Future<Map<String, dynamic>> terminateSession({
    bool clearCurrentSession = false,
  }) async {
    if (!isAuthenticated || _userId == null) {
      return {'success': false, 'error': 'Not authenticated or no user ID'};
    }

    try {
      print('🔄 Terminating session for user $_userId');

      // Update user's last activity to indicate session termination
      final result = await write(
        model: 'res.users',
        recordId: _userId!,
        values: {'last_activity': DateTime.now().toIso8601String()},
      );

      if (result['success']) {
        // Only clear local session data if explicitly requested
        if (clearCurrentSession) {
          clearSession();
          print('✅ Session terminated and cleared successfully');
        } else {
          print('✅ Session terminated successfully (keeping current session)');
        }

        return {'success': true, 'message': 'Session terminated successfully'};
      } else {
        return {'success': false, 'error': 'Failed to update user activity'};
      }
    } catch (e) {
      print('❌ Error terminating session: $e');
      return {'success': false, 'error': 'Exception: $e'};
    }
  }

  /// Build XML request for authentication
  String _buildAuthenticateRequest(
    String username,
    String password,
    String database,
  ) {
    return '''<?xml version="1.0"?>
<methodCall>
  <methodName>authenticate</methodName>
  <params>
    <param>
      <value><string>$database</string></value>
    </param>
    <param>
      <value><string>$username</string></value>
    </param>
    <param>
      <value><string>$password</string></value>
    </param>
    <param>
      <value><struct></struct></value>
    </param>
  </params>
</methodCall>''';
  }

  /// Build XML request for method execution
  String _buildExecuteRequest(
    String model,
    String method,
    List<dynamic> args,
    Map<String, dynamic> kwargs,
  ) {
    final argsXml = args.map((arg) => _valueToXml(arg)).join('');
    final kwargsXml = kwargs.entries
        .map(
          (entry) =>
              '<member><name>${entry.key}</name>${_valueToXml(entry.value)}</member>',
        )
        .join('');

    return '''<?xml version="1.0"?>
<methodCall>
  <methodName>execute_kw</methodName>
  <params>
    <param>
      <value><string>$_database</string></value>
    </param>
    <param>
      <value><int>$_userId</int></value>
    </param>
    <param>
      <value><string>$_sessionId</string></value>
    </param>
    <param>
      <value><string>$model</string></value>
    </param>
    <param>
      <value><string>$method</string></value>
    </param>
    <param>
      <value><array><data>$argsXml</data></array></value>
    </param>
    <param>
      <value><struct>$kwargsXml</struct></value>
    </param>
  </params>
</methodCall>''';
  }

  /// Convert Dart value to XML value
  String _valueToXml(dynamic value) {
    if (value == null) return '<value><nil/></value>';
    if (value is String) return '<value><string>$value</string></value>';
    if (value is int) return '<value><int>$value</int></value>';
    if (value is double) return '<value><double>$value</double></value>';
    if (value is bool)
      return '<value><boolean>${value ? 1 : 0}</boolean></value>';
    if (value is List) {
      final items = value.map((item) => _valueToXml(item)).join('');
      return '<value><array><data>$items</data></array></value>';
    }
    if (value is Map) {
      final members = value.entries
          .map(
            (entry) =>
                '<member><name>${entry.key}</name>${_valueToXml(entry.value)}</member>',
          )
          .join('');
      return '<value><struct>$members</struct></value>';
    }
    return '<value><string>${value.toString()}</string></value>';
  }

  /// Parse XML response from Odoo
  Map<String, dynamic> _parseXmlResponse(String xmlResponse) {
    // This is a simplified XML parser for Odoo responses
    // In production, you might want to use a proper XML parser
    try {
      // Remove XML tags and extract the response data
      final cleanResponse = xmlResponse
          .replaceAll(RegExp(r'<[^>]*>'), '')
          .replaceAll(RegExp(r'\s+'), ' ')
          .trim();

      // For now, return a basic structure
      // You'll need to implement proper XML parsing based on your needs
      return {
        'success': true,
        'raw': cleanResponse,
        'param': {
          'value': {
            'array': {
              'data': {'value': []},
            },
          },
        },
      };
    } catch (e) {
      return {'success': false, 'error': 'Failed to parse XML response: $e'};
    }
  }
}
