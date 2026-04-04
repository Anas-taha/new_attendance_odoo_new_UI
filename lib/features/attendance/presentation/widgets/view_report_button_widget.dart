import 'package:flutter/material.dart';
import 'package:hr_app_odoo/generated/l10n/app_localizations.dart';

class ViewReportButtonWidget extends StatelessWidget {
  const ViewReportButtonWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => Navigator.pushNamed(context, '/attendance-report'),
        icon: const Icon(Icons.analytics, size: 24),
        label: Text(
          AppLocalizations.of(context)!.viewDetailedReports,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        // style: ElevatedButton.styleFrom(
        //   backgroundColor: const Color(0xFF764ba2),
        //   foregroundColor: Colors.white,
        //   padding: const EdgeInsets.symmetric(vertical: 16),
        //   shape: RoundedRectangleBorder(
        //     borderRadius: BorderRadius.circular(12),
        //   ),
        //   elevation: 2,
        // ),
      ),
    );
  }
}
