import 'package:flutter_predictive_maintenance_app/features/chart/application/adjustment_service.dart';
import 'package:flutter_predictive_maintenance_app/features/chart/application/prediction_service.dart';
import 'package:flutter_predictive_maintenance_app/features/chart/domain/adjustment.dart';
import 'package:flutter_predictive_maintenance_app/features/chart/domain/prediction.dart';
import 'package:flutter_predictive_maintenance_app/features/measurement/application/measurement_service.dart';
import 'package:flutter_predictive_maintenance_app/features/measurement/domain/measurement.dart';
import 'package:flutter_predictive_maintenance_app/navigation/navigation.dart';
import 'package:flutter_predictive_maintenance_app/shared/utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


final dashboardControllerProvider = AsyncNotifierProvider<DashboardController, DashboardState>(DashboardController.new);

class DashboardController extends AsyncNotifier<DashboardState> {

  late final MeasurementService _measurementService = ref.read(measurementServiceProvider);
  late final PredictionService _predictionService = ref.read(predictionServiceProvider);
  late final AdjustmentService _adjustmentService = ref.read(adjustmentServiceProvider);


  @override
  Future<DashboardState> build() async {
     final pump = ref.watch(selectedPumpProvider);

    if (pump == null) {
      return DashboardState(
        measurements: [], 
        adjustments: [],
        prediction: Prediction(),
      );
    } 

    try {
      final pumpId = pump.id.replaceAll(RegExp(r'-\w+$'), '');
      final adjustmentId = '$pumpId-S'; 
      final predictions = await _predictionService.getPredictions(pump);
      final predictionTotal = predictions.firstWhere(
        (p) => p.adjusmentId == adjustmentId,
        orElse: () => Prediction(),
      );
      final measurements = await _measurementService.fetchMeasurementsByPumpId(pump.id);
      final groupedMeasurements = Utils().groupMeasurements(measurements);
      final adjustments = await _adjustmentService.fetchAdjustmentsByPumpId(pump.id);

      return DashboardState(
        measurements: measurements,
        adjustments: adjustments,
        prediction: predictionTotal,
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
  final List<Adjustment>? adjustments;
  final Prediction? prediction;

  DashboardState({
    List<Measurement>? measurements,
    List<Adjustment>? adjustments,
    Prediction? prediction,
  })  : measurements = measurements ?? [],
        adjustments = adjustments ?? [],
        prediction = prediction ?? Prediction();

  DashboardState copyWith({
    List<Measurement>? measurements,
    List<Adjustment>? adjustments,
    Prediction? prediction,
  }) {
    return DashboardState(
      measurements: measurements ?? this.measurements,
      adjustments: adjustments ?? this.adjustments,
      prediction: prediction ?? this.prediction,
    );
  }
}


  