import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hr_app_odoo/custom_widgets/custom_calender/custom_calender.dart';

class SalariesController extends GetxController {
  TextEditingController dateController = TextEditingController();
  void init() {
    dateController.text = '';
  }

  void selectDate() {
    CustomCalender.calenderDialog(
      contorller: dateController,
      title: 'اختر التاريخ',
    );
  }
}
