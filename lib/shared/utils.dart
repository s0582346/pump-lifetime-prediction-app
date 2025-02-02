class Utils {

    // Convert integer to double
  dynamic convertToInt(value) {
  double doubleValue = 0.0;
  if (!value.toString().contains(',') && !value.toString().contains('.')) {
      return value;
  }

  print('inside convertToInt');
  print(value);

  if (value is String) {
    doubleValue = double.tryParse(value) ?? 0.0;
  }


  return (doubleValue * 100).toInt();
  }
}