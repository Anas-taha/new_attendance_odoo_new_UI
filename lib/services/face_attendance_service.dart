import 'dart:convert';
import 'dart:developer';
import 'dart:io';
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

  /// Get current attendance status
  Future<Map<String, dynamic>> getCurrentAttendanceStatus() async {
    try {
      final result = await _callOdooMethod('hr.attendance', 'search_read', [
        [
          ['employee_id', '=', OdooRPCService.instance.currentEmployeeId],
          ['check_out', '=', false],
        ],
        ['id', 'check_in', 'check_out'],
      ]);

      if (result['success'] &&
          result['data'] != null &&
          result['data'].isNotEmpty) {
        final attendance = result['data'][0];
        return {
          'is_checked_in': true,
          'attendance_id': attendance['id'],
          'check_in': attendance['check_in'],
        };
      }

      return {'is_checked_in': false, 'attendance_id': null};
    } catch (e) {
      print('❌ Error getting current attendance status: $e');
      return {'is_checked_in': false, 'attendance_id': null};
    }
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

      final result = await _callOdooMethod('hr.attendance', 'create', [
        attendanceData,
      ]);

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

      final result = await _callOdooMethod('hr.attendance', 'write', [
        attendanceId,
        checkoutData,
      ]);

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

  /// Call Odoo method
  Future<Map<String, dynamic>> _callOdooMethod(
    String model,
    String method,
    List<dynamic> args,
  ) async {
    try {
      final url = Uri.parse('${OdooConfig.baseUrl}/jsonrpc');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'User-Agent': 'HR App Flutter Face Attendance',
          'Accept': 'application/json',
        },
        body: json.encode({
          'jsonrpc': '2.0',
          'method': 'call',
          'params': {
            'service': 'object',
            'method': 'execute_kw',
            'args': [
              OdooRPCService.instance.currentDatabase,
              OdooRPCService.instance.currentUserId,
              OdooRPCService.instance.currentPassword,
              model,
              method,
              args,
            ],
          },
        }),
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        if (jsonResponse['error'] != null) {
          return {
            'success': false,
            'error':
                jsonResponse['error']['data']['message'] ??
                'Odoo method call failed',
          };
        }

        return {'success': true, 'data': jsonResponse['result']};
      } else {
        return {
          'success': false,
          'error': 'HTTP Error: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Exception: $e'};
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

  /// Submit face attendance via Odoo's /submit_face controller endpoint
  /// This method uses face recognition on the server side for attendance
  /// The endpoint handles both check-in and check-out automatically based on employee's current status
  Future<Map<String, dynamic>> submitFaceViaController({
    required String base64Image,
    double? latitude,
    double? longitude,
  }) async {
    try {
      print('🔄 Submitting face attendance via controller...');
      print('📍 Location: lat=$latitude, lon=$longitude');
      
      final url = Uri.parse('${OdooConfig.baseUrl}/submit_face');
      final response = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/x-www-form-urlencoded',
              'User-Agent': 'HR App Flutter Face Attendance',
            },
            body: {
              'face_image': 'data:image/jpeg;base64,$base64Image',
              'latitude': latitude?.toString() ?? '',
              'longitude': longitude?.toString() ?? '',
            },
          )
          .timeout(Duration(milliseconds: OdooConfig.writeTimeout));

      print('📨 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final message = _extractMessageFromHtml(response.body);
        final isSuccess = message.contains('Success') || message.contains('✅');
        
        // Determine if it was check-in or check-out from the message
        String action = 'unknown';
        if (message.toLowerCase().contains('check') && message.toLowerCase().contains('in')) {
          action = 'check_in';
        } else if (message.toLowerCase().contains('check') && message.toLowerCase().contains('out')) {
          action = 'check_out';
        }
        
        if (isSuccess) {
          print('✅ Face attendance successful: $message');
          return {
            'success': true,
            'message': message,
            'action': action,
          };
        } else {
          print('❌ Face attendance failed: $message');
          return {'success': false, 'error': message};
        }
      } else {
        return {'success': false, 'error': 'HTTP ${response.statusCode}'};
      }
    } catch (e) {
      print('❌ Face verification error: $e');
      return {'success': false, 'error': 'Face verification failed: $e'};
    }
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
      );

      if (controllerResult['success'] == true) {
        return controllerResult;
      }

      // If face recognition fails (no matching face, etc.), check error
      final error = controllerResult['error']?.toString() ?? '';
      
      // If it's a face matching issue, don't fallback - return the error
      if (error.contains('No matching face') || 
          error.contains('No face detected') ||
          error.contains('face')) {
        return controllerResult;
      }

      // For other errors (network, endpoint not available), try direct RPC
      print('⚠️ Controller failed, falling back to direct RPC...');
      return await submitFaceAttendance(
        base64Image: base64Image,
        latitude: latitude,
        longitude: longitude,
        address: address,
      );
    } catch (e) {
      print('❌ Error in submitFaceAttendanceWithFallback: $e');
      return {'success': false, 'error': 'Attendance submission failed: $e'};
    }
  }

  /// Get face attendance page URL for web view
  String getFaceAttendanceUrl() {
    return '${OdooConfig.baseUrl}/face_attendance';
  }

  /// Check if face attendance controller is available
  Future<bool> isFaceAttendanceAvailable() async {
    try {
      final url = Uri.parse('${OdooConfig.baseUrl}/face_attendance');
      final response = await http.get(
        url,
        headers: {
          'User-Agent': 'HR App Flutter Face Attendance',
        },
      ).timeout(const Duration(seconds: 5));

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
          imageQuality: 90,
        );
      } else {
        // On desktop/web, use gallery as fallback
        log('🖼️ Opening gallery picker (desktop/web mode)...');
        try {
          image = await picker.pickImage(
            source: ImageSource.gallery,
            imageQuality: 90,
          );
        } catch (e) {
          log('❌ Gallery picker error: $e');
          return {'success': false, 'error': 'Could not open image picker: $e'};
        }
      }

      if (image == null) {
        log('❌ No image selected by user');
        return {'success': false, 'error': 'No image selected. Please select an image.'};
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
        quality: 88,
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
