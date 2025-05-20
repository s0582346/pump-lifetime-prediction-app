import 'package:flutter_predictive_maintenance_app/features/pump/domain/measurable_parameter.dart';
import 'package:flutter_predictive_maintenance_app/features/pump/domain/pump_type.dart';
import 'package:flutter_predictive_maintenance_app/features/pump/domain/rotor_geometry.dart';
import 'package:flutter_predictive_maintenance_app/features/pump/domain/rotor_stages.dart';
import 'package:flutter_predictive_maintenance_app/features/pump/domain/time_entry.dart';
import 'package:flutter_predictive_maintenance_app/features/pump/domain/viscosity_level.dart';
import 'package:flutter_predictive_maintenance_app/shared/utils.dart';

class Pump {
  final DateTime date;
  final String id;
  final PumpType? type;
  final name;
  final RotorGeometry? rotorGeometry;
  final RotorStages? numberOfStages;
  final speedChange; // Drehzahländerung
  final medium;
  final ViscosityLevel? viscosityLevel; // watery, low, medium, high
  final MeasurableParameter? measurableParameter; // volume flow or pressure
  final permissibleTotalWear; // percent
  final solidConcentration; // percent
  final TimeEntry? typeOfTimeEntry; // currentOperatingHours or average per day

  Pump({
    required this.type,
    required this.id,
    this.name,
    this.rotorGeometry,
    this.numberOfStages,
    this.speedChange,
    this.medium,
    this.viscosityLevel,
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
    viscosityLevel,
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
      viscosityLevel: viscosityLevel ?? this.viscosityLevel,
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
      'type': type.toString(),
      'rotorGeometry': rotorGeometry.toString(),
      'numberOfStages': numberOfStages.toString(),
      'speedChange': speedChange,
      'medium': medium,
      'viscosityLevel': viscosityLevel.toString(),
      'measurableParameter': measurableParameter.toString(),
      'permissibleTotalWear': Utils().convertToInt(permissibleTotalWear, factor: 100),
      'solidConcentration': solidConcentration,
      'typeOfTimeEntry': typeOfTimeEntry.toString(),
    };
  }

  factory Pump.fromMap(Map<String, dynamic> map) {
    return Pump(
      id: map['id'],
      type: PumpType.fromString(map['type']) ?? PumpType.nm045,
      name: map['name'],
      rotorGeometry: RotorGeometry.fromString(map['rotorGeometry']),
      numberOfStages: RotorStages.fromString(map['numberOfStages']),
      speedChange: map['speedChange'],
      medium: map['medium'],
      viscosityLevel: ViscosityLevel.fromString(map['viscosityLevel']),
      measurableParameter: MeasurableParameter.fromString(map['measurableParameter']),
      permissibleTotalWear: (map['permissibleTotalWear']).toInt() / 100,
      solidConcentration: map['solidConcentration'],
      typeOfTimeEntry: TimeEntry.fromString(map['typeOfTimeEntry']),
    );
  }
}
