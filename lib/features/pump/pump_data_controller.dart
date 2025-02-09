import 'package:flutter_predictive_maintenance_app/features/pump/pump_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_predictive_maintenance_app/features/pump/pump.dart';


class PumpDataController extends Notifier<Pump> {
  // initialize the state of the controller
  @override
  Pump build() {
    return Pump(type: '');
  }

  set pumpType(String? type) {
    state = state.copyWith(type: type);
  }

  set rotorGeometry(String rotorGeometry) {
    state = state.copyWith(rotorGeometry: rotorGeometry);
  }

  set statorGeometry(String statorGeometry) {
    state = state.copyWith(statorGeometry: statorGeometry);
  }

  set speedChange(String speedChange) {
    state = state.copyWith(speedChange: speedChange);
  }

  set medium(String medium) {
    state = state.copyWith(medium: medium);
  }

  set measurableParameter(String? measurableParameter) {
    state = state.copyWith(measurableParameter: measurableParameter);
  }

  set permissibleTotalWear(String permissibleTotalWear) {
    state = state.copyWith(permissibleTotalWear: permissibleTotalWear);
  }
  
  set solidConcentration(String solidConcentration) {
    state = state.copyWith(solidConcentration: solidConcentration);
  }

  set typeOfTimeEntry(String? typeOfTimeEntry) {
    state = state.copyWith(typeOfTimeEntry: typeOfTimeEntry);
  }


  Future<bool> savePumpData() async {

    // TODO: add all the fields
    final convertedState = state.copyWith(
      solidConcentration: state.solidConcentration,
      type: state.type,
      medium: state.medium,
      measurableParameter: state.measurableParameter,
      permissibleTotalWear: state.permissibleTotalWear
    );

    try {
      await PumpService().savePump(convertedState);
      state = build();
      return true;  // success
    } catch (e) {
      return false;  // failure
    }
  }
}

///  Providers

final pumpFormProvider = NotifierProvider<PumpDataController, Pump>(() => PumpDataController());

final pumpServiceProvider = Provider<PumpService>((ref) {
  return PumpService();
});

final pumpsProvider = FutureProvider<List<Pump>>((ref) async {
  final repo = ref.read(pumpServiceProvider);
  return await repo.getPumps();
});
