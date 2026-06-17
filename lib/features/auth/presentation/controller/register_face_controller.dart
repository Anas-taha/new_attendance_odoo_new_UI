import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hr_app_odoo/app/app_route.dart';
import 'package:hr_app_odoo/generated/l10n/app_localizations.dart';
import 'package:hr_app_odoo/services/face_attendance_service.dart';
import 'package:hr_app_odoo/services/odoo_rpc_service.dart';

class RegisterFaceController extends GetxController {
  RegisterFaceController({FaceAttendanceService? faceService})
    : _faceService = faceService ?? FaceAttendanceService.instance;

  final FaceAttendanceService _faceService;

  final RxBool isLoading = false.obs;
  final RxBool hasCapturedImage = false.obs;
  final Rxn<Uint8List> faceImageBytes = Rxn<Uint8List>();
  String? _base64Image;
  double? _latitude;
  double? _longitude;
  String? _address;

  Future<void> captureFace() async {
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
    _latitude = (result['latitude'] as num?)?.toDouble();
    _longitude = (result['longitude'] as num?)?.toDouble();
    _address = result['address'] as String?;
    faceImageBytes.value = base64Decode(image);
    hasCapturedImage.value = true;
  }

  Future<void> saveAndContinue() async {
    if (!hasCapturedImage.value || faceImageBytes.value == null) {
      _showMessage(
        AppLocalizations.of(Get.context!)!.registerFaceImageRequired,
        isError: true,
      );
      return;
    }

    final userId = OdooRPCService.instance.currentUserId;
    if (userId == null) {
      _showMessage(
        AppLocalizations.of(Get.context!)!.authFailed,
        isError: true,
      );
      return;
    }

    isLoading.value = true;
    try {
      final result = await _faceService.uploadUserImage(
        userId: userId,
        imageBytes: faceImageBytes.value!,
      );

      if (result['success'] == true) {
        Get.offAllNamed(AppRoutes.home);
        return;
      }

      _showMessage(
        result['error']?.toString() ??
            AppLocalizations.of(Get.context!)!.registerFaceUploadFailed,
        isError: true,
      );
    } catch (e) {
      _showMessage(
        AppLocalizations.of(Get.context!)!.connectionError(e.toString()),
        isError: true,
      );
    } finally {
      isLoading.value = false;
    }
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
