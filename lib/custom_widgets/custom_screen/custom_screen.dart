import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hr_app_odoo/custom_widgets/custom_Item/custom_item.dart';
import 'package:hr_app_odoo/theme/app_theme.dart';
import 'package:hr_app_odoo/custom_widgets/custom_appbar/custom_appbar.dart';
import 'package:hr_app_odoo/custom_widgets/custom_button/custom_button.dart';

class CustomScreen extends StatelessWidget {
  const CustomScreen({
    super.key,
    this.appBarTitle,
    required this.body,
    this.loading,
    this.screenPadding,
    this.appBar,
    this.floatingActionButton,
  });
  final String? appBarTitle;
  final RxBool? loading;
  final Widget body;
  final PreferredSizeWidget? appBar;
  final double? screenPadding;
  final Widget? floatingActionButton;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Stack(
        children: [
          Scaffold(
            backgroundColor: AppColors.appFFFFFFBackGround1,
            floatingActionButton: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: floatingActionButton,
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked,
            appBar: appBarTitle != null
                ? CustomAppBar(title: appBarTitle ?? '')
                : appBar,
            body: Padding(
              padding: EdgeInsets.all(screenPadding ?? 20),
              child: body,
            ),
          ),
          CustomItem.customLoading(loading: loading ?? false.obs),
          // Obx(() {
          //   return Container(
          //     height: double.infinity,
          //     width: double.infinity,
          //     color: AppColors.app9F9F9FText4.withValues(alpha: 0.1),
          //     child: Center(child: CircularProgressIndicator()),
          //   );
          // }),
        ],
      ),
    );
  }
}
