import 'package:flutter_predictive_maintenance_app/features/chart/application/adjustment_service.dart';
import 'package:flutter_predictive_maintenance_app/features/prediction/prediction_service.dart';
import 'package:flutter_predictive_maintenance_app/features/chart/domain/adjustment.dart';
import 'package:flutter_predictive_maintenance_app/features/prediction/prediction.dart';
import 'package:flutter_predictive_maintenance_app/features/history/application/measurement_service.dart';
import 'package:flutter_predictive_maintenance_app/features/history/domain/measurement.dart';
import 'package:flutter_predictive_maintenance_app/navigation/navigation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


final dashboardControllerProvider = AsyncNotifierProvider<DashboardController, DashboardState>(DashboardController.new);

class DashboardController extends AsyncNotifier<DashboardState> {

  late final MeasurementService _measurementService = ref.read(measurementServiceProvider);
  late final PredictionService _predictionService = ref.read(predictionServiceProvider);
  late final AdjustmentService _adjustmentService = ref.read(adjustmentServiceProvider);


  @override
  Future<DashboardState> build() async {
    List<Adjustment>? adjustments = [];
     final pump = ref.watch(selectedPumpProvider);

    if (pump == null) {
      return DashboardState(
        measurements: [], 
        adjustments: [],
        predictions: [],
      );
    } 

    try {
      final predictions = await _predictionService.getPredictions(pump);
      final measurements = await _measurementService.fetchMeasurementsByPumpId(pump.id);
      adjustments = await _adjustmentService.fetchAdjustmentsByPumpId(pump.id);
      adjustments = adjustments.where((a) => a.id != '${pump.id}-S').toList(); // first adjustment is the sum of all adjustments, so we skip it

      return DashboardState(
        measurements: measurements,
        adjustments: adjustments,
        predictions: predictions,
      );
    
    } catch (e, stack) {
      throw AsyncError(e, stack);
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading(); // Set the state to loading
    state = await AsyncValue.guard(() => build());
  }

}

class DashboardState {
  final List<Measurement>? measurements;
  final List<Adjustment> adjustments;
  final List<Prediction>? predictions;

  DashboardState({
    List<Measurement>? measurements,
    List<Adjustment>? adjustments,
    List<Prediction>? predictions,
  })  : measurements = measurements ?? [],
        predictions = predictions ?? [],
        adjustments = adjustments ?? [];

  DashboardState copyWith({
    List<Measurement>? measurements,
    List<Adjustment>? adjustments,
    List<Prediction>? predictions,
  }) {
    return DashboardState(
      measurements: measurements ?? this.measurements,
      adjustments: adjustments ?? this.adjustments,
      predictions: predictions ?? this.predictions,
    );
  }
}


  