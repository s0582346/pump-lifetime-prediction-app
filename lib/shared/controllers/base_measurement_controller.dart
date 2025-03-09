// base_measurement_controller.dart
import 'dart:async';
import 'package:flutter_predictive_maintenance_app/features/chart/domain/prediction.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_predictive_maintenance_app/features/measurement/application/measurement_service.dart';
import 'package:flutter_predictive_maintenance_app/features/measurement/domain/measurement.dart';
import 'package:flutter_predictive_maintenance_app/navigation/navigation.dart';

/*
abstract class BaseMeasurementController extends AsyncNotifier<Map<String, List<Measurement>>> {
  late final MeasurementService _measurementService;

  @override
  FutureOr<Map<String, List<Measurement>>> build() async {
    _measurementService = ref.read(measurementServiceProvider);
    return _fetchMeasurements();
  }

  Future<Map<String, List<Measurement>>> _fetchMeasurements() async {
    final pump = ref.watch(selectedPumpProvider);

    if (pump == null) {
      return {};
    }

    try {
      final measurements = await _measurementService.fetchMeasurementsByPumpId(pump.id);
      return _groupMeasurements(measurements);
    } catch (e, stackTrace) {
      throw AsyncError(e, stackTrace);
    }
  }

  Map<String, List<Measurement>> _groupMeasurements(List<Measurement> measurements) {
    final groupedMeasurements = <String, List<Measurement>>{};
    for (var measurement in measurements) {
      groupedMeasurements.putIfAbsent(measurement.adjustmentId, () => []).add(measurement);
    }
    return groupedMeasurements;
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchMeasurements());
  }

}


/// MeasurementService Provider
final measurementServiceProvider = Provider((ref) => MeasurementService());
*/