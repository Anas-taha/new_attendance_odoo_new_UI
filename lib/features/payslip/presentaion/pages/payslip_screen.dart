import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hr_app_odoo/services/extension.dart';
import 'package:hr_app_odoo/app/app_image.dart';
import 'package:hr_app_odoo/features/payslip/presentaion/controller/payslip_controller.dart';
import 'package:hr_app_odoo/theme/app_theme.dart';
import 'package:hr_app_odoo/custom_widgets/custom_appbar/custom_appbar.dart';
import 'package:hr_app_odoo/custom_widgets/custom_button/custom_button.dart';
import 'package:hr_app_odoo/custom_widgets/custom_container/custom_container.dart';
import 'package:hr_app_odoo/custom_widgets/custom_image/custom_image.dart';
import 'package:hr_app_odoo/custom_widgets/custom_screen/custom_screen.dart';
import 'package:hr_app_odoo/custom_widgets/custom_text/custom_text.dart';
import 'package:hr_app_odoo/custom_widgets/custom_text_field/custom_text_field.dart';

class PayslipScreen extends StatelessWidget {
  const PayslipScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PayslipController>(
      builder: (controller) {
        return CustomScreen(
          loading: controller.isLoading,
          floatingActionButton: Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: CustomButton(
              text:context.appWords.downloadPayslip ,
              onTap: () {
                controller.generatePdf();
              },
            ),
          ),
          appBarTitle: context.appWords.salary,
          body: Column(
            children: [
              GestureDetector(
                onTap: () => controller.selectDate(),
                child: CustomTextField(
                  hintText: context.appWords.selectDate,
                  usePrefixCalender: true,
                  useSuffixArrow: true,
                  controller: controller.dateController,
                  enabled: false,
                ),
              ),
              16.verticalSpace,
              Stack(
                alignment: AlignmentGeometry.center,
                children: [
                  Container(
                    height: 130.h,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: CustomImage(
                        image: AppImage.salaryCard,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      CustomText(
                        text: controller.salary.toString(),
                        color: AppColors.appFFFFFFBackGround1,
                        fontSize: 30.w,
                        fontWeight: FontWeight.w700,
                      ),
                      10.verticalSpace,
                      CustomText(
                        text: context.appWords.mainSalary,
                        color: AppColors.appFFFFFFBackGround1,
                        fontWeight: FontWeight.w700,
                      ),
                    ],
                  ),
                ],
              ),
              16.verticalSpace,
              GestureDetector(
                onTap: () {
                  controller.getPayslipLine();
                },
                child: CustomContainer(
                  horizontalPadding: 16,
                  verticalPadding: 16,
                  color: AppColors.appFAFAFABackGround2,
                  borderColor: AppColors.appE5E5E5Border,
                  child: Row(
                    children: [
                      CustomText(
                        text: context.appWords.allowances,
                        color: AppColors.appPrimaryColor,
                        fontWeight: FontWeight.w700,
                      ),
                      Spacer(),
                      CustomText(
                        text: '0',
                        color: AppColors.appPrimaryColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ],
                  ),
                ),
              ),
              16.verticalSpace,
              CustomContainer(
                horizontalPadding: 16,
                verticalPadding: 16,
                color: AppColors.appFDD9D7CardBG2,

                child: Row(
                  children: [
                    CustomText(
                      text: context.appWords.deductions,
                      color: AppColors.appF44336Error,
                      fontWeight: FontWeight.w700,
                    ),
                    Spacer(),
                    CustomText(
                      text: '2000',
                      color: AppColors.appF44336Error,
                      fontWeight: FontWeight.w700,
                    ),
                  ],
                ),
              ),
              16.verticalSpace,
              CustomContainer(
                horizontalPadding: 16,
                verticalPadding: 16,
                color: AppColors.appEEF7EECardBG3,

                child: Row(
                  children: [
                    CustomText(
                      text:context.appWords.netSalary,
                      color: AppColors.app4CAF50Success,
                      fontWeight: FontWeight.w700,
                    ),
                    Spacer(),
                    CustomText(
                      text: '30.000',
                      color: AppColors.app4CAF50Success,
                      fontWeight: FontWeight.w700,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
