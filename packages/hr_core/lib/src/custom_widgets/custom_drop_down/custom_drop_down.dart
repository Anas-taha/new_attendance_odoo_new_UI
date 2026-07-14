import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hr_core/src/theme/app_theme.dart';

class CustomDropDown extends StatefulWidget {
  const CustomDropDown({
    super.key,
    required this.itemList,
    required this.onSelect,
    this.hintText,
    this.value,
    this.height,
    this.fontSize,
  });

  final List<String> itemList;
  final Function(String) onSelect;
  final String? hintText;
  final String? value;
  final double? height;
  final double? fontSize;

  @override
  State<CustomDropDown> createState() => _CustomDropDownState();
}

class _CustomDropDownState extends State<CustomDropDown> {
  final valueListenable = ValueNotifier<String?>(null);

  double get _height => widget.height ?? 55.h;
  double get _fontSize => widget.fontSize ?? 12.w;

  TextStyle get _itemStyle => TextStyle(
    fontSize: _fontSize,
    fontWeight: FontWeight.w500,
    color: AppColors.app1A1A1AText1,
  );

  @override
  void initState() {
    super.initState();
    valueListenable.value = _resolveInitialValue();
  }

  @override
  void didUpdateWidget(covariant CustomDropDown oldWidget) {
    super.didUpdateWidget(oldWidget);
    final resolved = _resolveInitialValue();
    if (valueListenable.value != resolved) {
      valueListenable.value = resolved;
    }
  }

  @override
  void dispose() {
    valueListenable.dispose();
    super.dispose();
  }

  List<String> get _uniqueItems {
    final unique = <String>[];
    for (final item in widget.itemList) {
      if (item.isNotEmpty && !unique.contains(item)) {
        unique.add(item);
      }
    }
    return unique;
  }

  String? _resolveInitialValue() {
    final items = _uniqueItems;
    if (widget.value != null && items.contains(widget.value)) {
      return widget.value;
    }
    if (valueListenable.value != null && items.contains(valueListenable.value)) {
      return valueListenable.value;
    }
    return null;
  }

  Widget _itemLabel(String text, {Color? color}) {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: _itemStyle.copyWith(color: color),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = _uniqueItems;

    return DropdownButtonHideUnderline(
      child: DropdownButton2<String>(
        isExpanded: true,
        valueListenable: valueListenable,
        hint: _itemLabel(widget.hintText ?? '', color: AppColors.appA0A0A0Text2),
        selectedItemBuilder: (context) {
          return items
              .map((item) => _itemLabel(item))
              .toList();
        },
        items: items.map((item) {
          return DropdownItem<String>(
            value: item,
            child: _itemLabel(item),
          );
        }).toList(),
        onChanged: (val) {
          if (val == null) {
            return;
          }
          widget.onSelect(val);
          valueListenable.value = val;
        },
        buttonStyleData: ButtonStyleData(
          height: _height,
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 10.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.appE5E5E5Border),
            color: AppColors.appFAFAFABackGround2,
          ),
        ),
        dropdownStyleData: DropdownStyleData(
          maxHeight: 240,
          padding: EdgeInsets.symmetric(vertical: 6.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.appE5E5E5Border),
            color: AppColors.appFFFFFFBackGround1,
            boxShadow: [
              BoxShadow(
                color: AppColors.app1A1A1AText1.withValues(alpha: 0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          elevation: 0,
          offset: Offset(0, 4.h),
        ),
        menuItemStyleData: MenuItemStyleData(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        ),
        iconStyleData: IconStyleData(
          icon: const Icon(Icons.keyboard_arrow_down_rounded),
          iconSize: 22,
          iconEnabledColor: AppColors.appA0A0A0Text2,
        ),
      ),
    );
  }
}
