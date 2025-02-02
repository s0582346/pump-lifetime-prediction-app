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

      // Save measurement with the adjustment ID
      await measurementRepo.saveMeasurement(measurement.copyWith(adjustmentId: adjustmentId));
    } catch (e) {
      // Handle errors appropriately
      print('Error saving measurement: $e');
    }
    	
  }
}