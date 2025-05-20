import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_predictive_maintenance_app/features/chart/application/adjustment_service.dart';
import 'package:flutter_predictive_maintenance_app/features/pump/application/pump_service.dart';
import 'package:flutter_predictive_maintenance_app/features/pump/domain/measurable_parameter.dart';
import 'package:flutter_predictive_maintenance_app/features/pump/domain/pump_type.dart';
import 'package:flutter_predictive_maintenance_app/features/pump/domain/rotor_geometry.dart';
import 'package:flutter_predictive_maintenance_app/features/pump/domain/rotor_stages.dart';
import 'package:flutter_predictive_maintenance_app/features/pump/domain/time_entry.dart';
import 'package:flutter_predictive_maintenance_app/features/pump/domain/viscosity_level.dart';
import 'package:flutter_predictive_maintenance_app/features/pump/presentation/pump_validation_state.dart';
import 'package:flutter_predictive_maintenance_app/shared/result_info.dart';
import 'package:flutter_predictive_maintenance_app/shared/widgets/alert_widget.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_predictive_maintenance_app/features/pump/domain/pump.dart';

class PumpController extends Notifier<Pump> {
  late final PumpService _pumpServiceProvider = ref.read(pumpServiceProvider);
  late final AdjustmentService _adjustmentService = ref.read(adjustmentServiceProvider);
  
  
  @override
  Pump build() {
    return Pump(id: '', type: null);
  }

  set name(String? value) => state = state.copyWith(name: value);
  set pumpType(PumpType? value) => state = state.copyWith(type: value);
  set rotorGeometry(RotorGeometry? value) => state = state.copyWith(rotorGeometry: value);
  set numberOfStages(RotorStages? value) => state = state.copyWith(numberOfStages: value);
  set speedChange(String? value) => state = state.copyWith(speedChange: value);
  set medium(String? value) => state = state.copyWith(medium: value);
  set viscosityLevel(ViscosityLevel? value) => state = state.copyWith(viscosityLevel: value);
  set measurableParameter(MeasurableParameter? value) {
    state = state.copyWith(measurableParameter: value);
  } 
  set permissibleTotalWear(String value) => state = state.copyWith(permissibleTotalWear: value);
  set solidConcentration(String solidConcentration) => state = state.copyWith(solidConcentration: solidConcentration);
  set typeOfTimeEntry(TimeEntry? typeOfTimeEntry) => state = state.copyWith(typeOfTimeEntry: typeOfTimeEntry);
  


  Future<void> savePumpData(BuildContext context, isValid) async {
    final ref = this.ref;
    FocusManager.instance.primaryFocus?.unfocus(); // Close keyboard
    ResultInfo? result;

    if (context.mounted && isValid) {
      final pump = state;
      final pumpId = generatePumpId(pump.type!.label); // Generate a unique pump ID
      final updatedPump = pump.copyWith(id: pumpId);

      result = await _pumpServiceProvider.savePump(updatedPump, _adjustmentService);
      if (result.success) {
        Navigator.of(context).pop();
        ref.invalidate(pumpsProvider); // trigger a refresh of the pumps list
        ref.read(isSubmittingProvider.notifier).state = false;
        reset();
      } else {
        if (context.mounted) {
          showDialog(
              context: context,
              builder: (context) => AlertWidget(
                title: 'Oops! Something went wrong',
                body: result!.errorMessage ?? 'Error saving pump.',
              )
            );
        }
      }     
    }
  }

  Future<void> deletePump(String id, BuildContext context) async {
    ResultInfo? result;

    if (context.mounted) {
      result = await PumpService().deletePump(id);
      if (result.success) {
        ref.invalidate(pumpsProvider);
      } else {
        if (context.mounted) {
          showDialog(
          context: context,
          builder: (context) => AlertWidget(
            title: 'Oops! Something went wrong',
            body: result!.errorMessage ?? 'Error deleting pump.',
          )
        );
        }
      }
    }  
  }

  void reset() {
    state = build();
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

  String? validateSolidConcentration(String? value) {
    if (value == null) {
      return null;
    }
    final intValue = int.tryParse(value);
    if (intValue == null) {
      return 'Please enter a valid number';
    }

    if (intValue < 0 || intValue > 100) {
      return 'Please enter a value between 10 and 100';
    }
  
    return null;
  }


  String? validatePermissibleTotalWear(String? value) {
    if (value == null || value.trim().isEmpty) {
      return errorEmptyMessage;
    }

    final intValue = int.tryParse(value);
    if (intValue == null) {
      return 'Please enter a valid number';
    }

    if (intValue < 10 || intValue > 90) {
      return 'Please enter a value between 10 and 90';
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

  return PumpValidationState(
    nameError: validateName(pump.name),
    pumpTypeError: validatePumpType(pump.type?.label),
    solidConcentrationError: validateSolidConcentration(pump.solidConcentration),
    measurableParameterError: validateMeasurableParameter(pump.measurableParameter?.label),
    persmissibleTotalWearError: validatePermissibleTotalWear(pump.permissibleTotalWear),
    typeOfTimeEntryError: validateTypeOfTimeEntry(pump.typeOfTimeEntry?.label),
  );
});


 String generatePumpId(String pumpType) {
    const letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    final random = Random();

    String randomLetters = List.generate(3, (_) => letters[random.nextInt(letters.length)]).join();

    return '$pumpType-$randomLetters';
  }


