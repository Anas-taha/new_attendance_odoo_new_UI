import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hr_app_odoo/custom_widgets/custom_text/custom_text.dart';
import 'package:hr_app_odoo/theme/app_theme.dart';

class CustomDropDown extends StatefulWidget {
  const CustomDropDown({
    super.key,
    required this.itemList,
    required this.onSelect,
    this.hintText,
    this.value,
  });

  final List<String> itemList;
  final Function(String) onSelect;
  final String? hintText;
  final String? value;

  @override
  State<CustomDropDown> createState() => _CustomDropDownState();
}

class _CustomDropDownState extends State<CustomDropDown> {
  final valueListenable = ValueNotifier<String?>(null);
  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: DropdownButton2<String>(
        isExpanded: true,
        // value: value,
        valueListenable: valueListenable,
        // 👇 النص الافتراضي
        hint: Text(
          widget.hintText ?? '',
          style: const TextStyle(color: Colors.grey),
        ),

        // 👇 العناصر
        items: widget.itemList.map((e) {
          return DropdownItem<String>(value: e, child: Text(e));
        }).toList(),

        onChanged: (val) {
          if (val == null) return;
          widget.onSelect(val);
          valueListenable.value = val;
        },

        // 👇 شكل الزرار
        buttonStyleData: ButtonStyleData(
          height: 55,

          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey),
            color: Colors.white,
          ),
        ),

      
        dropdownStyleData: DropdownStyleData(
          maxHeight: 220,
          padding: const EdgeInsets.all(8), // 🔥 padding للقائمة كلها
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
          ),
          elevation: 4,
        ),

    
        menuItemStyleData: MenuItemStyleData(
          padding: const EdgeInsets.symmetric(horizontal: 12),
        ),

       
        iconStyleData: const IconStyleData(
          icon: Icon(Icons.keyboard_arrow_down),
          iconSize: 28,
          iconEnabledColor: Colors.grey,
        ),
      ),
    );
  }
}
// class CustomDropDown extends StatelessWidget {
//   const CustomDropDown({
//     super.key,
//     required this.itemList,
//     required this.onSelect,
//     this.hintText,
//   });
//   final List<String> itemList;
//   final Function(String)? onSelect;
//   final String? hintText;
//   @override
//   Widget build(BuildContext context) {
//     return DropdownButtonFormField<String>(
//       decoration: InputDecoration(
//         fillColor: AppColors.appFAFAFABackGround2,
//         filled: true,
//         focusedBorder: _borderStyle(),
//         enabledBorder: _borderStyle(),
//         border: _borderStyle(),
//         suffixIcon: Icon(
//           Icons.keyboard_arrow_down_sharp,
//           color: AppColors.appA0A0A0Text2,
//           size: 30,
//         ),
//       ),
//       hint: CustomText(
//         text: hintText ?? '',
//         color: AppColors.appA0A0A0Text2,
//         fontSize: 14.w,
//         fontWeight: FontWeight.w500,
//       ),
//       items: itemList
//           .map((e) => DropdownMenuItem(value: e, child: Text(e)))
//           .toList(),
//       onChanged: (value) {
//         if (value == null) return;
//         onSelect!(value);
//       },
//     );
//   }

//   OutlineInputBorder _borderStyle() {
//     return OutlineInputBorder(
//       borderRadius: BorderRadius.all(Radius.circular(10)),
//       borderSide: BorderSide(color: AppColors.appE5E5E5Border),
//     );
//   }
// }
