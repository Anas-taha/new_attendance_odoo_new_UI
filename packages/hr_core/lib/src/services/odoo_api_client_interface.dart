/// Interface for Odoo API clients
/// This allows switching between JSON-RPC and REST API implementations
abstract class OdooApiClient {
  /// Authenticate with Odoo server
  Future<Map<String, dynamic>> authenticate({
    required String username,
    required String password,
    String? database,
  });

  /// Execute a search_read operation
  Future<Map<String, dynamic>> searchRead({
    required String model,
    List<List<dynamic>>? domain,
    List<String>? fields,
    int? limit,
    int? offset,
    String? order,
  });

  /// Create a new record
  Future<Map<String, dynamic>> create({
    required String model,
    required Map<String, dynamic> values,
  });

  /// Update an existing record
  Future<Map<String, dynamic>> write({
    required String model,
    required int recordId,
    required Map<String, dynamic> values,
  });

  /// Delete a record
  Future<Map<String, dynamic>> delete({
    required String model,
    required int recordId,
  });

  /// Execute a custom RPC method (for JSON-RPC) or API call (for REST)
  Future<Map<String, dynamic>> executeRPC({
    required String model,
    required String method,
    List<dynamic>? args,
    Map<String, dynamic>? kwargs,
  });

  /// Get current user information
  Future<Map<String, dynamic>> getCurrentUser();

  /// Check if user is authenticated
  bool get isAuthenticated;

  /// Get current user ID
  int? get currentUserId;

  /// Get current database name
  String? get currentDatabase;

  /// Logout and clear session
  void logout();

  /// Test connection to server
  Future<Map<String, dynamic>> testConnection();
}
