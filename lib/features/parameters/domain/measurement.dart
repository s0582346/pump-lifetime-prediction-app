
class Measurement{
  final date;
  final volumeFlow;
  final pressure;
  final rotationalFrequency;
  final currentOperatingHours;
  final averageOperatingHoursPerDay;

  Measurement({
    this.date,
    this.volumeFlow,
    this.pressure,
    this.rotationalFrequency,
    this.currentOperatingHours,
    this.averageOperatingHoursPerDay
  });

  Measurement copyWith({
    date,
    volumeFlow,
    pressure,
    rotationalFrequency,
    currentOperatingHours,
    averageOperatingHoursPerDay
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

  Map<String, dynamic> toMap() {
    return {
      'date': date,
      'volumeFlow': volumeFlow,
      'pressure': pressure,
      'rotationalFrequency': rotationalFrequency,
      'currentOperatingHours': currentOperatingHours,
      'averageOperatingHoursPerDay': averageOperatingHoursPerDay
    };
  }
}