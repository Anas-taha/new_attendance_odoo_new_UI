import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hr_core/src/app/app_image.dart';
import 'package:hr_core/src/custom_widgets/custom_button/custom_button.dart';
import 'package:hr_core/src/custom_widgets/custom_container/custom_container.dart';
import 'package:hr_core/src/custom_widgets/custom_text/custom_image_text_value.dart';
import 'package:hr_core/src/custom_widgets/custom_text/custom_text.dart';
import 'package:hr_core/src/features/home/presentation/controllers/home_controller.dart';
import 'package:hr_core/src/features/home/presentation/widgets/time_box_widget.dart';
import 'package:hr_core/src/services/extension.dart';
import 'package:hr_core/src/theme/app_theme.dart';

class AttendanceWidget extends StatelessWidget {
  const AttendanceWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final homeController = Get.find<HomeController>();
    final brand = Theme.of(context).colorScheme.secondary;
    final primary = Theme.of(context).colorScheme.primary;

    return CustomContainer(
      color: AppColors.appFAFAFABackGround2,
      usedefaultSahdow: true,
      horizontalPadding: 16.w,
      verticalPadding: 14.h,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Obx(
                () => Expanded(
                  child: CustomTextValueAndImage(
                    text: homeController.currentDate.value,
                    textSize: 14.sp,
                    textColor: primary,
                    image: homeController.isAm.value
                        ? AppImage.sun
                        : AppImage.moon,
                    imageSize: 28.w,
                  ),
                ),
              ),
              Obx(() {
                final checkedIn = homeController.isCheckedIn.value;
                return Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: checkedIn
                        ? brand.withValues(alpha: 0.12)
                        : AppColors.appA0A0A0Text2.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: checkedIn
                          ? brand.withValues(alpha: 0.35)
                          : AppColors.appA0A0A0Text2.withValues(alpha: 0.25),
                    ),
                  ),
                  child: CustomText(
                    text: checkedIn
                        ? context.appWords.checkedInActive
                        : context.appWords.notCheckedIn,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: checkedIn ? brand : AppColors.appA0A0A0Text2,
                  ),
                );
              }),
            ],
          ),
          10.verticalSpace,
          Obx(
            () => GestureDetector(
              onTap: () => homeController.resolveLocationAndAddress(
                forceRefresh: true,
              ),
              onLongPress: homeController.addressDialog,
              child: Row(
                children: [
                  if (homeController.isResolvingLocation.value)
                    SizedBox(
                      width: 14.w,
                      height: 14.w,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: brand,
                      ),
                    )
                  else
                    Icon(
                      Icons.location_on_outlined,
                      size: 16.sp,
                      color: brand,
                    ),
                  4.horizontalSpace,
                  Flexible(
                    child: CustomText(
                      text: homeController.isResolvingLocation.value
                          ? context.appWords.waitingForLocation
                          : homeController.address.value.isNotEmpty
                              ? homeController.address.value
                              : context.appWords.enterYourAddress,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: primary,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Obx(() {
            if (!homeController.isCheckedIn.value) {
              return Padding(
                padding: EdgeInsets.only(top: 10.h),
                child: Row(
                  children: [
                    CustomText(
                      text: '${homeController.formattedTime} / ',
                      fontSize: 18.sp,
                      color: AppColors.app1A1A1AText1,
                      fontWeight: FontWeight.w500,
                    ),
                    CustomText(
                      text: homeController.totalToday.value,
                      color: AppColors.appA0A0A0Text2,
                      fontSize: 13.sp,
                    ),
                  ],
                ),
              );
            }

            homeController.elapsed.value;
            final totalSeconds = homeController.elapsed.value.inSeconds;
            final hours =
                (totalSeconds ~/ 3600).toString().padLeft(2, '0');
            final minutes =
                ((totalSeconds % 3600) ~/ 60).toString().padLeft(2, '0');
            final secs = (totalSeconds % 60).toString().padLeft(2, '0');

            return Padding(
              padding: EdgeInsets.only(top: 12.h),
              child: Column(
                children: [
                  CustomText(
                    text: context.appWords.currentSession,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.appA0A0A0Text2,
                  ),
                  8.verticalSpace,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TimeBoxWidget(time: hours),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4.w),
                        child: Text(
                          ':',
                          style: TextStyle(
                            color: brand,
                            fontSize: 22.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      TimeBoxWidget(time: minutes),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4.w),
                        child: Text(
                          ':',
                          style: TextStyle(
                            color: brand,
                            fontSize: 22.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      TimeBoxWidget(time: secs),
                    ],
                  ),
                  6.verticalSpace,
                  CustomText(
                    text: context.appWords
                        .startedAt(homeController.checkInTime.value),
                    fontSize: 12.sp,
                    color: AppColors.appA0A0A0Text2,
                  ),
                ],
              ),
            );
          }),
          12.verticalSpace,
          Obx(
            () => CustomButton(
              text: homeController.isCheckedIn.value
                  ? context.appWords.checkOut
                  : context.appWords.checkIn,
              onTap: () {
                if (!homeController.isLoading.value) {
                  homeController.handleAttendance();
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
