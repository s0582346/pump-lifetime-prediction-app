import 'dart:math';

import 'package:flutter_predictive_maintenance_app/database/database_helper.dart';
import 'package:flutter_predictive_maintenance_app/features/prediction/prediction_service.dart';
import 'package:flutter_predictive_maintenance_app/features/history/domain/measurement.dart';
import 'package:flutter_predictive_maintenance_app/features/chart/data/adjustment_repository.dart';
import 'package:flutter_predictive_maintenance_app/features/history/data/measurement_repository.dart';
import 'package:flutter_predictive_maintenance_app/features/pump/domain/measurable_parameter.dart';
import 'package:flutter_predictive_maintenance_app/features/pump/domain/pump.dart';
import 'package:flutter_predictive_maintenance_app/features/pump/domain/time_entry.dart';
import 'package:flutter_predictive_maintenance_app/shared/result_info.dart';
import 'package:flutter_predictive_maintenance_app/shared/utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
      double? Qn, pn, QnTotal, pnTotal;
      double? currentOperatingHours = double.tryParse(newMeasurement.currentOperatingHours) ?? 0.0; // default current operating hours from the new measurement
      final isVolumeFlow = pump.measurableParameter == MeasurableParameter.volumeFlow;
      final previousEntry = measurementsTotal.isNotEmpty ? (getPreviousEntry(measurementsTotal, newMeasurement.id) ?? measurementsTotal.last) : null; // get the previous entry for the current adjustment

      if (previousEntry != null && !forceSave) {
        if (newMeasurement.date.isBefore(DateTime.parse(previousEntry.date))) {
          return ResultInfo.error('date', 'This date comes before your last entry. Do you still want to proceed?');
        }
        if (newMeasurement.currentOperatingHours < previousEntry.currentOperatingHours) {
          return ResultInfo.error('operatingHours', 'This value is less than your last recorded operating hours. Do you still want to proceed?');
        }
      }

      // default flows 
      if (isVolumeFlow) {
        Qn = 1;
        QnTotal = 1; 
      } else {
        pn = 1; 
        pnTotal = 1;
      }

    
      // Compute reference values if measurements exist
      if (measurements.isNotEmpty && (newMeasurement.id == null || previousEntry != null)) {
        reference = measurements.first;
        final result = Utils().normalize(pump.measurableParameter!, reference, newMeasurement);
        
        if (result < wearLimit && !forceSave) {
          final ratio = pump.measurableParameter == MeasurableParameter.volumeFlow ? 'Q/n' : 'p/n';
          return ResultInfo.error('flow', "The calculated $ratio exceeds the max. permissble wear (0.900). Do you still want to proceed?"); // return if the wear limit is exceeded
        }
        isVolumeFlow ? Qn = result : pn = result;
      }

      if (measurementsTotal.isNotEmpty) {
        referenceTotal = measurementsTotal.first;
        final resultTotal = Utils().normalize(pump.measurableParameter!, referenceTotal, newMeasurement);
        isVolumeFlow ? QnTotal = resultTotal : pnTotal = resultTotal;
      }

      // Compute current operating hours based on time entry type
      if (measurementsTotal.isNotEmpty) {
        final lastMeasurement = measurementsTotal.last;
        final lastOperatingHours = lastMeasurement.currentOperatingHours;

        if (pump.typeOfTimeEntry == TimeEntry.average) {
          int? avgOperatingHoursPerDay;
          DateTime? startDate;
          DateTime? currentDate;
          Measurement? previousEntry;
      
          if (isEditing) {
            previousEntry = getPreviousEntry(measurementsTotal, newMeasurement.id);
            startDate = (previousEntry != null) ? DateTime.tryParse(previousEntry.date) : newMeasurement.date;
          } else {
            startDate = DateTime.tryParse(lastMeasurement.date);
          }
          currentDate = newMeasurement.date;
          avgOperatingHoursPerDay = int.tryParse(newMeasurement.averageOperatingHoursPerDay) ?? 0;

          currentOperatingHours = Utils().calculateCurrentOperatingHours(
            isEditing ? previousEntry?.currentOperatingHours : lastOperatingHours,
            avgOperatingHoursPerDay,
            currentDate,
            startDate, 
          );
        }

        if (pump.typeOfTimeEntry == TimeEntry.relative) {

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

      final id = !isEditing ? generateMeasurementId(adjustmentId!) : newMeasurement.id;

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
      await predictionService.predict(adjustmentId!, pump);
      await predictionService.predictTotal(pump);

      return ResultInfo.success();
    } catch (e, stack) {
      Utils().logError(e, stack);
      return ResultInfo.error(null, 'Error saving measurement');
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

  String generateMeasurementId(String adjustmentId) {
    const letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    final random = Random();

    String randomLetters = List.generate(3, (_) => letters[random.nextInt(letters.length)]).join();

    return '$adjustmentId-$randomLetters';
  }
  
}