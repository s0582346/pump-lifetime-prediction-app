import 'package:flutter_predictive_maintenance_app/features/pump/pump_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_predictive_maintenance_app/features/pump/pump.dart';


class PumpDataController extends Notifier<Pump> {
  // initialize the state of the controller
  @override
  Pump build() {
    return Pump(type: '', id: '');
  }

  set name(String? value) {
    state = state.copyWith(name: value);
  }

  set pumpType(String? value) {
    state = state.copyWith(type: value);
  }

  set rotorGeometry(String? value) {
    state = state.copyWith(rotorGeometry: value);
  }

  set numberOfStages(String? value) {
    state = state.copyWith(numberOfStages: value);
  }

  set speedChange(String? value) {
    state = state.copyWith(speedChange: value);
  }

  set medium(String? value) {
    state = state.copyWith(medium: value);
  }

  set measurableParameter(String? value) {
    state = state.copyWith(measurableParameter: value);
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

final pumpsProvider = FutureProvider<List<Pump>>((ref) async {
  return await ref.read(pumpServiceProvider).getPumps();
});
