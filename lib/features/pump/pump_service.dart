import 'package:flutter_predictive_maintenance_app/database/database_helper.dart';
import 'package:flutter_predictive_maintenance_app/features/pump/pump.dart';

class PumpService{

  Future<void> savePump(Pump pump) async {
    // create a pumpRepository
    final db = await DatabaseHelper().database;
    await db.insert(
      'pump',
      pump.toMap(),
    );
  }

}