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
  RxBool hasSavedCredentials = false.obs;
  RxBool isBiometricRequired = false.obs;
  bool _autoBiometricAttempted = false;

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  Future<void> attemptAutoBiometricLogin({BuildContext? context}) async {
    if (_autoBiometricAttempted) {
      return;
    }
    _autoBiometricAttempted = true;

    await prefillSavedCredentials();
    await _refreshBiometricState();

    await Future<void>.delayed(const Duration(milliseconds: 350));

    if (!Get.isRegistered<LoginController>()) {
      return;
    }

    final activeContext = context ?? Get.context;
    if (activeContext == null) {
      return;
    }
    if (context != null && !context.mounted) {
      return;
    }

    if (!isBiometricRequired.value) {
      return;
    }

    await _handleRequiredBiometricLogin(context: activeContext);
  }

  Future<void> _refreshBiometricState() async {
    final storage = LocalStorageService();
    final savedEmail = await storage.getSavedEmail();
    final savedPassword = await storage.getSavedPassword();

    hasSavedCredentials.value =
        savedEmail != null &&
        savedPassword != null &&
        savedEmail.isNotEmpty &&
        savedPassword.isNotEmpty;
    isBiometricEnabled.value = await storage.isBiometricLoginEnabled();
    isBiometricRequired.value =
        hasSavedCredentials.value && isBiometricEnabled.value;

    final availability = await _biometricAuth.getAvailability();
    isBiometricAvailable.value =
        availability == BiometricAvailability.ready;
  }

  Future<void> prefillSavedCredentials() async {
    final storage = LocalStorageService();
    final savedEmail = await storage.getSavedEmail();
    final savedPassword = await storage.getSavedPassword();
    final biometricEnabled = await storage.isBiometricLoginEnabled();

    if (savedEmail != null) {
      emailController.text = savedEmail;
    }
    if (biometricEnabled) {
      passwordController.clear();
    } else if (savedPassword != null) {
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

  Future<void> tryBiometricLogin({BuildContext? context}) async {
    await _refreshBiometricState();
    if (context != null && !context.mounted) {
      return;
    }
    await _handleRequiredBiometricLogin(context: context);
  }

  Future<void> _handleRequiredBiometricLogin({BuildContext? context}) async {
    if (isLoading.value) {
      return;
    }

    final storage = LocalStorageService();
    final email = await storage.getSavedEmail();
    final password = await storage.getSavedPassword();
    if (email == null ||
        password == null ||
        email.isEmpty ||
        password.isEmpty) {
      return;
    }

    if (!isBiometricRequired.value) {
      return;
    }

    if (context != null && !context.mounted) {
      return;
    }

    final activeContext = context ?? Get.context;
    if (activeContext == null) {
      return;
    }

    final l10n = AppLocalizations.of(activeContext)!;

    final availability = await _biometricAuth.getAvailability();
    isBiometricAvailable.value =
        availability == BiometricAvailability.ready;

    if (availability == BiometricAvailability.disabledInSettings) {
      await _showBiometricSettingsDialog(l10n);
      return;
    }

    if (availability != BiometricAvailability.ready) {
      _showSnackBar(l10n.biometricSetupRequired, isError: true);
      return;
    }

    final authenticated = await _biometricAuth.authenticate(
      reason: l10n.biometricLoginReason,
    );
    if (!authenticated) {
      return;
    }

    emailController.text = email;
    passwordController.text = password;
    await _loginWithCredentials(
      email: email,
      password: password,
      offerBiometricSetup: false,
    );
  }

  Future<void> handleLogin() async {
    FocusScope.of(Get.context!).unfocus();
    await _refreshBiometricState();

    if (isBiometricRequired.value) {
      await tryBiometricLogin();
      return;
    }

    if (!formKey.currentState!.validate()) {
      return;
    }

    await _loginWithCredentials(
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
    if (isLoading.value) {
      return;
    }

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
        final enabled = await _requireBiometricLoginSetup();
        if (!enabled) {
          _showSnackBar(
            AppLocalizations.of(Get.context!)!.biometricSetupRequired,
            isError: true,
          );
          return;
        }
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

  Future<bool> _requireBiometricLoginSetup() async {
    final availability = await _biometricAuth.getAvailability();
    if (availability == BiometricAvailability.notSupported) {
      return true;
    }

    if (availability == BiometricAvailability.disabledInSettings) {
      final l10n = AppLocalizations.of(Get.context!);
      if (l10n != null) {
        await _showBiometricSettingsDialog(l10n);
      }
      return false;
    }

    final storage = LocalStorageService();
    if (await storage.isBiometricLoginEnabled()) {
      isBiometricEnabled.value = true;
      isBiometricRequired.value = true;
      return true;
    }

    final l10n = AppLocalizations.of(Get.context!);
    if (l10n == null) {
      return false;
    }

    while (true) {
      final confirmed = await CustomDialog.dialog(
        barrierDismissible: false,
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
              text: l10n.enableBiometricRequiredMessage,
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
          ],
        ),
      );

      if (confirmed != true) {
        continue;
      }

      final verified = await _biometricAuth.authenticate(
        reason: l10n.enableBiometricReason,
      );
      if (!verified) {
        continue;
      }

      await storage.setBiometricLoginEnabled(true);
      isBiometricEnabled.value = true;
      isBiometricRequired.value = true;
      return true;
    }
  }

  Future<void> _showBiometricSettingsDialog(AppLocalizations l10n) async {
    await CustomDialog.dialog(
      barrierDismissible: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomText(
            text: l10n.biometricRequiredTitle,
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.app1A1A1AText1,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          CustomText(
            text: l10n.biometricDisabledInSettings,
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.appA0A0A0Text2,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          CustomButton(
            text: l10n.openSettings,
            onTap: () async {
              await _biometricAuth.openDeviceSettings();
              Get.back();
            },
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () {
              Get.back();
              tryBiometricLogin();
            },
            child: Text(l10n.retryBiometric),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message, {required bool isError}) {
    final context = Get.context;
    if (context == null) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }
}
