import 'dart:math';

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
      final measurements = await fetchMeasurementsFromAdjustment(adjustmentId, pump.id) ?? []; // measurements for the current adjustment
      final measurementsTotal = await fetchMeasurementsByPumpId(pump.id) ?? []; // total measurements for the pump
      final isEditing = newMeasurement.id != null;

      // Initialize variables with default values
      Measurement? reference, referenceTotal;
      double Qn = 1, pn = 1, QnTotal = 1, pnTotal = 1;
      final op = newMeasurement.currentOperatingHours;
      double? currentOperatingHours = double.tryParse(newMeasurement.currentOperatingHours ?? '') ?? 0.0; // default current operating hours from the new measurement
      final isVolumeFlow = pump.measurableParameter == 'volume flow';
    
      // Compute reference values if measurements exist
      if (measurements.isNotEmpty && (newMeasurement.id == null || getPreviousEntry(measurements, newMeasurement.id) != null)) {
        reference = measurements.first;
        final result = Utils().normalize(pump.measurableParameter, reference, newMeasurement);
        
        if (result < wearLimit && !forceSave) {
          return ResultInfo.error(result); // return if the wear limit is exceeded
        }
        isVolumeFlow ? Qn = result : pn = result;
      }

      if (measurementsTotal.isNotEmpty) {
        referenceTotal = measurementsTotal.first;
        final resultTotal = Utils().normalize(pump.measurableParameter, referenceTotal, newMeasurement);
        isVolumeFlow ? QnTotal = resultTotal : pnTotal = resultTotal;
      }

      // Compute current operating hours based on time entry type
      if (measurementsTotal.isNotEmpty) {
        final lastMeasurement = measurementsTotal.last;
        final lastOperatingHours = lastMeasurement.currentOperatingHours;

        if (pump.typeOfTimeEntry.contains('average')) {
          int? avgOperatingHoursPerDay;
          DateTime? startDate;
          DateTime? currentDate;
          Measurement? previousEntry;
      
          if (isEditing) {
            previousEntry = getPreviousEntry(measurementsTotal, newMeasurement.id);
            startDate = (previousEntry != null) ? DateTime.tryParse(previousEntry.date) : DateTime.now();
            //previousOperatingHours = (previousEntry != null) ? previousEntry.currentOperatingHours : 0;
          } else {
            startDate = DateTime.tryParse(lastMeasurement.date);
          }
          currentDate = newMeasurement.date;
          avgOperatingHoursPerDay = int.tryParse(newMeasurement.averageOperatingHoursPerDay) ?? 0;

          debugPrint('Start Date: $startDate, Current Operating Hours: $lastOperatingHours');
          debugPrint('Average Operating Hours Per Day: $avgOperatingHoursPerDay, Current Date: $currentDate');

          currentOperatingHours = Utils().calculateCurrentOperatingHours(
            isEditing ? previousEntry?.currentOperatingHours : lastOperatingHours,
            avgOperatingHoursPerDay,
            currentDate,
            startDate, 
          );

          debugPrint('Updated Current Operating Hours: $currentOperatingHours');
        }

        if (pump.typeOfTimeEntry.contains('relative')) {
          debugPrint("Calculating relative current operating hours");

          if (isEditing) {
            final previousEntry = getPreviousEntry(measurementsTotal, newMeasurement.id);

            // sum if its not the first entry, else operating hours will be the same as the last entry  
            if (previousEntry != null) {
              currentOperatingHours = double.tryParse(newMeasurement.currentOperatingHours) ?? 0;
              currentOperatingHours = currentOperatingHours + (previousEntry.currentOperatingHours);
            }
          } else {
            final newHours = double.tryParse(newMeasurement.currentOperatingHours) ?? 0;
            currentOperatingHours = newHours + lastMeasurement.currentOperatingHours;
          }
        }
      }

      final id = !isEditing ? generateMeasurementId(adjustmentId) : newMeasurement.id;

      // Create the updated measurement
      final updatedMeasurement = newMeasurement.copyWith(
        id: id,
        adjustmentId: adjustmentId,
        currentOperatingHours: currentOperatingHours,
        Qn: Qn,
        pn: pn,
        QnTotal: QnTotal,
        pnTotal: pnTotal,
      );

      // Save measurement and prediction
      await measurementRepo.saveMeasurement(updatedMeasurement);
      await predictionService.predict(adjustmentId, pump);
      await predictionService.predictTotal(pump);


      return ResultInfo.success();
    } catch (e, stackTrace) {
      // TODO use logError
      debugPrint('Error saving measurement: $e');
      debugPrint(stackTrace.toString());

      return ResultInfo.error(stackTrace.toString());
    }
  }

  Measurement? getPreviousEntry(List<Measurement> dataList, String? currentId) {
    // Find the index of the current entry
    int index = dataList.indexWhere((entry) => entry.id == currentId);

    // Check if there's a previous entry
    if (index > 0) {
      return dataList[index - 1]; // Return the previous entry
    }

    return null; // No previous entry found
  }

  /// Fetch all measurements for a given pump
  /// [pumpId] The pump ID to fetch measurements for
  Future<List<Measurement>?> fetchMeasurementsByPumpId(pumpId) async {
    final db = await DatabaseHelper().database;
    final measurementRepo = MeasurementRepository(db: db);
    final measurements = await measurementRepo.fetchMeasurementsByPumpId(pumpId);
    return measurements.map((e) => Measurement.fromMap(e)).toList();
  }

  Future<List<Measurement>?> fetchMeasurementsFromAdjustment(adjustmentId, pumpId) async {
    final db = await DatabaseHelper().database;
    final measurementRepo = MeasurementRepository(db: db);
    
    final measurements = await measurementRepo.fetchMeasurementsFromAdjustment(adjustmentId, pumpId);
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

  String generateMeasurementId(String adjustmentId) {
    const letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    final random = Random();

    String randomLetters = List.generate(3, (_) => letters[random.nextInt(letters.length)]).join();

    return '$adjustmentId-$randomLetters';
  }
  
}