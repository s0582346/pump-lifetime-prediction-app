import 'dart:io';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_predictive_maintenance_app/features/history/domain/measurement.dart';
import 'package:flutter_predictive_maintenance_app/features/pump/domain/measurable_parameter.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

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
    if (value is double) return (value * factor).round(); // Directly convert if it's a double
    
    if (value.contains(',')) {
      value = value.replaceAll(',', '.');
    }
    
    double? doubleValue = double.tryParse(value);
    return ((doubleValue ?? 0.0) * factor).round();
  }

  String formatAdjustmentId(String pumpId, String adjustmentCount) {
    return '$pumpId-$adjustmentCount';
  }

  
  String? normalizeInput(dynamic value) {
    if (value == null) return null; 

    if (value is num) {
      return value.toString().replaceAll(',', '.');
    } 

    return value.replaceAll(',', '.');
  }

  /// Removes the middle section of an adjustment ID that matches
  /// a hyphen followed by exactly three uppercase letters (e.g., "-ALV").
  /// 
  /// Example:
  ///   Input:  "NM090-ALV-0"
  ///   Output: "NM090-0"
  String formatTabLabel(String adjustmentId) {
    RegExp regExp = new RegExp(r'(-[A-Z]{3})');
    String? result = regExp.firstMatch(adjustmentId)?.group(0);
    return adjustmentId.replaceAll(result ?? '', ''); 
  }

  double normalize(MeasurableParameter measurableParameter, Measurement reference, Measurement newMeasurement) {
    final isVolumeFlow = measurableParameter == MeasurableParameter.volumeFlow;
    final double flow = _toDouble((isVolumeFlow) ? newMeasurement.volumeFlow : newMeasurement.pressure);
    final double n = _toDouble(newMeasurement.rotationalFrequency);
    final double refFlow = _toDouble((isVolumeFlow) ? reference.volumeFlow : reference.pressure);
    final double refN = _toDouble(reference.rotationalFrequency);
  
    if (refN == 0 || refFlow == 0) {
      throw ArgumentError("nStart and flowStart must not be zero to avoid division by zero.");
    }
  
    double ratio = (flow / n) / (refFlow / refN);
    return double.parse(ratio.toStringAsFixed(3));
  }
  
  /// Helper function to parse dynamic -> double safely
  double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  /// Log error to a file in the app's documents directory
  Future<void> logError(Object error, StackTrace stackTrace) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/error_log.txt');
    final now = DateTime.now();
    await file.writeAsString(
      '[$now] $error\n$stackTrace\n\n',
      mode: FileMode.append,
    );
  }


  /// Calculate the current operating hours based on the start operating hours, 
  /// average operating hours per day, current date and last date
  /// TO USE
  /// - when type of time entry = 'average operating hours per day'
  double calculateCurrentOperatingHours(int? startOperatingHours, int? averageOperatingHoursPerDay, DateTime? currentDate, DateTime? lastDate) {
    if (startOperatingHours == null || averageOperatingHoursPerDay == null || currentDate == null || lastDate == null) {
      return 0;
    }

    final dayDiff = currentDate.difference(lastDate).inDays.toDouble();
    
    if (dayDiff <= 0) {
      return 0;
    }

    final currentOperatingHours = startOperatingHours + (averageOperatingHoursPerDay * dayDiff);
    
    return currentOperatingHours;
  }
  
  // Generate a list of FlSpot objects based on a quadratic function
  List<FlSpot> generateQuadraticSpots(
  double a,
  double b,
  double c, {
  double start = 0,
  double end = 50,
  double step = 1,
  double targetY = 0.9,
}) {
  final List<FlSpot> spots = [];

  for (double x = start; x <= end; x += step) {

    final double y = a * x * x + b * x + c;
    if (y >= targetY) {
      spots.add(FlSpot(x - start, y)); // <-- use absolute x
    }
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