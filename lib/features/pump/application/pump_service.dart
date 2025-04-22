import 'package:flutter_predictive_maintenance_app/database/database_helper.dart';
import 'package:flutter_predictive_maintenance_app/features/chart/application/adjustment_service.dart';
import 'package:flutter_predictive_maintenance_app/features/pump/data/pump_repository.dart';
import 'package:flutter_predictive_maintenance_app/features/pump/domain/pump.dart';
import 'package:flutter_predictive_maintenance_app/shared/result_info.dart';
import 'package:flutter_predictive_maintenance_app/shared/utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final pumpServiceProvider = Provider<PumpService>((ref) => PumpService());

class PumpService{

  Future<ResultInfo> savePump(Pump pump, AdjustmentService adjustmentService) async {
     try {
      final db = await DatabaseHelper().database;  
      final pumpRepository = PumpRepository(db: db);

      await pumpRepository.savePump(pump.toMap());
      await adjustmentService.createSumAdjustment(pump.id);
      await adjustmentService.createAdjustment(pump.id);
      return ResultInfo.success(); 

    } catch (e, stack) {
      Utils().logError(e, stack);
      return ResultInfo.error(null, 'Error saving pump');  
    }
  }

  Future<List<Pump>> getPumps() async {
    try {
      final db = await DatabaseHelper().database;
      final PumpRepository pumpRepository = PumpRepository(db: db);
      final List<Map<String, dynamic>> pumps = await pumpRepository.getPumps();
      return pumps.map((pump) => Pump.fromMap(pump)).toList();
    } catch (e, stack) {
      Utils().logError(e, stack);
      return []; // Return an empty list in case of an error
    }
  }

  Future<ResultInfo> deletePump(String id) async {
    try {
      final db = await DatabaseHelper().database;
      final PumpRepository pumpRepository = PumpRepository(db: db);
      await pumpRepository.deletePump(id);
      return ResultInfo.success(); 
    } catch (e, stack) {
      Utils().logError(e, stack);
      return ResultInfo.error(null, 'Error deleting pump');
    }
  }

}