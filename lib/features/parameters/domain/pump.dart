import 'package:flutter_riverpod/flutter_riverpod.dart';

class Pump {
  final String? type;
  final String? rotorGeometry;
  final String? statorGeometry;
  final String? speedChange;
  final String? medium;
  final String? measurableParameter;
  final String? permissibleTotalWear;
  final String? solidConcentration;

  Pump({
    this.type,
    this.rotorGeometry,
    this.statorGeometry,
    this.speedChange,
    this.medium,
    this.measurableParameter,
    this.permissibleTotalWear,
    this.solidConcentration
  });


  // It creates a new instance of a class with some fields updated while keeping other fields the same as the original instance.
  Pump copyWith({
    String? type,
    String? rotorGeometry,
    String? statorGeometry,
    String? speedChange,
    String? medium,
    String? measurableParameter,
    String? permissibleTotalWear,
    String? solidConcentration
  }) {
    return Pump(
      type: type ?? this.type,
      rotorGeometry: rotorGeometry ?? this.rotorGeometry,
      statorGeometry: statorGeometry ?? this.statorGeometry,
      speedChange: speedChange ?? this.speedChange,
      medium: medium ?? this.medium,
      measurableParameter: measurableParameter ?? this.measurableParameter,
      permissibleTotalWear: permissibleTotalWear ?? this.permissibleTotalWear,
      solidConcentration: solidConcentration ?? this.solidConcentration
    );
  }
}