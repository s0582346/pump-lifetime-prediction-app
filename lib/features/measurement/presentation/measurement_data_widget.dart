import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_predictive_maintenance_app/features/measurement/presentation/measurement_controller.dart';
import 'package:flutter_predictive_maintenance_app/components/form_components/input_widget.dart';
import 'package:flutter_predictive_maintenance_app/components/form_components/date_input_widget.dart';
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
    final measurementValidationState = ref.watch(measurementValidationProvider);
    final isVolumeFlow = pump?.measurableParameter == 'volume flow';
    final isAverage = pump?.typeOfTimeEntry.contains('average');
    final isSubmitting = ref.watch(isSubmittingProvider);

    final hLabel = pump?.typeOfTimeEntry.contains('average') ? 'Average Operating Hours Per Day' : pump?.typeOfTimeEntry.contains('relative') ? 'Operating Time (Relative)' : 'Operating Time (Absolute)';

    return ListView(
      padding: const EdgeInsets.all(40.0),
      children: [
        DateInputWidget(
          label: 'Date',
          initialValue: measurementState.date,
          onChanged: (value) => measurementNotifier.date = value,
        ),

        InputWidget(
          label: (isVolumeFlow) ? 'Volume Flow [Q]' : 'Pressure [p]',
          initialValue: (isVolumeFlow) ? measurementState.volumeFlow : measurementState.pressure,	
          onChanged: (value) => (isVolumeFlow) ? measurementNotifier.volumeFlow = value : measurementNotifier.pressure = value,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          validator: (isSubmitting) ? ((isVolumeFlow) ? measurementValidationState.volumeFlowError : measurementValidationState.pressureError) : null,
          //isSubmitting: isSubmitting,
        ),

        InputWidget(
          label: 'Rotational Frequency [n]',
          initialValue: measurementState.rotationalFrequency,
          onChanged: (value) => measurementNotifier.rotationalFrequency = value,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          validator: (isSubmitting) ? measurementValidationState.rotationalFrequencyError : null,
        ),

        InputWidget(
          label: "$hLabel [h]",
          initialValue: (isAverage) ? measurementState.averageOperatingHoursPerDay : measurementState.currentOperatingHours,
          onChanged: (value) => (isAverage) ? measurementNotifier.averageOperatingHoursPerDay = value : measurementNotifier.currentOperatingHours = value,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          validator: (isSubmitting) ? (isAverage) ? measurementValidationState.averageOperatingHoursPerDayError : measurementValidationState.currentOperatingHoursError : null,
        ),

        const SizedBox(height: 20),
        
        PrimaryButton(
          onPressed: () => measurementNotifier.saveMeasurement(context, measurementValidationState.isValid),
          label: 'Save',
          buttonColor: AppColors.greyColor,
        ),
      ],
    );
  }

}