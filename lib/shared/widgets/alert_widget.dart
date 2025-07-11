import 'package:flutter/material.dart';
import 'package:flutter_predictive_maintenance_app/shared/components/primary_button.dart';
import 'package:flutter_predictive_maintenance_app/constants/app_colors.dart';

class AlertWidget extends StatelessWidget {
  final String title;
  final String body;
  final VoidCallback? onTap;

  const AlertWidget({super.key, this.title = 'Attention!', required this.body, this.onTap});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
      backgroundColor: Colors.grey[100],
      title: Text(title, style: const TextStyle(fontSize: 20, color: Colors.black, fontWeight: FontWeight.bold)),
      content: Text(
        body,
        style: const TextStyle(
          fontSize: 16,
          color: Colors.black,
        ),
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        if (onTap == null) ...[
          const SizedBox(width: 10),
          PrimaryButton(
            onPressed: () => Navigator.of(context).pop(),
            label: 'OK',
            buttonColor: AppColors.primaryColor,
          ),
        ] else ...[
          PrimaryButton(
            onPressed: () => Navigator.of(context).pop(),
            label: 'Cancel',
            buttonColor: AppColors.greyColor,
          ),
          const SizedBox(width: 10),
          PrimaryButton(
            onPressed: () {
              onTap!();
            },
            label: 'Proceed',
            buttonColor: AppColors.primaryColor,
          ),
        ],
      ],
    );
  }
}