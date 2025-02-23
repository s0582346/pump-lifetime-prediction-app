import 'package:flutter/material.dart';
import 'package:flutter_predictive_maintenance_app/features/chart/presentation/chart_controller.dart';
import 'package:flutter_predictive_maintenance_app/features/history/presentation/controllers/history_controller.dart';
import 'package:flutter_predictive_maintenance_app/navigation/navigation_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_predictive_maintenance_app/features/measurement/presentation/measurement_controller.dart';
import 'package:flutter_predictive_maintenance_app/components/form_components/input_widget.dart';
import 'package:flutter_predictive_maintenance_app/components/form_components/date_input_widget.dart';
import 'package:flutter_predictive_maintenance_app/components/form_components/primary_button.dart';
import 'package:flutter_predictive_maintenance_app/constants/app_colors.dart';
import 'package:flutter_predictive_maintenance_app/navigation/navigation.dart';
import 'package:intl/intl.dart';

class MeasurementDataWidget extends ConsumerWidget {
  const MeasurementDataWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final measurementNotifier = ref.read(measurementProvider.notifier);
    final measurementState = ref.watch(measurementProvider);
    final pump = ref.watch(selectedPumpProvider);
    
    return ListView(
      padding: const EdgeInsets.all(40.0),
      children: [
        DateInputWidget(
          label: 'Date',
          initialValue: measurementState.date,
          onChanged: (value) => measurementNotifier.date = value,
        ),

        InputWidget(
          label: (pump?.measurableParameter == 'volume flow') ? 'Volumen Flow' : 'Pressure',
          initialValue: (pump?.measurableParameter == 'volume flow') ? measurementState.volumeFlow : measurementState.pressure,	
          onChanged: (value) => (pump?.measurableParameter == 'volume flow') ? measurementNotifier.volumeFlow = value : measurementNotifier.pressure = value,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
        ),
        InputWidget(
          label: 'Rotational Frequency',
          initialValue: measurementState.rotationalFrequency,
          onChanged: (value) => measurementNotifier.rotationalFrequency = value,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
        ),
        InputWidget(
          label: 'Current Operating Hours',
          initialValue: measurementState.currentOperatingHours,
          onChanged: (value) => measurementNotifier.currentOperatingHours = value,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
        ),
        const SizedBox(height: 20),
        PrimaryButton(
          onPressed: () async {
            // if user hasnt picked picked date
            if (measurementState.date == null) {
              measurementNotifier.date = DateTime.now();
            }

            final success = measurementNotifier.saveMeasurement();

            if (await success) {
              Future.microtask(() => ref.read(historyControllerProvider.notifier).refresh());
              Future.microtask(() => ref.read(chartControllerProvider.notifier).refresh());
              ref.read(bottomNavigationProvider.notifier).state = 0; // Navigate to the history screen
            }
          },
          label: 'Save',
          buttonColor: AppColors.greyColor,
        ),
      ],
    );
  }

}