import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hr_app_odoo/features/attendance/presentation/controller/attendance_controller.dart';
import 'package:hr_app_odoo/widgets/custom_screen/custom_screen.dart';

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
    return CustomScreen(body: Column());
  }
}
