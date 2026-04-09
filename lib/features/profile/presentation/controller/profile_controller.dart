import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hr_app_odoo/custom_widgets/custom_text/custom_text.dart';
import 'package:hr_app_odoo/features/profile/presentation/widgets/change_lang_widget.dart';
import 'package:hr_app_odoo/models/hr_employee.dart';
import 'package:hr_app_odoo/services/simple_hr_service.dart';
import 'package:hr_app_odoo/theme/app_theme.dart';

class ProfileController extends GetxController {
  // ignore: prefer_typing_uninitialized_variables
  SimpleHrService hrService = SimpleHrService();
  Rx<HrEmployee> profileData = HrEmployee(id: 0, name: '').obs;
  RxBool loading = false.obs;

  void init() {
    getProfileData();
  }

  void getProfileData() async {
    loading.value = true;
    final result = await hrService.getEmployeeProfile();
    if (result.isNotEmpty) {
      profileData.value = result.first;

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
              text: 'اللغه',
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
}
