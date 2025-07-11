import 'package:flutter_predictive_maintenance_app/database/database_helper.dart';
import 'package:flutter_predictive_maintenance_app/features/chart/data/adjustment_repository.dart';
import 'package:flutter_predictive_maintenance_app/features/chart/domain/adjustment.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


final adjustmentServiceProvider = Provider((ref) => AdjustmentService());

class AdjustmentService {

  Future<Map<String, dynamic>> getOpenAdjustment(pumpId) async {
    final db = await DatabaseHelper().database;
    final adjustmentRepo = AdjustmentRepository(db: db);
    final adjustment = await adjustmentRepo.getOpenAdjustment(pumpId);
    return adjustment![0];
  }

  Future<void> createAdjustment(pumpId) async {
    final db = await DatabaseHelper().database;
    final adjustmentRepo = AdjustmentRepository(db: db);
    await adjustmentRepo.createAdjustment(pumpId);
  }

  Future<void> createSumAdjustment(pumpId) async {
    final db = await DatabaseHelper().database;
    final adjustmentRepo = AdjustmentRepository(db: db);
    await adjustmentRepo.createSumAdjustment(pumpId);
  }

  Future<void> closeAdjustment(String adjustmentId) async {
    final db = await DatabaseHelper().database;
    final adjustmentRepo = AdjustmentRepository(db: db);
    await adjustmentRepo.closeAdjustment(db, adjustmentId);
  }

  Future<void> openAdjustment(String adjustmentId) async {
    final db = await DatabaseHelper().database;
    final adjustmentRepo = AdjustmentRepository(db: db);
    await adjustmentRepo.openAdjustment(db, adjustmentId);
  }

 Future<List<Adjustment>> fetchAdjustmentsByPumpId(pumpId) async {
  final db = await DatabaseHelper().database;
  final adjustmentRepo = AdjustmentRepository(db: db);
  final rawAdjustments = await adjustmentRepo.fetchAdjustmentsByPumpId(pumpId);

  if (rawAdjustments == null) return [];

  return rawAdjustments.map((a) => Adjustment.fromMap(a)).toList();
}
}
