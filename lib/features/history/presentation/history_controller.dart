import 'dart:async';
import 'package:flutter_predictive_maintenance_app/features/chart/application/adjustment_service.dart';
import 'package:flutter_predictive_maintenance_app/features/chart/domain/adjustment.dart';
import 'package:flutter_predictive_maintenance_app/shared/utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_predictive_maintenance_app/features/history/application/measurement_service.dart';
import 'package:flutter_predictive_maintenance_app/features/history/domain/measurement.dart';
import 'package:flutter_predictive_maintenance_app/navigation/navigation.dart';

final historyControllerProvider = AsyncNotifierProvider<HistoryController, HistoryState>(HistoryController.new);
final tabIndexProvider = StateProvider<int>((ref) => 0);

class HistoryController extends AsyncNotifier<HistoryState> {

  late final MeasurementService _measurementService = ref.read(measurementServiceProvider);
  late final AdjustmentService _adjustmentService = ref.read(adjustmentServiceProvider);
  
  @override
  Future<HistoryState> build() async {
     final pump = ref.watch(selectedPumpProvider);

    if (pump == null) {
      return HistoryState(
        groupedMeasurements: {}, 
        adjustments: []
      );
    } 

    try {
      final measurements = await _measurementService.fetchMeasurementsByPumpId(pump.id);
      final groupedMeasurements = Utils().groupMeasurements(measurements);
      final adjustments = (await _adjustmentService.fetchAdjustmentsByPumpId(pump.id))!.skip(1).toList(); // first adjustment is the sum of all adjustments, so we skip it


      return HistoryState(
        groupedMeasurements: groupedMeasurements,
        adjustments: adjustments,
      );
    
    } catch (e, stack) {
      throw AsyncError(e, stack);
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => build());
  }
}

class HistoryState {
  final Map<String, List<Measurement>> groupedMeasurements;
  final List<Adjustment> adjustments;

  HistoryState({
    Map<String, List<Measurement>>? groupedMeasurements,
    List<Adjustment>? adjustments,
  })  : groupedMeasurements = groupedMeasurements ?? {},
        adjustments = adjustments ?? [];

  HistoryState copyWith({
    Map<String, List<Measurement>>? measurements,
    List<Adjustment>? adjustments,
  }) {
    return HistoryState(
      groupedMeasurements: measurements ?? this.groupedMeasurements,
      adjustments: adjustments ?? this.adjustments,
    );
  }
}



