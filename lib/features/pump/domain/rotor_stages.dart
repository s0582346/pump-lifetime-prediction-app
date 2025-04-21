enum RotorStages{
  stage1('1'),
  stage2('2');

  final String label;
  const RotorStages(this.label);

  static RotorStages? fromString(String? value) {
    try {
      return RotorStages.values.firstWhere((e) => e.label == value);
    } catch (e) {
      return null;
    }
  }

  @override
  String toString() => label;
}