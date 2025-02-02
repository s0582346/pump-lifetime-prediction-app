import 'package:flutter_predictive_maintenance_app/database/database_helper.dart';
import 'package:flutter_predictive_maintenance_app/features/parameters/domain/measurement.dart';

class MeasurementService {
   final DatabaseHelper _databaseHelper = DatabaseHelper();

   Future<void> saveMeasurement(Measurement measurement) async {
    await _databaseHelper.insert(
      'measurements',
      measurement.toMap(),
    );
   }
}