import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hr_app_odoo/features/attendance/presentation/controller/attendance_controller.dart';
import 'package:hr_app_odoo/features/attendance/presentation/widgets/attendance_info_card_widget.dart';
import 'package:hr_app_odoo/features/attendance/presentation/widgets/weak_info_widget.dart';
import 'package:hr_app_odoo/theme/app_theme.dart';
import 'package:hr_app_odoo/custom_widgets/custom_screen/custom_screen.dart';
import 'package:hr_app_odoo/custom_widgets/custom_text/custom_text.dart';
import 'package:hr_app_odoo/custom_widgets/custom_text_field/custom_text_field.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  final controller = Get.find<AttendanceController>();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.init();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh attendance data when screen becomes visible
    controller.refreshAttendanceState();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScreen(
      appBarTitle: 'الحضور والانصراف',
      body: Column(
        children: [
          GestureDetector(
            onTap: () => controller.selectDate(),
            child: CustomTextField(
              controller: controller.dateController,
              enabled: false,
              usePrefixCalender: true,
              useSuffixArrow: true,
            ),
          ),
          16.verticalSpace,
          Row(
            children: [
              AttendanceInfoCardWidget(
                value: 1.toString(),
                state: AttendanceStateEnum.leaveEarly,
              ),
              10.horizontalSpace,
              AttendanceInfoCardWidget(
                value: 25.toString(),
                state: AttendanceStateEnum.absences,
              ),
              10.horizontalSpace,
              AttendanceInfoCardWidget(
                value: 3.toString(),
                state: AttendanceStateEnum.holidays,
              ),
              10.horizontalSpace,
              AttendanceInfoCardWidget(
                value: 99.toString(),
                state: AttendanceStateEnum.lateArrival,
              ),
            ],
          ),
          16.verticalSpace,
          Expanded(
            child: ListView.separated(
              itemCount: controller.weekCards.value.length,
              itemBuilder: (context, index) {
                {
                  return WeakInfoWidget(index: index);
                }
              },
              separatorBuilder: (context, index) => 8.verticalSpace,
            ),
          ),
        ],
      ),
    );
  }
}
