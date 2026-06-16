import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hr_app_odoo/app/app_route.dart';
import 'package:hr_app_odoo/config/odoo_config.dart';
import 'package:hr_app_odoo/custom_widgets/custom_button/custom_button.dart';
import 'package:hr_app_odoo/custom_widgets/custom_dialog/custom_dialog.dart';
import 'package:hr_app_odoo/custom_widgets/custom_text/custom_text.dart';
import 'package:hr_app_odoo/generated/l10n/app_localizations.dart';
import 'package:hr_app_odoo/services/biometric_auth_service.dart';
import 'package:hr_app_odoo/services/hr_service.dart';
import 'package:hr_app_odoo/services/local_storage_service.dart';
import 'package:hr_app_odoo/services/odoo_rpc_service.dart';
import 'package:hr_app_odoo/services/simple_hr_service.dart';
import 'package:hr_app_odoo/theme/app_theme.dart';

class LoginController extends GetxController {
  LoginController({BiometricAuthService? biometricAuth})
    : _biometricAuth = biometricAuth ?? BiometricAuthService();

  final BiometricAuthService _biometricAuth;

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  RxBool isLoading = false.obs;
  RxBool isBiometricAvailable = false.obs;
  RxBool isBiometricEnabled = false.obs;

  @override
  void onReady() {
    super.onReady();
    _initLoginState();
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  Future<void> _initLoginState() async {
    await prefillSavedCredentials();
    await _refreshBiometricState();
    await tryBiometricLogin();
  }

  Future<void> _refreshBiometricState() async {
    final storage = LocalStorageService();
    isBiometricAvailable.value = await _biometricAuth.isAvailable();
    isBiometricEnabled.value = await storage.isBiometricLoginEnabled();
  }

  Future<void> prefillSavedCredentials() async {
    final storage = LocalStorageService();
    final savedEmail = await storage.getSavedEmail();
    final savedPassword = await storage.getSavedPassword();

    if (savedEmail != null) {
      emailController.text = savedEmail;
    }
    if (savedPassword != null) {
      passwordController.text = savedPassword;
    }
  }

  void changeLanguage() {
    if (Get.locale == const Locale('ar')) {
      Get.updateLocale(const Locale('en'));
    } else {
      Get.updateLocale(const Locale('ar'));
    }
  }

  Future<void> tryBiometricLogin() async {
    if (!isBiometricEnabled.value || !isBiometricAvailable.value) return;
    if (isLoading.value) return;

    final storage = LocalStorageService();
    final email = await storage.getSavedEmail();
    final password = await storage.getSavedPassword();
    if (email == null ||
        password == null ||
        email.isEmpty ||
        password.isEmpty) {
      return;
    }

    final l10n = AppLocalizations.of(Get.context!);
    if (l10n == null) return;

    final authenticated = await _biometricAuth.authenticate(
      reason: l10n.biometricLoginReason,
    );
    if (!authenticated) return;

    emailController.text = email;
    passwordController.text = password;
    await _loginWithCredentials(
      email: email,
      password: password,
      offerBiometricSetup: false,
    );
  }

  void handleLogin() {
    FocusScope.of(Get.context!).unfocus();
    if (!formKey.currentState!.validate()) return;

    _loginWithCredentials(
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
      offerBiometricSetup: true,
    );
  }

  Future<void> _loginWithCredentials({
    required String email,
    required String password,
    required bool offerBiometricSetup,
  }) async {
    if (isLoading.value) return;

    try {
      isLoading.value = true;
      final result = await OdooRPCService.instance.authenticate(
        username: email,
        password: password,
        database: OdooConfig.database,
      );

      if (!result.success) {
        _showSnackBar(
          result.error ?? AppLocalizations.of(Get.context!)!.authFailed,
          isError: true,
        );
        return;
      }

      final storage = LocalStorageService();
      await storage.saveLastCredentials(
        email: email,
        password: password,
        name: result.userName ?? '',
      );

      if (offerBiometricSetup) {
        await _maybeEnableBiometricLogin();
      }

      await OdooRPCService.instance.trackLoginTime();

      final hrService = HrService();
      final employee = await hrService.getCurrentEmployee();
      if (employee != null) {
        OdooRPCService.instance.setCurrentEmployeeId(
          employee.profile?.id ?? 0,
        );
      }

      final profile = await SimpleHrService().getProfile();
      final needsFaceRegistration = profile.profile?.hasImage != true;

      if (needsFaceRegistration) {
        Get.offAllNamed(AppRoutes.registerFace);
      } else {
        Get.offAllNamed(AppRoutes.home);
      }
    } catch (e) {
      _showSnackBar(
        AppLocalizations.of(Get.context!)!.connectionError(e.toString()),
        isError: true,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _maybeEnableBiometricLogin() async {
    if (!await _biometricAuth.isAvailable()) return;

    final storage = LocalStorageService();
    if (await storage.isBiometricLoginEnabled()) {
      isBiometricEnabled.value = true;
      return;
    }

    final l10n = AppLocalizations.of(Get.context!);
    if (l10n == null) return;

    final shouldEnable = await CustomDialog.dialog(
      barrierDismissible: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomText(
            text: l10n.enableBiometricTitle,
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.app1A1A1AText1,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          CustomText(
            text: l10n.enableBiometricMessage,
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.appA0A0A0Text2,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          CustomButton(
            text: l10n.enableBiometricConfirm,
            onTap: () => Get.back(result: true),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(l10n.notNow),
          ),
        ],
      ),
    );

    if (shouldEnable != true) return;

    final verified = await _biometricAuth.authenticate(
      reason: l10n.enableBiometricReason,
    );
    if (!verified) return;

    await storage.setBiometricLoginEnabled(true);
    isBiometricEnabled.value = true;
  }

  void _showSnackBar(String message, {required bool isError}) {
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
