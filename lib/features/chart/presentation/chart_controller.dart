import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_predictive_maintenance_app/features/chart/application/adjustment_service.dart';
import 'package:flutter_predictive_maintenance_app/features/chart/application/prediction_service.dart';
import 'package:flutter_predictive_maintenance_app/features/chart/domain/adjustment.dart';
import 'package:flutter_predictive_maintenance_app/features/chart/domain/prediction.dart';
import 'package:flutter_predictive_maintenance_app/shared/controllers/base_measurement_controller.dart';
import 'package:flutter_predictive_maintenance_app/shared/utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_predictive_maintenance_app/features/measurement/application/measurement_service.dart';
import 'package:flutter_predictive_maintenance_app/features/measurement/domain/measurement.dart';
import 'package:flutter_predictive_maintenance_app/navigation/navigation.dart';

final chartControllerProvider =
    AsyncNotifierProvider<ChartController, ChartState>(ChartController.new);

class ChartController extends AsyncNotifier<ChartState> {

  late final MeasurementService _measurementService =
      ref.read(measurementServiceProvider);

  late final PredictionService _predictionService =
      ref.read(predictionServiceProvider);


  // On build, fetch measurements and predictions together.
  @override
  Future<ChartState> build() async {
   

    final pump = ref.watch(selectedPumpProvider);
    if (pump == null) {
      // If no pump is selected, return empty values
      return ChartState(
        groupedMeasurements: {},
        predictions: [],
      );
    }

    try {
      // 1) Fetch measurements
      final measurements = await _measurementService.fetchMeasurementsByPumpId(pump.id);
      final groupedMeasurements = _groupMeasurements(measurements);

      // 2) Fetch predictions
      final predictions = await _predictionService.getPredictions(pump);

      // 3) Return combined state
      return ChartState(
        groupedMeasurements: groupedMeasurements,
        predictions: predictions,
      );
    } catch (e, stack) {
      throw AsyncError(e, stack);
    }
  }

  // If you want, add a refresh method
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => build());
  }

  Future<void> closeAdjustment(adjustmentId) async {
    AdjustmentService().closeAdjustment(adjustmentId);
    
  }

  Map<String, List<Measurement>> _groupMeasurements(
    List<Measurement> measurements,
  ) {
    final groupedMeasurements = <String, List<Measurement>>{};
    for (var measurement in measurements) {
      groupedMeasurements
          .putIfAbsent(measurement.adjustmentId, () => [])
          .add(measurement);
    }
    return groupedMeasurements;
  }
}

final predictionServiceProvider = Provider((ref) => PredictionService());

class ChartState {
  final Map<String, List<Measurement>> groupedMeasurements;
  final List<Prediction> predictions;

  ChartState({
    required this.groupedMeasurements,
    required this.predictions,
  });

  ChartState copyWith({
    Map<String, List<Measurement>>? groupedMeasurements,
    List<Prediction>? predictions,
  }) {
    return ChartState(
      groupedMeasurements: groupedMeasurements ?? this.groupedMeasurements,
      predictions: predictions ?? this.predictions,
    );
  }
}
