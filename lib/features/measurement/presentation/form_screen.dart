import 'package:flutter/material.dart';
import 'package:flutter_predictive_maintenance_app/features/measurement/presentation/measurement_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_predictive_maintenance_app/features/measurement/presentation/measurement_data_widget.dart';


class FormScreen extends ConsumerWidget {
  const FormScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF007167),
        title: const Text(
          "NETZSCH",
            style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () {
            if (ref.watch(isEditingProvider) == true) {
              ref.read(measurementProvider.notifier).reset();
              ref.read(isEditingProvider.notifier).state = false;
            }
            Navigator.of(context).pop(false);
          },
        ),
      ),
      backgroundColor: Colors.white,
      body: MeasurementDataWidget(),
    ); 
  }
}