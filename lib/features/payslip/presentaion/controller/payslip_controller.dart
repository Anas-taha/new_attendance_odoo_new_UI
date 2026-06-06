import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hr_app_odoo/custom_widgets/custom_calender/custom_calender.dart';
import 'package:hr_app_odoo/models/hr_payslip.dart';
import 'package:hr_app_odoo/services/simple_hr_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PayslipController extends GetxController {
  TextEditingController dateController = TextEditingController();
  SimpleHrService hrService = SimpleHrService();
  bool salary = false;
  RxBool isLoading = false.obs;
  String allSalary = '30.000';
  String netSalary = '1.000';
  String grossSalary = '25.000';
  Uint8List? pdfBytes;

  @override
  void onReady() {
    super.onReady();
    dateController.text = '';
    getSalaries();
  }

  void getSalaries() async {
    isLoading.value = true;
    final result = await hrService.getPayslip();
    if (result.isNotEmpty) {
      // salary.value = result.first;
      salary = true;
      update();
      log(name: 'iscbisducbds', 'result: $result');
    } else {
      salary = false;
      update();
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

  Future<void> generatePdf() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Name: ${allSalary}'),
              pw.Text('Age: ${netSalary}'),
              pw.Text('Address: ${grossSalary}'),
            ],
          );
        },
      ),
    );

    pdfBytes = await pdf.save();
  }

  Widget buildPdfPreview() {
    if (pdfBytes == null) return SizedBox();

    return Expanded(child: PdfPreview(build: (format) => pdfBytes!));
  }

  Future<void> savePdf() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/my_form.pdf');
    await file.writeAsBytes(pdfBytes!);
    print('Saved to: ${file.path}');
  }
}
