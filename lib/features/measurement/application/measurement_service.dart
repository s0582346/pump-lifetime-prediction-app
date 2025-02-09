import 'package:flutter_predictive_maintenance_app/database/database_helper.dart';
import 'package:flutter_predictive_maintenance_app/features/measurement/domain/measurement.dart';
import 'package:flutter_predictive_maintenance_app/features/chart/data/adjustment_repository.dart';
import 'package:flutter_predictive_maintenance_app/features/measurement/data/measurement_repository.dart';

class MeasurementService {

  /// Save a measurement to the database
  Future<void> saveMeasurement(Measurement measurement, String pumpId) async {
    final db = await DatabaseHelper().database;
    final adjustmentRepo = AdjustmentRepository(db: db);
    final measurementRepo = MeasurementRepository(db: db);   

    try {
      // Get or create adjustment
      final adjustmentId = await adjustmentRepo.getOrCreateAdjustment(pumpId);

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

  /// Fetch measurements for a given pump
  /// [pumpId] The pump ID to fetch measurements for
  Future<List<Measurement>> fetchMeasurements(pumpId) async {
    print('Fetching measurements for pump: $pumpId');

    final db = await DatabaseHelper().database;
    /*
    final adjustmentRepo = AdjustmentRepository(db: db);
    
    final adjustmentId = await adjustmentRepo.getOpenAdjustment(pumpId);

    if (adjustmentId.isEmpty) {
      return [];
    }*/

    final List<Map<String, dynamic>> measurements = await db.rawQuery(
      '''
      SELECT m.*
      FROM measurements m
      JOIN adjustment a ON m.adjustmentId = a.id
      WHERE a.pumpId = ?;
      ''',
      [pumpId],
    );

    return measurements.map((e) => Measurement.fromMap(e)).toList();
  }
}