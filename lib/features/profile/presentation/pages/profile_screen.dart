import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:hr_app_odoo/app/app_image.dart';
import 'package:hr_app_odoo/app/app_route.dart';
import 'package:hr_app_odoo/custom_widgets/custom_container/custom_container.dart';
import 'package:hr_app_odoo/custom_widgets/custom_image/custom_image.dart';
import 'package:hr_app_odoo/custom_widgets/custom_text/custom_text.dart';
import 'package:hr_app_odoo/features/profile/presentation/controller/profile_controller.dart';
import 'package:hr_app_odoo/features/profile/presentation/widgets/profile_appbar_widget.dart';
import 'package:hr_app_odoo/features/profile/presentation/widgets/profile_info_item_widget.dart';
import 'package:hr_app_odoo/theme/app_theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final controller = Get.find<ProfileController>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.app670379Sedondary2,
      body: Column(
        children: [
          16.verticalSpace,
          ProfileAppBar(),
          20.verticalSpace,
          Expanded(
            child: Stack(
              alignment: AlignmentGeometry.topCenter,
              children: [
                Column(
                  children: [
                    50.verticalSpace,
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.appFFFFFFBackGround1,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10),
                          ),
                        ),
                        child: Column(
                          children: [
                            60.verticalSpace,
                            CustomText(
                              text: 'محمد ممدوح',
                              fontSize: 16.w,
                              fontWeight: FontWeight.w700,
                              color: AppColors.app1A1A1AText1,
                            ),
                            8.verticalSpace,
                            CustomText(
                              text: 'مدير انتاج فرع الرياض',
                              fontSize: 16.w,
                              fontWeight: FontWeight.w400,
                              color: AppColors.appA0A0A0Text2,
                            ),
                            14.verticalSpace,
                            GestureDetector(
                              onTap: () {},
                              child: CustomContainer(
                                color: AppColors.appFAFAFABackGround2,
                                child: Column(
                                  children: [
                                    ProfileItemInfoWidget(
                                      title: 'المدير المباشر',
                                      value: 'سالم عبد الحكيم صابر',
                                    ),
                                    ProfileItemInfoWidget(
                                      title: 'تابع الي قسم',
                                      value: 'قسم الانتاج',
                                    ),
                                    ProfileItemInfoWidget(
                                      title: 'فرع',
                                      value: 'الفرع الرئيسي بالرياض',
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            16.verticalSpace,
                            CustomContainer(
                              color: AppColors.appFAFAFABackGround2,
                              child: Column(
                                children: [
                                  ProfileItemInfoWidget(
                                    title: 'رقم الهاتف',
                                    value: '123456789',
                                  ),
                                  ProfileItemInfoWidget(
                                    title: 'البريد الالكرتوني',
                                    value:
                                        'username@forexamername@forexaple.com',
                                  ),
                                ],
                              ),
                            ),
                            16.verticalSpace,
                            GestureDetector(
                              onTap: () =>
                                  controller.openChangeLanguageDialog(),
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 13),
                                height: 54.h,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: AppColors.appFAFAFABackGround2,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Row(
                                  children: [
                                    CustomImage(
                                      image: AppImage.changeLang,
                                      height: 30.h,
                                      width: 30.h,
                                    ),
                                    5.horizontalSpace,
                                    CustomText(
                                      text: 'اللغة',
                                      fontSize: 13.w,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.app1A1A1AText1,
                                    ),
                                    Spacer(),
                                    Icon(
                                      Icons.arrow_forward_ios,
                                      size: 16.w,
                                      color: AppColors.app6C757DText5,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Container(
                  height: 100.h,
                  width: 100.w,
                  padding: EdgeInsets.all(13),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.appFFFFFFBackGround1,
                  ),
                  child: CustomImage(
                    shape: BoxShape.circle,
                    image: AppImage.defaultProfile,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
