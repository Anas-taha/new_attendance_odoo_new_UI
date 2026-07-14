import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hr_core/src/custom_widgets/custom_calender/custom_calender.dart';
import 'package:hr_core/generated/l10n/app_localizations.dart';
import 'package:hr_core/src/features/payslip/data/repositories/payslip_repository_impl.dart';
import 'package:hr_core/src/features/payslip/domain/repositories/payslip_repository.dart';
import 'package:hr_core/src/models/salary_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PayslipController extends GetxController {
  PayslipController({PayslipRepository? payslipRepository})
    : _payslipRepository = payslipRepository ?? PayslipRepositoryImpl();

  final PayslipRepository _payslipRepository;

  TextEditingController dateController = TextEditingController();
  Payslips salary = Payslips();
  RxBool isLoading = false.obs;

  Uint8List? pdfBytes;

  @override
  void onReady() {
    super.onReady();
    dateController.text = '';
    getSalaries();
  }

  Future<void> getSalaries() async {
    isLoading.value = true;
    final result = await _payslipRepository.getPayslips();
    log(name: 'sfdbdfgjhndtyj', 'result: ${result.status} ');
    salary = result.payslips?.first ?? Payslips();
    update();
    log(
      name: 'PayslipController',
      'result: $result salary: $salary name: ${salary.basicSalary}',
    );
    isLoading.value = false;
  }

  Future<void> getPayslipLine() async {
    isLoading.value = true;
    final result = await _payslipRepository.getPayslipLine();
    log(name: 'PayslipController', 'getPayslipLine result: $result');
    isLoading.value = false;
  }

  void selectDate() {
    final ctx = Get.context;
    final title = ctx == null ? '' : AppLocalizations.of(ctx)!.selectDate;
    CustomCalender.calenderDialog(contorller: dateController, title: title);
  }

  Future<void> generatePdf() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // pw.Text('Name: $allSalary'),
              // pw.Text('Age: $netSalary'),
              // pw.Text('Address: $grossSalary'),
            ],
          );
        },
      ),
    );

    pdfBytes = await pdf.save();
  }

  Widget buildPdfPreview() {
    if (pdfBytes == null) {
      return const SizedBox();
    }

    return Expanded(child: PdfPreview(build: (format) => pdfBytes!));
  }

  Future<void> savePdf() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/my_form.pdf');
    await file.writeAsBytes(pdfBytes!);
  }
}
