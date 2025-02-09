class Utils {

    // Convert integer to double
  dynamic convertToInt(value) {
    double doubleValue = 0.0;
    
    if (value.toString().contains(',')) {
      value = value.toString().replaceAll(',', '.');
    }

    if (value is String) {
      doubleValue = double.tryParse(value) ?? 0.0;
    }


    return (doubleValue * 100).toInt();
  }

  dynamic getAdjustmentId(String pumpId, int adjustmentCount) {
    return '$pumpId-$adjustmentCount';
  }
}