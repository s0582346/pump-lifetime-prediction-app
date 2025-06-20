import 'package:flutter/material.dart';
import 'package:flutter_predictive_maintenance_app/features/chart/presentation/chart_controller.dart';
import 'package:flutter_predictive_maintenance_app/features/dashboard/dashboard_controller.dart';
import 'package:flutter_predictive_maintenance_app/features/history/presentation/history_controller.dart';
import 'package:flutter_predictive_maintenance_app/features/history/presentation/measurement_validation_state.dart';
import 'package:flutter_predictive_maintenance_app/features/pump/domain/measurable_parameter.dart';
import 'package:flutter_predictive_maintenance_app/features/pump/domain/pump.dart';
import 'package:flutter_predictive_maintenance_app/features/pump/domain/time_entry.dart';
import 'package:flutter_predictive_maintenance_app/shared/result_info.dart';
import 'package:flutter_predictive_maintenance_app/shared/utils.dart';
import 'package:flutter_predictive_maintenance_app/shared/widgets/alert_widget.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_predictive_maintenance_app/features/history/domain/measurement.dart';
import 'package:flutter_predictive_maintenance_app/features/history/application/measurement_service.dart';
import 'package:flutter_predictive_maintenance_app/navigation/navigation.dart';


class MeasurementController extends Notifier<Measurement> {
  final MeasurementService _measurementService = MeasurementService();

  // initialize the state of the controller
  @override
  Measurement build() {
    return Measurement();
  }

  set date(value) { 
    state = state.copyWith(date: value); 
  }
  set volumeFlow(value) => state = state.copyWith(volumeFlow: Utils().normalizeInput(value));
  set pressure(value) => state = state.copyWith(pressure: Utils().normalizeInput(value));
  set rotationalFrequency(value) => state = state.copyWith(rotationalFrequency: Utils().normalizeInput(value));
  set currentOperatingHours(value) => state = state.copyWith(currentOperatingHours: Utils().normalizeInput(value));
  set averageOperatingHoursPerDay(value) => state = state.copyWith(averageOperatingHoursPerDay: Utils().normalizeInput(value));
  
  
  void loadMeasurement(Measurement measurement) {
    ref.read(isEditingProvider.notifier).state = true;
    state = measurement.copyWith(
      date: DateTime.tryParse(measurement.date),
      volumeFlow: measurement.volumeFlow?.toString(),
      pressure: measurement.pressure?.toString(),
      rotationalFrequency: measurement.rotationalFrequency?.toString(),
      currentOperatingHours: measurement.currentOperatingHours?.toString(),
      averageOperatingHoursPerDay: measurement.averageOperatingHoursPerDay?.toString(),
    );
  }

  Future<void> saveMeasurement(BuildContext context, isValid) async {
    final ref = this.ref;
    final pump = ref.watch(selectedPumpProvider);
    ref.read(isSubmittingProvider.notifier).state = true;
    FocusManager.instance.primaryFocus?.unfocus(); // Close keyboard
    ResultInfo? result;
  
    // Use internal state directly
    if (state.date == null) {
      final date = DateTime.now();
      DateTime dateOnly = DateTime(date.year, date.month, date.day);
      state = state.copyWith(date: dateOnly);
    }

    if (context.mounted && isValid && pump != null) {
      result = await _measurementService.saveMeasurement(state, pump);

      if (result.success) { // ratio is within permissible loss
        reset(); // Reset state after save
        ref.read(historyControllerProvider.notifier).refresh();
        ref.read(chartControllerProvider.notifier).refresh();
        ref.read(dashboardControllerProvider.notifier).refresh();
        if (context.mounted) Navigator.of(context).pop();
      } else { 
        if (context.mounted) {
          if (result.prop != null && result.errorMessage != null) {
            showDialog(
              context: context,
              builder: (context) => AlertWidget(
                body: result!.errorMessage,
                onTap: () async {
                  result = await _measurementService.saveMeasurement(state, pump, forceSave: true);
                  reset();
                  ref.read(historyControllerProvider.notifier).refresh();
                  ref.read(chartControllerProvider.notifier).refresh();
                  ref.read(dashboardControllerProvider.notifier).refresh();
                  if (context.mounted) Navigator.of(context).popUntil((route) => route.isFirst); 
                }  
              )
            );
          } else {
            showDialog(
              context: context,
              builder: (context) => AlertWidget(
                title: 'Oops! Something went wrong',
                body: result!.errorMessage ?? 'Error saving measurement.',
              )
            );
          }
        
        }
      }
      ref.read(isSubmittingProvider.notifier).state = false;
      ref.read(isEditingProvider.notifier).state = false;
    }
  }

  void reset() {
    state = build();
  }
}

final measurementProvider = NotifierProvider<MeasurementController, Measurement>(() => MeasurementController());
final isSubmittingProvider = StateProvider<bool>((ref) => false);
final isEditingProvider = StateProvider<bool>((ref) => false);


MeasurementValidationState validateMeasurement(
  Measurement measurement,
  Pump? pump
) {
  final isVolumeFlow = pump?.measurableParameter == MeasurableParameter.volumeFlow;
  final isAverage = pump?.typeOfTimeEntry == TimeEntry.average;
  const errorEmptyMessage = 'This field is required.';
  const validNumberMessage = 'Please enter a valid number.';

  String? validateRotationalFrequency(value) {
    final stringValue = value?.toString().trim();

    if (stringValue == null || stringValue.isEmpty) return errorEmptyMessage;

    final normalized = stringValue.replaceAll(',', '.');

    final parsed = double.tryParse(normalized);

    if (parsed == null || parsed < 0) return validNumberMessage;

    return null;
  }

  String? validateOperatingHours(dynamic value) {
    final stringValue = value?.toString().trim();

    if (stringValue == null || stringValue.isEmpty) return errorEmptyMessage;

    if (stringValue.contains(',')) {
      value = stringValue.replaceAll(',', '.');
    } else {
      value = stringValue;
    }

    final formatted = int.tryParse(value
    );

    if (formatted == null || formatted < 0) return validNumberMessage;

    return null;
  }

  String? validateFlow(dynamic value) {
    final stringValue = value?.toString().trim();

    if (stringValue == null || stringValue.isEmpty) return errorEmptyMessage;

    final normalized = stringValue.replaceAll(',', '.');
    final formatted = double.tryParse(normalized);

    if (formatted == null || formatted <= 0.0) return validNumberMessage;

    return null;
  }
  
  return MeasurementValidationState(
    dateError: null,
    volumeFlowError: isVolumeFlow ? validateFlow(measurement.volumeFlow) : null,
    pressureError: !isVolumeFlow ? validateFlow(measurement.pressure) : null,
    rotationalFrequencyError: validateRotationalFrequency(measurement.rotationalFrequency),
    currentOperatingHoursError: !isAverage ? validateOperatingHours(measurement.currentOperatingHours) : null,
    averageOperatingHoursPerDayError: isAverage ? validateOperatingHours(measurement.averageOperatingHoursPerDay) : null,
  );
}


final measurementValidationProvider = Provider<MeasurementValidationState>((ref) {
  final measurement = ref.watch(measurementProvider);
  final pump = ref.watch(selectedPumpProvider);

  return validateMeasurement(measurement, pump);
});


