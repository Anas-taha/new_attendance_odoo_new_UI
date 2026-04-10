import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hr_app_odoo/custom_widgets/custom_calender/custom_calender.dart';
import 'package:hr_app_odoo/models/hr_payslip.dart';
import 'package:hr_app_odoo/services/simple_hr_service.dart';

class SalariesController extends GetxController {
  TextEditingController dateController = TextEditingController();
  SimpleHrService hrService = SimpleHrService();
  Rx<bool> salary = false.obs;
  RxBool isLoading = false.obs;
  void init() {
    dateController.text = '';
    getSalaries();
  }

  void getSalaries() async {
    isLoading.value = true;
    final result = await hrService.getPayslip();
    if (result) {
      // salary.value = result.first;
      salary.value = true;
      log(name: 'iscbisducbds', 'result: $result');
    } else {
      salary.value = false;
      // salary.value = HrSalaryModel();
      log(name: 'iscbisducbds', 'result: $result');
    }
    isLoading.value = false;
  }

  void getPayslipLine() async {
    isLoading.value = true;
    final result = await hrService.getPayslipLine();
    if (result) {
      log(name: 'qqqqqqqqqq', 'result: $result');
    } else {
      log(name: 'qqqqqqqqqq', 'result: $result');
    }
    isLoading.value = false;
  }

  void selectDate() {
    CustomCalender.calenderDialog(
      contorller: dateController,
      title: 'اختر التاريخ',
    );
  }
}
