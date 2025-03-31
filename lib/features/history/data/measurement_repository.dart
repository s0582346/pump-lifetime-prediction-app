import 'package:sqflite/sqflite.dart';
import 'package:flutter_predictive_maintenance_app/features/history/domain/measurement.dart';

class MeasurementRepository {
  final Database db;

  MeasurementRepository({required this.db});

  /// Save measurement with linked adjustment ID
  Future<void> saveMeasurement(Measurement measurement) async {
    await db.insert(
      'measurements',
      measurement.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Fetch all measurements for a given pump
  Future<List<Map<String, dynamic>>> fetchMeasurementsByPumpId(String pumpId) async {
    final List<Map<String, dynamic>> measurements = await db.rawQuery(
      '''
      SELECT m.*
      FROM measurements m
      JOIN adjustments a ON m.adjustmentId = a.id
      WHERE a.pumpId = ?
      ORDER BY m.currentOperatingHours ASC, m.date ASC
      ''',
      [pumpId],
    );
    
    return measurements;
  }

  /// Fetch measurements for a given pump
  Future<List<Map<String, dynamic>>> getCurrentMeasurementsCount(String pumpId) async {
    final List<Map<String, dynamic>> measurements = await db.rawQuery(
      '''
      SELECT count(m.*)
      FROM measurements m
      JOIN adjustments a ON m.adjustmentId = a.id
      WHERE a.pumpId = ?
      ''',
      [pumpId],
    );
    
    return measurements;
  }

  /// Fetch measurements for a given adjustment
  Future<List<Map<String, dynamic>>?> fetchMeasurementsFromAdjustment(String adjustmentId, String pumpId) async {
    final List<Map<String, dynamic>> measurements = await db.rawQuery(
      '''
      SELECT m.*
      FROM measurements m
      JOIN adjustments a ON m.adjustmentId = a.id
      WHERE a.id = ? AND a.pumpId = ?
      ORDER BY m.date ASC, m.currentOperatingHours ASC
      ''',
      [adjustmentId, pumpId],
    );

    if (measurements.isEmpty) {
      return null;
    } 

    
    return measurements;
  }
  

}