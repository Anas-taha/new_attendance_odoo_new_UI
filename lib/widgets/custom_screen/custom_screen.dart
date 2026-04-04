import 'package:flutter/material.dart';
import 'package:hr_app_odoo/theme/app_theme.dart';
import 'package:hr_app_odoo/widgets/custom_appbar/custom_appbar.dart';

class CustomScreen extends StatelessWidget {
  CustomScreen({
    super.key,
    this.appBarTitle,
    required this.body,
    this.screenPadding,
    this.appBar,
  });
  String? appBarTitle;

  Widget body;
  PreferredSizeWidget? appBar;
  double? screenPadding;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appFFFFFFBackGround1,
      appBar: appBarTitle != null
          ? CustomAppBar(title: appBarTitle ?? '')
          : appBar,
      body: Padding(padding: EdgeInsets.all(screenPadding ?? 20), child: body),
    );
  }
}
