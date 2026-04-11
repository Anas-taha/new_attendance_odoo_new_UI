import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hr_app_odoo/custom_widgets/custom_button/custom_button.dart';
import 'package:hr_app_odoo/custom_widgets/custom_text/custom_text.dart';
import 'package:hr_app_odoo/custom_widgets/custom_text_field/custom_text_field.dart';
import 'package:hr_app_odoo/features/auth/presentation/controller/login_controller.dart';
import 'package:hr_app_odoo/theme/app_theme.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});
  final loginController = Get.find<LoginController>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appFFFFFFBackGround1,
      body: Form(
        key: loginController.formKey,
        child: Column(
          children: [
            100.verticalSpace,
            CustomText(text: 'تسجيل الدخول'),
            CustomText(text: 'سجّل دخولك للوصول إلى حسابك وإدارة عملك بسهولة'),
            CustomText(text: 'البريد الالكتروني'),
            CustomTextField(controller: loginController.emailController),
            CustomText(text: 'كلمة المرور'),
            CustomTextField(controller: loginController.passwordController),
            CustomButton(text: 'تسجيل الدخول', onTap: () {
              loginController.handleLogin();
            }),
          ],
        ),
      ),
    );
  }
}
