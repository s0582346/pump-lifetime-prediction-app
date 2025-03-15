import 'package:flutter/material.dart';
import 'package:flutter_predictive_maintenance_app/constants/app_colors.dart';

class InputWidget extends StatefulWidget {
  final initialValue;
  final ValueChanged<String> onChanged;
  final String label;
  final String placeholder;
  final TextInputType keyboardType;
  final validator;
  final isSubmitting;

  const InputWidget({
    super.key,
    this.initialValue,
    this.label = '',
    this.placeholder = '',
    required this.onChanged,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.isSubmitting = false,
  });

  @override
  _InputWidgetState createState() => _InputWidgetState();
}

class _InputWidgetState extends State<InputWidget> {
  late TextEditingController _controller;

  // Initialize the controller with the initial value
  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  // Clear the controller when the initial value changes to null
  @override
  void didUpdateWidget(covariant InputWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Clear the controller when the initial value changes to null
    if (widget.initialValue == null) {
      _controller.clear();
    }
  }

  // Dispose the controller when the widget is removed
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
              fontSize: 15,
              color: Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(
            height: 40,
            child:
              TextFormField(
              controller: _controller,
              onChanged: widget.onChanged,
              //validator: (value) => widget.validator,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                hintText: widget.placeholder,
                hintStyle: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: (widget.validator != null) ? AppColors.errorMessageColor : Colors.grey,        
                    width: 1, 
                    style: BorderStyle.solid                
                  ),
                  borderRadius: BorderRadius.circular(3),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: (widget.validator != null) ? AppColors.errorMessageColor : AppColors.primaryColor,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              style: const TextStyle(fontSize: 14, color: Colors.black, fontWeight: FontWeight.bold),
              keyboardType: widget.keyboardType,
            ),
          ),

          (widget.validator != null) ? 
            Text(
              widget.validator,
              style: const TextStyle(color: AppColors.errorMessageColor, fontSize: 12),
            ) : Container()
        ],
      ),
    );
  }
}