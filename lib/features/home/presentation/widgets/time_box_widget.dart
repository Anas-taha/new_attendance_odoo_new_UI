import 'package:flutter/material.dart';
import 'package:hr_app_odoo/custom_widgets/custom_container/custom_container.dart';

class TimeBoxWidget extends StatelessWidget {
  TimeBoxWidget({super.key, required this.time});
  String time;
  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      child: Center(
        child: Text(
          time,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF6B46C1),
          ),
        ),
      ),
    );
  }
}
