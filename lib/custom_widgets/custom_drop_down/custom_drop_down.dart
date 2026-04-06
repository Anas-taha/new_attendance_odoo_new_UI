import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hr_app_odoo/custom_widgets/custom_text/custom_text.dart';
import 'package:hr_app_odoo/theme/app_theme.dart';

class CustomDropDown extends StatelessWidget {
  const CustomDropDown({
    super.key,
    required this.itemList,
    required this.onSelect,
    this.hintText,
  });
  final List<String> itemList;
  final Function(String)? onSelect;
  final String? hintText;
  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        fillColor: AppColors.appFAFAFABackGround2,
        filled: true,
        focusedBorder: _borderStyle(),
        enabledBorder: _borderStyle(),
        border: _borderStyle(),
        suffixIcon: Icon(
          Icons.keyboard_arrow_down_sharp,
          color: AppColors.appA0A0A0Text2,
          size: 30,
        ),
      ),
      hint: CustomText(
        text: hintText ?? '',
        color: AppColors.appA0A0A0Text2,
        fontSize: 14.w,
        fontWeight: FontWeight.w500,
      ),
      items: itemList
          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
          .toList(),
      onChanged: (value) {
        if (value == null) return;
        onSelect!(value);
      },
    );
  }

  OutlineInputBorder _borderStyle() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(10)),
      borderSide: BorderSide(color: AppColors.appE5E5E5Border),
    );
  }
}
