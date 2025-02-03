import 'package:flutter_predictive_maintenance_app/database/database_helper.dart';
import 'package:flutter_predictive_maintenance_app/features/parameters/domain/measurement.dart';
import 'package:flutter_predictive_maintenance_app/features/chart/data/adjustment_repository.dart';
import 'package:flutter_predictive_maintenance_app/features/parameters/data/measurement_repository.dart';

class MeasurementService {
  Future<void> saveMeasurement(Measurement measurement) async {
    final db = await DatabaseHelper().database;
    final adjustmentRepo = AdjustmentRepository(db: db);
    final measurementRepo = MeasurementRepository(db: db);    

    try {
      // Get or create adjustment
      final adjustmentId = await adjustmentRepo.getOrCreateAdjustment();

      final updatedMeasurement = measurement.copyWith(adjustmentId: adjustmentId);

      print('Date: ${updatedMeasurement.date}');
      print('Adjustment ID: ${updatedMeasurement.adjustmentId}');
      print('Volume Flow: ${updatedMeasurement.volumeFlow}');
      print('Pressure: ${updatedMeasurement.pressure}');
      print('Rotational Frequency: ${updatedMeasurement.rotationalFrequency}');
      print('Current Operating Hours: ${updatedMeasurement.currentOperatingHours}');
      print('Average Operating Hours Per Day: ${updatedMeasurement.averageOperatingHoursPerDay}');


      await measurementRepo.saveMeasurement(updatedMeasurement);
    } catch (e) {
      // Handle errors appropriately
      print('Error saving measurement: $e');
    }
    	
  }
}