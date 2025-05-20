enum ViscosityLevel {
  watery('watery'),
  low('low (1000–2000 mPas)'),
  medium('medium (3000–5000 mPas)'),
  high('high (6000–8000 mPas)');

  final String label;
  const ViscosityLevel(this.label);

  static ViscosityLevel? fromString(String? value) {
    try {
      return ViscosityLevel.values.firstWhere((e) => e.label == value);
    } catch (e) {
      return null;
    }
  }

  @override
  String toString() => label;
}
