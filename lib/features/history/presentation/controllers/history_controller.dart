import 'dart:async';
import 'package:flutter_predictive_maintenance_app/shared/controllers/base_measurement_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_predictive_maintenance_app/features/measurement/application/measurement_service.dart';
import 'package:flutter_predictive_maintenance_app/features/measurement/domain/measurement.dart';

class HistoryController extends BaseMeasurementController {
  
}

/// Provider for HistoryController
final historyControllerProvider = AsyncNotifierProvider<HistoryController, Map<String, List<Measurement>>>(
  HistoryController.new
);

/// MeasurementService Provider
final measurementServiceProvider = Provider((ref) => MeasurementService());