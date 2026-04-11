import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hr_app_odoo/app/app_image.dart';
import 'package:hr_app_odoo/features/home/presentation/controllers/home_controller.dart';
import 'package:hr_app_odoo/features/home/presentation/widgets/quick_state_widget.dart';
import 'package:hr_app_odoo/features/home/presentation/widgets/time_box_widget.dart';
import 'package:hr_app_odoo/generated/l10n/app_localizations.dart';
import 'package:hr_app_odoo/theme/app_theme.dart';
import 'package:hr_app_odoo/custom_widgets/custom_button/custom_button.dart';
import 'package:hr_app_odoo/custom_widgets/custom_container/custom_container.dart';
import 'package:hr_app_odoo/custom_widgets/custom_text/custom_image_text_value.dart';
import 'package:hr_app_odoo/custom_widgets/custom_text/custom_text.dart';

class AttendanceWidget extends StatelessWidget {
  AttendanceWidget({super.key});
  final homeController = Get.find<HomeController>();
  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      color: AppColors.appFAFAFABackGround2,
      usedefaultSahdow: true,
      horizontalPadding: 16.w,
      verticalPadding: 14.h,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            children: [
              Obx(
                () => Expanded(
                  child: CustomTextValueAndImage(
                    text: homeController.currentDate.value,
                    textSize: 14.w,
                    textColor: AppColors.appPrimaryColor,
                    image: homeController.isAm.value
                        ? AppImage.moon
                        : AppImage.sun,
                    imageSize: 32.w,
                  ),
                ),
              ),
              CustomContainer(
                verticalPadding: 8,
                child: CustomText(
                  text: 'حي الجامعه.منطقة الزهور',
                  fontSize: 13.w,
                  fontWeight: FontWeight.w600,
                  color: AppColors.appPrimaryColor,
                ),
              ),
            ],
          ),
          8.verticalSpace,
          Obx(() {
            return Row(
              children: [
                CustomText(
                  text: '${homeController.formattedTime} / ',
                  fontSize: 18.w,
                  color: AppColors.app1A1A1AText1,
                  fontWeight: FontWeight.w500,
                ),
                CustomText(
                  text: homeController.totalToday.value,
                  color: AppColors.appA0A0A0Text2,
                  fontSize: 13.w,
                ),
              ],
            );
          }),
          8.verticalSpace,
          Obx(
            () => CustomButton(
              text: homeController.isRunning.value
                  ? 'تسجيل الانصراف'
                  : 'تسجيل الحضور',
              onTap: () {
                homeController.timerSwitchButton();
              },
            ),
          ),
        ],
      ),

      // child: Column(
      //   children: [
      //     const SizedBox(height: 20),
      //     Row(
      //       children: [
      //         Expanded(
      //           child: QuickStateWidget(
      //             icon: Icons.timer,
      //             title: AppLocalizations.of(context)!.today,
      //             value: homeController.totalToday.value,
      //             color: const Color(0xFF667eea),
      //           ),
      //         ),
      //         const SizedBox(width: 16),
      //         Expanded(
      //           child: QuickStateWidget(
      //             icon: Icons.schedule,
      //             title: AppLocalizations.of(context)!.thisWeek,
      //             value: homeController.beforeTime.value,
      //             color: const Color(0xFF764ba2),
      //           ),
      //         ),
      //       ],
      //     ),
      //     const SizedBox(height: 20),
      //     if (homeController.isCheckedIn.value) ...[
      //       Container(
      //         padding: const EdgeInsets.all(16),
      //         decoration: BoxDecoration(
      //           gradient: const LinearGradient(
      //             colors: [Color(0xFF6B46C1), Color(0xFF9F7AEA)],
      //             begin: Alignment.topLeft,
      //             end: Alignment.bottomRight,
      //           ),
      //           borderRadius: BorderRadius.circular(12),
      //         ),
      //         child: Column(
      //           children: [
      //             Text(
      //               AppLocalizations.of(context)!.currentSession,
      //               style: const TextStyle(
      //                 color: Colors.white,
      //                 fontSize: 14,
      //                 fontWeight: FontWeight.w500,
      //               ),
      //             ),
      //             const SizedBox(height: 8),
      //             Row(
      //               mainAxisAlignment: MainAxisAlignment.center,
      //               children: [
      //                 TimeBoxWidget(
      //                   time:
      //                       '${(homeController.seconds.value ~/ 3600).toString().padLeft(2, '0')}',
      //                 ),
      //                 const Text(
      //                   ' : ',
      //                   style: TextStyle(
      //                     color: Colors.white,
      //                     fontSize: 24,
      //                     fontWeight: FontWeight.bold,
      //                   ),
      //                 ),
      //                 TimeBoxWidget(
      //                   time:
      //                       '${((homeController.seconds.value % 3600) ~/ 60).toString().padLeft(2, '0')}',
      //                 ),
      //                 const Text(
      //                   ' : ',
      //                   style: TextStyle(
      //                     color: Colors.white,
      //                     fontSize: 24,
      //                     fontWeight: FontWeight.bold,
      //                   ),
      //                 ),
      //                 TimeBoxWidget(
      //                   time:
      //                       '${(homeController.seconds.value % 60).toString().padLeft(2, '0')}',
      //                 ),
      //               ],
      //             ),
      //             const SizedBox(height: 8),
      //             Text(
      //               AppLocalizations.of(
      //                 context,
      //               )!.startedAt(homeController.checkInTime.value),
      //               style: const TextStyle(color: Colors.white70, fontSize: 12),
      //             ),
      //           ],
      //         ),
      //       ),
      //       const SizedBox(height: 20),
      //     ],
      //     Column(
      //       crossAxisAlignment: CrossAxisAlignment.start,
      //       children: [
      //         Text(
      //           AppLocalizations.of(context)!.registerAttendance,
      //           style: const TextStyle(
      //             fontSize: 16,
      //             fontWeight: FontWeight.bold,
      //             color: Color(0xFF2D3748),
      //           ),
      //         ),
      //         const SizedBox(height: 12),
      //         Row(
      //           children: [
      //             Expanded(
      //               child: ElevatedButton.icon(
      //                 onPressed: () =>
      //                     Navigator.pushNamed(context, '/face-attendance'),
      //                 icon: Icon(
      //                   homeController.isCheckedIn.value
      //                       ? Icons.logout
      //                       : Icons.login,
      //                 ),
      //                 label: Text(
      //                   homeController.isCheckedIn.value
      //                       ? AppLocalizations.of(context)!.checkOutFace
      //                       : AppLocalizations.of(context)!.checkInFace,
      //                 ),
      //                 style: ElevatedButton.styleFrom(
      //                   backgroundColor: homeController.isCheckedIn.value
      //                       ? Colors.red[600]
      //                       : Colors.green[600],
      //                   foregroundColor: Colors.white,
      //                   padding: const EdgeInsets.symmetric(vertical: 12),
      //                   shape: RoundedRectangleBorder(
      //                     borderRadius: BorderRadius.circular(8),
      //                   ),
      //                 ),
      //               ),
      //             ),
      //             const SizedBox(width: 12),
      //             Expanded(
      //               child: OutlinedButton.icon(
      //                 onPressed: () => Navigator.pushNamed(
      //                   context,
      //                   '/attendance',
      //                   arguments: {
      //                     'isCheckedIn': homeController.isCheckedIn.value,
      //                     'checkInDateTime':
      //                         homeController.checkInDateTime.value,
      //                     'checkInTime': homeController.checkInTime.value,
      //                     'totalWorkedHours': homeController.totalToday.value,
      //                   },
      //                 ),
      //                 icon: const Icon(Icons.visibility),
      //                 label: Text(AppLocalizations.of(context)!.viewDetails),
      //                 style: OutlinedButton.styleFrom(
      //                   foregroundColor: const Color(0xFF6B46C1),
      //                   side: const BorderSide(color: Color(0xFF6B46C1)),
      //                   padding: const EdgeInsets.symmetric(vertical: 12),
      //                   shape: RoundedRectangleBorder(
      //                     borderRadius: BorderRadius.circular(8),
      //                   ),
      //                 ),
      //               ),
      //             ),
      //           ],
      //         ),
      //       ],
      //     ),
      //   ],
      // ),
    );
  }
}
