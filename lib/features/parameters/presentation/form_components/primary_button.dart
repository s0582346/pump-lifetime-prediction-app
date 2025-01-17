import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Color? buttonColor;
  final Color? textColor;
  final IconData? icon;

  const PrimaryButton({
    Key? key,
    required this.label,
    this.onPressed,
    this.buttonColor,
    this.textColor,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Decide if we show an icon to the left of the text
    final hasIcon = icon != null;

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: buttonColor ?? Theme.of(context).primaryColor,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
      ),
      onPressed: onPressed,
      child: hasIcon
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: textColor ?? Colors.white),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(color: textColor ?? Colors.white),
                ),
              ],
            )
          : Text(
              label,
              style: TextStyle(color: textColor ?? Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
    );
  }
}
