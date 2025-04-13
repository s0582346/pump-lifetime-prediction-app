import 'package:flutter/material.dart';
import 'package:flutter_predictive_maintenance_app/shared/components/primary_button.dart';
import 'package:flutter_predictive_maintenance_app/constants/app_colors.dart';
import 'package:flutter_predictive_maintenance_app/features/pump/presentation/pump_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_predictive_maintenance_app/features/pump/presentation/pump_screen.dart';
import 'package:flutter_predictive_maintenance_app/features/pump/presentation/pump_box.dart';

/// LandingPage is the initial page the user sees
class InitialScreen extends ConsumerWidget {
  const InitialScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pumpsAsyncValue = ref.watch(pumpsProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF007167),
        centerTitle: false,
        title: const Text(
          "NETZSCH",
            style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
      ),
      // Put the main content into the body
      backgroundColor: Colors.white,
      body: pumpsAsyncValue.when(
        data: (pumps) {
          if (pumps.isEmpty) {
            return const Center(
              child: InstructionBox(),
            );
          } else {
            return ListView.builder(
              padding: const EdgeInsets.symmetric(
                vertical: 16,
                horizontal: 16,
              ),
              itemCount: pumps.length,
              itemBuilder: (context, index) {
                final pump = pumps[index];
                return PumpBox(pump: pump);
              },
            );
          }
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Text('Error: $err'),
        ),
      ),
      // Pin the button to the bottom using bottomNavigationBar
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: PrimaryButton(
            label: 'Add Pump',
            buttonColor: AppColors.greyColor,
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const PumpScreen(),
                ),
              );
            },
          ),
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
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text(
        'No pumps found. Press the button below to add a pump.',
        style: TextStyle(fontSize: 16),
        textAlign: TextAlign.center,
      ),
    );
  }
}
