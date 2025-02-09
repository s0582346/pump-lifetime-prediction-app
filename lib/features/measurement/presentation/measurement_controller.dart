import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_predictive_maintenance_app/features/measurement/domain/measurement.dart';
import 'package:flutter_predictive_maintenance_app/features/measurement/application/measurement_service.dart';
import 'package:flutter_predictive_maintenance_app/shared/utils.dart';
import 'package:flutter_predictive_maintenance_app/navigation/navigation.dart';


class MeasurementController extends Notifier<Measurement> {
  final MeasurementService _measurementService = MeasurementService();

  // initialize the state of the controller
  @override
  Measurement build() {
    return Measurement();
  }

  // setters for the different fields in the form
  /*
  set date(date) {
  
    final regex = RegExp(r'^\d{2}-\d{2}-\d{4}$');
    if (!regex.hasMatch(date)) {
       return;
    }
    DateFormat format = DateFormat("dd-MM-yyyy"); 
    state = state.copyWith(date: date);
  }*/

  set volumeFlow(value) {
    state = state.copyWith(volumeFlow: value);
  }

  set pressure(value) {
    state = state.copyWith(pressure: value);
  }

  set rotationalFrequency(value) {
    state = state.copyWith(rotationalFrequency: value);
  }

  set currentOperatingHours(value) {
    state = state.copyWith(currentOperatingHours: value);
  }

  set averageOperatingHoursPerDay(value) {
    state = state.copyWith(averageOperatingHoursPerDay: value);
  }
 

  /// Save the measurement data to the database
  Future<bool> saveMeasurement() async {
    try {
      final pump = ref.watch(selectedPumpProvider);

      if (pump == null) {
        return false;
      }

      await _measurementService.saveMeasurement(state, pump.id);
      state = build(); // reset the form
      return true;
    } catch (e) {
      // Handle errors appropriately
      print('Error saving measurement: $e');
      return false;
    }
  }
}

final measurementProvider = NotifierProvider<MeasurementController, Measurement>(() => MeasurementController());


