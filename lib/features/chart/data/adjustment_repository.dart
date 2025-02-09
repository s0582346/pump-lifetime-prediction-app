import 'package:flutter_predictive_maintenance_app/shared/utils.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';

class AdjustmentRepository {
  final Database db;

  AdjustmentRepository({required this.db});

  Future<String> getOrCreateAdjustment(String pumpId) async {
    try {
      
      // First check for existing open adjustment for this pump
      final openAdjustment = await getOpenAdjustment(pumpId); 

      if (openAdjustment.isNotEmpty) {
        return openAdjustment[0]['id'].toString();
      }
 
      // if no open adjustment found, get adjustment count
      final count = await getAdjustmentCount(pumpId);

      final String adjustmentId = Utils().getAdjustmentId(pumpId, count);

      // If no open adjustment found, create a new one
      await db.rawInsert(
        'INSERT INTO adjustment (id, status, pumpId, date) VALUES (?, ?, ?, ?)',
        [    
          adjustmentId,  // Using passed pumpId
          'open',
          pumpId,  // Using passed pumpId
          DateTime.now().toIso8601String(),
        ],
      );

      return adjustmentId; // return adjustment id
    } catch (e) {
      throw Exception('Failed to get or create adjustment: $e');
    }
  }


  Future<List<Map<String, dynamic>>> getOpenAdjustment(pumpId) {
    return db.rawQuery(
      'SELECT * FROM adjustment WHERE status = ? AND pumpId = ? LIMIT 1',
      ['open', pumpId],
    );
  }
  
  /// Get the count of adjustments for a given pump
  /// [pumpId] The pump ID to get the adjustment count for
  Future<int> getAdjustmentCount(String pumpId) async {
  try {
    final List<Map<String, dynamic>> result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM adjustment WHERE pumpId = ?',
      [pumpId],
    );
    
    // Safely extract the count value from the result.
    // COUNT(*) always returns a row, but we add a safety check anyway.
    if (result.isNotEmpty) {
      return result.first['count'] as int;
    }
    return 0;
  } catch (e) {
    throw Exception('Failed to get adjustment count: $e');
  }
  }
}