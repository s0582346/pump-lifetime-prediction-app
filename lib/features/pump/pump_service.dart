import 'package:flutter_predictive_maintenance_app/database/database_helper.dart';
import 'package:flutter_predictive_maintenance_app/features/pump/data/pump_repository.dart';
import 'package:flutter_predictive_maintenance_app/features/pump/pump.dart';

class PumpService{

  Future<void> savePump(Pump pump) async {
    final db = await DatabaseHelper().database;
    try {
      await db.insert('pump', pump.toMap());
    } catch (e) {
      print('Error saving pump: $e');
    }
  }

  Future<List<Pump>> getPumps() async {
    final db = await DatabaseHelper().database;
    final PumpRepository pumpRepository = PumpRepository(db: db);
    final List<Map<String, dynamic>> pumps = await pumpRepository.getPumps();
    
    return pumps.map((pump) => Pump.fromMap(pump)).toList();
  }  

}