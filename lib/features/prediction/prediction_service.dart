import 'package:flutter_predictive_maintenance_app/database/database_helper.dart';
import 'package:flutter_predictive_maintenance_app/features/prediction/prediction.dart';
import 'package:flutter_predictive_maintenance_app/features/prediction/prediction_repository.dart';
import 'package:flutter_predictive_maintenance_app/features/history/application/measurement_service.dart';
import 'package:flutter_predictive_maintenance_app/features/pump/domain/measurable_parameter.dart';
import 'package:flutter_predictive_maintenance_app/features/pump/domain/pump.dart';
import 'package:flutter_predictive_maintenance_app/shared/math_utils.dart';
import 'package:flutter_predictive_maintenance_app/shared/utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


final predictionServiceProvider = Provider((ref) => PredictionService());

class PredictionService {

 Future<List<Prediction>> getPredictions(Pump pump) async {
  try {
    final db = await DatabaseHelper().database;
    final predictionService = PredictionRepository(db: db);
    final predictionsMapList = await predictionService.getPredictions(pump.id);

    return predictionsMapList.map((map) => Prediction.fromMap(map)).toList();
  } catch (e, stack) {
    Utils().logError(e, stack);
    return [];
  }
}

Future<void> predict(String adjustmentId, Pump pump) async {
  try {
    final db = await DatabaseHelper().database;
    final predictionService = PredictionRepository(db: db);
    final measurementService = MeasurementService();
    final math = MathUtils();

    // Check if an existing prediction already exists
    Prediction? existingPrediction = await predictionService.getPredictionByAdjustmentId(adjustmentId);
    Prediction prediction = existingPrediction ?? Prediction();

    final List<double> currentOperatingHours = [];
    final List<double> Qn = [];
    final List<double> pn = [];
    List<double> coeffs = [];

    final measurements = await measurementService.fetchMeasurementsFromAdjustment(adjustmentId, pump.id);

    if (measurements == null || measurements.length < 3) return;

    if (pump.measurableParameter == MeasurableParameter.volumeFlow) {
      for (final m in measurements) {
        final double? hours = m.currentOperatingHours.toDouble();
        final double? flow = m.Qn;

        if (hours != null && flow != null) {
          currentOperatingHours.add(hours);
          Qn.add(flow);
        }
      }

      if (currentOperatingHours.where((h) => h == 0.0).length > 1) return;
      coeffs = math.fitQuadratic(currentOperatingHours, Qn);
    } else {
      for (final m in measurements) {
        final double? hours = m.currentOperatingHours.toDouble();
        final double? pressure = m.pn;

        if (hours != null && pressure != null) {
          currentOperatingHours.add(hours);
          pn.add(pressure);
        }
      }

      if (currentOperatingHours.where((h) => h == 0.0).length > 1) return;
      coeffs = math.fitQuadratic(currentOperatingHours, pn);
    }

    final a = coeffs.length > 2 ? coeffs[2] : 0.0;
    final b = coeffs.length > 1 ? coeffs[1] : 0.0;
    final c = coeffs.length > 0 ? coeffs[0] : 0.0;

    final solutions = math.findIntersectionAtY(a, b, c, 0.900);
    double? estimatedOperatingHours;

    for (final x in solutions) {
      if (x >= 0) {
        estimatedOperatingHours = x;
      }
    }

    DateTime? estimatedMaintenanceDate;
    if (estimatedOperatingHours != null) {
      final remainingHours = ((estimatedOperatingHours - currentOperatingHours.last).abs()).toInt();
      estimatedMaintenanceDate = Utils().getEstimatedMaintenanceDate(
        remainingHours,
        DateTime.parse(measurements.last.date),
      );
    }

    prediction = prediction.copyWith(
      estimatedOperatingHours: estimatedOperatingHours,
      estimatedMaintenanceDate: estimatedMaintenanceDate,
      adjusmentId: adjustmentId,
      a: a,
      b: b,
      c: c,
    );

    if (existingPrediction != null) {
      await predictionService.updatePrediction(prediction);
    } else {
      await predictionService.savePrediction(prediction, adjustmentId);
    }

  } catch (e, stack) {
    Utils().logError(e, stack);
  }
}

Future<void> predictTotal(Pump pump) async {
  try {
    final math = MathUtils();
  final adjustmentId = '${pump.id}-S'; 
  final db = await DatabaseHelper().database;
  final predictionService = PredictionRepository(db: db);
  final measurementService = MeasurementService();
  final measurementsTotal = await measurementService.fetchMeasurementsByPumpId(pump.id);

  Prediction? existingPrediction = await predictionService.getPredictionByAdjustmentId(adjustmentId);
  Prediction prediction = existingPrediction ?? Prediction(); // no prediction, then create one


  if (measurementsTotal == null || measurementsTotal.length < 3) {
    return;
  }

  List<double> QnTotal = [], pnTotal = [], currentOperatingHoursTotal = [], coeffs = [];
  if (pump.measurableParameter == MeasurableParameter.volumeFlow) {
    for (final m in measurementsTotal) {
      final double? hours = m.currentOperatingHours.toDouble();
      final double? flow = m.QnTotal.toDouble();

      if (hours != null && flow != null) {
        currentOperatingHoursTotal.add(hours);
        QnTotal.add(flow);
      }
    }

    final zeroCount = currentOperatingHoursTotal.where((h) => h == 0.0).length;
    if (zeroCount > 1) return;

    coeffs = math.fitQuadratic(currentOperatingHoursTotal, QnTotal); 
  } else if (pump.measurableParameter == MeasurableParameter.pressure) {
    for (final m in measurementsTotal) {
      final double? hours = m.currentOperatingHours.toDouble();
      final double? flow = m.pnTotal;

      if (hours != null && flow != null) {
        currentOperatingHoursTotal.add(hours);
        pnTotal.add(flow);
      }
    }

    final zeroCount = currentOperatingHoursTotal.where((h) => h == 0.0).length;
    if (zeroCount > 1) return;

    coeffs = math.fitQuadratic(currentOperatingHoursTotal, pnTotal); 
  }


  final a = coeffs.length > 2 ? coeffs[2] : 0.0;
  final b = coeffs.length > 1 ? coeffs[1] : 0.0;
  final c = coeffs.length > 0 ? coeffs[0] : 0.0;

  prediction = prediction.copyWith(
    adjusmentId: adjustmentId,
    a: a,
    b: b,
    c: c,
  );

  (existingPrediction != null) ? await predictionService.updatePrediction(prediction) : await predictionService.savePrediction(prediction, adjustmentId);

  } catch (e, stack) {
    Utils().logError(e, stack);
  }
}
}