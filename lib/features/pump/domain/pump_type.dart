enum PumpType {
  nm045('NM045'),
  nm053('NM053'),
  nm063('NM063'),
  nm076('NM076'),
  nm090('NM090');

  final String label;
  const PumpType(this.label);

  static PumpType? fromString(String? value) {
    try {
      return PumpType.values.firstWhere((e) => e.label == value);
    } catch (e) {
      return null;
    }
  }

  @override
  String toString() => label;
}
