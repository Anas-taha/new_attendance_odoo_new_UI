import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hr_app_odoo/generated/l10n/app_localizations.dart';
import 'package:hr_app_odoo/screens/home/home_controller.dart';
import 'package:hr_app_odoo/theme/app_theme.dart';
import 'package:hr_app_odoo/widgets/CustomText/customText.dart';

class GreetingWidget extends StatelessWidget {
  GreetingWidget({super.key});
  final homeController = Get.find<HomeController>();
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        // Container(
        //   width: 60,
        //   height: 60,
        //   decoration: BoxDecoration(
        //     color: const Color(0xFF6B46C1),
        //     borderRadius: BorderRadius.circular(30),
        //   ),
        //   child: const Icon(Icons.person, size: 30, color: Colors.white),
        // ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Customtext(
                text: 'مرحباً بك',
                color: AppColors.appA0A0A0Text2,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
              Customtext(
                text:
                    " ${homeController.currentEmployee.value?.name ?? AppLocalizations.of(context)!.employee}",
                color: AppColors.primaryColor,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
              // Text(
              //   '${homeController.getGreeting(context)}, ${homeController.currentEmployee.value?.name ?? AppLocalizations.of(context)!.employee}',
              //   style: TextStyle(
              //     fontSize: 20,
              //     fontWeight: FontWeight.bold,
              //     color: Colors.grey[800],
              //   ),
              // ),

              // Text(
              //   AppLocalizations.of(context)!.welcomeBackDashboard,
              //   style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              // ),
              SizedBox(height: 4),
              // Text(
              //   AppLocalizations.of(
              //     context,
              //   )!.currentTime(homeController.getCurrentTime()),
              //   style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              // ),
            ],
          ),
        ),
      ],
    );
  }
}
