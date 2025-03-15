class MeasurementValidationState {
  final String? dateError;
  final String? volumeFlowError;
  final String? pressureError;
  final String? rotationalFrequencyError;
  final String? currentOperatingHoursError;
  final String? averageOperatingHoursPerDayError;

  MeasurementValidationState({
    this.dateError,
    this.volumeFlowError,
    this.pressureError,
    this.rotationalFrequencyError,
    this.currentOperatingHoursError,
    this.averageOperatingHoursPerDayError,
  });

  bool get isValid => dateError == null && volumeFlowError == null && pressureError == null && rotationalFrequencyError == null && currentOperatingHoursError == null && averageOperatingHoursPerDayError == null;

}