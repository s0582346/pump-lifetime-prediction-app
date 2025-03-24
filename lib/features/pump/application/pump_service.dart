import 'dart:math';

import 'package:flutter_predictive_maintenance_app/database/database_helper.dart';
import 'package:flutter_predictive_maintenance_app/features/chart/application/adjustment_service.dart';
import 'package:flutter_predictive_maintenance_app/features/pump/data/pump_repository.dart';
import 'package:flutter_predictive_maintenance_app/features/pump/domain/pump.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PumpService{

  Future<void> savePump(Pump pump) async {
    try {
      final pumpRepository = PumpRepository(db: await DatabaseHelper().database);
      await pumpRepository.savePump(pump.toMap());
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

  Future<void> deletePump(String id) async {
    final db = await DatabaseHelper().database;
    final PumpRepository pumpRepository = PumpRepository(db: db);
    await pumpRepository.deletePump(id);
  }

}

 final pumpServiceProvider = Provider<PumpService>((ref) => PumpService());