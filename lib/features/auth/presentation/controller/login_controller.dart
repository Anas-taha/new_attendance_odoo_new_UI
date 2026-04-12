import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:hr_app_odoo/app/app_route.dart';
import 'package:hr_app_odoo/config/odoo_config.dart';
import 'package:hr_app_odoo/generated/l10n/app_localizations.dart';
import 'package:hr_app_odoo/services/hr_service.dart';
import 'package:hr_app_odoo/services/local_storage_service.dart';
import 'package:hr_app_odoo/services/odoo_rpc_service.dart';

class LoginController extends GetxController {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  RxBool isLoading = false.obs;
  @override
  void onReady() {
    super.onReady();
    prefillSavedCredentials();
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

  void handleLogin() async {
    FocusScope.of(Get.context!).unfocus();
    if (formKey.currentState!.validate()) {
      try {
        isLoading.value = true;
        final result = await OdooRPCService.instance.authenticate(
          username: emailController.text.trim(),
          password: passwordController.text,
          database: OdooConfig.database,
        );
        if (result.success) {
          final storage = LocalStorageService();
          await storage.saveLastCredentials(
            email: emailController.text.trim(),
            password: passwordController.text,
            name: result.userName ?? '',
          );
          await OdooRPCService.instance.trackLoginTime();
          final hrService = HrService();
          final employee = await hrService.getCurrentEmployee();
          if (employee != null) {
            OdooRPCService.instance.setCurrentEmployeeId(employee.id);
          }
          // // if (!mounted) return;
          // final l10n = AppLocalizations.of(Get.context!)!;
          // ScaffoldMessenger.of(Get.context!).showSnackBar(
          //   SnackBar(
          //     content: Text(
          //       l10n.welcomeName(employee?.name ?? emailController.text.trim()),
          //     ),
          //     backgroundColor: Colors.green,
          //   ),
          // );
          isLoading.value = false;
          Get.toNamed(AppRoutes.home);
        } else {
          isLoading.value = false;
          ScaffoldMessenger.of(Get.context!).showSnackBar(
            SnackBar(
              content: Text(
                result.error ?? AppLocalizations.of(Get.context!)!.authFailed,
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        isLoading.value = false;
        print('Login error: $e');
        ScaffoldMessenger.of(Get.context!).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(Get.context!)!.connectionError(e.toString()),
            ),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        isLoading.value = false;
      }
    }
  }
}
