

import 'package:flutter_predictive_maintenance_app/features/prediction/prediction.dart';
import 'package:flutter_predictive_maintenance_app/shared/utils.dart';
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
    } catch (e, stack) {
      Utils().logError(e, stack);
      return [];
    }
  }

  Future<void> savePrediction(Prediction prediction, adjustmentId) async {
    try {
      await db.insert('predictions', prediction.toMap(), conflictAlgorithm: ConflictAlgorithm.replace,);
    } catch (e, stack) {
      Utils().logError(e, stack);
    }
  }

  Future<void> updatePrediction(Prediction prediction) async {
    try {
    await db.update(
      'predictions',
      prediction.toMap(),
      where: 'adjustmentId = ?',
      whereArgs: [prediction.adjusmentId],
    );
    } catch (e, stack) {
      Utils().logError(e, stack);
    }
  }

   Future<Prediction?> getPredictionByAdjustmentId(String adjustmentId) async {
    try {

    final List<Map<String, dynamic>> maps = await db.query(
      'predictions',
      where: 'adjustmentId = ?',
      whereArgs: [adjustmentId],
    );

    if (maps.isNotEmpty) {
      return Prediction.fromMap(maps.first);
    }
    return null;
    } catch (e, stack) {
      Utils().logError(e, stack);
      return null;
    }
  }

}