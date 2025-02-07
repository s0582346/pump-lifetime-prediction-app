import 'package:flutter/material.dart';
import 'package:flutter_predictive_maintenance_app/components/form_components/primary_button.dart';
import 'package:flutter_predictive_maintenance_app/constants/app_colors.dart';
import 'package:flutter_predictive_maintenance_app/features/pump/pump_service.dart';
import 'package:flutter_predictive_maintenance_app/navigation/custom_app_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_predictive_maintenance_app/features/pump/pump_screen.dart';

/// LandingPage is the initial page the user sees
class InitialScreen extends ConsumerWidget {
  const InitialScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'NETZSCH'),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            InstructionBox(),
            SizedBox(height: 20),
            PrimaryButton(
              label: 'Add Pump',
              buttonColor: AppColors.greyColor,
              onPressed: () {
                // Navigate to pump form
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => PumpScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Simple widget representing an instruction box
class InstructionBox extends StatelessWidget {
  const InstructionBox({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        'No pumps found. Press the button below to add a pump.',
        style: TextStyle(fontSize: 16),
        textAlign: TextAlign.center,
      ),
    );
  }
}


