import 'package:flutter_predictive_maintenance_app/database/database_helper.dart';
import 'package:flutter_predictive_maintenance_app/features/parameters/domain/pump.dart';

class PumpService{
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  Future<void> savePump(Pump pump) async {
    //final db = await _databaseHelper.database;
    await _databaseHelper.insert(
      'pump',
      pump.toMap(),
    );
  }

}