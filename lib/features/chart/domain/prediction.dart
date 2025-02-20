class Prediction {
  final String? id;
  final double? a;  // Quadratic coefficient
  final double? b;  // Quadratic coefficient
  final double? c;  // Quadratic coefficient

  final double? residualWear;
  final double? estimatedOperatingHours;
  final DateTime? estimatedMaintenanceDate;
  final String? adjusmentId;
  final DateTime date;

  Prediction({
    this.id,
    this.a,
    this.b,
    this.c,
    this.residualWear,
    this.estimatedOperatingHours,
    this.estimatedMaintenanceDate,
    this.adjusmentId,
    DateTime? date,
  }) : date = date ?? DateTime.now();

  Prediction copyWith({
    String? id,
    double? a,
    double? b,
    double? c,
    double? residualWear,
    double? estimatedOperatingHours,
    DateTime? estimatedMaintenanceDate,
    String? adjusmentId,
    DateTime? date,
  }) {
    return Prediction(
      id: id ?? this.id,
      a: a ?? this.a,
      b: b ?? this.b,
      c: c ?? this.c,
      residualWear: residualWear ?? this.residualWear,
      estimatedOperatingHours: estimatedOperatingHours ?? this.estimatedOperatingHours,
      estimatedMaintenanceDate: estimatedMaintenanceDate ?? this.estimatedMaintenanceDate,
      adjusmentId: adjusmentId ?? this.adjusmentId,
      date: date ?? this.date,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'a': a,
      'b': b,
      'c': c,
      'residualWear': residualWear,
      'estimatedOperatingHours': estimatedOperatingHours,
      'estimatedMaintenanceDate': estimatedMaintenanceDate?.toIso8601String(),
      'adjusmentId': adjusmentId,
      'date': date.toIso8601String(),
    };
  }

  factory Prediction.fromMap(Map<String, dynamic> map) {
    return Prediction(
      id: map['id'],
      a: map['a'],
      b: map['b'],
      c: map['c'],
      residualWear: map['residualWear'],
      estimatedOperatingHours: map['estimatedOperatingHours'],
      estimatedMaintenanceDate: map['estimatedMaintenanceDate'] != null
          ? DateTime.parse(map['estimatedMaintenanceDate'])
          : null,
      adjusmentId: map['adjusmentId'],
      date: map['date'] != null ? DateTime.parse(map['date']) : DateTime.now(),
    );
  }
}
