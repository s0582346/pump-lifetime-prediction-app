

import 'package:flutter_predictive_maintenance_app/features/chart/application/adjustment_service.dart';
import 'package:flutter_predictive_maintenance_app/features/chart/domain/adjustment.dart';
import 'package:flutter_predictive_maintenance_app/features/history/presentation/history_controller.dart';
import 'package:flutter_predictive_maintenance_app/features/measurement/application/measurement_service.dart';
import 'package:flutter_predictive_maintenance_app/features/measurement/domain/measurement.dart';
import 'package:flutter_predictive_maintenance_app/navigation/navigation.dart';
import 'package:flutter_predictive_maintenance_app/shared/utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


final dashboardControllerProvider = AsyncNotifierProvider<DashboardController, DashboardState>(DashboardController.new);

class DashboardController extends AsyncNotifier<DashboardState> {

  late final MeasurementService _measurementService = ref.read(measurementServiceProvider);
  late final AdjustmentService _adjustmentService = ref.read(adjustmentServiceProvider);


    @override
  Future<DashboardState> build() async {
     final pump = ref.watch(selectedPumpProvider);

    if (pump == null) {
      return DashboardState(
        groupedMeasurements: {}, 
        adjustments: []
      );
    } 

    try {
      final measurements = await _measurementService.fetchMeasurementsByPumpId(pump.id);
      final groupedMeasurements = Utils().groupMeasurements(measurements);
      final adjustments = await _adjustmentService.fetchAdjustmentsByPumpId(pump.id);

      return DashboardState(
        groupedMeasurements: groupedMeasurements,
        adjustments: adjustments,
      );
    
    } catch (e, stack) {
      throw AsyncError(e, stack);
    }
  }

}

class DashboardState {
  final Map<String, List<Measurement>> groupedMeasurements;
  final List<Adjustment> adjustments;

  DashboardState({
    Map<String, List<Measurement>>? groupedMeasurements,
    List<Adjustment>? adjustments,
  })  : groupedMeasurements = groupedMeasurements ?? {},
        adjustments = adjustments ?? [];

  DashboardState copyWith({
    Map<String, List<Measurement>>? groupedMeasurements,
    List<Adjustment>? adjustments,
  }) {
    return DashboardState(
      groupedMeasurements: groupedMeasurements ?? this.groupedMeasurements,
      adjustments: adjustments ?? this.adjustments,
    );
  }
}


  