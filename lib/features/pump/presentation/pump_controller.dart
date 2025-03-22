import 'package:flutter_predictive_maintenance_app/features/pump/application/pump_service.dart';
import 'package:flutter_predictive_maintenance_app/features/pump/presentation/pump_validation_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_predictive_maintenance_app/features/pump/domain/pump.dart';


class PumpController extends Notifier<Pump> {
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

  set permissibleTotalWear(String value) {
    state = state.copyWith(permissibleTotalWear: value);
  }
  
  set solidConcentration(String solidConcentration) {
    state = state.copyWith(solidConcentration: solidConcentration);
  }

  set typeOfTimeEntry(String? typeOfTimeEntry) {
    state = state.copyWith(typeOfTimeEntry: typeOfTimeEntry);
  }


  Future<bool> savePumpData() async {
    // TODO: code below still needed?
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

  Future<void> deletePump(String id) async {
    await PumpService().deletePump(id);
  }
}

///  Providers
final pumpFormProvider = NotifierProvider<PumpController, Pump>(() => PumpController());

final pumpsProvider = FutureProvider<List<Pump>>((ref) async {
  return await ref.read(pumpServiceProvider).getPumps();
});


final isSubmittingProvider = StateProvider<bool>((ref) => false);

/// A provider to compute validation errors based on the Pump state
final pumpValidationProvider = Provider<PumpValidationState>((ref) {
  final pump = ref.watch(pumpFormProvider);
  const errorEmptyMessage = 'This field is required';
  final isSubmitting = ref.watch(isSubmittingProvider);

  String? validateName(String? name) {
    if (name == null || name.trim().isEmpty) {
      return errorEmptyMessage;
    }
    
    return null;
  }

  String? validatePumpType(String? type) {
    if (type == null || type.trim().isEmpty) {
      return errorEmptyMessage;
    }
    
    return null;
  }

  String? validateMeasurableParameter(String? value) {
    if (value == null || value.trim().isEmpty) {
      return errorEmptyMessage;
    }
    
    return null;
  }

  String? validatePermissibleTotalWear(String? value) {

    if (value == null || value.trim().isEmpty) {
      return errorEmptyMessage;
    }

    // Try parsing the string to an int.
    final intValue = int.tryParse(value);
    if (intValue == null) {
      return 'Please enter a valid number';
    }

    if (intValue < 10 || intValue > 100) {
      return 'Please enter a value between 10 and 100';
    }

    if (intValue % 10 != 0) {
      return 'Please enter a value that is a multiple of 10';
    }
  
    return null;
  }


  String? validateTypeOfTimeEntry(String? value) {
    if (value == null || value.trim().isEmpty) {
      return errorEmptyMessage;
    }
    
    return null;
  }

  return isSubmitting ? PumpValidationState(
    nameError: validateName(pump.name),
    pumpTypeError: validatePumpType(pump.type),
    measurableParameterError: validateMeasurableParameter(pump.measurableParameter),
    persmissibleTotalWearError: validatePermissibleTotalWear(pump.permissibleTotalWear),
    typeOfTimeEntryError: validateTypeOfTimeEntry(pump.typeOfTimeEntry),
  ) : const PumpValidationState();
});

