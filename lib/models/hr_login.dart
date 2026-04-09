class HrLogin {
  final bool success;
  final String? error;
  final int? userId;
  final String? sessionId;
  final String? database;
  final String? userName;
  final String? message;
  final String? mobileToken;

  HrLogin({
    required this.success,
    this.userId,
    this.error,
    this.sessionId,
    this.database,
    this.userName,
    this.message,
    this.mobileToken,
  });
}
