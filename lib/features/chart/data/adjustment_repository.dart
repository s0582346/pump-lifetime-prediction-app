import 'package:flutter_predictive_maintenance_app/database/database_helper.dart';
import 'package:flutter_predictive_maintenance_app/features/parameters/domain/measurement.dart';
import 'package:sqflite/sqflite.dart';

class AdjustmentRepository {
  final Database db;

  AdjustmentRepository({required this.db});

  Future<String> getOrCreateAdjustment() async {
    // TODO this query must be enhanced by getting current pump id
      
    // First verify pump exists
    /*
    await db.rawInsert(
      'INSERT INTO pump (id, type, medium, measurableParameter, permissibleTotalWear) VALUES (?, ?, ?, ?, ?)',	
      ['NM045', 'NM045', 'sand', 'volumeFlow', '70'],
    );*/ 


    final List<Map<String, dynamic>> existingAdjustment = await db.rawQuery(
      'Select * FROM adjustment WHERE status = ? LIMIT 1',
      ['open'],
    );

    if (existingAdjustment.isNotEmpty) {
      return existingAdjustment[0]['id']; // Return existing adjustment ID
    }
 
    // if no open adjustment found, create a new one
    return await db.rawInsert(
      'INSERT INTO adjustment (id, status, pumpId, date) VALUES (?, ?, ?, ?)',
      [    
        'NM045-1', // should not be static, 
        'open',
        'NM045', // TODO get current pump id
        DateTime.now().toIso8601String(),
      ],
    ).toString();
  }


}