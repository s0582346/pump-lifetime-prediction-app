import 'package:sqflite/sqflite.dart';
import 'package:flutter_predictive_maintenance_app/features/measurement/domain/measurement.dart';

class MeasurementRepository {
  final Database db;

  MeasurementRepository({required this.db});

  // Save measurement with linked adjustment ID
  Future<void> saveMeasurement(Measurement measurement) async {
    await db.insert(
      'measurements',
      measurement.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Fetch measurements for a given pump
  Future<List<Map<String, dynamic>>> fetchMeasurementsByPumpId(String pumpId) async {
    print('Fetching measurements for pump: $pumpId');

    final List<Map<String, dynamic>> measurements = await db.rawQuery(
      '''
      SELECT m.*
      FROM measurements m
      JOIN adjustment a ON m.adjustmentId = a.id
      WHERE a.pumpId = ?;
      ''',
      [pumpId],
    );
    
    return measurements;
  }

  // Fetch measurements for a given adjustment
  Future<List<Map<String, dynamic>>?> fetchMeasurementsByAdjustmentId(String adjustmentId) async {
    print('Fetching measurements for adjustment: $adjustmentId');

    final List<Map<String, dynamic>> measurements = await db.rawQuery(
      '''
      SELECT *
      FROM measurements
      WHERE adjustmentId = ?;
      ''',
      [adjustmentId],
    );

    if (measurements.isEmpty) {
      return null;
    } 

    
    return measurements;
  }
  

}