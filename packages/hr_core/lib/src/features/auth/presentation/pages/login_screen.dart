import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hr_core/src/app/app_image.dart';
import 'package:hr_core/src/config/odoo_config.dart';
import 'package:hr_core/src/custom_widgets/custom_button/custom_button.dart';
import 'package:hr_core/src/custom_widgets/custom_image/custom_image.dart';
import 'package:hr_core/src/custom_widgets/custom_screen/custom_screen.dart';
import 'package:hr_core/src/custom_widgets/custom_text/custom_text.dart';
import 'package:hr_core/src/custom_widgets/custom_text_field/custom_text_field.dart';
import 'package:hr_core/src/features/auth/presentation/controller/login_controller.dart';
import 'package:hr_core/src/services/extension.dart';
import 'package:hr_core/src/theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final LoginController loginController;

  @override
  void initState() {
    super.initState();
    loginController = Get.find<LoginController>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loginController.attemptAutoBiometricLogin(context: context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomScreen(
      loading: loginController.isLoading,
      body: Form(
        key: loginController.formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              10.verticalSpace,
              Align(
                alignment: AlignmentDirectional.topEnd,
                child: GestureDetector(
                  onTap: loginController.changeLanguage,
                  child: Container(
                    padding: const EdgeInsets.all(7),
                    height: 40.h,
                    width: 40.h,
                    decoration: BoxDecoration(
                      color: AppColors.appFAFAFABackGround2,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.appE5E5E5Border),
                    ),
                    child: CustomImage(
                      image: AppImage.changeLang,
                      color: AppColors.app9F9F9FText4,
                    ),
                  ),
                ),
              ),
              48.verticalSpace,
              _LoginBrandHeader(),
              24.verticalSpace,
              CustomText(
                text: context.appWords.logIn,
                fontSize: 16.w,
                color: AppColors.app1A1A1AText1,
                fontWeight: FontWeight.w700,
                textAlign: TextAlign.center,
              ),
              8.verticalSpace,
              Obx(() {
                final biometricRequired =
                    loginController.isBiometricRequired.value;
                return CustomText(
                  text: biometricRequired
                      ? context.appWords.biometricRequiredMessage
                      : context.appWords.loginDes,
                  fontSize: 13.w,
                  color: AppColors.appA0A0A0Text2,
                  fontWeight: FontWeight.w500,
                  textAlign: TextAlign.center,
                );
              }),
              16.verticalSpace,
              Obx(() {
                if (loginController.isBiometricRequired.value) {
                  return Column(
                    children: [
                      CustomTextField(
                        controller: loginController.emailController,
                        hintText: context.appWords.email,
                        hintLocationTop: true,
                        enabled: false,
                      ),
                      28.verticalSpace,
                      CustomButton(
                        text: context.appWords.loginWithBiometric,
                        onTap: () =>
                            loginController.tryBiometricLogin(context: context),
                      ),
                    ],
                  );
                }

                return Column(
                  children: [
                    CustomTextField(
                      controller: loginController.emailController,
                      hintText: context.appWords.email,
                      hintLocationTop: true,
                    ),
                    16.verticalSpace,
                    CustomTextField(
                      controller: loginController.passwordController,
                      hintText: context.appWords.password,
                      hintLocationTop: true,
                      obscureText: true,
                    ),
                    28.verticalSpace,
                    CustomButton(
                      text: context.appWords.logIn,
                      onTap: loginController.handleLogin,
                    ),
                  ],
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoginBrandHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final logoPath = OdooConfig.logoAssetPath;
    final brand = Theme.of(context).colorScheme.secondary;
    final primary = Theme.of(context).colorScheme.primary;

    return Column(
      children: [
        if (logoPath != null && logoPath.isNotEmpty)
          ClipRRect(
            borderRadius: BorderRadius.circular(16.r),
            child: Image.asset(
              logoPath,
              height: 88.h,
              width: 88.w,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => Icon(
                Icons.business,
                size: 64.sp,
                color: brand,
              ),
            ),
          )
        else
          Icon(
            Icons.business,
            size: 64.sp,
            color: brand,
          ),
        12.verticalSpace,
        CustomText(
          text: OdooConfig.appName,
          fontSize: 18.sp,
          fontWeight: FontWeight.w700,
          color: primary,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
