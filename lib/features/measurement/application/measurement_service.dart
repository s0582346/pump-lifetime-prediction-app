import 'package:flutter_predictive_maintenance_app/database/database_helper.dart';
import 'package:flutter_predictive_maintenance_app/features/chart/application/prediction_service.dart';
import 'package:flutter_predictive_maintenance_app/features/measurement/domain/measurement.dart';
import 'package:flutter_predictive_maintenance_app/features/chart/data/adjustment_repository.dart';
import 'package:flutter_predictive_maintenance_app/features/measurement/data/measurement_repository.dart';
import 'package:flutter_predictive_maintenance_app/features/pump/pump.dart';
import 'package:flutter_predictive_maintenance_app/shared/utils.dart';

class MeasurementService {

  /// Save a measurement to the database
  Future<void> saveMeasurement(Measurement newMeasurement, Pump pump) async {
    final db = await DatabaseHelper().database;
    final adjustmentRepo = AdjustmentRepository(db: db);
    final measurementRepo = MeasurementRepository(db: db);   
    final predictionService = PredictionService();
    final measurableParameter = pump.measurableParameter;
    final typeOfTimeEntry = pump.typeOfTimeEntry;

    try {
      // Get or create adjustment
      final adjustmentId = await adjustmentRepo.getCurrentAdjustmentId(pump.id); 

      final measurements = await measurementRepo.fetchMeasurementsByAdjustmentId(adjustmentId);

      Measurement? reference;
      double result = 1.0; // if no reference, qn or pn is 1
      double? currentOperatingHours;
      if (measurements != null) {
        reference = Measurement.fromMap(measurements.first);  

        // calculate normalized Value
        result = (measurableParameter == 'volume flow') ? Utils().calculateQn(newMeasurement, reference) : Utils().calculatePn(newMeasurement, reference);
      }
      
      final Qn = (measurableParameter == 'volume flow') ? result : 0;
      final pn = (measurableParameter == 'pressure') ? result : 0;
      
      // compute average operating hours per day
      if (measurements != null) {

        if (typeOfTimeEntry.contains('average')) {
        print('Calculating average operating hours per day');

        // cumulative 
        currentOperatingHours = (measurements.last['currentOperatingHours'] / 100); 
        final averageOperatingHoursPerDay = int.parse(newMeasurement.averageOperatingHoursPerDay);
        final currentDate = newMeasurement.date;
        final startDate = DateTime.parse(measurements.last['date']);

        print('startDate: ${startDate}');
        print('current operating hours: ${currentOperatingHours}');
        print('average operating hours ${averageOperatingHoursPerDay}');
        print('currentDate: ${currentDate}');

        currentOperatingHours = Utils().calculateCurrentOperatingHours(
          currentOperatingHours,
          averageOperatingHoursPerDay,
          currentDate,
          startDate
        );

        print('current operating hours: $currentOperatingHours');
        }

        // compute current operating hours
        if (typeOfTimeEntry.contains('relative')) {  
          print("current operating hours ${measurements.last['currentOperatingHours'].runtimeType}");
          print("current operating hours ${newMeasurement.currentOperatingHours.runtimeType}");
          currentOperatingHours = double.parse(newMeasurement.currentOperatingHours) + (measurements.last['currentOperatingHours'] / 100).toDouble();
        }
      }
      
     
      final updatedMeasurement = newMeasurement.copyWith(
        adjustmentId: adjustmentId, 
        currentOperatingHours: currentOperatingHours ?? 0, 
        Qn: Qn, 
        pn: pn
      );

      await measurementRepo.saveMeasurement(updatedMeasurement);      
      await predictionService.savePrediction(adjustmentId, measurableParameter);
      
    } catch (e) {
      // Handle errors appropriately
      print('Error saving: $e');
    }
    	
  }

  /// Fetch measurements for a given pump
  /// [pumpId] The pump ID to fetch measurements for
  Future<List<Measurement>> fetchMeasurementsByPumpId(pumpId) async {
    print('Fetching measurements for pump: $pumpId');

    final db = await DatabaseHelper().database;
    final measurementRepo = MeasurementRepository(db: db);
    /*
    final adjustmentRepo = AdjustmentRepository(db: db);
    
    final adjustmentId = await adjustmentRepo.getOpenAdjustment(pumpId);

    if (adjustmentId.isEmpty) {
      return [];
    }*/
    final measurements = await measurementRepo.fetchMeasurementsByPumpId(pumpId);
    return measurements.map((e) => Measurement.fromMap(e)).toList();
  }

  Future<List<Measurement>?> fetchMeasurementsByAdjustmentId(adjustmentId) async {
    print('Fetching measurements for adjustment: $adjustmentId');

    final db = await DatabaseHelper().database;
    final measurementRepo = MeasurementRepository(db: db);
    
    final measurements = await measurementRepo.fetchMeasurementsByAdjustmentId(adjustmentId);
    if (measurements == null) {
      return null;
    }

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