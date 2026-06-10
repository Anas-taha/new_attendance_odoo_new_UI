// import 'dart:developer';

// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:get/get.dart';
// import 'package:hr_app_odoo/app/app_route.dart';
// import 'package:hr_app_odoo/custom_widgets/custom_button/custom_button.dart';
// import 'package:hr_app_odoo/custom_widgets/custom_dialog/custom_dialog.dart';
// import 'package:hr_app_odoo/custom_widgets/custom_text/custom_text.dart';
// import 'package:hr_app_odoo/features/profile/data/repositories/profile_repository_impl.dart';
// import 'package:hr_app_odoo/features/profile/domain/repositories/profile_repository.dart';
// import 'package:hr_app_odoo/features/profile/presentation/widgets/change_lang_widget.dart';
// import 'package:hr_app_odoo/generated/l10n/app_localizations.dart';
// import 'package:hr_app_odoo/models/hr_employee.dart';
// import 'package:hr_app_odoo/services/local_storage_service.dart';
// import 'package:hr_app_odoo/theme/app_theme.dart';

// class ProfileController extends GetxController {
//   ProfileController({ProfileRepository? profileRepository})
//     : _profileRepository = profileRepository ?? ProfileRepositoryImpl();

//   final ProfileRepository _profileRepository;

//   HrEmployee profileData = HrEmployee(id: 0, name: '');
//   RxBool loading = false.obs;

//   @override
//   void onReady() {
//     log(name: "ProfileControllerState", "onReady");
//     getProfileData();
//     super.onReady();
//   }

//   @override
//   void onClose() {
//     log(name: "ProfileControllerState", "onClose");
//     super.onClose();
//   }

//   Future<void> getProfileData() async {
//     loading.value = true;
//     final result = await _profileRepository.getProfileData();
//     if (result != null) {
//       profileData = result;
//       update();
//     }
//     loading.value = false;
//   }

//   void openChangeLanguageDialog() {
//     final l10n = AppLocalizations.of(Get.context!)!;
//     Get.bottomSheet(
//       Container(
//         padding: const EdgeInsets.all(13),
//         decoration: const BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             10.verticalSpace,
//             CustomText(
//               text: l10n.language,
//               fontSize: 16.w,
//               fontWeight: FontWeight.w700,
//               color: AppColors.appPrimaryColor,
//             ),
//             24.verticalSpace,
//             ChangeLangWidget(lang: 'ar'),
//             ChangeLangWidget(lang: 'en'),
//             const SizedBox(height: 10),
//           ],
//         ),
//       ),
//       isScrollControlled: true,
//     );
//   }

//   void logOut() {
//     final l10n = AppLocalizations.of(Get.context!)!;
//     CustomDialog.dialog(
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           CustomText(
//             text: l10n.logoutConfirm,
//             fontSize: 16,
//             fontWeight: FontWeight.w700,
//             color: AppColors.app1A1A1AText1,
//           ),
//           16.verticalSpace,
//           CustomButton(
//             text: l10n.logOut,
//             onTap: () async {
//               final storage = LocalStorageService();
//               await storage.saveLastCredentials(
//                 email: '',
//                 password: '',
//                 name: '',
//               );
//               Get.offAllNamed(AppRoutes.login);
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }
