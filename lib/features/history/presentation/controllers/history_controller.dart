import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_predictive_maintenance_app/features/measurement/application/measurement_service.dart';
import 'package:flutter_predictive_maintenance_app/features/measurement/domain/measurement.dart';
import 'package:flutter_predictive_maintenance_app/navigation/navigation.dart';

class HistoryController extends AsyncNotifier<Map<String, List<Measurement>>> {
  late final MeasurementService _measurementService;

  @override
  FutureOr<Map<String, List<Measurement>>> build() async {
    // Initialize the service
    _measurementService = ref.read(measurementServiceProvider);
    
    // Get initial data
    return _fetchMeasurements();
  }

  Future<Map<String, List<Measurement>>> _fetchMeasurements() async {
    final pump = ref.watch(selectedPumpProvider);

    // If pump is null, return an empty dataset
    if (pump == null) {
      return {};
    }

    try {
      final measurements = await _measurementService.fetchMeasurements(pump.id);

      // Group by adjustment_id
      final groupedMeasurements = <String, List<Measurement>>{};
      for (var measurement in measurements) {
        groupedMeasurements.putIfAbsent(measurement.adjustmentId, () => []).add(measurement);
      }

      return groupedMeasurements;
    } catch (e, stackTrace) {
      // AsyncNotifier will automatically handle the error state
      throw AsyncError(e, stackTrace);
    }
  }

  /// Manually refresh measurements
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchMeasurements());
  }
}

/// Provider for HistoryController
final historyControllerProvider = AsyncNotifierProvider<HistoryController, Map<String, List<Measurement>>>(
  HistoryController.new
);

/// MeasurementService Provider
final measurementServiceProvider = Provider((ref) => MeasurementService());