import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:flutter_predictive_maintenance_app/constants/app_colors.dart';

//final dateProvider = StateProvider<DateTime?>((ref) => DateTime.now());

class DateInputWidget extends ConsumerStatefulWidget {
  final DateTime? initialValue;
  final ValueChanged<DateTime?> onChanged;
  final String label;
  final String placeholder;

  const DateInputWidget({
    super.key,
    this.initialValue,
    this.label = '',
    this.placeholder = '',
    required this.onChanged,
  });

  @override
  _DateInputWdigetState createState() => _DateInputWdigetState();
}

class _DateInputWdigetState extends ConsumerState<DateInputWidget> {
  late TextEditingController _controller;
  late DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialValue ?? DateTime.now();
    _controller = TextEditingController(
      text: _formatDate(_selectedDate),
    );
  }

  @override
  void didUpdateWidget(covariant DateInputWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue == null) {
      _selectedDate = DateTime.now();
      _controller.text = _formatDate(_selectedDate);
    } else if (widget.initialValue != oldWidget.initialValue) {
      _selectedDate = widget.initialValue;
      _controller.text = _formatDate(_selectedDate);
    }
  }

  String _formatDate(DateTime? date) {
    return date != null ? DateFormat('dd.MM.yyyy').format(date) : '';
  }

  Future<void> _selectDate(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.greyColor,
              onPrimary: AppColors.primaryColor,
              onSurface: Colors.grey,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey,
              ),
            ),
          ),
          child: AlertDialog(
            backgroundColor: Colors.white,
            contentPadding: const EdgeInsets.all(16),
            content: SizedBox(
              height: 300,
              child: CalendarDatePicker(
                initialDate: _selectedDate ?? DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
                onDateChanged: (DateTime date) {
                  setState(() {
                    _selectedDate = date;
                    _controller.text = _formatDate(date);
                  });
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context), // Cancel
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () {
                  // The _selectedDate has already been updated via onDateChanged.
                  widget.onChanged(_selectedDate);
                  Navigator.pop(context);
                },
                child: const Text("OK"),
              ),
            ],
          ),
        );
      },
    );
  }

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
            child: TextFormField(
              controller: _controller,
              readOnly: true,
              onTap: () => _selectDate(context),
              decoration: InputDecoration(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                hintText: widget.placeholder,
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
                suffixIcon:
                    const Icon(Icons.calendar_today, color: Colors.grey),
              ),
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
