import 'package:flutter_predictive_maintenance_app/features/measurement/domain/measurement.dart';

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

  dynamic getAdjustmentId(String pumpId, int adjustmentCount) {
    return '$pumpId-$adjustmentCount';
  }

  double calculateQn(Measurement actual, Measurement reference) {
    // Safely convert any numeric-like field to double
    final double actualQ = _toDouble(actual.volumeFlow);
    final double actualN = _toDouble(actual.rotationalFrequency);
    final double refQ = _toDouble(reference.volumeFlow);
    final double refN = _toDouble(reference.rotationalFrequency);

    print("actualQ: ${actualQ}");
    print("actualN: ${actualN}");
    print("refQ: ${refQ}");
    print("refN: ${refN}");
  
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
  
  // Helper function to parse dynamic -> double safely
  double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}