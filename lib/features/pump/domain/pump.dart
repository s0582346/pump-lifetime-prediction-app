import 'package:flutter_predictive_maintenance_app/shared/utils.dart';

class Pump {
  final DateTime date;
  final String id;
  final String type;
  final name;
  final rotorGeometry;
  final numberOfStages;
  final speedChange; // Drehzahländerung
  final medium;
  final measurableParameter; // volume flow or pressure
  final permissibleTotalWear; // percent
  final solidConcentration; // percent
  final typeOfTimeEntry; // currentOperatingHours or average per day

  Pump({
    required this.type,
    required this.id,
    this.name,
    this.rotorGeometry,
    this.numberOfStages,
    this.speedChange,
    this.medium,
    this.measurableParameter,
    this.permissibleTotalWear,
    this.solidConcentration,
    this.typeOfTimeEntry,
  }) : date = DateTime.now();

  Pump copyWith({
    id,
    type,
    name,
    rotorGeometry,
    numberOfStages,
    speedChange,
    medium,
    measurableParameter,
    permissibleTotalWear,
    solidConcentration,
    typeOfTimeEntry,
  }) {
    return Pump(
      id: id ?? this.id,
      type: type ?? this.type,
      name: name ?? this.name,
      rotorGeometry: rotorGeometry ?? this.rotorGeometry,
      numberOfStages: numberOfStages ?? this.numberOfStages,
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
      'name': name,
      'type': type,
      'rotorGeometry': rotorGeometry,
      'numberOfStages': numberOfStages,
      'speedChange': speedChange,
      'medium': medium,
      'measurableParameter': measurableParameter,
      'permissibleTotalWear': Utils().convertToInt(permissibleTotalWear, factor: 100),
      'solidConcentration': solidConcentration,
      'typeOfTimeEntry': typeOfTimeEntry,
    };
  }

  factory Pump.fromMap(Map<String, dynamic> map) {
    return Pump(
      id: map['id'],
      type: map['type'],
      name: map['name'],
      rotorGeometry: map['rotorGeometry'],
      numberOfStages: map['numberOfStages'],
      speedChange: map['speedChange'],
      medium: map['medium'],
      measurableParameter: map['measurableParameter'],
      permissibleTotalWear: (map['permissibleTotalWear']).toInt() / 100,
      solidConcentration: map['solidConcentration'],
      typeOfTimeEntry: map['typeOfTimeEntry'],
    );
  }
}
