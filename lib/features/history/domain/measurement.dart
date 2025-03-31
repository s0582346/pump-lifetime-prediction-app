import 'package:flutter_predictive_maintenance_app/shared/utils.dart';

class Measurement {
  final date;
  final id;
  final adjustmentId;
  final volumeFlow;
  final pressure;
  final rotationalFrequency;
  final currentOperatingHours;
  final averageOperatingHoursPerDay;
  final Qn;
  final pn;
  final QnTotal;
  final pnTotal;

  Measurement({
    this.date,
    this.id,
    this.adjustmentId,
    this.volumeFlow,
    this.pressure,
    this.rotationalFrequency,
    this.currentOperatingHours,
    this.averageOperatingHoursPerDay,
    this.Qn,
    this.pn,
    this.QnTotal,
    this.pnTotal 
  }); 

  Measurement copyWith({
    date,
    id,
    adjustmentId,
    volumeFlow,
    pressure,
    rotationalFrequency,
    currentOperatingHours,
    averageOperatingHoursPerDay,
    Qn,
    pn,
    QnTotal,
    pnTotal
  }) {
    return Measurement(
      date: date ?? this.date,
      id: id ?? this.id,
      adjustmentId: adjustmentId ?? this.adjustmentId,
      volumeFlow: volumeFlow ?? this.volumeFlow,
      pressure: pressure ?? this.pressure,
      rotationalFrequency: rotationalFrequency ?? this.rotationalFrequency,
      currentOperatingHours: currentOperatingHours ?? this.currentOperatingHours,
      averageOperatingHoursPerDay: averageOperatingHoursPerDay ?? this.averageOperatingHoursPerDay,
      Qn: Qn ?? this.Qn,
      pn: pn ?? this.pn,
      QnTotal: QnTotal ?? this.QnTotal,
      pnTotal: pnTotal ?? this.pnTotal
    );}

  Map<String, dynamic> toMap() {
    return {
    'id': id,
    'adjustmentId': adjustmentId?.toString(),
    'date': date.toIso8601String(),
    'volumeFlow': Utils().convertToInt(volumeFlow),
    'pressure': Utils().convertToInt(pressure),
    'rotationalFrequency': Utils().convertToInt(rotationalFrequency),
    'currentOperatingHours': Utils().convertToInt(currentOperatingHours),
    'averageOperatingHoursPerDay': Utils().convertToInt(averageOperatingHoursPerDay),
    'Qn': Utils().convertToInt(Qn, factor: 1000),
    'pn': Utils().convertToInt(pn, factor: 1000) ,
    'QnTotal': Utils().convertToInt(QnTotal, factor: 1000),
    'pnTotal': Utils().convertToInt(pnTotal, factor: 1000),
    };
  }

  factory Measurement.fromMap(Map<String, dynamic> map) {
    return Measurement(
      date: map['date'],
      id: map['id'],
      adjustmentId: map['adjustmentId'],
      volumeFlow: (map['volumeFlow']).toDouble() / 100,
      pressure: (map['pressure']).toDouble() / 100,
      rotationalFrequency: (map['rotationalFrequency']).toDouble() / 100,
      currentOperatingHours: ((map['currentOperatingHours'] ?? 0) ~/ 100), // interger division
      averageOperatingHoursPerDay: ((map['averageOperatingHoursPerDay'] ?? 0) ~/ 100), // interger division
      Qn: (map['Qn'] ?? 0).toDouble() / 1000,
      pn: (map['pn'] ?? 0).toDouble() / 1000,
      QnTotal: (map['QnTotal'] ?? 0).toDouble() / 1000,
      pnTotal: (map['pnTotal'] ?? 0).toDouble() / 1000,
    );
  }
}