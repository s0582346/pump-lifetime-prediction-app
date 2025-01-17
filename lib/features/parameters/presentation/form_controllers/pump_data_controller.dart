import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_predictive_maintenance_app/features/parameters/domain/pump.dart';


class PumpDataController extends Notifier<Pump> {
  // initialize the state of the controller
  @override
  Pump build() {
    return Pump();
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

  set measurableParameter(String measurableParameter) {
    state = state.copyWith(measurableParameter: measurableParameter);
  }

  set permissibleTotalWear(String permissibleTotalWear) {
    state = state.copyWith(permissibleTotalWear: permissibleTotalWear);
  }
  
  set solidConcentration(String solidConcentration) {
    state = state.copyWith(solidConcentration: solidConcentration);
  }


  void reset() {
    state = Pump();
  } 

  Future<void> savePumpData() async {
    // save the pump data to the database
    print('Type: ${state.type}');
    print('medium: ${state.medium}');
    print('solid Concentration: ${state.solidConcentration}');
    print('measurable Parameter: ${state.measurableParameter}');
    print('permissible Total Wear: ${state.permissibleTotalWear}');

    print('sending to server...');
    await Future.delayed(const Duration(seconds: 2));
    print('Server response: success');
  }
}

final pumpDataProvider = NotifierProvider<PumpDataController, Pump>(() => PumpDataController());