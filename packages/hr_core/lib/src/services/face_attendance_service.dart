import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:camera/camera.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import '../config/odoo_config.dart';
import 'odoo_rpc_service.dart';

class FaceAttendanceService {
  static FaceAttendanceService? _instance;
  static FaceAttendanceService get instance =>
      _instance ??= FaceAttendanceService._internal();

  FaceAttendanceService._internal();

  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isInitialized = false;
  bool _isCameraActive = false;
  bool? _geoFieldsSupported;

  // Getter for camera initialization status
  bool get isInitialized => _isInitialized;
  bool get isCameraActive => _isCameraActive;

  /// Initialize camera and permissions
  Future<dynamic> initializeCamera() async {
    try {
      // Request notification permission

      // Request camera permission
      final cameraStatus = await Permission.camera.request();
      if (cameraStatus != PermissionStatus.granted) {
        print('❌ Camera permission denied');
        return 'Camera permission denied';
      }

      // Request location permission
      final locationStatus = await Permission.location.request();
      if (locationStatus != PermissionStatus.granted) {
        print('❌ Location permission denied');
        return 'Location permission denied';
      }

      // Get available cameras
      _cameras = await availableCameras();
      if (_cameras == null || _cameras!.isEmpty) {
        print('❌ No cameras available');
        return 'No cameras available';
      }

      // Initialize camera controller with front camera if available
      final frontCamera = _cameras!.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => _cameras!.first,
      );

      _cameraController = CameraController(
        frontCamera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _cameraController!.initialize();

      // Verify camera is actually initialized (important for iOS)
      if (!_cameraController!.value.isInitialized) {
        print('❌ Camera initialization failed - not initialized');
        await _cameraController!.dispose();
        _cameraController = null;
        return 'Camera initialization failed';
      }

      _isInitialized = true;

      print('✅ Camera initialized successfully');
      return true;
    } catch (e) {
      print('❌ Error initializing camera: $e');
      return 'Error initializing camera: $e';
    }
  }

  /// Start camera preview
  Future<void> startCamera() async {
    if (_isInitialized && _cameraController != null) {
      try {
        // Verify camera is initialized before resuming (critical for iOS)
        if (!_cameraController!.value.isInitialized) {
          print('❌ Camera not initialized, cannot start preview');
          return;
        }

        // On iOS, ensure camera is ready before resuming
        if (Platform.isIOS) {
          // Wait a bit for iOS camera to be fully ready
          await Future.delayed(const Duration(milliseconds: 100));
        }

        await _cameraController!.resumePreview();
        _isCameraActive = true;
        print('✅ Camera started');
      } catch (e) {
        print('❌ Error starting camera: $e');
        rethrow;
      }
    }
  }

  /// Stop camera preview
  Future<void> stopCamera() async {
    if (_cameraController != null) {
      try {
        await _cameraController!.pausePreview();
        _isCameraActive = false;
        print('✅ Camera stopped');
      } catch (e) {
        print('❌ Error stopping camera: $e');
      }
    }
  }

  /// Get camera controller
  CameraController? get cameraController => _cameraController;

  /// Get available cameras
  List<CameraDescription>? get cameras => _cameras;

  /// Take a photo and get current location
  Future<Map<String, dynamic>> takeAttendancePhoto() async {
    try {
      if (!_isInitialized || _cameraController == null) {
        return {'success': false, 'error': 'Camera not initialized'};
      }

      if (!_isCameraActive) {
        await startCamera();
      }

      // Get current location
      final location = await _getCurrentLocation();
      if (location == null) {
        return {'success': false, 'error': 'Could not get current location'};
      }

      // Take photo
      final image = await _cameraController!.takePicture();

      // Compress and convert image to base64
      final compressedBytes = await _compressImage(image.path);
      if (compressedBytes == null) {
        return {'success': false, 'error': 'Failed to compress image'};
      }
      final base64Image = base64Encode(compressedBytes);
      log('base64Image length: ${base64Image.length} characters');

      // Get address from coordinates
      final address = await _getAddressFromCoordinates(
        location.latitude,
        location.longitude,
      );

      final result = {
        'success': true,
        'image': base64Image,
        'latitude': location.latitude,
        'longitude': location.longitude,
        'address': address,
        'timestamp': DateTime.now().toIso8601String(),
      };
      log('result takeAttendancePhoto: $result');
      return result;
    } catch (e, stackTrace) {
      log('❌ Error taking attendance photo: $e');
      log('❌ Stack trace: $stackTrace');
      return {'success': false, 'error': 'Error taking photo: $e'};
    }
  }

  /// Get current location
  Future<Position?> _getCurrentLocation() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('❌ Location services are disabled');
        return null;
      }

      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print('❌ Location permissions are permanently denied');
        return null;
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      print('✅ Location obtained: ${position.latitude}, ${position.longitude}');
      return position;
    } catch (e) {
      print('❌ Error getting location: $e');
      return null;
    }
  }

  /// Get address from coordinates
  Future<String> _getAddressFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latitude,
        longitude,
      );
      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        final street = placemark.street?.trim();
        final locality = placemark.locality?.trim();
        final adminArea = placemark.administrativeArea?.trim();

        final parts = [
          if (street != null && street.isNotEmpty) street,
          if (locality != null && locality.isNotEmpty) locality,
          if (adminArea != null && adminArea.isNotEmpty) adminArea,
        ];

        if (parts.isNotEmpty) {
          return parts.join(', ');
        }
      }
      return 'Unknown location';
    } catch (e) {
      print('❌ Error getting address: $e');
      return 'Unknown location';
    }
  }

  /// Submit face attendance to Odoo with check-in/check-out logic
  Future<Map<String, dynamic>> submitFaceAttendance({
    required String base64Image,
    required double latitude,
    required double longitude,
    String? address,
  }) async {
    try {
      if (!OdooRPCService.instance.isAuthenticated) {
        return {
          'success': false,
          'error': 'Not authenticated. Please login first.',
        };
      }

      // Check current attendance status
      final currentStatus = await getCurrentAttendanceStatus();
      final isCurrentlyCheckedIn = currentStatus['is_checked_in'] ?? false;
      final currentAttendanceId = currentStatus['attendance_id'];

      print(
        '🔍 Current attendance status: ${isCurrentlyCheckedIn ? "Checked In" : "Checked Out"}',
      );

      if (isCurrentlyCheckedIn) {
        // Perform check-out
        return await performCheckOut(
          attendanceId: currentAttendanceId,
          latitude: latitude,
          longitude: longitude,
          address: address,
        );
      } else {
        // Perform check-in
        return await performCheckIn(
          base64Image: base64Image,
          latitude: latitude,
          longitude: longitude,
          address: address,
        );
      }
    } catch (e) {
      print('❌ Error submitting face attendance: $e');
      return {'success': false, 'error': 'Error submitting attendance: $e'};
    }
  }

  /// Get current attendance status.
  ///
  /// Prefer `/mobile/profile` (works without a linked res.users). Fall back to
  /// `hr.attendance` search_read only when the profile call is unavailable.
  Future<Map<String, dynamic>> getCurrentAttendanceStatus() async {
    try {
      final profileResult = await OdooRPCService.instance.callOdooApi(
        apiUrl: 'profile',
      );
      if (profileResult is Map &&
          profileResult['status'] == 'success' &&
          profileResult['profile'] is Map) {
        final profile = Map<String, dynamic>.from(profileResult['profile'] as Map);
        final state = (profile['attendance_state'] ?? '').toString().toLowerCase();
        final last = profile['last_attendance'];
        final lastMap = last is Map ? Map<String, dynamic>.from(last) : null;
        final checkedIn = state == 'checked_in' ||
            (lastMap != null &&
                (lastMap['check_in']?.toString().isNotEmpty ?? false) &&
                lastMap['check_out'] == null);
        return {
          'is_checked_in': checkedIn,
          'attendance_id': null,
          'check_in': lastMap?['check_in'],
          'attendance_state': state,
        };
      }
    } catch (e, stackTrace) {
      log(
        '⚠️ profile attendance status failed, falling back to search_read: $e',
        name: 'FaceAttendanceService',
        stackTrace: stackTrace,
      );
    }

    try {
      final employeeId = OdooRPCService.instance.currentEmployeeId;
      if (employeeId == null) {
        log('⚠️ No employee ID for attendance status', name: 'FaceAttendanceService');
        return {'is_checked_in': false, 'attendance_id': null};
      }

      final result = await OdooRPCService.instance.searchRead(
        model: 'hr.attendance',
        domain: [
          ['employee_id', '=', employeeId],
          ['check_out', '=', false],
        ],
        fields: ['id', 'check_in', 'check_out'],
        limit: 1,
      );

      if (result['success'] &&
          result['data'] != null &&
          (result['data'] as List).isNotEmpty) {
        final attendance = (result['data'] as List).first;
        return {
          'is_checked_in': true,
          'attendance_id': attendance['id'],
          'check_in': attendance['check_in'],
        };
      }

      return {'is_checked_in': false, 'attendance_id': null};
    } catch (e, stackTrace) {
      log(
        '❌ Error getting current attendance status: $e',
        name: 'FaceAttendanceService',
        stackTrace: stackTrace,
      );
      return {'is_checked_in': false, 'attendance_id': null};
    }
  }

  Map<String, dynamic>? _tryParseJsonMap(String body) {
    final trimmed = body.trim();
    if (trimmed.isEmpty ||
        !(trimmed.startsWith('{') || trimmed.startsWith('['))) {
      return null;
    }
    try {
      final decoded = json.decode(trimmed);
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
    } catch (_) {
      return null;
    }
    return null;
  }

  /// Perform check-in
  Future<Map<String, dynamic>> performCheckIn({
    required String base64Image,
    required double latitude,
    required double longitude,
    String? address,
  }) async {
    try {
      final useGeo = _geoFieldsSupported ?? true;

      final attendanceData = <String, dynamic>{
        'employee_id': OdooRPCService.instance.currentEmployeeId,
        'check_in': _formatOdooDateTime(DateTime.now()),
      };

      if (useGeo) {
        attendanceData['in_latitude'] = latitude;
        attendanceData['in_longitude'] = longitude;
      }

      print('🔍 Performing check-in with data: $attendanceData');

      final result = await OdooRPCService.instance.create(
        model: 'hr.attendance',
        values: attendanceData,
      );

      if (result['success']) {
        _geoFieldsSupported = useGeo;
        print('✅ Check-in successful');
        return {
          'success': true,
          'action': 'check_in',
          'message':
              'Successfully checked in with face recognition and location',
          'data': result['data'],
        };
      } else {
        final error = result['error']?.toString() ?? 'Failed to check in';
        if (useGeo && _looksLikeMissingGeoField(error)) {
          _geoFieldsSupported = false;
          return await performCheckIn(
            base64Image: base64Image,
            latitude: latitude,
            longitude: longitude,
            address: address,
          );
        }
        return {'success': false, 'action': 'check_in', 'error': error};
      }
    } catch (e) {
      return {
        'success': false,
        'action': 'check_in',
        'error': 'Exception during check-in: $e',
      };
    }
  }

  /// Perform check-out
  Future<Map<String, dynamic>> performCheckOut({
    required int attendanceId,
    required double latitude,
    required double longitude,
    String? address,
  }) async {
    try {
      final useGeo = _geoFieldsSupported ?? true;

      final checkoutData = <String, dynamic>{
        'check_out': _formatOdooDateTime(DateTime.now()),
      };

      if (useGeo) {
        checkoutData['out_latitude'] = latitude;
        checkoutData['out_longitude'] = longitude;
      }

      print('🔍 Performing check-out with data: $checkoutData');

      final result = await OdooRPCService.instance.write(
        model: 'hr.attendance',
        recordId: attendanceId,
        values: checkoutData,
      );

      if (result['success']) {
        _geoFieldsSupported = useGeo;
        print('✅ Check-out successful');
        return {
          'success': true,
          'action': 'check_out',
          'message': 'Successfully checked out with location data',
          'data': result['data'],
        };
      } else {
        final error = result['error']?.toString() ?? 'Failed to check out';
        if (useGeo && _looksLikeMissingGeoField(error)) {
          _geoFieldsSupported = false;
          return await performCheckOut(
            attendanceId: attendanceId,
            latitude: latitude,
            longitude: longitude,
            address: address,
          );
        }
        return {'success': false, 'action': 'check_out', 'error': error};
      }
    } catch (e) {
      return {
        'success': false,
        'action': 'check_out',
        'error': 'Exception during check-out: $e',
      };
    }
  }

  /// Format DateTime to Odoo expected UTC string without fractional seconds
  String _formatOdooDateTime(DateTime dateTime) {
    final utc = dateTime.toUtc();
    return '${utc.year.toString().padLeft(4, '0')}'
        '-${utc.month.toString().padLeft(2, '0')}'
        '-${utc.day.toString().padLeft(2, '0')} '
        '${utc.hour.toString().padLeft(2, '0')}:'
        '${utc.minute.toString().padLeft(2, '0')}:'
        '${utc.second.toString().padLeft(2, '0')}';
  }

  bool _looksLikeMissingGeoField(String message) {
    return message.contains("Invalid field 'in_latitude'") ||
        message.contains("Invalid field 'in_longitude'") ||
        message.contains("Invalid field 'out_latitude'") ||
        message.contains("Invalid field 'out_longitude'");
  }

  /// Upload user face image via POST /api/v1/user/upload_image (multipart).
  Future<Map<String, dynamic>> uploadUserImage({
    required int userId,
    required Uint8List imageBytes,
    String filename = 'face.jpg',
  }) async {
    try {
      final url = Uri.parse(OdooConfig.apiV1Endpoint('user/upload_image'));
      log('POST $url (upload_image)', name: 'FaceAttendanceService');

      final request = http.MultipartRequest('POST', url)
        ..fields['user_id'] = userId.toString()
        ..files.add(
          http.MultipartFile.fromBytes(
            'image_file',
            imageBytes,
            filename: filename,
          ),
        );

      final streamedResponse = await request.send().timeout(
        Duration(milliseconds: OdooConfig.writeTimeout),
      );
      final response = await http.Response.fromStream(streamedResponse);

      log(
        '📨 upload_image status: ${response.statusCode}',
        name: 'FaceAttendanceService',
      );

      if (response.statusCode != 200) {
        _logHttpError('upload_image', url, response);
        return {
          'success': false,
          'error': _httpErrorMessage('upload_image', response),
        };
      }

      final jsonResponse = json.decode(response.body);
      if (jsonResponse is! Map<String, dynamic>) {
        return {'success': false, 'error': 'Invalid upload response'};
      }

      if (jsonResponse['success'] == true) {
        return {
          'success': true,
          'has_image': jsonResponse['has_image'] ?? true,
        };
      }

      return {
        'success': false,
        'error': jsonResponse['error']?.toString() ?? 'Upload failed',
      };
    } catch (e, stackTrace) {
      log(
        '❌ uploadUserImage error: $e',
        name: 'FaceAttendanceService',
        stackTrace: stackTrace,
      );
      return {'success': false, 'error': 'Upload failed: $e'};
    }
  }

  /// Submit face attendance via Odoo's /submit_face controller endpoint
  /// This method uses face recognition on the server side for attendance
  /// The endpoint handles both check-in and check-out automatically based on employee's current status
  Future<Map<String, dynamic>> submitFaceViaController({
    required String base64Image,
    double? latitude,
    double? longitude,
    String? address,
  }) async {
    try {
      print('🔄 Submitting face attendance via controller...');
      print('📍 Location: lat=$latitude, lon=$longitude');

      final mobileToken = OdooRPCService.instance.mobileToken;
      if (mobileToken == null || mobileToken.isEmpty) {
        return {
          'success': false,
          'error': 'Not authenticated. Please login first.',
        };
      }

      final url = Uri.parse(OdooConfig.rootEndpoint('submit_face'));
      log('POST $url (submit_face)', name: 'FaceAttendanceService');

      final request = http.MultipartRequest('POST', url)
        ..fields['mobile_token'] = mobileToken
        ..fields['face_image'] = 'data:image/jpeg;base64,$base64Image'
        ..fields['latitude'] = latitude?.toString() ?? ''
        ..fields['longitude'] = longitude?.toString() ?? ''
        ..fields['address'] = address ?? '';

      final response = await _sendMultipartWithRedirect(request);

      log(
        '📨 submit_face status: ${response.statusCode}',
        name: 'FaceAttendanceService',
      );

      if (response.statusCode != 200) {
        _logHttpError('submit_face', url, response);
        // Prefer JSON error body from the face controller when present.
        final jsonError = _tryParseJsonMap(response.body);
        if (jsonError != null) {
          final msg = (jsonError['message'] ?? jsonError['error'] ?? '')
              .toString();
          if (msg.isNotEmpty) {
            return {
              'success': false,
              'error': msg,
              // Geofence / face rejects must NOT fall back to a second toggle.
              'use_attendance_check_fallback': false,
            };
          }
        }
        return {
          'success': false,
          'error': _httpErrorMessage('submit_face', response),
          'use_attendance_check_fallback': true,
        };
      }

      // Backend returns JSON ({status, action, ...}). Older builds returned HTML.
      final jsonBody = _tryParseJsonMap(response.body);
      if (jsonBody != null) {
        final status = (jsonBody['status'] ?? '').toString().toLowerCase();
        if (status == 'success') {
          final action = (jsonBody['action'] ?? 'unknown').toString();
          print('✅ Face attendance successful (JSON): action=$action');
          return {
            'success': true,
            'action': action,
            'attendance_id': jsonBody['attendance_id'],
            'attendance_state': jsonBody['attendance_state'],
            'geofence_status': jsonBody['geofence_status'],
            'check_in': jsonBody['check_in'],
            'check_out': jsonBody['check_out'],
            'message': jsonBody['message'],
          };
        }
        final err = (jsonBody['message'] ?? jsonBody['error'] ?? 'Face attendance failed')
            .toString();
        print('❌ Face attendance failed (JSON): $err');
        return {
          'success': false,
          'error': err,
          'use_attendance_check_fallback': false,
        };
      }

      // Legacy HTML response fallback (should be rare).
      final message = _extractMessageFromHtml(response.body);
      final isSuccess = message.toLowerCase().contains('success') ||
          message.contains('✅');

      String action = 'unknown';
      final lower = message.toLowerCase();
      if (lower.contains('check-out') ||
          lower.contains('check out') ||
          lower.contains('checkout')) {
        action = 'check_out';
      } else if (lower.contains('check-in') ||
          lower.contains('check in') ||
          lower.contains('checkin')) {
        action = 'check_in';
      }

      if (isSuccess) {
        print('✅ Face attendance successful (HTML): $message');
        return {'success': true, 'message': message, 'action': action};
      }

      print('❌ Face attendance failed (HTML): $message');
      return {'success': false, 'error': message};
    } catch (e, stackTrace) {
      log(
        '❌ Face verification error: $e',
        name: 'FaceAttendanceService',
        stackTrace: stackTrace,
      );
      return {'success': false, 'error': 'Face verification failed: $e'};
    }
  }

  void _logHttpError(String label, Uri url, http.Response response) {
    log('❌ $label → HTTP ${response.statusCode}', name: 'FaceAttendanceService');
    log('   URL: $url', name: 'FaceAttendanceService');
    log(
      '   Location: ${response.headers['location'] ?? response.headers['Location'] ?? 'n/a'}',
      name: 'FaceAttendanceService',
    );
    final body = response.body;
    log(
      '   Body: ${body.length > 500 ? '${body.substring(0, 500)}...' : body}',
      name: 'FaceAttendanceService',
    );
  }

  String _httpErrorMessage(String label, http.Response response) {
    final location = response.headers['location'] ?? response.headers['Location'];
    if (response.statusCode == 301 || response.statusCode == 302) {
      return '$label: HTTP ${response.statusCode} redirect'
          '${location != null ? ' → $location' : ''}. '
          'Check OdooConfig.baseUrl matches Postman base_url.';
    }
    final snippet = response.body.length > 120
        ? '${response.body.substring(0, 120)}...'
        : response.body;
    return '$label: HTTP ${response.statusCode}${snippet.isNotEmpty ? ' — $snippet' : ''}';
  }

  /// Submit face attendance with automatic fallback
  /// First tries the controller endpoint (/submit_face) with face recognition
  /// If that fails, falls back to direct RPC attendance submission
  Future<Map<String, dynamic>> submitFaceAttendanceWithFallback({
    required String base64Image,
    required double latitude,
    required double longitude,
    String? address,
  }) async {
    try {
      print('🔄 Attempting face attendance with controller first...');

      // First, try the face recognition controller
      final controllerResult = await submitFaceViaController(
        base64Image: base64Image,
        latitude: latitude,
        longitude: longitude,
        address: address,
      );

      if (controllerResult['success'] == true) {
        return controllerResult;
      }

      final error = controllerResult['error']?.toString() ?? '';
      log(
        '⚠️ submit_face failed: $error',
        name: 'FaceAttendanceService',
      );

      // If it's a face matching issue, don't fallback - return the error
      if (error.contains('No matching face') ||
          error.contains('No face detected') ||
          error.contains('face')) {
        return controllerResult;
      }

      // For other errors (301, network, etc.) signal caller to use /mobile/attendance/check
      return {
        'success': false,
        'error': error,
        'use_attendance_check_fallback': true,
      };
    } catch (e) {
      print('❌ Error in submitFaceAttendanceWithFallback: $e');
      return {
        'success': false,
        'error': 'Attendance submission failed: $e',
        'use_attendance_check_fallback': true,
      };
    }
  }

  Future<http.Response> _sendMultipartWithRedirect(
    http.MultipartRequest request,
  ) async {
    var streamedResponse = await request.send().timeout(
      Duration(milliseconds: OdooConfig.writeTimeout),
    );
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 301 || response.statusCode == 302) {
      final location =
          response.headers['location'] ?? response.headers['Location'];
      if (location != null && location.isNotEmpty) {
        final redirectUri = location.startsWith('http')
            ? Uri.parse(location)
            : Uri.parse(
                '${request.url.scheme}://${request.url.authority}$location',
              );
        log(
          '↪️ submit_face redirect → $redirectUri',
          name: 'FaceAttendanceService',
        );
        final redirectRequest = http.MultipartRequest('POST', redirectUri)
          ..fields.addAll(request.fields);
        streamedResponse = await redirectRequest.send().timeout(
          Duration(milliseconds: OdooConfig.writeTimeout),
        );
        response = await http.Response.fromStream(streamedResponse);
      }
    }

    return response;
  }

  /// Get face attendance page URL for web view
  String getFaceAttendanceUrl() {
    return '${OdooConfig.serverRootUrl}/face_attendance';
  }

  /// Check if face attendance controller is available
  Future<bool> isFaceAttendanceAvailable() async {
    try {
      final url = Uri.parse('${OdooConfig.serverRootUrl}/face_attendance');
      final response = await http
          .get(url, headers: {'User-Agent': 'HR App Flutter Face Attendance'})
          .timeout(const Duration(seconds: 5));

      return response.statusCode == 200;
    } catch (e) {
      print('❌ Face attendance controller not available: $e');
      return false;
    }
  }

  String _extractMessageFromHtml(String html) {
    final messageMatch = RegExp(
      r'<p[^>]*class="message"[^>]*>(.*?)</p>',
      caseSensitive: false,
      dotAll: true,
    ).firstMatch(html);
    var message = messageMatch?.group(1) ?? html;
    message = message.replaceAll(RegExp(r'<[^>]+>'), '');
    message = message
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>');
    return message.trim();
  }

  /// Check if we're running on a mobile platform with camera support
  bool get _isMobilePlatform {
    // Web doesn't support native camera through image_picker
    if (kIsWeb) {
      log('📱 Platform: Web - camera not supported');
      return false;
    }

    try {
      // Check for mobile platforms only (Android/iOS)
      final isMobile = Platform.isAndroid || Platform.isIOS;
      if (isMobile) {
        log('📱 Platform: Mobile (Android/iOS) - camera supported');
        return true;
      }
      // Desktop platforms (Windows, macOS, Linux) - no camera support
      log('📱 Platform: Desktop (${Platform.operatingSystem}) - using gallery');
      return false;
    } catch (e) {
      log('📱 Platform detection error: $e - defaulting to gallery');
      return false;
    }
  }

  /// Capture image from camera and get current location
  /// Camera will only start when this method is called (on Check In press)
  /// On desktop/web, falls back to gallery picker
  Future<Map<String, dynamic>> pickImageFromGallery() async {
    try {
      log('🔄 Starting image capture process...');

      // Determine platform first before any async operations
      final bool useMobileCamera = _isMobilePlatform;
      log('📱 Using mobile camera: $useMobileCamera');

      // Get current location (with timeout to prevent hanging)
      Position? location;
      try {
        location = await _getCurrentLocation().timeout(
          const Duration(seconds: 15),
          onTimeout: () => null,
        );
      } catch (e) {
        log('⚠️ Location error (continuing anyway): $e');
        // Continue without location on desktop - don't block the flow
      }

      if (location != null) {
        log('✅ Location obtained: ${location.latitude}, ${location.longitude}');
      } else {
        log('⚠️ Location not available, continuing without it');
      }

      final ImagePicker picker = ImagePicker();
      XFile? image;

      // Use camera on mobile, gallery on desktop/web
      if (useMobileCamera) {
        log('📷 Opening camera...');
        // Open camera to capture image (camera starts here, not before)
        image = await picker.pickImage(
          source: ImageSource.camera,
          preferredCameraDevice: CameraDevice.front,
          imageQuality: 80,
        );
      } else {
        // On desktop/web, use gallery as fallback
        log('🖼️ Opening gallery picker (desktop/web mode)...');
        try {
          image = await picker.pickImage(
            source: ImageSource.gallery,
            imageQuality: 80,
          );
        } catch (e) {
          log('❌ Gallery picker error: $e');
          return {'success': false, 'error': 'Could not open image picker: $e'};
        }
      }

      if (image == null) {
        log('❌ No image selected by user');
        return {
          'success': false,
          'error': 'No image selected. Please select an image.',
        };
      }
      log('✅ Image selected: ${image.path}');

      // Read image bytes
      final imageBytes = await image.readAsBytes();
      log('📊 Image size: ${imageBytes.length} bytes');

      String base64Image;

      // Compress image on mobile platforms, use raw bytes on desktop/web
      if (useMobileCamera && !kIsWeb) {
        log('🗜️ Compressing image...');
        final compressedBytes = await _compressImage(image.path);
        if (compressedBytes == null) {
          log('⚠️ Compression failed, using original image');
          base64Image = base64Encode(imageBytes);
        } else {
          base64Image = base64Encode(compressedBytes);
        }
      } else {
        // On desktop/web, use the raw bytes directly
        base64Image = base64Encode(imageBytes);
      }

      log('✅ base64Image length: ${base64Image.length} characters');

      // Get address from coordinates (only if location available)
      String address = 'Unknown location';
      double? latitude;
      double? longitude;

      if (location != null) {
        latitude = location.latitude;
        longitude = location.longitude;
        try {
          address = await _getAddressFromCoordinates(latitude, longitude);
        } catch (e) {
          log('⚠️ Address lookup failed: $e');
        }
        log('📍 Address: $address');
      }

      final result = {
        'success': true,
        'image': base64Image,
        'latitude': latitude ?? 0.0,
        'longitude': longitude ?? 0.0,
        'address': address,
        'timestamp': DateTime.now().toIso8601String(),
      };
      log('✅ Image capture complete');
      return result;
    } catch (e, stackTrace) {
      log('❌ Error picking image: $e');
      log('❌ Stack trace: $stackTrace');
      return {'success': false, 'error': 'Error picking image: $e'};
    }
  }

  /// Compress image to reduce size while maintaining quality for face recognition
  ///
  /// Compresses the image with 88% quality and resizes to max 1024x1024
  /// Returns compressed image bytes, or null if compression fails
  Future<List<int>?> _compressImage(String filePath) async {
    try {
      final result = await FlutterImageCompress.compressWithFile(
        filePath,
        minWidth: 1024,
        minHeight: 1024,
        quality: 80,
        format: CompressFormat.jpeg,
      );

      if (result != null) {
        final originalSize = File(filePath).lengthSync();
        final compressedSize = result.length;
        final reduction = ((originalSize - compressedSize) / originalSize * 100)
            .toStringAsFixed(1);
        log(
          '📸 Image compressed: ${originalSize ~/ 1024}KB → ${compressedSize ~/ 1024}KB (${reduction}% reduction)',
        );
      }

      return result;
    } catch (e) {
      log('❌ Error compressing image: $e');
      return null;
    }
  }

  /// Dispose camera resources
  void dispose() {
    _cameraController?.dispose();
    _isInitialized = false;
    _isCameraActive = false;
  }
}
