import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_predictive_maintenance_app/features/measurement/domain/measurement.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';

class Utils {

  // save 
  dynamic convertToInt(value, {factor = 100}) {
    print("value: $value");

    if (value == null) return 0;
    if (value is int) return value * factor; // Directly multiply if it's already an int
    if (value is double) return (value * factor).toInt(); // Directly convert if it's a double

    String valueToString = value.toString();
    
    if (valueToString.contains(',')) {
      valueToString = valueToString.replaceAll(',', '.');
    }

    double? doubleValue = double.tryParse(valueToString.toString());
    return ((doubleValue ?? 0.0) * factor).toInt();
  }

  dynamic formatAdjustmentId(String pumpId, int adjustmentCount) {
    return '$pumpId-$adjustmentCount';
  }

  double calculateQn(Measurement actual, Measurement reference) {
    // Safely convert any numeric-like field to double
    final double actualQ = _toDouble(actual.volumeFlow);
    final double actualN = _toDouble(actual.rotationalFrequency);
    final double refQ = _toDouble(reference.volumeFlow);
    final double refN = _toDouble(reference.rotationalFrequency);

    /*
    print("actualQ: ${actualQ}");
    print("actualN: ${actualN}");
    print("refQ: ${refQ}");
    print("refN: ${refN}"); */
  
    if (refN == 0 || refQ == 0) {
      throw ArgumentError("nStart and QStart must not be zero to avoid division by zero.");
    }
  
    double ratio = (actualQ / actualN) / (refQ / refN);
    return double.parse(ratio.toStringAsFixed(3));
  }

  double calculatePn(Measurement actual, Measurement reference) {
    // Safely convert any numeric-like field to double
    final double actualP = _toDouble(actual.pressure);
    final double actualN = _toDouble(actual.rotationalFrequency);
    final double refP = _toDouble(reference.pressure);
    final double refN = _toDouble(reference.rotationalFrequency);

    print("actualQ: ${actualP}");
    print("actualN: ${actualN}");
    print("refQ: ${refP}");
    print("refN: ${refN}");
  
    if (refN == 0 || refP == 0) {
      throw ArgumentError("nStart and QStart must not be zero to avoid division by zero.");
    }
  
    double ratio = (actualP / actualN) / (refP / refN);
    return double.parse(ratio.toStringAsFixed(3));
  }
  
  /// Helper function to parse dynamic -> double safely
  double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }


  /// Calculate the current operating hours based on the start operating hours, 
  /// average operating hours per day, current date and last date
  /// TO USE
  /// - when type of time entry = 'average operating hours per day'
  int calculateCurrentOperatingHours(startOperatingHours, averageOperatingHoursPerDay, currentDate, lastDate) {
    if (startOperatingHours == null || averageOperatingHoursPerDay == null || currentDate == null || lastDate == null) {
      return 0;
    }

    final currentDays = currentDate.difference(lastDate).inDays;
    final currentOperatingHours = startOperatingHours + (averageOperatingHoursPerDay * currentDays);
    
    return currentOperatingHours;
  }

  /// -> Estimate Daily Usage
  /// Calculate the average operating hours per day based on the start operating hours,
  /// current operating hours, current date and last date
  double? calculateAverageOperatingHoursPerDay({
    required int startOperatingHours,
    required int currentOperatingHours,
    required DateTime startDate,
    required DateTime currentDate,
  }) {

  // Ensure we don't have illogical inputs
    if (startOperatingHours >= currentOperatingHours) {
      return null;
    }

    // Compute fractional day difference
    final double dayDiff = currentDate.difference(startDate).inHours / 24.0;

    // If dayDiff is 0, it means either same day or timestamps are identical
    if (dayDiff == 0) {
      return null;
    }

    final double average = (currentOperatingHours - startOperatingHours) / dayDiff;
    return average; 
  }


  List<FlSpot> generateQuadraticSpots(double a, double b, double c,
    {double start = 0, double end = 100, double step = 1}) {
  final List<FlSpot> spots = [];
  for (double x = start; x <= end; x += step) {
    final double y = a * x * x + b * x + c; 
    spots.add(FlSpot(x, y));
  }
  return spots;
}

  /// Calculate the remaining days till maintenance based on the current date,
  int calculateRemainingDaysTillMaintenance(DateTime? currentDate, hoursTillMaintenance, currentOperatingHours, averageHoursPerDay) 
  {
    if (currentDate == null || hoursTillMaintenance == null || currentOperatingHours == null || averageHoursPerDay == null) {
      return 0;
    }

    final remainingHours = hoursTillMaintenance - currentOperatingHours;

    return (currentDate.day + (remainingHours / averageHoursPerDay)).toInt();
  }

  Map<String, List<Measurement>> groupMeasurementsByAdjustment(List<Measurement> measurements) {
    // group by adjustment_id
    final groupedMeasurements = <String, List<Measurement>>{};
    for (var measurement in measurements) {
      groupedMeasurements.putIfAbsent(measurement.adjustmentId, () => []).add(measurement);
    }

    return groupedMeasurements;
  }


  /// Returns a formatted date string indicating the maintenance date based
  /// on the [daysTillMaintenance] parameter.
  String getEstimatedMaintenanceDate(int daysTillMaintenance) {
    final now = DateTime.now();

    final maintenanceDate = now.add(Duration(days: daysTillMaintenance));
  
    // Format the date into a human-readable string (e.g., "Feb 20, 2025")
    //final formatter = DateFormat('MMM d, yyyy');
    //return formatter.format(maintenanceDate);
    return maintenanceDate.toIso8601String();
  }
}