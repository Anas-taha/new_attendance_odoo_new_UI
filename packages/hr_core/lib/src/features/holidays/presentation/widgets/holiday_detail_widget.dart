import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hr_core/src/features/holidays/presentation/controller/holidays_controller.dart';
import 'package:hr_core/src/features/holidays/presentation/widgets/HolidayColoredStateCardWidget.dart';
import 'package:hr_core/src/models/holiday_model.dart';
import 'package:hr_core/src/services/extension.dart';
import 'package:hr_core/src/theme/app_theme.dart';
import 'package:hr_core/src/custom_widgets/custom_text/custom_text.dart';

class HolidayDetailWidget extends StatelessWidget {
  const HolidayDetailWidget({
    super.key,
    required this.state,
    required this.leave,
    required this.stateTitle,
    required this.stateColor,
    required this.cardColor,
  });

  final HolidayStateEnum state;
  final Leaves? leave;
  final String stateTitle;
  final Color stateColor;
  final Color cardColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
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
                  color: stateColor,
                ),
              ),
              8.horizontalSpace,
              CustomText(
                text: leave?.title ?? '',
                fontSize: 14.w,
                fontWeight: FontWeight.w500,
                color: AppColors.app1A1A1AText1,
              ),
              4.horizontalSpace,
              CustomText(
                text: leave?.dateFrom ?? '',
                fontSize: 13.w,
                fontWeight: FontWeight.w500,
                color: AppColors.appA0A0A0Text2,
              ),
              const Spacer(),
              HolidayColoredStateCardWidget(
                title: stateTitle,
                stateColor: stateColor,
                cardColor: cardColor,
              ),
            ],
          ),
          5.verticalSpace,
          _holidayDetail(
            title: context.appWords.leaveReason,
            discription: leave?.holidayReason ?? '',
          ),
          if (state == HolidayStateEnum.rejected &&
              leave?.rejectedReason != null &&
              leave!.rejectedReason!.isNotEmpty)
            _holidayDetail(
              title: context.appWords.rejectionReason,
              discription: leave?.rejectedReason ?? '',
            ),
        ],
      ),
    );
  }

  Widget _holidayDetail({required String title, required String discription}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(color: AppColors.appE5E5E5Border),
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
