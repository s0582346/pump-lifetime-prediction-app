//final pumpDataState = ref.watch(pumpDataProvider);
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
//import 'package:flutter_predictive_maintenance_app/features/parameters/presentation/form_controllers/pump_data_controller.dart';
import 'package:flutter_predictive_maintenance_app/features/parameters/presentation/form_controllers/measurement_controller.dart';
import 'package:flutter_predictive_maintenance_app/features/parameters/presentation/form_components/input_widget.dart';
import 'package:flutter_predictive_maintenance_app/features/parameters/presentation/form_components/select_widget.dart';
import 'package:flutter_predictive_maintenance_app/features/parameters/presentation/form_components/primary_button.dart';
import 'package:flutter_predictive_maintenance_app/constants/app_colors.dart';  


class MeasurementDataWidget extends ConsumerWidget {
  const MeasurementDataWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final measurementNotifier = ref.read(measurementProvider.notifier);
    
     return ListView(
      padding: const EdgeInsets.all(50.0),
      children: [
        //TODO implement condition for volume flow
        InputWidget(
          label: 'Datum',
          onChanged: (value) => measurementNotifier.date = value,
        ),
        InputWidget(
          label: 'Volumenstrom',
          onChanged: (value) => measurementNotifier.volumeFlow = value,
        ),
        InputWidget(
          label: 'Drehzahl',
          onChanged: (value) => measurementNotifier.rotationalFrequency = value,
        ),
        InputWidget(
          label: 'Aktuelle Betriebsstunden',
          onChanged: (value) => measurementNotifier.currentOperatingHours = value,
        ),
        PrimaryButton(
          onPressed: () => measurementNotifier.saveMeasurement(),
          label: 'Speichern',
          buttonColor: AppColors.greyColor,
        ),
      ],
    );
  }

}