import 'package:flutter/material.dart';

class CustomDialog {
  static dialog(BuildContext context, Widget child) {
    showDialog(
      context: context,
      builder: (context) {
        return child;
      },
    );
  }
}
