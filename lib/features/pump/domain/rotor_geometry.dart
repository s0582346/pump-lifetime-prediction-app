enum RotorGeometry {
  s('S'),
  l('L'),
  d('D'),
  p('P');

  final String label;

  const RotorGeometry(this.label);

  static RotorGeometry? fromString(String? value) {
    try {
      return RotorGeometry.values.firstWhere((e) => e.label == value);
    } catch (e) {
      return null;
    }
  }

  @override
  String toString() => label;
}