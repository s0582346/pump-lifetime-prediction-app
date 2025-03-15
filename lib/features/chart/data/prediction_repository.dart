

import 'package:flutter_predictive_maintenance_app/features/chart/domain/prediction.dart';
import 'package:sqflite/sqflite.dart';

class PredictionRepository {

  final Database db;

  PredictionRepository({required this.db});


  /// Get the current prediction ID for a given pump
  /// [pumpId] The pump ID to get the prediction ID for
  Future<List<Map<String, dynamic>>> getPredictions(String pumpId) async {
    try {
      final List<Map<String, dynamic>> predictions = await db.rawQuery(
        ''' SELECT p.* FROM predictions p
        JOIN adjustments a ON p.adjustmentId = a.id
        WHERE a.pumpId = ? ''',
        [pumpId],
      );
      return predictions;
    } catch (e) {
      throw Exception('Failed to get predictions: $e');
    }
  }

  Future<void> savePrediction(Prediction prediction, adjustmentId) async {
    await db.insert('predictions', prediction.toMap(), conflictAlgorithm: ConflictAlgorithm.replace,);
  }

  Future<void> updatePrediction(Prediction prediction) async {
    await db.update(
      'predictions',
      prediction.toMap(),
      where: 'adjustmentId = ?',
      whereArgs: [prediction.adjusmentId],
    );
  }

   Future<Prediction?> getPredictionByAdjustmentId(String adjustmentId) async {
    final List<Map<String, dynamic>> maps = await db.query(
      'predictions',
      where: 'adjustmentId = ?',
      whereArgs: [adjustmentId],
    );

    if (maps.isNotEmpty) {
      return Prediction.fromMap(maps.first);
    }
    return null;
  }

}