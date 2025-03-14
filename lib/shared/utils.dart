import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_predictive_maintenance_app/features/measurement/domain/measurement.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';

class Utils {

  String formatDate(dynamic date) {
  
    DateTime parsedDate;

    if (date is DateTime) {
      parsedDate = date;
    } else if (date is String) {
      // Assuming the string is in the format "dd.MM.yyyy"
      parsedDate = DateFormat('yyyy-MM-dd').parse(date);
    } else {
      throw Exception('Unsupported date format');
    }

    return "${parsedDate.day.toString().padLeft(2, '0')}"
         ".${parsedDate.month.toString().padLeft(2, '0')}"
         ".${parsedDate.year}";
         
  }

  
  dynamic convertToInt(value, {factor = 100}) {

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
    RegExp regExp = new RegExp(r'^[^-]+');
    String? result = regExp.firstMatch(pumpId)?.group(0);

    return '$result-$adjustmentCount';
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
  double calculateCurrentOperatingHours(double? startOperatingHours, int? averageOperatingHoursPerDay, DateTime? currentDate, DateTime? lastDate) {
    if (startOperatingHours == null || averageOperatingHoursPerDay == null || currentDate == null || lastDate == null) {
      return 0;
    }

    final dayDiff = currentDate.difference(lastDate).inHours / 24;
    print("dayDiff: $dayDiff");
    
    if (dayDiff <= 0) {
      return 0;
    }

    final currentOperatingHours = startOperatingHours + (averageOperatingHoursPerDay * dayDiff);
    
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

    print("is start bigger than current: ${startOperatingHours >= currentOperatingHours}");
    // Ensure we don't have illogical inputs
    if (startOperatingHours >= currentOperatingHours) {
      return null;
    }

    // Compute fractional day difference
    final double dayDiff = currentDate.difference(startDate).inHours / 24;

    print("dayDiff: $dayDiff");

    // If dayDiff is 0, it means either same day or timestamps are identical
    if (dayDiff <= 0) {
      return null;
    }

    final double average = (currentOperatingHours - startOperatingHours) / dayDiff;
    print("average: $average");
    return average; 
  }

  // Generate a list of FlSpot objects based on a quadratic function
  List<FlSpot> generateQuadraticSpots(double a, double b, double c, {double start = 0, double end = 50, double step = 1, double targetY = 0.8}) {
    final List<FlSpot> spots = [];
    double newEnd = calculateXIntercept(a, b, c) ?? end;
    end = newEnd;

    for (double x = start; x <= end; x += step) {
      final double y = a * x * x + b * x + c;
      if (y >= targetY) {
        spots.add(FlSpot(x, y));
      }
    }
    return spots;
  }

  
/// Computes the x-axis intercept for the quadratic equation.
/// Returns the new end value if it is greater than the current end; otherwise, returns currentEnd.
double? calculateXIntercept(double a, double b, double c) {
  /*
  if (a == 0) {
    // Handle linear case: y = b*x + c => x = -c / b (if b != 0)
    return b != 0 ? (-c / b) : currentEnd;
  }*/
  
  final double discriminant = (b * b) - (4 * a * c);
  if (discriminant < 0) {
    // No real roots; return the current end.
    return null;
  }
  
  final double sqrtDiscriminant = sqrt(discriminant);
  final double root1 = (-b + sqrtDiscriminant) / (2 * a);
  final double root2 = (-b - sqrtDiscriminant) / (2 * a);
  
  // Choose the root that is greater than currentEnd.
  double newEnd = root1 > root2 ? root1 : root2;
  
  /*
  if (root1 > currentEnd) {
    newEnd = root1;
  } else if (root2 > currentEnd) {
    newEnd = root2;
  }*/
  
    return newEnd;
  }

  /// Returns all real solutions x for the equation:
/// a*x^2 + b*x + (c - targetY) = 0.
///
/// Typically you'll either get 0, 1, or 2 real solutions.
/// You can decide which solution(s) make physical sense (e.g., x >= 0).
List<double> findXForY(double a, double b, double c, double targetY) {
  final c_ = c - targetY; // shift so that we solve a*x^2 + b*x + c_ = 0

  // Edge case: If 'a' ~ 0, we have a linear equation:
  /*
  if (a.abs() < 1e-12) {
    // b*x + c_ = 0 => x = -c_/b
    if (b.abs() < 1e-12) {
      return []; // No solution if b also ~ 0
    }
    return [-c_ / b];
  }*/

  // Solve discriminant
  final discriminant = b * b - 4 * a * c_;
  if (discriminant < 0) {
    // No real solutions
    return [];
  } else if (discriminant == 0) {
    // One real solution
    final x = -b / (2 * a);
    return [x];
  } else {
    // Two real solutions
    final sqrtD = sqrt(discriminant);
    final x1 = (-b + sqrtD) / (2 * a);
    final x2 = (-b - sqrtD) / (2 * a);
    return [x1, x2];
  }
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
  DateTime getEstimatedMaintenanceDate(int hoursTillMaintenance, DateTime currentDate) {
    final maintenanceDate = currentDate.add(Duration(hours: hoursTillMaintenance));
  
    // Format the date into a human-readable string (e.g., "Feb 20, 2025")
    //final formatter = DateFormat('MMM d, yyyy');
    //return formatter.format(maintenanceDate);
    return maintenanceDate;
  }

   Map<String, List<Measurement>> groupMeasurements(List<Measurement>? measurements) {
    final groupedMeasurements = <String, List<Measurement>>{};
    
    if (measurements == null) {
      return groupedMeasurements;
    }

    for (var measurement in measurements) {
      groupedMeasurements
          .putIfAbsent(measurement.adjustmentId, () => [])
          .add(measurement);
    }
    return groupedMeasurements;
  }


}