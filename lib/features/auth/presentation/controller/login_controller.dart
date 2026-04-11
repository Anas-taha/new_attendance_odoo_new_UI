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
  void handleLogin() async {
    if (formKey.currentState!.validate()) {
      try {
        // Attempt to authenticate
        print('Attempting authentication with: ${emailController.text}');
        final result = await OdooRPCService.instance.authenticate(
          username: emailController.text.trim(),
          password: passwordController.text,
          database: OdooConfig.database,
        );

        print('Authentication result: $result');

        if (result.success == true) {
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

          // if (!mounted) return;
          final l10n = AppLocalizations.of(Get.context!)!;
          ScaffoldMessenger.of(Get.context!).showSnackBar(
            SnackBar(
              content: Text(
                l10n.welcomeName(employee?.name ?? emailController.text.trim()),
              ),
              backgroundColor: Colors.green,
            ),
          );

          // if (!mounted) return;
          Get.toNamed(AppRoutes.home);
          // Navigator.pushReplacement(
          //   context,
          //   MaterialPageRoute(builder: (context) => const HomeScreen()),
          // );
        } else {
          // if (mounted) {
          //   ScaffoldMessenger.of(Get.context!).showSnackBar(
          //     SnackBar(
          //       content: Text(
          //         result.error ?? AppLocalizations.of(Get.context!)!.authFailed,
          //       ),
          //       backgroundColor: Colors.red,
          //     ),
          //   );
          // }
        }
      } catch (e) {
        print('Login error: $e');
        // if (mounted) {
        //   ScaffoldMessenger.of(Get.context!).showSnackBar(
        //     SnackBar(
        //       content: Text(
        //         AppLocalizations.of(
        //           Get.context!,
        //         )!.connectionError(e.toString()),
        //       ),
        //       backgroundColor: Colors.red,
        //     ),
        //   );
        // }
      } finally {
        // if (mounted) {
        //   setState(() {
        //     _isLoading = false;
        //   });
        // }
      }
    }
  }
}
