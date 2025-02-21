import 'package:flutter_predictive_maintenance_app/database/database_helper.dart';
import 'package:flutter_predictive_maintenance_app/features/chart/data/adjustment_repository.dart';

class AdjustmentService {

  Future<Map<String, dynamic>> getOpenAdjustment(pumpId) async {
    final db = await DatabaseHelper().database;
    final adjustmentRepo = AdjustmentRepository(db: db);
    final adjustment = await adjustmentRepo.getOpenAdjustment(pumpId);
    return adjustment[0];
  }



  Future<void> closeAdjustment(String adjustmentId) async {
    final db = await DatabaseHelper().database;
    final adjustmentRepo = AdjustmentRepository(db: db);
    await adjustmentRepo.closeAdjustment(db, adjustmentId);
  }
}
