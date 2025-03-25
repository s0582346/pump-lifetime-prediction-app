import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_predictive_maintenance_app/features/chart/application/adjustment_service.dart';
import 'package:flutter_predictive_maintenance_app/features/chart/application/prediction_service.dart';
import 'package:flutter_predictive_maintenance_app/features/chart/domain/adjustment.dart';
import 'package:flutter_predictive_maintenance_app/features/chart/domain/prediction.dart';
import 'package:flutter_predictive_maintenance_app/features/dashboard/dashboard_controller.dart';
import 'package:flutter_predictive_maintenance_app/features/history/presentation/history_controller.dart';
import 'package:flutter_predictive_maintenance_app/shared/utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_predictive_maintenance_app/features/measurement/application/measurement_service.dart';
import 'package:flutter_predictive_maintenance_app/features/measurement/domain/measurement.dart';
import 'package:flutter_predictive_maintenance_app/navigation/navigation.dart';

final chartControllerProvider = AsyncNotifierProvider<ChartController, ChartState>(ChartController.new);
final tabIndexProvider = StateProvider<int>((ref) => 0);
final settingsOverlayProvider  = StateProvider<OverlayEntry?>((ref) => null);

class ChartController extends AsyncNotifier<ChartState> {

  late final MeasurementService _measurementService = ref.read(measurementServiceProvider);
  late final PredictionService _predictionService = ref.read(predictionServiceProvider);
  late final AdjustmentService _adjustmentService = ref.read(adjustmentServiceProvider);


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
      final measurements = await _measurementService.fetchMeasurementsByPumpId(pump.id);
      final groupedMeasurements = Utils().groupMeasurements(measurements);
      final adjustments = (await _adjustmentService.fetchAdjustmentsByPumpId(pump.id))!.skip(1).toList();
      final predictions = await _predictionService.getPredictions(pump);
     
      return ChartState(
        groupedMeasurements: groupedMeasurements,
        predictions: predictions,
        adjustments: adjustments,
      );
    } catch (e, stack) {
      throw AsyncError(e, stack);
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading(); // Set the state to loading
    state = await AsyncValue.guard(() => build());
  }

  Future<void> closeAdjustment(String adjustmentId) async {
    final pump = ref.read(selectedPumpProvider);
    if (pump == null) return;

    await _adjustmentService.closeAdjustment(adjustmentId);
    refresh();
    ref.read(historyControllerProvider.notifier).refresh();
    ref.read(dashboardControllerProvider.notifier).refresh();
  }

   Future<void> openAdjustment(String adjustmentId) async {
    final pump = ref.read(selectedPumpProvider);
    if (pump == null) return;
   
    await _adjustmentService.openAdjustment(adjustmentId);
    refresh();
    ref.read(historyControllerProvider.notifier).refresh();
    ref.read(dashboardControllerProvider.notifier).refresh();
  }

  Future<void> createAdjustment(String adjustmentId) async {
    final pump = ref.read(selectedPumpProvider);
    if (pump == null) return;

    await _adjustmentService.createAdjustment(pump.id);
    refresh();
    ref.read(historyControllerProvider.notifier).refresh();
  }

}


class ChartState {
  final Map<String, List<Measurement>> groupedMeasurements;
  final List<Prediction> predictions;
  final List<Adjustment> adjustments;

  ChartState({
    Map<String, List<Measurement>>? groupedMeasurements,
    List<Prediction>? predictions,
    List<Adjustment>? adjustments,
  })  : groupedMeasurements = groupedMeasurements ?? {},
        predictions = predictions ?? [],
        adjustments = adjustments ?? [];

  ChartState copyWith({
    Map<String, List<Measurement>>? groupedMeasurements,
    List<Prediction>? predictions,
    List<Adjustment>? adjustments, 
  }) {
    return ChartState(
      groupedMeasurements: groupedMeasurements ?? this.groupedMeasurements,
      predictions: predictions ?? this.predictions,
      adjustments: adjustments ?? this.adjustments,
    );
  }
}
