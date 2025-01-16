import 'package:flutter/material.dart';
import 'package:flutter_predictive_maintenance_app/constants/app_colors.dart';


class InputWidget extends StatelessWidget {
  final initialValue;
  final ValueChanged<String> onChanged;
  final String label;
  final String placeholder;

  const InputWidget({
    super.key,
    this.initialValue,
    this.label = '',
    this.placeholder = '',
    required this.onChanged,
  });

 @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 325,
      height: 85,
      child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        Container(
          height: 43,
          child: TextFormField(
          initialValue: initialValue,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
            border: OutlineInputBorder(
              borderSide: const BorderSide(
                color: Colors.grey,        
                width: 1,                  
              ),
              borderRadius: BorderRadius.circular(2),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(
                color: AppColors.primaryColor,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          style: const TextStyle(fontSize: 14),
          keyboardType: TextInputType.number,
        )
        )
      ],
    )
    );
  }
}