import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/foundation.dart';        // for describeEnum
import 'package:flutter/material.dart';
import 'package:flutter_predictive_maintenance_app/constants/app_colors.dart';

class SelectWidget<T extends Enum> extends StatefulWidget {
  final T? selectedValue;
  final String label;
  final ValueChanged<T?>? onChanged;
  final List<T> items;
  final String? validator;
  final bool isSubmitting;
  final String Function(T)? itemLabelBuilder;
   
  const SelectWidget({
    Key? key,
    this.selectedValue,
    this.label = '',
    required this.onChanged,
    required this.items,
    this.validator,
    this.isSubmitting = false,
    this.itemLabelBuilder,
  }) : super(key: key);

  @override
  _SelectWidgetState<T> createState() => _SelectWidgetState<T>();
}

class _SelectWidgetState<T extends Enum> extends State<SelectWidget<T>> {
  late List<DropdownMenuItem<T>> _menuItems;

  @override
  void initState() {
    super.initState();
    _buildMenuItems();
  }

  @override
  void didUpdateWidget(covariant SelectWidget<T> old) {
    super.didUpdateWidget(old);
    // if items list or label builder changes, rebuild menu items
    if (!listEquals(old.items, widget.items) ||
        old.itemLabelBuilder != widget.itemLabelBuilder) {
      _buildMenuItems();
    }
  }

  void _buildMenuItems() {
    _menuItems = widget.items.map((T value) {
      final label = widget.itemLabelBuilder != null
          ? widget.itemLabelBuilder!(value)
          : describeEnum(value);
      return DropdownMenuItem<T>(
        value: value,
        child: Text(
          label,
          style: const TextStyle(fontSize: 14, color: Colors.black),
        ),
      );
    }).toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 325,
      height: 90,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(
            height:
                (widget.isSubmitting && widget.selectedValue == null) ? 60 : 40,
            child: DropdownButtonFormField2<T>(
              value: widget.selectedValue,
              onChanged: widget.onChanged,                          
              hint: const Text(
                'Bitte auswählen',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              dropdownStyleData: DropdownStyleData(
                elevation: 8,
                direction: DropdownDirection.left,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              decoration: InputDecoration(
                errorText: (widget.isSubmitting) ? widget.validator : null,
                border: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.grey, width: 1),
                  borderRadius: BorderRadius.circular(3),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                      color: AppColors.primaryColor, width: 1),
                  borderRadius: BorderRadius.circular(3),
                ),
                contentPadding: const EdgeInsets.symmetric(),
              ),
              items: _menuItems,                                     
            ),
          ),
        ],
      ),
    );
  }
}
