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
      'volumeFlow': volumeFlow,
      'pressure': pressure,
      'rotationalFrequency': rotationalFrequency,
      'currentOperatingHours': currentOperatingHours,
      'averageOperatingHoursPerDay': averageOperatingHoursPerDay
    };
  }
}