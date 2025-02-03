import 'package:flutter/material.dart';
import 'package:flutter_predictive_maintenance_app/constants/app_colors.dart';

class SelectWidget extends StatefulWidget {
  final String? selectedValue;
  final String label;
  final ValueChanged<String?>? onChanged;
  final List<String> items;
   
  const SelectWidget({
    super.key, 
    this.selectedValue, 
    this.label = '', 
    required this.onChanged, 
    required this.items
  });

  @override
  _SelectWidgetState createState() => _SelectWidgetState();
}

class _SelectWidgetState extends State<SelectWidget> {

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
            height: 40,
            child: DropdownButtonFormField<String>(
              value: (widget.selectedValue != null && widget.selectedValue!.isNotEmpty) ? widget.selectedValue : null,
              onChanged: widget.onChanged,
              hint: const Text(
                'Bitte auswählen',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderSide: const BorderSide(
                    color: Colors.grey,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(3),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                    color: AppColors.primaryColor,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(3),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              ),
              items: widget.items.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value,
                    style: const TextStyle(fontSize: 14),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}