import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_predictive_maintenance_app/features/parameters/domain/measurement.dart';
import 'dart:ffi';

class MeasurementController extends Notifier<Measurement> {
  // initialize the state of the controller
  @override
  Measurement build() {
    return Measurement();
  }


  // setters for the different fields in the form
  set date(date) {
    state = state.copyWith(date: date);
  }

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


  void reset() {
    state = Measurement();
  }

  Future<void> saveMeasurement() async {
    // save the measurement data to the database
    print('Date: ${state.date}');
    print('Volume Flow: ${state.volumeFlow}');
    print('Pressure: ${state.pressure}');
    print('Rotational Frequency: ${state.rotationalFrequency}');
    print('Current Operating Hours: ${state.currentOperatingHours}');
    print('Average Operating Hours Per Day: ${state.averageOperatingHoursPerDay}');

    print('sending to server...');
    await Future.delayed(const Duration(seconds: 2));
    print('Server response: success');
  }
}

final measurementProvider = NotifierProvider<MeasurementController, Measurement>(() => MeasurementController());


