import 'dart:math';

import 'package:flutter_predictive_maintenance_app/database/database_helper.dart';
import 'package:flutter_predictive_maintenance_app/features/chart/application/adjustment_service.dart';
import 'package:flutter_predictive_maintenance_app/features/pump/data/pump_repository.dart';
import 'package:flutter_predictive_maintenance_app/features/pump/pump.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PumpService{

  Future<void> savePump(Pump pump) async {
    try {
      final db = await DatabaseHelper().database;
      final adjustmentService = AdjustmentService();

      final pumpId = generatePumpId(pump.type); // Generate a unique pump ID
      pump = pump.copyWith(id: pumpId);

      await db.insert('pumps', pump.toMap());
      // create an open adjustment for the pump
      await adjustmentService.createAdjustment(pump.id);

    } catch (e) {
      print('Error saving pump: $e');
    }
  }

  String generatePumpId(String pumpType) {
    const letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    final random = Random();

    String randomLetters = List.generate(3, (_) => letters[random.nextInt(letters.length)]).join();

    return '$pumpType-$randomLetters';
  }

  Future<List<Pump>> getPumps() async {
    final db = await DatabaseHelper().database;
    final PumpRepository pumpRepository = PumpRepository(db: db);
    final List<Map<String, dynamic>> pumps = await pumpRepository.getPumps();
    
    return pumps.map((pump) => Pump.fromMap(pump)).toList();
  }


}

 final pumpServiceProvider = Provider<PumpService>((ref) => PumpService());