import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hr_app_odoo/services/extension.dart';
import 'package:hr_app_odoo/app/app_route.dart';
import 'package:hr_app_odoo/custom_widgets/custom_button/custom_button.dart';
import 'package:hr_app_odoo/custom_widgets/custom_dialog/custom_dialog.dart';
import 'package:hr_app_odoo/custom_widgets/custom_text/custom_text.dart';
import 'package:hr_app_odoo/features/profile/presentation/widgets/change_lang_widget.dart';
import 'package:hr_app_odoo/models/hr_employee.dart';
import 'package:hr_app_odoo/services/local_storage_service.dart';
import 'package:hr_app_odoo/services/simple_hr_service.dart';
import 'package:hr_app_odoo/theme/app_theme.dart';
import 'package:path/path.dart';

class ProfileController extends GetxController {
  // ignore: prefer_typing_uninitialized_variables
  SimpleHrService hrService = SimpleHrService();
  HrEmployee profileData = HrEmployee(id: 0, name: '');
  RxBool loading = false.obs;
  @override
  void onReady() {
    log(name: "ProfileControllerState", "onReady");
    getProfileData();
    super.onReady();
  }

  @override
  void onClose() {
    log(name: "ProfileControllerState", "onClose");
    super.onClose();
  }
  // void initData() {
  //   getProfileData();
  // }

  void getProfileData() async {
    loading.value = true;
    final result = await hrService.getEmployeeProfile();
    if (result.isNotEmpty) {
      profileData = result.first;
      update();
      loading.value = false;
    } else {
      loading.value = false;
    }
  }

  void openChangeLanguageDialog() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(13),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            10.verticalSpace,
            CustomText(
              text: Get.context!.appWords.language,
              fontSize: 16.w,
              fontWeight: FontWeight.w700,
              color: AppColors.appPrimaryColor,
            ),
            24.verticalSpace,
            ChangeLangWidget(lang: 'ar'),
            ChangeLangWidget(lang: 'en'),
            const SizedBox(height: 10),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  void logOut() async {
    CustomDialog.dialog(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomText(
            text: 'هل أنت متأكد من تسجيل الخروج؟',
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.app1A1A1AText1,
          ),
          16.verticalSpace,
          CustomButton(
            text: 'تسجيل الخروج',
            onTap: () async {
              final storage = LocalStorageService();
              await storage.saveLastCredentials(
                email: '',
                password: '',
                name: '',
              );
              Get.offAllNamed(AppRoutes.login);
            },
          ),
        ],
      ),
    );
  }
}
