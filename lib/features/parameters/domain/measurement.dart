import 'dart:ffi';

class Measurement{
  final DateTime? date;
  final Double? volumeFlow;
  final Double? pressure;
  final Double? rotationalFrequency;
  final String? currentOperatingHours;
  final Int? averageOperatingHoursPerDay;

  Measurement({
    this.date,
    this.volumeFlow,
    this.pressure,
    this.rotationalFrequency,
    this.currentOperatingHours,
    this.averageOperatingHoursPerDay
  });

  Measurement copyWith({
    DateTime? date,
    Double? volumeFlow,
    Double? pressure,
    Double? rotationalFrequency,
    String? currentOperatingHours,
    Int? averageOperatingHoursPerDay
  }) {
    return Measurement(
      date: date ?? this.date,
      volumeFlow: volumeFlow ?? this.volumeFlow,
      pressure: pressure ?? this.pressure,
      rotationalFrequency: rotationalFrequency ?? this.rotationalFrequency,
      currentOperatingHours: currentOperatingHours ?? this.currentOperatingHours,
      averageOperatingHoursPerDay: averageOperatingHoursPerDay ?? this.averageOperatingHoursPerDay
    );
  }
}