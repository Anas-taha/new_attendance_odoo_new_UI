import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hr_app_odoo/app/app_image.dart';
import 'package:hr_app_odoo/custom_widgets/custom_button/custom_button.dart';
import 'package:hr_app_odoo/custom_widgets/custom_image/custom_image.dart';
import 'package:hr_app_odoo/custom_widgets/custom_screen/custom_screen.dart';
import 'package:hr_app_odoo/custom_widgets/custom_text/custom_text.dart';
import 'package:hr_app_odoo/features/auth/presentation/controller/register_face_controller.dart';
import 'package:hr_app_odoo/services/extension.dart';
import 'package:hr_app_odoo/theme/app_theme.dart';

class RegisterFaceScreen extends StatelessWidget {
  RegisterFaceScreen({super.key});

  final controller = Get.find<RegisterFaceController>();

  @override
  Widget build(BuildContext context) {
    return CustomScreen(
      loading: controller.isLoading,
      body: Column(
        children: [
          48.verticalSpace,
          CustomText(
            text: context.appWords.registerFaceTitle,
            fontSize: 16.w,
            color: AppColors.app1A1A1AText1,
            fontWeight: FontWeight.w700,
            textAlign: TextAlign.center,
          ),
          8.verticalSpace,
          CustomText(
            text: context.appWords.registerFaceDescription,
            fontSize: 13.w,
            color: AppColors.appA0A0A0Text2,
            fontWeight: FontWeight.w500,
            textAlign: TextAlign.center,
          ),
          32.verticalSpace,
          Obx(() => _FacePreview(imageBytes: controller.faceImageBytes.value)),
          24.verticalSpace,
          GestureDetector(
            onTap: controller.captureFace,
            child: Container(
              width: double.infinity,
              height: 48.h,
              decoration: BoxDecoration(
                color: AppColors.appFAFAFABackGround2,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.appE5E5E5Border),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.camera_alt_outlined,
                    color: AppColors.app670379Sedondary2,
                    size: 20.w,
                  ),
                  8.horizontalSpace,
                  CustomText(
                    text: context.appWords.takePhoto,
                    fontSize: 16.w,
                    fontWeight: FontWeight.w600,
                    color: AppColors.app670379Sedondary2,
                  ),
                ],
              ),
            ),
          ),
          28.verticalSpace,
          Obx(
            () => CustomButton(
              text: context.appWords.registerFaceContinue,
              onTap: controller.saveAndContinue,
              color: controller.hasCapturedImage.value
                  ? AppColors.app670379Sedondary2
                  : AppColors.app670379Sedondary2.withValues(alpha: 0.45),
            ),
          ),
        ],
      ),
    );
  }
}

class _FacePreview extends StatelessWidget {
  const _FacePreview({required this.imageBytes});

  final Uint8List? imageBytes;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200.h,
      width: 200.h,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.appFAFAFABackGround2,
        border: Border.all(color: AppColors.appE5E5E5Border, width: 1.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: imageBytes != null
          ? Image.memory(imageBytes!, fit: BoxFit.cover)
          : Padding(
              padding: const EdgeInsets.all(36),
              child: CustomImage(
                image: AppImage.defaultProfile,
                color: AppColors.app9F9F9FText4,
              ),
            ),
    );
  }
}
