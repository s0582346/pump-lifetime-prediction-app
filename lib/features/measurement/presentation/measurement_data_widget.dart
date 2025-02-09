import 'package:flutter/material.dart';
import 'package:flutter_predictive_maintenance_app/features/history/presentation/controllers/history_controller.dart';
import 'package:flutter_predictive_maintenance_app/navigation/navigation_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_predictive_maintenance_app/features/measurement/presentation/measurement_controller.dart';
import 'package:flutter_predictive_maintenance_app/components/form_components/input_widget.dart';
import 'package:flutter_predictive_maintenance_app/components/form_components/primary_button.dart';
import 'package:flutter_predictive_maintenance_app/constants/app_colors.dart';
import 'package:flutter_predictive_maintenance_app/navigation/navigation.dart';

class MeasurementDataWidget extends ConsumerWidget {
  const MeasurementDataWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final measurementNotifier = ref.read(measurementProvider.notifier);
    final measurementState = ref.watch(measurementProvider);
    final pump = ref.watch(selectedPumpProvider);
    
    final String label;
    final String initialValue;
    final void Function(String) onChangedCallback;

    // Set the label, initial value, and onChanged callback based on the selected pump
    if (pump?.measurableParameter == 'volume flow') {
      label = 'Volumen Flow';
      initialValue = measurementState.volumeFlow ?? '';
      onChangedCallback = (value) => measurementNotifier.volumeFlow = value;
    } else {
      label = 'Pressure';
      initialValue = measurementState.pressure ?? '';
      onChangedCallback = (value) => measurementNotifier.pressure = value;
    }
    
    
    return ListView(
      padding: const EdgeInsets.all(40.0),
      children: [
        //TODO implement condition for volume flow
         InputWidget(
          label: label,
          initialValue: initialValue,
          onChanged: onChangedCallback,
        ),
        InputWidget(
          label: 'Drehzahl',
          initialValue: measurementState.rotationalFrequency,
          onChanged: (value) => measurementNotifier.rotationalFrequency = value,
        ),
        InputWidget(
          label: 'Aktuelle Betriebsstunden',
          initialValue: measurementState.currentOperatingHours,
          onChanged: (value) => measurementNotifier.currentOperatingHours = value,
        ),
        const SizedBox(height: 20),
        PrimaryButton(
          onPressed: () async {
            final success = measurementNotifier.saveMeasurement();

            if (await success) {
              Future.microtask(() => ref.read(historyControllerProvider.notifier).refresh());
              ref.read(bottomNavigationProvider.notifier).state = 0; // Navigate to the history screen
            }
          },
          label: 'Speichern',
          buttonColor: AppColors.greyColor,
        ),
      ],
    );
  }

}