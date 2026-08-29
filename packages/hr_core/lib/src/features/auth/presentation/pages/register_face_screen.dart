import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:hr_core/src/app/app_image.dart';
import 'package:hr_core/src/custom_widgets/custom_button/custom_button.dart';
import 'package:hr_core/src/custom_widgets/custom_screen/custom_screen.dart';
import 'package:hr_core/src/custom_widgets/custom_text/custom_text.dart';
import 'package:hr_core/src/features/auth/presentation/controller/register_face_controller.dart';
import 'package:hr_core/src/services/extension.dart';
import 'package:hr_core/src/theme/app_theme.dart';

class RegisterFaceScreen extends StatelessWidget {
  const RegisterFaceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<RegisterFaceController>();
    final primary = Theme.of(context).colorScheme.primary;
    final secondary = Theme.of(context).colorScheme.secondary;

    return PopScope(
      canPop: false,
      child: CustomScreen(
        loading: controller.isLoading,
        screenPadding: 20,
        body: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CustomText(
                      text: context.appWords.registerFaceTitle,
                      fontSize: 18.w,
                      color: primary,
                      fontWeight: FontWeight.w700,
                      textAlign: TextAlign.center,
                    ),
                    8.verticalSpace,
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                      child: CustomText(
                        text: context.appWords.registerFaceDescription,
                        fontSize: 13.w,
                        color: AppColors.appA0A0A0Text2,
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
                        accentColor: secondary,
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
                      color: primary,
                      textAlign: TextAlign.center,
                    ),
                    12.verticalSpace,
                    _InstructionItem(
                      text: context.appWords.registerFaceInstruction1,
                      accentColor: secondary,
                    ),
                    8.verticalSpace,
                    _InstructionItem(
                      text: context.appWords.registerFaceInstruction2,
                      accentColor: secondary,
                    ),
                    8.verticalSpace,
                    _InstructionItem(
                      text: context.appWords.registerFaceInstruction3,
                      accentColor: secondary,
                    ),
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
                        color: requiresRetake || !hasImage
                            ? secondary.withValues(alpha: 0.85)
                            : null,
                      );
                    }),
                    16.verticalSpace,
                  ],
                ),
              ),
            );
          },
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
    required this.accentColor,
  });

  final Uint8List? imageBytes;
  final bool hasCapturedImage;
  final VoidCallback onTap;
  final Color accentColor;

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
                  color: accentColor.withValues(alpha: 0.92),
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
  const _InstructionItem({
    required this.text,
    required this.accentColor,
  });

  final String text;
  final Color accentColor;

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
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.7),
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
