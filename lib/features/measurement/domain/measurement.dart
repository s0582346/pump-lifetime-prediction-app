import 'package:flutter_predictive_maintenance_app/shared/utils.dart';

class Measurement{
  final date = DateTime.now();
  final adjustmentId;
  final volumeFlow;
  final pressure;
  final rotationalFrequency;
  final currentOperatingHours;
  final averageOperatingHoursPerDay;

  Measurement({
    this.adjustmentId,
    this.volumeFlow,
    this.pressure,
    this.rotationalFrequency,
    this.currentOperatingHours,
    this.averageOperatingHoursPerDay
  });

  Measurement copyWith({
    adjustmentId,
    volumeFlow,
    pressure,
    rotationalFrequency,
    currentOperatingHours,
    averageOperatingHoursPerDay
  }) {
    return Measurement(
      adjustmentId: adjustmentId ?? this.adjustmentId,
      volumeFlow: volumeFlow ?? this.volumeFlow,
      pressure: pressure ?? this.pressure,
      rotationalFrequency: rotationalFrequency ?? this.rotationalFrequency,
      currentOperatingHours: currentOperatingHours ?? this.currentOperatingHours,
      averageOperatingHoursPerDay: averageOperatingHoursPerDay ?? this.averageOperatingHoursPerDay
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'adjustmentId': adjustmentId,
      'date': date.toIso8601String(),
      'volumeFlow': Utils().convertToInt(volumeFlow),
      'pressure': Utils().convertToInt(pressure),
      'rotationalFrequency': Utils().convertToInt(rotationalFrequency),
      'currentOperatingHours': currentOperatingHours,
      'averageOperatingHoursPerDay': averageOperatingHoursPerDay
    };
  }

  factory Measurement.fromMap(Map<String, dynamic> map) {
    return Measurement(
      adjustmentId: map['adjustmentId'],
      volumeFlow: (map['volumeFlow']).toDouble() / 100,
      pressure: (map['pressure']).toDouble() / 100,
      rotationalFrequency: (map['rotationalFrequency']).toDouble() / 100,
      currentOperatingHours: map['currentOperatingHours'],
      averageOperatingHoursPerDay: map['averageOperatingHoursPerDay']
    );
  }
}