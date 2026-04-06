import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hr_app_odoo/features/holidays/presentation/controller/holidays_controller.dart';
import 'package:hr_app_odoo/features/holidays/presentation/widgets/HolidayColoredStateCardWidget.dart';
import 'package:hr_app_odoo/theme/app_theme.dart';
import 'package:hr_app_odoo/custom_widgets/custom_text/custom_text.dart';

class HolidayDetailWidget extends StatelessWidget {
  HolidayDetailWidget({super.key, required this.state});
  final controller = Get.find<HolidaysController>();
  HolidayStateEnum state;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: AppColors.appFAFAFABackGround2,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                height: 13.h,
                width: 13.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: controller.holidayStateColor(state),
                ),
              ),
              8.horizontalSpace,
              CustomText(
                text: 'أجازه مرضية',
                fontSize: 14.w,
                fontWeight: FontWeight.w500,
                color: AppColors.app1A1A1AText1,
              ),
              4.horizontalSpace,
              CustomText(
                text: '01 مايو 2024',
                fontSize: 13.w,
                fontWeight: FontWeight.w500,
                color: AppColors.appA0A0A0Text2,
              ),
              Spacer(),
              HolidayColoredStateCardWidget(state: state),
            ],
          ),
          5.verticalSpace,
          _holidayDetail(
            title: 'سبب الاجازه',
            discription:
                'هناك حقيقة مثبتة منذ زمن طويل وهي أن المحتوى المقروء لصفحة ما سيلهي القارئ عن التركيز على الشكل ',
          ),
          state == HolidayStateEnum.rejected
              ? _holidayDetail(
                  title: 'سبب الرفض',
                  discription:
                      'هناك حقيقة مثبتة منذ زمن طويل وهي أن المحتوى المقروء لصفحة ما سيلهي القارئ عن التركيز على الشكل ',
                )
              : SizedBox.shrink(),
        ],
      ),
    );
  }

  Widget _holidayDetail({required String title, required String discription}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(color: AppColors.appE5E5E5Border),
        8.verticalSpace,
        CustomText(
          text: title,
          fontSize: 14.w,
          fontWeight: FontWeight.w500,
          color: AppColors.app1A1A1AText1,
        ),
        4.verticalSpace,
        CustomText(
          text: discription,
          fontSize: 13.w,
          fontWeight: FontWeight.w500,
          color: AppColors.appA0A0A0Text2,
        ),
        8.verticalSpace,
      ],
    );
  }
}
