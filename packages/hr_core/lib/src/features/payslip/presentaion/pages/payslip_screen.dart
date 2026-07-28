import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hr_core/src/app/app_image.dart';
import 'package:hr_core/src/custom_widgets/custom_button/custom_button.dart';
import 'package:hr_core/src/custom_widgets/custom_container/custom_container.dart';
import 'package:hr_core/src/custom_widgets/custom_image/custom_image.dart';
import 'package:hr_core/src/custom_widgets/custom_screen/custom_screen.dart';
import 'package:hr_core/src/custom_widgets/custom_text/custom_text.dart';
import 'package:hr_core/src/custom_widgets/custom_text_field/custom_text_field.dart';
import 'package:hr_core/src/features/payslip/presentation/controllers/payslip_controller.dart';
import 'package:hr_core/src/services/extension.dart';
import 'package:hr_core/src/theme/app_theme.dart';

class PayslipScreen extends StatelessWidget {
  const PayslipScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PayslipController>(
      builder: (controller) {
        return CustomScreen(
          loading: controller.isLoading,
          floatingActionButton: !controller.hasPayslips
              ? null
              : Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: CustomButton(
                    text: context.appWords.downloadPayslip,
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
              if (!controller.hasPayslips) ...[
                Expanded(
                  child: Center(
                    child: CustomText(
                      text: context.appWords.noPayslipsFound,
                      color: AppColors.appPrimaryColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ] else ...[
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
                        text: _amountLabel(controller.salary.basicSalary),
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
                        text: _amountLabel(controller.salary.allowances),
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
                      text: _amountLabel(controller.salary.deductions),
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
                      text: context.appWords.netSalary,
                      color: AppColors.app4CAF50Success,
                      fontWeight: FontWeight.w700,
                    ),
                    Spacer(),
                    CustomText(
                      text: _amountLabel(controller.salary.netSalary),
                      color: AppColors.app4CAF50Success,
                      fontWeight: FontWeight.w700,
                    ),
                  ],
                ),
              ),
              ],
            ],
          ),
        );
      },
    );
  }

  String _amountLabel(num? value) => (value ?? 0).toStringAsFixed(2);
}
