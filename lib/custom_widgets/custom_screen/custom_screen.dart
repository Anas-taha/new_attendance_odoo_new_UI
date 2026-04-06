import 'package:flutter/material.dart';
import 'package:hr_app_odoo/theme/app_theme.dart';
import 'package:hr_app_odoo/custom_widgets/custom_appbar/custom_appbar.dart';
import 'package:hr_app_odoo/custom_widgets/custom_button/custom_button.dart';

class CustomScreen extends StatelessWidget {
  CustomScreen({
    super.key,
    this.appBarTitle,
    required this.body,
    this.screenPadding,
    this.appBar,
    this.floatingActionButton,
  });
  String? appBarTitle;

  Widget body;
  PreferredSizeWidget? appBar;
  double? screenPadding;
  Widget? floatingActionButton;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppColors.appFFFFFFBackGround1,
        floatingActionButton: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: floatingActionButton,
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        appBar: appBarTitle != null
            ? CustomAppBar(title: appBarTitle ?? '')
            : appBar,
        body: Padding(
          padding: EdgeInsets.all(screenPadding ?? 20),
          child: body,
        ),
      ),
    );
  }
}
