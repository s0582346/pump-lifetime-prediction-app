enum MeasurableParameter {
  volumeFlow('Volume Flow'),
  pressure('Pressure');

  final String label;
  const MeasurableParameter(this.label);

  static MeasurableParameter? fromString(String? value) {
    try {
      return MeasurableParameter.values.firstWhere((e) => e.label == value);
    } catch (e) {
      return null;
    }
  }

  @override
  String toString() => label;
}