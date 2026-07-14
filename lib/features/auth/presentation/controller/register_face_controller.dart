import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hr_app_odoo/app/app_route.dart';
import 'package:hr_app_odoo/generated/l10n/app_localizations.dart';
import 'package:hr_app_odoo/services/face_attendance_service.dart';
import 'package:hr_app_odoo/services/simple_hr_service.dart';

class RegisterFaceController extends GetxController {
  RegisterFaceController({
    FaceAttendanceService? faceService,
    SimpleHrService? hrService,
  }) : _faceService = faceService ?? FaceAttendanceService.instance,
       _hrService = hrService ?? SimpleHrService();

  final FaceAttendanceService _faceService;
  final SimpleHrService _hrService;

  final RxBool isLoading = false.obs;
  final RxBool hasCapturedImage = false.obs;
  final Rxn<Uint8List> faceImageBytes = Rxn<Uint8List>();
  final RxnString errorMessage = RxnString();
  final RxBool requiresRetake = false.obs;

  String? _base64Image;

  Future<void> captureFace() async {
    errorMessage.value = null;
    requiresRetake.value = false;

    final result = await _faceService.pickImageFromGallery();
    if (result['success'] != true) {
      final message =
          result['error']?.toString() ??
          AppLocalizations.of(Get.context!)!.couldNotSelectImage;
      _showMessage(message, isError: true);
      return;
    }

    final image = result['image'] as String?;
    if (image == null || image.isEmpty) {
      _showMessage(
        AppLocalizations.of(Get.context!)!.faceImageNotSelected,
        isError: true,
      );
      return;
    }

    _base64Image = image;
    faceImageBytes.value = base64Decode(image);
    hasCapturedImage.value = true;
  }

  Future<void> saveAndContinue() async {
    final l10n = AppLocalizations.of(Get.context!)!;

    if (!hasCapturedImage.value ||
        faceImageBytes.value == null ||
        _base64Image == null ||
        _base64Image!.isEmpty) {
      _showMessage(l10n.registerFaceImageRequired, isError: true);
      return;
    }

    isLoading.value = true;
    errorMessage.value = null;
    requiresRetake.value = false;

    try {
      final result = await _hrService.uploadProfilePhoto(
        imageBase64: _base64Image!,
      );

      final status = result['status']?.toString();
      final code = result['code']?.toString();

      if (code == 'no_face_detected' ||
          (status == 'error' && code == 'no_face_detected')) {
        _clearCapturedImage();
        requiresRetake.value = true;
        errorMessage.value =
            result['message']?.toString() ?? l10n.registerFaceNoFaceDetected;
        _showMessage(errorMessage.value!, isError: true);
        return;
      }

      if (status != 'success') {
        errorMessage.value =
            result['message']?.toString() ?? l10n.registerFaceUploadFailed;
        _showMessage(errorMessage.value!, isError: true);
        return;
      }

      final faceRegistered = result['face_registered'] == true;
      if (!faceRegistered) {
        // Photo saved but encoding unavailable — allow continue per brief.
        debugPrint(
          'register_face: face_registered=false (photo saved; backend face lib may be off)',
        );
      }

      final profile = await _hrService.getProfile();
      if (profile.profile?.hasImage != true) {
        errorMessage.value = l10n.registerFaceUploadFailed;
        _showMessage(errorMessage.value!, isError: true);
        return;
      }

      Get.offAllNamed(AppRoutes.home);
    } catch (e) {
      errorMessage.value = l10n.connectionError(e.toString());
      _showMessage(errorMessage.value!, isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  void _clearCapturedImage() {
    _base64Image = null;
    faceImageBytes.value = null;
    hasCapturedImage.value = false;
  }

  void _showMessage(String message, {required bool isError}) {
    final context = Get.context;
    if (context == null) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }
}
