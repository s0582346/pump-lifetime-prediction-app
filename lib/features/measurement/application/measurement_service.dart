import 'package:flutter_predictive_maintenance_app/database/database_helper.dart';
import 'package:flutter_predictive_maintenance_app/features/measurement/domain/measurement.dart';
import 'package:flutter_predictive_maintenance_app/features/chart/data/adjustment_repository.dart';
import 'package:flutter_predictive_maintenance_app/features/measurement/data/measurement_repository.dart';
import 'package:flutter_predictive_maintenance_app/features/pump/pump.dart';
import 'package:flutter_predictive_maintenance_app/shared/utils.dart';

class MeasurementService {

  /// Save a measurement to the database
  Future<void> saveMeasurement(Measurement measurement, Pump pump) async {
    final db = await DatabaseHelper().database;
    final adjustmentRepo = AdjustmentRepository(db: db);
    final measurementRepo = MeasurementRepository(db: db);   

    try {
      // Get or create adjustment
      final adjustmentId = await adjustmentRepo.getCurrentAdjustmentId(pump.id); 

      // calculate normalized Value
      final reference = await getFirstMeasurement(adjustmentId);
      final result = (reference != null) ? ((pump.measurableParameter == 'volume flow') ? Utils().calculateQn(measurement, Measurement.fromMap(reference)) : Utils().calculatePn(measurement, Measurement.fromMap(reference))) : 1;
      
      final Qn = (pump.measurableParameter == 'volume flow') ? result : 0;
      final pn = (pump.measurableParameter == 'pressure') ? result : 0;
      final updatedMeasurement = measurement.copyWith(adjustmentId: adjustmentId, Qn: Qn, pn: pn);

      print('volume flow: ${updatedMeasurement.volumeFlow}');
      //print('Adjustment ID: ${updatedMeasurement.adjustmentId}');
      //print('Volume Flow: ${updatedMeasurement.volumeFlow}');
      //print('Pressure: ${updatedMeasurement.pressure}');
      //print('Rotational Frequency: ${updatedMeasurement.rotationalFrequency}');
      //print('Current Operating Hours: ${updatedMeasurement.currentOperatingHours}');
      //print('Average Operating Hours Per Day: ${updatedMeasurement.averageOperatingHoursPerDay}');

      final v = Utils().convertToInt(updatedMeasurement.volumeFlow);
      print("volumen flow: $v");

      await measurementRepo.saveMeasurement(updatedMeasurement);
    } catch (e) {
      // Handle errors appropriately
      print('Error saving: $e');
    }
    	
  }

  /// Fetch measurements for a given pump
  /// [pumpId] The pump ID to fetch measurements for
  Future<List<Measurement>> fetchMeasurements(pumpId) async {
    print('Fetching measurements for pump: $pumpId');

    final db = await DatabaseHelper().database;
    /*
    final adjustmentRepo = AdjustmentRepository(db: db);
    
    final adjustmentId = await adjustmentRepo.getOpenAdjustment(pumpId);

    if (adjustmentId.isEmpty) {
      return [];
    }*/

    final List<Map<String, dynamic>> measurements = await db.rawQuery(
      '''
      SELECT m.*
      FROM measurements m
      JOIN adjustment a ON m.adjustmentId = a.id
      WHERE a.pumpId = ?;
      ''',
      [pumpId],
    );

    return measurements.map((e) => Measurement.fromMap(e)).toList();
  }


  
  /// Get first measurement
  Future<Map<String, dynamic>?> getFirstMeasurement(String adjustmentId) async {
    final db = await DatabaseHelper().database;
    
    final result = await db.rawQuery(
        ''' SELECT *
        FROM measurements 
        WHERE adjustmentId = ? 
        ORDER BY date ASC 
        LIMIT 1; ''',
        [adjustmentId],
    );

    if (result.isEmpty) {
      return null;
    }
    
    return result.first;
  }
}