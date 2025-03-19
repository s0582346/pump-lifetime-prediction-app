import 'package:flutter_predictive_maintenance_app/database/database_helper.dart';
import 'package:flutter_predictive_maintenance_app/features/chart/application/prediction_service.dart';
import 'package:flutter_predictive_maintenance_app/features/measurement/domain/measurement.dart';
import 'package:flutter_predictive_maintenance_app/features/chart/data/adjustment_repository.dart';
import 'package:flutter_predictive_maintenance_app/features/measurement/data/measurement_repository.dart';
import 'package:flutter_predictive_maintenance_app/features/pump/domain/pump.dart';
import 'package:flutter_predictive_maintenance_app/shared/result_info.dart';
import 'package:flutter_predictive_maintenance_app/shared/utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';

final measurementServiceProvider = Provider((ref) => MeasurementService());

class MeasurementService {

  Future<double?> calculateRatios(String measurableParameter, Measurement reference, Measurement newMeasurement) async {
    return Utils().normalize(measurableParameter, reference, newMeasurement);
  }

  /// Save a measurement to the database
  Future<ResultInfo> saveMeasurement(Measurement newMeasurement, Pump pump, {forceSave = false, wearLimit = 0.9}) async {
  try {
    // Initialize dependencies
    final db = await DatabaseHelper().database;
    final adjustmentRepo = AdjustmentRepository(db: db);
    final measurementRepo = MeasurementRepository(db: db);
    final predictionService = PredictionService();

    // Fetch necessary data
    final adjustmentId = await adjustmentRepo.getCurrentAdjustmentId(pump.id);
    final measurements = await measurementRepo.fetchMeasurementsByAdjustmentId(adjustmentId) ?? []; // measurements for the current adjustment
    final measurementsTotal = await measurementRepo.fetchMeasurementsByPumpId(pump.id) ?? []; // total measurements for the pump

    // Initialize variables with default values
    Measurement? reference, referenceTotal;
    double Qn = 1, pn = 1, QnTotal = 1, pnTotal = 1, limit = 0.9;

    double? currentOperatingHours = double.tryParse(newMeasurement.currentOperatingHours); // default current operating hours from the new measurement
    
    final isVolumeFlow = pump.measurableParameter == 'volume flow';

    
    // Compute reference values if measurements exist
    if (measurements.isNotEmpty) {
      reference = Measurement.fromMap(measurements.first);
      final result = Utils().normalize(pump.measurableParameter, reference, newMeasurement);

      if (result < wearLimit && !forceSave) {
        return ResultInfo.error(result); // return if the wear limit is exceeded
      }
      
      referenceTotal = Measurement.fromMap(measurementsTotal.first);
      final resultTotal = Utils().normalize(pump.measurableParameter, referenceTotal, newMeasurement);

      if (isVolumeFlow) {
        Qn = result;
        QnTotal = resultTotal;
      } else {
        pn = result;
        pnTotal = resultTotal;
      }
    }

  
    // Compute current operating hours based on time entry type
    if (measurements.isNotEmpty) {
      final lastMeasurement = measurements.last;
      final lastOperatingHours = (lastMeasurement['currentOperatingHours'] as num) / 100;

      if (pump.typeOfTimeEntry.contains('average')) {
        debugPrint('Calculating average operating hours per day');
        final averageOperatingHoursPerDay = int.tryParse(newMeasurement.averageOperatingHoursPerDay) ?? 0;
        final currentDate = newMeasurement.date;
        final startDate = DateTime.tryParse(lastMeasurement['date']) ?? DateTime.now();

        debugPrint('Start Date: $startDate, Current Operating Hours: $lastOperatingHours');
        debugPrint('Average Operating Hours Per Day: $averageOperatingHoursPerDay, Current Date: $currentDate');

        currentOperatingHours = Utils().calculateCurrentOperatingHours(
          lastOperatingHours,
          averageOperatingHoursPerDay,
          currentDate,
          startDate,
        );

        debugPrint('Updated Current Operating Hours: $currentOperatingHours');
      }

      if (pump.typeOfTimeEntry.contains('relative')) {
        debugPrint("Calculating relative current operating hours");
        final newHours = double.tryParse(newMeasurement.currentOperatingHours) ?? 0;
        currentOperatingHours = newHours + lastOperatingHours;
      }
    }

    // Create the updated measurement
    final updatedMeasurement = newMeasurement.copyWith(
      adjustmentId: adjustmentId,
      currentOperatingHours: currentOperatingHours,
      Qn: Qn,
      pn: pn,
      QnTotal: QnTotal,
      pnTotal: pnTotal,
    );

    // Save measurement and prediction
    await measurementRepo.saveMeasurement(updatedMeasurement);
    await predictionService.savePrediction(adjustmentId, pump.measurableParameter);
  
    return ResultInfo.success();
  } catch (e, stackTrace) {
    // TODO use logError
    debugPrint('Error saving measurement: $e');
    debugPrint(stackTrace.toString());

    return ResultInfo.error(stackTrace.toString());
  }
}


  /// Fetch measurements for a given pump
  /// [pumpId] The pump ID to fetch measurements for
  Future<List<Measurement>?> fetchMeasurementsByPumpId(pumpId) async {
    print('Fetching measurements for pump: $pumpId');

    final db = await DatabaseHelper().database;
    final measurementRepo = MeasurementRepository(db: db);
    /*
    final adjustmentRepo = AdjustmentRepository(db: db);
    
    final adjustmentId = await adjustmentRepo.getOpenAdjustment(pumpId);

    if (adjustmentId.isEmpty) {
      return [];
    }*/
    final measurements = await measurementRepo.fetchMeasurementsByPumpId(pumpId);
    return measurements.map((e) => Measurement.fromMap(e)).toList();
  }

  Future<List<Measurement>?> fetchMeasurementsByAdjustmentId(adjustmentId) async {
    print('Fetching measurements for adjustment: $adjustmentId');

    final db = await DatabaseHelper().database;
    final measurementRepo = MeasurementRepository(db: db);
    
    final measurements = await measurementRepo.fetchMeasurementsByAdjustmentId(adjustmentId);
    if (measurements == null) {
      return null;
    }

    return measurements.map((e) => Measurement.fromMap(e)).toList();
  }


  
  /// Get first measurement
  Future<Map<String, dynamic>?> getFirstMeasurement(String adjustmentId) async {
    final db = await DatabaseHelper().database;
    
    final result = await db.rawQuery(
        ''' SELECT *
        FROM measurements 
        WHERE adjustmentId = ? 
        ORDER BY date ASC 
        LIMIT 1; ''',
        [adjustmentId],
    );

    if (result.isEmpty) {
      return null;
    }
    
    return result.first;
  }
}