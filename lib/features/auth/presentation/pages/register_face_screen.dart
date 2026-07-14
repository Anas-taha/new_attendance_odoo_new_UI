import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hr_app_odoo/app/app_image.dart';
import 'package:hr_app_odoo/custom_widgets/custom_button/custom_button.dart';
import 'package:hr_app_odoo/custom_widgets/custom_screen/custom_screen.dart';
import 'package:hr_app_odoo/custom_widgets/custom_text/custom_text.dart';
import 'package:hr_app_odoo/features/auth/presentation/controller/register_face_controller.dart';
import 'package:hr_app_odoo/services/extension.dart';
import 'package:hr_app_odoo/theme/app_theme.dart';

class RegisterFaceScreen extends StatelessWidget {
  const RegisterFaceScreen({super.key});

  static const _descriptionColor = Color(0xFF5B5858);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<RegisterFaceController>();

    return PopScope(
      canPop: false,
      child: CustomScreen(
        loading: controller.isLoading,
        screenPadding: 20,
        body: SingleChildScrollView(
          child: Column(
            children: [
              24.verticalSpace,
              CustomText(
                text: context.appWords.registerFaceTitle,
                fontSize: 18.w,
                color: AppColors.app1A1A1AText1,
                fontWeight: FontWeight.w700,
                textAlign: TextAlign.center,
              ),
              8.verticalSpace,
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                child: CustomText(
                  text: context.appWords.registerFaceDescription,
                  fontSize: 13.w,
                  color: _descriptionColor,
                  fontWeight: FontWeight.w500,
                  textAlign: TextAlign.center,
                ),
              ),
              40.verticalSpace,
              Obx(
                () => _FacePreview(
                  imageBytes: controller.faceImageBytes.value,
                  hasCapturedImage: controller.hasCapturedImage.value,
                  onTap: controller.captureFace,
                ),
              ),
              16.verticalSpace,
              Obx(() {
                final message = controller.errorMessage.value;
                if (message == null || message.isEmpty) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.w),
                  child: CustomText(
                    text: message,
                    fontSize: 13.w,
                    fontWeight: FontWeight.w500,
                    color: AppColors.appF44336Error,
                    textAlign: TextAlign.center,
                  ),
                );
              }),
              24.verticalSpace,
              CustomText(
                text: context.appWords.registerFaceInstructionsTitle,
                fontSize: 13.w,
                fontWeight: FontWeight.w500,
                color: AppColors.app1A1A1AText1,
                textAlign: TextAlign.center,
              ),
              12.verticalSpace,
              _InstructionItem(text: context.appWords.registerFaceInstruction1),
              8.verticalSpace,
              _InstructionItem(text: context.appWords.registerFaceInstruction2),
              8.verticalSpace,
              _InstructionItem(text: context.appWords.registerFaceInstruction3),
              32.verticalSpace,
              Obx(() {
                final hasImage = controller.hasCapturedImage.value;
                final requiresRetake = controller.requiresRetake.value;
                final buttonText = requiresRetake || !hasImage
                    ? context.appWords.registerFaceRetake
                    : context.appWords.registerFaceContinue;

                return CustomButton(
                  text: buttonText,
                  onTap: () {
                    if (requiresRetake || !hasImage) {
                      controller.captureFace();
                    } else {
                      controller.saveAndContinue();
                    }
                  },
                  color: hasImage && !requiresRetake
                      ? AppColors.primary
                      : AppColors.primary.withValues(alpha: 0.85),
                );
              }),
              16.verticalSpace,
            ],
          ),
        ),
      ),
    );
  }
}

class _FacePreview extends StatelessWidget {
  const _FacePreview({
    required this.imageBytes,
    required this.hasCapturedImage,
    required this.onTap,
  });

  final Uint8List? imageBytes;
  final bool hasCapturedImage;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final size = 210.w;

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            ClipOval(
              child: SizedBox(
                width: size,
                height: size,
                child: imageBytes != null
                    ? Image.memory(imageBytes!, fit: BoxFit.cover)
                    : Image.asset(
                        AppImage.registerFacePlaceholder,
                        fit: BoxFit.cover,
                      ),
              ),
            ),
            if (!hasCapturedImage)
              ClipOval(
                child: SizedBox(
                  width: size,
                  height: size,
                  child: Stack(
                    children: [
                      Positioned(
                        left: size / 2,
                        top: size / 2,
                        right: 0,
                        bottom: 0,
                        child: SvgPicture.asset(
                          AppImage.registerFaceScanOverlay,
                          fit: BoxFit.fill,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            Positioned(
              right: 8.w,
              bottom: 8.w,
              child: Container(
                width: 36.w,
                height: 36.w,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.92),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.camera_alt_outlined,
                  color: AppColors.appFFFFFFBackGround1,
                  size: 18.w,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InstructionItem extends StatelessWidget {
  const _InstructionItem({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 6.h),
          child: Container(
            width: 5.w,
            height: 5.w,
            decoration: const BoxDecoration(
              color: AppColors.appA0A0A0Text2,
              shape: BoxShape.circle,
            ),
          ),
        ),
        8.horizontalSpace,
        Flexible(
          child: CustomText(
            text: text,
            fontSize: 13.w,
            fontWeight: FontWeight.w500,
            color: AppColors.appA0A0A0Text2,
            textAlign: TextAlign.start,
          ),
        ),
      ],
    );
  }
}
