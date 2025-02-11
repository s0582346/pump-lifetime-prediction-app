import 'package:flutter_predictive_maintenance_app/shared/utils.dart';

class Measurement{
  final date = DateTime.now();
  final dynamic adjustmentId;
  final volumeFlow;
  final pressure;
  final rotationalFrequency;
  final currentOperatingHours;
  final averageOperatingHoursPerDay;
  final Qn;
  final pn;

  Measurement({
    this.adjustmentId,
    this.volumeFlow,
    this.pressure,
    this.rotationalFrequency,
    this.currentOperatingHours,
    this.averageOperatingHoursPerDay,
    this.Qn,
    this.pn
  }); 

  Measurement copyWith({
    adjustmentId,
    volumeFlow,
    pressure,
    rotationalFrequency,
    currentOperatingHours,
    averageOperatingHoursPerDay,
    Qn,
    pn
  }) {
    return Measurement(
      adjustmentId: adjustmentId ?? this.adjustmentId,
      volumeFlow: volumeFlow ?? this.volumeFlow,
      pressure: pressure ?? this.pressure,
      rotationalFrequency: rotationalFrequency ?? this.rotationalFrequency,
      currentOperatingHours: currentOperatingHours ?? this.currentOperatingHours,
      averageOperatingHoursPerDay: averageOperatingHoursPerDay ?? this.averageOperatingHoursPerDay,
      Qn: Qn ?? this.Qn,
      pn: pn ?? this.pn
    );}

  Map<String, dynamic> toMap() {
    return {
    'adjustmentId': adjustmentId?.toString(),
    'date': date.toIso8601String(),
    'volumeFlow': Utils().convertToInt(volumeFlow),
    'pressure': Utils().convertToInt(pressure),
    'rotationalFrequency': Utils().convertToInt(rotationalFrequency),
    'currentOperatingHours': Utils().convertToInt(currentOperatingHours),
    'averageOperatingHoursPerDay': Utils().convertToInt(averageOperatingHoursPerDay),
    'Qn': Utils().convertToInt(Qn, factor: 1000),
    'pn': Utils().convertToInt(pn, factor: 1000) ,
    };
  }

  factory Measurement.fromMap(Map<String, dynamic> map) {
    return Measurement(
      adjustmentId: map['adjustmentId'],
      volumeFlow: (map['volumeFlow']).toDouble() / 100,
      pressure: (map['pressure']).toDouble() / 100,
      rotationalFrequency: (map['rotationalFrequency']).toDouble() / 100,
      currentOperatingHours: (map['currentOperatingHours'] ?? 0) / 100,
      averageOperatingHoursPerDay: (map['averageOperatingHoursPerDay'] ?? 0) / 100,
      Qn: (map['Qn'] ?? 0).toDouble() / 1000,
      pn: (map['pn'] ?? 0).toDouble() / 1000,
    );
  }
}