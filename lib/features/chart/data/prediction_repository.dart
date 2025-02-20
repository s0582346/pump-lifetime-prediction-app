

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
        'SELECT * FROM prediction WHERE pumpId = ?',
        [pumpId],
      );
      return predictions;
    } catch (e) {
      throw Exception('Failed to get predictions: $e');
    }
  }

  Future<void> savePrediction(Prediction prediction, adjustmentId) async {
    await db.insert('prediction', prediction.toMap());
  }

}