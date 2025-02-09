import 'package:flutter/material.dart';
import 'package:flutter_predictive_maintenance_app/features/history/presentation/controllers/history_controller.dart';
import 'package:flutter_predictive_maintenance_app/navigation/navigation_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_predictive_maintenance_app/features/measurement/presentation/measurement_controller.dart';
import 'package:flutter_predictive_maintenance_app/components/form_components/input_widget.dart';
import 'package:flutter_predictive_maintenance_app/components/form_components/primary_button.dart';
import 'package:flutter_predictive_maintenance_app/constants/app_colors.dart';  

class MeasurementDataWidget extends ConsumerWidget {
  const MeasurementDataWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final measurementNotifier = ref.read(measurementProvider.notifier);
    final measurementState = ref.watch(measurementProvider);
    
     return ListView(
      padding: const EdgeInsets.all(40.0),
      children: [
        //TODO implement condition for volume flow
        InputWidget(
          label: 'Volumenstrom',
          initialValue: measurementState.volumeFlow,
          onChanged: (value) => measurementNotifier.volumeFlow = value,
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
              ref.invalidate(measurementsProvider);
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