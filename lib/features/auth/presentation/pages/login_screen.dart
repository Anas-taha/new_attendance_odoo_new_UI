import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hr_app_odoo/app/app_image.dart';
import 'package:hr_app_odoo/custom_widgets/custom_button/custom_button.dart';
import 'package:hr_app_odoo/custom_widgets/custom_image/custom_image.dart';
import 'package:hr_app_odoo/custom_widgets/custom_screen/custom_screen.dart';
import 'package:hr_app_odoo/custom_widgets/custom_text/custom_text.dart';
import 'package:hr_app_odoo/custom_widgets/custom_text_field/custom_text_field.dart';
import 'package:hr_app_odoo/features/auth/presentation/controller/login_controller.dart';
import 'package:hr_app_odoo/theme/app_theme.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});
  final loginController = Get.find<LoginController>();
  @override
  Widget build(BuildContext context) {
    return CustomScreen(
      loading: loginController.isLoading,
      body: Form(
        key: loginController.formKey,
        child: Column(
          children: [
            10.verticalSpace,
            Align(
              alignment: AlignmentDirectional.topEnd,
              child: GestureDetector(
                onTap: () {
                  loginController.changeLanguage();
                },
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
            80.verticalSpace,

            CustomText(
              text: 'تسجيل الدخول',
              fontSize: 16.w,
              color: AppColors.app1A1A1AText1,
              fontWeight: FontWeight.w700,
              textAlign: TextAlign.center,
            ),
            8.verticalSpace,
            CustomText(
              text: 'سجّل دخولك للوصول إلى حسابك وإدارة عملك بسهولة',
              fontSize: 13.w,
              color: AppColors.appA0A0A0Text2,
              fontWeight: FontWeight.w500,
              textAlign: TextAlign.center,
            ),
            16.verticalSpace,
            CustomTextField(
              controller: loginController.emailController,
              hintText: 'البريد الالكتروني',
              hintLocationTop: true,
            ),
            16.verticalSpace,
            CustomTextField(
              controller: loginController.passwordController,
              hintText: 'كلمة المرور',
              hintLocationTop: true,
            ),
            28.verticalSpace,
            CustomButton(
              text: 'تسجيل الدخول',
              onTap: () {
                loginController.handleLogin();
              },
            ),
          ],
        ),
      ),
    );
  }
}
