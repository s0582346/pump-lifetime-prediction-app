class Pump {
  final DateTime date;
  final String type;
  final rotorGeometry;
  final statorGeometry;
  final speedChange; // Drehzahländerung
  final medium;
  final measurableParameter; // volume flow or pressure
  final permissibleTotalWear; // percent
  final solidConcentration; // percent
  final typeOfTimeEntry; // currentOperatingHours or average per day

  Pump({
    required this.type,
    this.rotorGeometry,
    this.statorGeometry,
    this.speedChange,
    this.medium,
    this.measurableParameter,
    this.permissibleTotalWear,
    this.solidConcentration,
    this.typeOfTimeEntry,
  }) : date = DateTime.now();

  // This getter makes pump.id always equal pump.type.
  String get id => type;

  // Updated copyWith without id parameter since id is derived from type.
  Pump copyWith({
    String? type,
    rotorGeometry,
    statorGeometry,
    speedChange,
    medium,
    measurableParameter,
    permissibleTotalWear,
    solidConcentration,
    typeOfTimeEntry,
  }) {
    return Pump(
      type: type ?? this.type,
      rotorGeometry: rotorGeometry ?? this.rotorGeometry,
      statorGeometry: statorGeometry ?? this.statorGeometry,
      speedChange: speedChange ?? this.speedChange,
      medium: medium ?? this.medium,
      measurableParameter: measurableParameter ?? this.measurableParameter,
      permissibleTotalWear: permissibleTotalWear ?? this.permissibleTotalWear,
      solidConcentration: solidConcentration ?? this.solidConcentration,
      typeOfTimeEntry: typeOfTimeEntry ?? this.typeOfTimeEntry,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'date': date.toIso8601String(),
      'id': id,
      'type': type,
      'rotorGeometry': rotorGeometry,
      'statorGeometry': statorGeometry,
      'speedChange': speedChange,
      'medium': medium,
      'measurableParameter': measurableParameter,
      'permissibleTotalWear': permissibleTotalWear,
      'solidConcentration': solidConcentration,
      'typeOfTimeEntry': typeOfTimeEntry,
    };
  }

  factory Pump.fromMap(Map<String, dynamic> map) {
    return Pump(
      type: map['type'],
      rotorGeometry: map['rotorGeometry'],
      statorGeometry: map['statorGeometry'],
      speedChange: map['speedChange'],
      medium: map['medium'],
      measurableParameter: map['measurableParameter'],
      permissibleTotalWear: map['permissibleTotalWear'],
      solidConcentration: map['solidConcentration'],
      typeOfTimeEntry: map['typeOfTimeEntry'],
    );
  }
}
