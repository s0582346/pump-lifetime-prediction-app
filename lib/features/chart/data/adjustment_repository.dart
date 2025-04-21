import 'package:flutter_predictive_maintenance_app/shared/utils.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';

class AdjustmentRepository {
  final Database db;

  AdjustmentRepository({required this.db});

  /// Get the current adjustment ID for a given pump
  /// [pumpId] The pump ID to get the adjustment ID for
  Future<String> getCurrentAdjustmentId(String pumpId) async {
    try {
      
      // First check for existing open adjustment for this pump
      final openAdjustment = await getOpenAdjustment(pumpId); 

      // if adjustment is found, return the adjustment id
      if (openAdjustment.isNotEmpty) {
        return openAdjustment[0]['id'].toString();
      }
 
      // if no open adjustment found, get adjustment count
      final count = await _getAdjustmentCount(pumpId);

      final adjustmentId = Utils().formatAdjustmentId(pumpId, count.toString());

      // If no open adjustment found, create a new one
      await db.rawInsert(
        'INSERT INTO adjustments (id, status, pumpId, date) VALUES (?, ?, ?, ?)',
        [    
          adjustmentId,
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


  Future<void> createAdjustment(String pumpId) async {
    try {
      // if no open adjustment found, get adjustment count
      int count = await _getAdjustmentCount(pumpId) - 1;
      final adjustmentId = Utils().formatAdjustmentId(pumpId, count.toString());


      // Get the current adjustment ID for the pump
      await db.rawInsert(
        'INSERT INTO adjustments (id, status, pumpId, date) VALUES (?, ?, ?, ?)',
        [    
          adjustmentId,
          'open',
          pumpId,  // Using passed pumpId
          DateTime.now().toIso8601String(),
        ],
      );
      
    } catch (e) {
      throw Exception('Failed to create adjustment: $e');
    }
  }

  Future<void> createSumAdjustment(String pumpId) async {
    try {
      final adjustmentId = Utils().formatAdjustmentId(pumpId, 'S');

      await db.rawInsert(
        'INSERT INTO adjustments (id, status, pumpId, date) VALUES (?, ?, ?, ?)',
        [    
          adjustmentId,
          'close',
          pumpId, 
          DateTime.now().toIso8601String(),
        ],
      );
      
    } catch (e) {
      throw Exception('Failed to create adjustment: $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchAdjustmentsByPumpId(String pumpId) {
    return db.rawQuery(
      'SELECT * FROM adjustments WHERE pumpId = ?',
      [pumpId],
    );
  }


  Future<List<Map<String, dynamic>>> getOpenAdjustment(pumpId) {
    return db.rawQuery(
      'SELECT * FROM adjustments WHERE status = ? AND pumpId = ? LIMIT 1',
      ['open', pumpId],
    );
  }

  /// Closes the adjustment by setting its status to "closed" and recording the closing time.
Future<void> closeAdjustment(Database db, String adjustmentId) async {
  try {
    await db.update(
      'adjustments',
      {
        'status': 'close',
      },
      where: 'id = ?',
      whereArgs: [adjustmentId],
    );
  } catch (e) {
    throw Exception('Failed to close adjustment: $e');
  }
}

  /// Closes the adjustment by setting its status to "closed" and recording the closing time.
Future<void> openAdjustment(Database db, String adjustmentId) async {
  try {
    await db.update(
      'adjustments',
      {
        'status': 'open',
      },
      where: 'id = ?',
      whereArgs: [adjustmentId],
    );
  } catch (e) {
    throw Exception('Failed to open adjustment: $e');
  }
}
  
  /// Get the count of adjustments for a given pump
  /// If no adjustments are found, return 0
  /// [pumpId] The pump ID to get the adjustment count for
  Future<int> _getAdjustmentCount(String pumpId) async {
  try {
    final List<Map<String, dynamic>> result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM adjustments WHERE pumpId = ?',
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