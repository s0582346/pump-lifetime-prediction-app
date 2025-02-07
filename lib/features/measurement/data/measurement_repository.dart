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

}