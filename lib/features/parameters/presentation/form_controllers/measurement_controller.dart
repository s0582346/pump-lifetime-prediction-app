import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_predictive_maintenance_app/features/parameters/domain/measurement.dart';
import 'package:flutter_predictive_maintenance_app/features/parameters/application/measurement_service.dart';
import 'package:flutter_predictive_maintenance_app/shared/utils.dart';

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
    //value = Utils().convertToInt(value);
    state = state.copyWith(pressure: value);
  }

  set rotationalFrequency(value) {
    //value = Utils().convertToInt(value);
    state = state.copyWith(rotationalFrequency: value);
  }

  set currentOperatingHours(value) {
    //value = Utils().convertToInt(value);
    state = state.copyWith(currentOperatingHours: value);
  }

  set averageOperatingHoursPerDay(value) {
    //value = Utils().convertToInt(value);
    state = state.copyWith(averageOperatingHoursPerDay: value);
  }


  void reset() {
    state = Measurement();
  }

  // save the measurement data to the database
  Future<void> saveMeasurement() async {

    // convert values to int if necessary
    final convertedState = state.copyWith(
      volumeFlow: Utils().convertToInt(state.volumeFlow),
      pressure: Utils().convertToInt(state.pressure),
      rotationalFrequency: Utils().convertToInt(state.rotationalFrequency),
      currentOperatingHours: Utils().convertToInt(state.currentOperatingHours),
      averageOperatingHoursPerDay: Utils().convertToInt(state.averageOperatingHoursPerDay),
    );

    print('Date: ${convertedState.date}');
    print('Volume Flow: ${convertedState.volumeFlow}');
    print('Pressure: ${convertedState.pressure}');
    print('Rotational Frequency: ${convertedState.rotationalFrequency}');
    print('Current Operating Hours: ${convertedState.currentOperatingHours}');
    print('Average Operating Hours Per Day: ${convertedState.averageOperatingHoursPerDay}');

    
    _measurementService.saveMeasurement(convertedState);
    
    // reset the form
    reset();
  }
}

final measurementProvider = NotifierProvider<MeasurementController, Measurement>(() => MeasurementController());


