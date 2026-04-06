import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:hr_app_odoo/custom_widgets/custom_drop_down/custom_drop_down.dart';
import 'package:hr_app_odoo/features/holidays/presentation/controller/holidays_controller.dart';
import 'package:hr_app_odoo/theme/app_theme.dart';
import 'package:hr_app_odoo/custom_widgets/custom_button/custom_button.dart';
import 'package:hr_app_odoo/custom_widgets/custom_screen/custom_screen.dart';
import 'package:hr_app_odoo/custom_widgets/custom_text/custom_text.dart';
import 'package:hr_app_odoo/custom_widgets/custom_text_field/custom_text_field.dart';

class RequestHolidayScreen extends StatefulWidget {
  RequestHolidayScreen({super.key});

  @override
  State<RequestHolidayScreen> createState() => _RequestHolidayScreenState();
}

class _RequestHolidayScreenState extends State<RequestHolidayScreen> {
  final controller = Get.find<HolidaysController>();
  @override
  void initState() {
    super.initState();
    controller.init();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScreen(
      floatingActionButton: CustomButton(text: 'ارسال', onTap: () {}),
      appBarTitle: 'طلب اجازة',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            text: 'نوع الاجازة',
            fontSize: 14.w,
            fontWeight: FontWeight.w500,
            color: AppColors.app1A1A1AText1,
          ),
          8.verticalSpace,
          CustomDropDown(
            itemList: ['1', '2', '3'],
            onSelect: (type) {
              controller.selectHoolidayType(type);
            },
          ),

          16.verticalSpace,
          CustomText(
            text: 'تاريخ البداية',
            fontSize: 14.w,
            fontWeight: FontWeight.w500,
            color: AppColors.app1A1A1AText1,
          ),
          8.verticalSpace,
          GestureDetector(
            onTap: () {
              controller.selectStartDate();
            },
            child: CustomTextField(
              controller: controller.holidayStartDateController,
              enabled: false,
              usePrefixCalender: true,
              useSuffixArrow: true,
            ),
          ),
          16.verticalSpace,
          CustomText(
            text: 'تاريخ النهاية',
            fontSize: 14.w,
            fontWeight: FontWeight.w500,
            color: AppColors.app1A1A1AText1,
          ),
          8.verticalSpace,
          GestureDetector(
            onTap: () {
              controller.selectEndDate();
            },
            child: CustomTextField(
              controller: controller.holidayEndDateController,
              enabled: false,
              usePrefixCalender: true,
              useSuffixArrow: true,
            ),
          ),
          16.verticalSpace,
          CustomText(
            text: 'سبب الاجازة',
            fontSize: 14.w,
            fontWeight: FontWeight.w500,
            color: AppColors.app1A1A1AText1,
          ),
          8.verticalSpace,
          CustomTextField(controller: TextEditingController(), maxLines: 2),
        ],
      ),
    );
  }
}
